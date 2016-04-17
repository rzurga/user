#
# Cookbook Name:: user
# Recipe:: default
#
# Copyright 2016, Robert Zurga (vagrant@zurga.com)
#
# All rights reserved - Do Not Redistribute
#

# Change password for data bag users which are listed in password node

include_recipe "chef-solo-search"

node[:passwords].each do |user_id|
    user_entry = search(:users, "id:" + user_id).first
    user_password = user_entry["password"] || node[:machine][:password]
    home_dir = user_entry["home"] || node[:machine][:home] || "/home/" + user_id

    user user_id do
      password user_password
      action :modify
    end
end
