#
# Cookbook Name:: user
# Recipe:: default
#
# Copyright 2016, Robert Zurga (vagrant@zurga.com)
#
# All rights reserved - Do Not Redistribute
#

# Create users from data bag users which are listed in users node

include_recipe "chef-solo-search"

node[:users].each do |user_id|
    user_entry = search(:users, "id:" + user_id).first
    group_name = user_entry["group"] || node[:machine][:group] || user_id
    user_uid = user_entry["uid"] || node[:machine][:uid]
    home_dir = user_entry["home"] || node[:machine][:home] || "/home/" + user_id
    user_name = user_entry["name"] || node[:machine][:name] || user_id
    user_password = user_entry["password"] || node[:machine][:password]
    user_email = user_entry["email"] || node[:machine][:email]
    user_comment = user_entry["comment"] || node[:machine][:comment] || user_name
    user_shell = user_entry["shell"] || node[:machine][:shell]
    dev_dir = user_entry["dev"] || node[:machine][:dev] || home_dir + "/dev"
    gpghome  = user_entry["gpghome"] || node[:machine][:gpghome]
    ssh_keys = user_entry["ssh_keys"]
    bashrz = home_dir + ".bashrz"

    group group_name

    user user_id do
      comment user_comment
      group group_name
      system true
      shell user_shell
      home home_dir
      supports :manage_home => true
      password user_password
      action :create
    end
    
    ssh_dir = home_dir + '/.ssh'
    directory ssh_dir do
        owner user_id
        group group_name
        mode '0700'
        action :create
    end
    
    unless ssh_keys.nil?
        file ssh_dir + "/authorized_keys" do
            content ssh_keys
            owner user_id
            group group_name
            mode 00600
        end
    end

    directory home_dir + "/Downloads" do
        owner user_id
        group group_name
        mode '0755'
        action :create
    end
    
    unless dev_dir.nil?
        directory dev_dir do
            owner user_id
            group group_name
            mode '0755'
            action :create
        end
    end

    unless user_uid.nil? || user_uid == 0
        bash "set user UID" do
            user "root"
            action :run
            code <<-EOD
                usermod -u #{user_uid} #{user_id}
            EOD
        end
    end

    link "/#{user_id}" do
      link_type :symbolic
      to "#{home_dir}"
    end
end
