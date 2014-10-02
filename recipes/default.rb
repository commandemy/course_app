#
# Cookbook Name:: course_app
# Recipe:: default
#
# Copyright (C) 2014 Edmund Haselwanter
#
#
include_recipe "apt"

# 1 Install Ruby and Bundler
include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby "2.1.1" do
  global true
end

template "/etc/profile" do
  source "profile"
  action :create
end

rbenv_gem "bundler"

# Create folder for app
#%w[/home/course_app /home/course_app/blog].each do |path|
#  directory path do
#    owner 'ubuntu'
#    action :create
#  end
#end

# Apache and Passenger
node.default['passenger']['version'] = "4.0.14"
node.default['passenger']['ruby_bin'] = "/opt/rbenv/shims/ruby"
node.default['passenger']['root_path'] = "/opt/rbenv/versions/2.1.1/lib/ruby/gems/2.1.0/gems/passenger-4.0.14"

include_recipe "passenger_apache2"

web_app "course_app" do
  docroot "/var/www/current/public" #new
  server_name "course_app"
  server_aliases [ "course_app", node['hostname'] ]
end

# Make Ubuntu the Apache User #new
#template "/etc/apache2/envvars" do
#  source "envvars"
#end

# Artifact Deploy

database_hosts = []
search(:node, "role:#{node['course_roles']['database_server']}").each do |n|
  database_hosts << n['ipaddress']
end

jenkins_hosts = []
search(:node, "role:#{node['course_roles']['jenkins_server']}").each do |n|
  jenkins_hosts << n['ipaddress']
end

artifact_deploy "blog" do
  version "1.0.0"
  artifact_location "http://#{jenkins_hosts.first}:8080/job/blog-app-artifact-deploy/lastSuccessfulBuild/artifact/blog.tar"
  deploy_to "/var/www/"
  owner "www-data"
  group "www-data"

  before_migrate Proc.new {

    execute "sudo rm #{release_path}/environments.rb"

    template "#{release_path}/environments.rb" do
      source "environments.rb.erb"
      owner "www-data"
      group "www-data"
      mode "0644"
      variables ({
        prod_database: {
          host: database_hosts.first,
          username: node['database']['prod']['username'],
          password: node['database']['prod']['password'],
          database: node['database']['prod']['dbname']
        }
      })
    end

    rbenv_execute "bundle install" do
      cwd release_path
    end
  }

  migrate Proc.new {
    rbenv_execute "bundle exec rake db:migrate RACK_ENV=production" do
      cwd release_path
    end
  }

  restart Proc.new {
    service 'apache2' do
      action :restart
    end
  }

  keep 2
  should_migrate (node[:pvpnet][:should_migrate] ? true : false)
  force (node[:pvpnet][:force_deploy] ? true : false)
  action :deploy
end