class WelcomeController < ApplicationController 
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  before_filter :init_request
  def init_request
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Credentials'] = "true"
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  def incoming_message
    Message.handle_incoming_message(params)
    render json: {success: true}
  end

  def sparklive_widget
    visitor_id = session[:visitor_id]
    if visitor_id.blank?
      visitor_id = Random.rand(10**10)
      session[:visitor_id] = visitor_id
    end
    f = File.read("public/sparklive_template.js")
    res = "visitor_id=#{visitor_id};sparklive_url = 'https://#{User::HOST}';" + f
    new_name = "public/sparklive.js"
    f1 = File.open(new_name, "w")
    f1.write(res)
    f1.close
    send_file(new_name)
  end

  def get_messages
    # messages = [{mpn: {text: "chus", by: "by"}}]
    user_client = User.find_byjs(spark_id: params[:client_id])
    visitor_id = params[:visitor_id]
    visitor_room = VisitorRoom.find_byjs(visitor_id: visitor_id) rescue nil
    # messages_to_send = []
    # if !visitor_room.blank?
    #   messages = visitor_room.get_messages
    #   messages.each do |message|
    #     by = 2
    #     by = 1 if message.keys.include?("html")
    #     messages_to_send << {text: message.text, by: by}
    #   end
    # end
    # messages_to_send = []
    messages_to_send = visitor_room.blank? ? [] : visitor_room.get_messages
    result = {messages: messages_to_send}
    if !visitor_room.blank?
      sip_address = visitor_room.get_sip_address
      result[:sip_address] = sip_address
    end
    render json: result
  end

  def index

  end

  def new_message
    puts "==="*30
    puts params.inspect
    puts "==="*30
    visitor_id = params[:visitor_id]
    user_client = User.find_byjs(spark_id: params[:client_id])
    support_type = params[:support_type].blank? ? nil : params[:support_type] 
    user_client.add_message(params[:text], visitor_id, Message::FROM_USER, support_type: support_type, browser: browser, ip: request.remote_ip)
    render json: {success: true, access_token: user_client.get_access_token, sip_address: VisitorRoom.find_byjs(visitor_id: visitor_id).get_sip_address}
  end

  def configure
    sign_in User.first
  end

  def save_config
    current_user.update_attributes(configuration: params["selected_teams"])
    redirect_to :back
    # render json: {success: true}
  end
  
  def call
    if !params[:a].blank? 
      sign_in User.find 7
    else
      sign_in User.find 8
    end
  end

  def incoming_spark
    user = User.handle_incoming_spark(params[:code], session[:type])
    if user
      sign_in user
      redirect_to configure_path
    end
  end

  def redirect_spark
    session[:type] = params[:type]
    redirect_to User::AUTH_URI
  end


end
