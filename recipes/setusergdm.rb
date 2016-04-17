#
# Cookbook Name:: user
# Recipe:: setgdm
#
# Copyright 2016, Robert Zurga (vagrant@zurga.com)
#
# All rights reserved - Do Not Redistribute
#

# Handle GDM settings for data bag users which are listed in users node

include_recipe "chef-solo-search"

node[:users].each do |user_id|
    user_entry = search(:users, "id:" + user_id).first

    bash "disable lock screen" do
        user "root"
        code <<-EOH
            sudo -u #{user_uid} -H dbus-launch gsettings set org.gnome.desktop.screensaver lock-enabled false
        EOH
        action :run
    end

    bash "disable password" do
        user "root"
        code "sudo -u #{user_uid} -H dbus-launch gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false"
        action :run
    end

    bash "enlarge icons" do
        user "root"
        code "sudo -u #{user_uid} -H dbus-launch dconf write /org/compiz/profiles/unity/plugins/unityshell/icon-size 64"
        action :run
    end

    bash "enlarge fonts" do
        user "root"
        code "sudo -u #{user_uid} -H dbus-launch gsettings set org.gnome.desktop.interface text-scaling-factor 2.0"
        action :run
    end
end
