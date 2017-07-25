class User  < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  store_accessor :json_store, :role, :auth, :spark_id, :cached_get_teams, :configuration
  has_and_belongs_to_many :users, -> { uniq }, join_table: "hospital_user_mappings" 

  CLIENT_ID = "Ca545c560c3f17dff5de2e9aa33ee9a092044a29219b4529d200ebfda4376a9c4"
  CLIENT_SECRET = "42d05d5908037edaee9f84cff8bc30843c1aacd492d96c9a20a88a50221f7e04"
  HOST = "sparklive.herokuapp.com"
  BASE_API_URL = "https://api.ciscospark.com/v1/"
  REDIRECT_URI = CGI.escape("https://#{HOST}/incoming_spark")
  AUTH_URI = "#{BASE_API_URL}authorize?client_id=#{CLIENT_ID}&response_type=code&redirect_uri=#{REDIRECT_URI}&scope=spark%3Aall%20spark%3Akms"

  def self.find_byjs(hash)
    User.where("(json_store ->> '#{hash.keys.first}') = ?", hash.values.first).last
  end

  def self.quote(s)
    res = "\n"
    s.split("\n").each do |line|
      res = "#{res}> #{line}\n" 
    end
    return res
  end

  def quote(s)
    User.quote(s)
  end

  def add_message(text, visitor_id, message_type, browser: nil, ip: nil, support_type: nil)
    room = VisitorRoom.find_byjs(visitor_id: visitor_id.to_s) rescue nil
    if !room
      room = create_new_room(visitor_id, support_type: support_type)
      Message.send_intro_message(self, room, browser, ip)
    end
    if message_type == Message::FROM_USER
      send_text = quote(text)      
      send_text = "User-#{visitor_id}: #{send_text}"
    else
      send_text = text
    end
    # data = {markdown: send_text, roomId: room.remote_id}
    # res = curl("'#{BASE_API_URL}messages' -X POST -d '#{data.to_json}'")
    # # Message.create(remote_id: res.id)
    if text == "close ticket"
      room.delete_remote_room
      room.delete
      Message.send_close_ticket(self, room)
      return res
    end
    res = Message.send_and_create_new_message(self, send_text, room, message_type)
    return res
  end

  def get_message(id)
    curl("'#{BASE_API_URL}messages/#{id}' -X GET")
  end

  def send_message(data)
    curl("'#{BASE_API_URL}messages' -X POST -d '#{data.to_json}'")
  end

  def self.get_location_info_from_ip(ip)
    res = User.curl("'freegeoip.net/json/#{ip}'")
    return res
  end

  def text_team_id
    return configuration["text_team_id"]
  end

  def video_team_id
    return configuration["video_team_id"]
  end

  def audio_team_id
    return configuration["audio_team_id"]
  end

  def create_new_room(visitor_id, support_type: nil)
    if support_type.blank?
      support_type = "text"
    end
    team_id = configuration["#{support_type}_team_id"]
    data = {title: "#{support_type}-support-#{visitor_id}", teamId: team_id}
    res = curl("'#{BASE_API_URL}rooms' --data-binary '#{data.to_json}' -X POST")
    room = VisitorRoom.create(visitor_room_id: res.id, team_id: res.teamId, name: res.title, user_id: res.creatorId, visitor_id: visitor_id)
    # room = VisitorRoom.last
    return room
  end

  def self.handle_incoming_spark(code, role)
    res = curl("'#{BASE_API_URL}access_token' -H 'Content-Type: application/x-www-form-urlencoded' -d 'grant_type=authorization_code&client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}&code=#{code}&redirect_uri=#{REDIRECT_URI}'")
    user = User.create_user(res, role)
    return user
  end

  def get_script_tag
    return "<script src='https://#{HOST}/sparklive_widget.js' id='sparklive-script' data-client-id='#{self.spark_id}'></script>"
  end

  def self.create_user(auth, role)
    access_token = auth.access_token
    res = get_details(access_token)
    user = User.find_or_create_by(email: res.emails[0])
    user.update_attributes(password: "User1234", spark_id: res.id, name: res.displayName, auth: auth, role: role)
    return user
  end

  def get_messages(room_id = "Y2lzY29zcGFyazovL3VzL1JPT00vOTJkMjA2NzAtNjU3Yi0xMWU3LTg0NmYtNTk2ZDg2ODZjMzYx")
    res = curl("#{BASE_API_URL}/messages?roomId=#{room_id}").items
  end

  def get_rooms
    cmd = curl("'#{BASE_API_URL}/rooms'")
  end

  def get_teams
    #todo
    # if cached_get_teams.blank?
      cmd = curl("'#{BASE_API_URL}/teams'")
      # update_attributes(cached_get_teams: cmd)
    # else
      # cmd = self.cached_get_teams
    # end
    return cmd.items
  end

  def curl(s)
    cmd = User.curl("#{s} -H 'Authorization: Bearer #{get_access_token}'")
    return cmd
  end

  def self.curl(s)
    cmd = "curl #{s} -H 'Content-Type: application/json'"
    puts "========="
    puts cmd
    puts "========="
    res = `#{cmd}`
    puts res
    puts "========="
    return res.parse_json
  end

  def self.get_details(access_token)
    cmd = curl "'#{BASE_API_URL}people/me' -H 'Authorization: Bearer #{access_token}' -H 'Content-Type: application/json'"
    return cmd
  end

  def get_access_token
    return auth.access_token
  end

  def set_webhooks
    data = {name: "Incoming Messages hooks", targetUrl: "https://#{HOST}/incoming_messages", resource: "messages", event: "created"}
    res = curl("'#{BASE_API_URL}webhooks' -X POST -d '#{data.to_json}'")
  end

end
