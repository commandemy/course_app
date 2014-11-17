#
# Cookbook Name:: course_app
# Recipe:: ssh_build
#
# Copyright (C) 2014 Edmund Haselwanter
#
#

# Create folder for app

%w[/home/course_app /home/course_app/blog /home/course_app/blog/public].each do |path|
  directory path do
    owner 'ubuntu'
    action :create
  end
end

web_app "course_app" do
  docroot "/home/course_app/blog/public"
  server_name "course_app"
  server_aliases [ "course_app", node['hostname'] ]
end