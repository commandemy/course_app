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
%w[/home/course_app /home/course_app/blog /home/course_app/blog/public].each do |path|
  directory path do
    owner 'ubuntu'
    action :create
  end
end

# Apache and Passenger
node.default['passenger']['version'] = "4.0.14"
node.default['passenger']['ruby_bin'] = "/opt/rbenv/shims/ruby"
node.default['passenger']['root_path'] = "/opt/rbenv/versions/2.1.1/lib/ruby/gems/2.1.0/gems/passenger-4.0.14"

include_recipe "passenger_apache2"

web_app "course_app" do
  docroot "/home/course_app/blog/current/public" #new
  server_name "course_app"
  server_aliases [ "course_app", node['hostname'] ]
end

# Artifact Deploy (all below is new)
# http://10.11.12.2:8080/job/blog-app-artifact-deploy/lastSuccessfulBuild/artifact/blog.tar
database_hosts = []
search(:node, "role:#{node['course_roles']['database_server']}").each do |n|
  database_hosts << n['ipaddress']
end

#TODO: Search for Jenkins Host

artifact_deploy "blog" do
  version "1.0.0"
  artifact_location "http://10.11.12.2:8080/job/blog-app-artifact-deploy/lastSuccessfulBuild/artifact/blog.tar"
  deploy_to "/home/course_app/blog"
  owner "ubuntu"
  group "ubuntu"

  before_migrate Proc.new {
    execute "sudo chown -R www-data /home/course_app"
    execute "sudo rm /home/course_app/blog/current/environments.rb"

    template "/home/course_app/blog/current/environments.rb" do
      source "environments.rb.erb"
      owner "ubuntu"
      group "ubuntu"
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

    execute "bundle install --local --path=vendor/bundle --without test development cucumber --binstubs" do
      user "ubuntu"
      group "ubuntu"
    end
  }

  migrate Proc.new {
    execute "bundle exec rake db:migrate RACK_ENV=production" do
      cwd release_path
      user "ubuntu"
      group "ubuntu"
    end
  }

  restart Proc.new {
    service 'apache2' do
      action :restart
    end
  }

  keep 2
  action :deploy
end