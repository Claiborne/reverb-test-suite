module OdinSpecHelper
  def extractNotification(notifications, notification)
    notifications.each do |n|
      return n if n[notification]
    end
  end
end
