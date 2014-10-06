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

# Apache and Passenger
node.default['passenger']['version'] = "4.0.14"
node.default['passenger']['ruby_bin'] = "/opt/rbenv/shims/ruby"
node.default['passenger']['root_path'] = "/opt/rbenv/versions/2.1.1/lib/ruby/gems/2.1.0/gems/passenger-4.0.14"

include_recipe "passenger_apache2"

# Choose build style
include_recipe "course_app::#{node.default['build_style']}_build"