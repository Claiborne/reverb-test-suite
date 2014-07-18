module OdinSpecHelper

  def extractNotification(notifications, notification)
    notifications.each do |n|
      return n if n[notification]
    end
    return nil
  end
  
  def tunnnel_odin_dev
    cmd = 'ssh -f -N -L 5672:localhost:5672 54.219.86.212'
    ssh = `ps aux | grep ssh`
    system cmd unless ssh.match(cmd)
  end

end
