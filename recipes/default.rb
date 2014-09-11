#
# Cookbook Name:: course_app
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby "2.1.1" do
  global true
end

# Create user and folder
user "course_app" do
  action :create
end

%w[ /home/course_app /home/course_app/public].each do |path|
  directory path do
    owner 'course_app'
    action :create
  end
end

# Apache and Passenger
# TODO: Cookbook still uses Chef Ruby all the time...
#node.default['passenger']['ruby_bin'] = "/opt/rbenv/shims/ruby"
#node.default['passenger']['root_path'] = "/opt/rbenv/shims/ruby/gems/2.1.1/gems/passenger-4.0.14"
include_recipe "passenger_apache2"

web_app "course_app" do
  docroot "/home/course_app/public"
  server_name "course_app"
  server_aliases [ "course_app", node[:hostname] ]
end

# Gems
gem_package "bundler"
gem_package "sinatra"