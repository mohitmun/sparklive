class Message < ActiveRecord::Base
  validates :remote_id, presence: true, uniqueness: true
  store_accessor :json_store, :from_chat, :markdown, :message_type
  MESSAGE_TYPES = {"0" => "System Generated", "1" => "From User", "2" => "From Suport"}
  scope :from_user, -> {where("(json_store ->> 'message_type') = ?", FROM_USER)}
  scope :from_system, -> {where("(json_store ->> 'message_type') = ?",  FROM_SYSTEM)}
  scope :from_support, -> {where("(json_store ->> 'message_type') = ?", FROM_SUPPORT)}
  scope :room, ->(room_id){where(room_id: room_id)}
  FROM_SYSTEM = "0"
  FROM_USER = "2"
  FROM_SUPPORT = "1"
  
  def self.send_and_create_new_message(user,send_text, room, message_type)
    data = {markdown: send_text, roomId: room.remote_id}
    res = user.send_message(data)
    create_new_message(res, message_type)
  end

  def self.create_new_message_from_remote_id(user, remote_id)
    res = user.get_message(remote_id)
    create_new_message(res, FROM_SUPPORT)
  end

  def self.handle_incoming_message(params)
    user = User.find_byjs(spark_id: params["createdBy"])
    if user.blank?
      puts "user is blank #{params}"
    else
      create_new_message_from_remote_id(user, params["data"]["id"])
    end
  end

  def self.create_new_message(res, message_type)
    m = Message.find_by(remote_id: res.id) rescue nil
    if m.blank?
      Message.create(remote_id: res.id, room_id: res.roomId, text: res.text, html: res.html, markdown: (res.markdown rescue nil), person_id: res.personId, message_type: message_type)
      puts "=== Creating new message ==="
    else
      puts "=== Meesage already present ==="
    end
  end

  def self.send_intro_message(user, room, browser, ip)
    text = get_intro_message(browser, ip)
    send_and_create_new_message(user, text, room, FROM_SYSTEM)
  end
  
  def self.send_close_ticket(user, room)
    text = "User has marked issue resolved"
    send_and_create_new_message(user, text, room, FROM_SYSTEM)
  end

  def self.get_intro_message(browser, ip)
    res = "**New incoming support request**\n\n"
    res = res + "Browser/Platform\n> #{browser.name} #{browser.full_version}/ #{browser.platform.name} #{browser.platform.version}\n\n" if !browser.blank?
    if !ip.blank?
      res = res + "IP\n> #{ip}\n\nCity/Region\n> "
      location_info_json = User.get_location_info_from_ip(ip)
      comma = ""
      ["city", "region_name", "country_name"].each do |key|
        value = location_info_json[key]
        res = res + "#{comma} #{value}" if !value.blank?
        comma = ","
      end 
    end
    return User.quote(res)
  end

end
