class VisitorRoom < ActiveRecord::Base
  store_accessor :json_store, :details, :user_id, :team_id, :visitor_id, :sip_address
  
  def self.find_byjs(hash)
    VisitorRoom.where("(json_store ->> '#{hash.keys.first}') = ?", hash.values.first).last
  end

  def get_spark_user
    User.find_byjs(spark_id: user_id)
  end

  def get_messages_remote
    user = get_spark_user
    user.get_messages(visitor_room_id)
    # Message.where(room_id: remote_id)
  end

  def get_messages
    messages_to_send = []
    messages = Message.room(remote_id).order(:created_at)
    messages.each do |message|
      if message.message_type == Message::FROM_USER || message.message_type == Message::FROM_SUPPORT
        by = message.message_type
        messages_to_send << {text: message.text, by: by}
      end
    end
    return messages_to_send
  end

  def get_remote_object
    return get_spark_user.curl("'#{User::BASE_API_URL}rooms/#{remote_id}'")
  end

  def add_message(text, from_chat: false, browser: nil, ip: nil)
    get_spark_user.add_message(text, self.visitor_id, from_chat: from_chat, browser: browser, ip: ip)
  end

  def get_sip_address
    if sip_address.blank?
      res = get_remote_object
      update_attributes(sip_address: res.sipAddress)
    end
    return self.sip_address
  end

  def remote_id
    return visitor_room_id
  end

  def delete_remote_room
    puts "===="*10
    puts "Deleting remote room"
    puts "===="*10
    get_spark_user.curl("'#{User::BASE_API_URL}rooms/#{visitor_room_id}' -X DELETE")
  end

end
