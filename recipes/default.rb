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
  docroot "/home/course_app/blog/public"
  server_name "course_app"
  server_aliases [ "course_app", node['hostname'] ]
end