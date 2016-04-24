#
# Cookbook Name:: user
# Recipe:: default
#
# Copyright 2016, Robert Zurga (vagrant@zurga.com)
#
# All rights reserved - Do Not Redistribute
#
# Create users from data bag users which are listed in users node

# Chef::Resource::User.send(:include, User::Helper)
class Chef::Recipe
    include Helper
end

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
    id_rsa_pub = user_entry["id_rsa.pub"]
    id_rsa_key = user_entry["id_rsa"]
    id_rsa = id_rsa_key ? id_rsa_key.join("\n") : nil
    known_hosts_key = user_entry["known_hosts"]
    known_hosts = known_hosts_key ? known_hosts_key.join("\n") : nil
    bashrz = home_dir + ".bashrz"
    
    user_exists = does_user_exist(user_id)
    printf "User %s ::-> %s", user_id, user_exists

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
      # only_if {not user_exists}
    end

#     user user_id do
#       comment user_comment
#       group group_name
#       system true
#       shell user_shell
#       home home_dir
#       supports :manage_home => true
#       password user_password
#       action :modify
#       only_if {user_exists}
#     end
    
    ssh_dir = home_dir + '/.ssh'
    directory ssh_dir do
        owner user_id
        group group_name
        mode '0700'
        action :create
        not_if { ::File.directory?("#{ssh_dir}") }
    end
    
    unless ssh_keys.nil?
        authorized_keys = ssh_dir + "/authorized_keys"
        file authorized_keys do
            content ssh_keys
            owner user_id
            group group_name
            mode 00600
            not_if { ::File.exist?("#{authorized_keys}") }
        end
    end
    
    unless id_rsa_pub.nil?
        id_rsa_pub_file = ssh_dir + "/id_rsa.pub"
        file id_rsa_pub_file do
            content id_rsa_pub
            owner user_id
            group group_name
            mode 00600
            not_if { ::File.exist?("#{id_rsa_pub_file}") }
        end
    end
    
    unless id_rsa.nil?
        id_rsa_file = ssh_dir + "/id_rsa"
        file id_rsa_file do
            content id_rsa
            owner user_id
            group group_name
            mode 00600
            not_if { ::File.exist?("#{id_rsa_file}") }
        end
    end
    
    unless known_hosts.nil?
        know_hosts_file = ssh_dir + "/known_hosts"
        file know_hosts_file do
            content known_hosts
            owner user_id
            group group_name
            mode 00600
            not_if { ::File.exist?("#{know_hosts_file}") }
        end
    end

    Downloads_directory = home_dir + "/Downloads"
    directory Downloads_directory do
        owner user_id
        group group_name
        mode '0755'
        action :create
        not_if { ::File.directory?("#{Downloads_directory}") }
    end
    
    unless dev_dir.nil?
        directory dev_dir do
            owner user_id
            group group_name
            mode '0755'
            action :create
            not_if { ::File.directory?("#{dev_dir}") }
        end
    end

    unless user_uid.nil? || user_uid == 0
        bash "set user UID" do
            user "root"
            action :run
            code <<-EOD
                usermod -u #{user_uid} #{user_id}
            EOD
            only_if {not user_exists}
        end
    end

    link "/#{user_id}" do
      link_type :symbolic
      to "#{home_dir}"
      not_if { ::File.directory?("/#{user_id}") }
    end
end
