module OdinSpecHelper

  require 'config_path'

  def extractNotification(notifications, notification)
    notifications.each do |n|
      return n if n[notification]
    end
    return nil
  end

  def tunnnel_odin_bunny
    ConfigPath.config_path = File.dirname(__FILE__) + "/../../config/odin_bunny.yml"
    odin = "#{ConfigPath.new.options['baseurl']}"
    return if odin == 'localhost'
    cmd = "ssh -f -N -L 5672:localhost:5672 #{odin}"
    puts cmd
    ssh = `ps aux | grep ssh`
    system cmd unless ssh.match(cmd)
  end

end
