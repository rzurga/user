module Helper

    # include Chef::Mixin::ShellOut
    # 
    # def user_exists?(user_id)
    #   cmd = shell_out!('getent passwd #{user_id}', {:returns => [0,2]})
    #   cmd.stderr.empty? && (cmd.stdout =~ /^#{user_id}/)
    # end

    def does_user_exist(user_id)
        cmd = `getent passwd #{user_id}`
        status = $?.exitstatus == 0 ? true : nil
        printf "does_user_exist(%s) ::=> %s: [%s]", user_id, cmd, status
        return status
    end

end
