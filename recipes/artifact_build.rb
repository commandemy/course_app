#
# Cookbook Name:: course_app
# Recipe:: artifact_build
#
# Copyright (C) 2014 Edmund Haselwanter
#
#

web_app "course_app" do
  docroot "/var/www/current/public" #new
  server_name "course_app"
  server_aliases [ "course_app", node['hostname'] ]
end

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