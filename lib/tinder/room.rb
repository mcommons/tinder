module Tinder
  # A campfire room
  class Room
    attr_reader :id, :name

    def initialize(campfire, id, name = nil, topic = nil)
      @id       = id
      @campfire = campfire
      @topic    = topic
      @name     = name
    end
    
    # Toggle guest access on or off
    def toggle_guest_access
      raise "not implemented"
    end

    # Get the url for guest access
    def guest_url
      raise "not implemented"
    end
    
    def guest_access_enabled?
      raise "not implemented"
      # !guest_url.nil?
    end

    # The invite code use for guest
    def guest_invite_code
      raise "not implemented"
      # guest_url.scan(/\/(\w*)$/).to_s
    end

    # Change the name of the room
    def name=(name)
      raise "not implemented"
      # @name = name if verify_response(post("account/edit/room/#{id}", { :room => { :name => name }}, :ajax => true), :success)
    end
    alias_method :rename, :name=

    # Change the topic
    def topic=(topic)
      raise "not implemented"
      # topic if verify_response(post("room/#{id}/change_topic", { 'room' => { 'topic' => topic }}, :ajax => true), :success)
    end
    
    # Get the current topic
    def topic
      @topic
    end
    
    def ping(force = false)
      raise "not implemented"
      # 
      # returning verify_response(post("room/#{id}/tabs", { }, :ajax => true), :success) do
      #   @idle_since = Time.now
      # end if @idle_since < 1.minute.ago || force
    end

    def destroy
      raise "not implemented"
      # verify_response(post("account/delete/room/#{id}"), :success)
    end

    # Post a new message to the chat room
    def speak(msg, options = {})
      if options[:paste]
        paste msg
      else
        message msg
      end
    end
    
    # Get the list of users currently chatting for this room
    def users
      raise "not implemented"
      # @campfire.users name
    end

    # Get and array of the messages that have been posted to the room. Each
    # messages is a hash with:
    # * +:person+: the display name of the person that posted the message
    # * +:message+: the body of the message
    # * +:user_id+: Campfire user id
    # * +:id+: Campfire message id
    #
    #   room.listen
    #   #=> [{:person=>"Brandon", :message=>"I'm getting very sleepy", :user_id=>"148583", :id=>"16434003"}]
    #
    # Called without a block, listen will return an array of messages that have been
    # posted since you joined. listen also takes an optional block, which then polls
    # for new messages every 5 seconds and calls the block for each message.
    #
    #   room.listen do |m|
    #     room.speak "#{m[:person]}, Go away!" if m[:message] =~ /Java/i
    #   end
    #
    def listen(interval = 5)
      raise "not implemented"
      # join
      # if block_given?
      #   catch(:stop_listening) do
      #     trap('INT') { throw :stop_listening }
      #     loop do
      #       ping
      #       self.messages.each {|msg| yield msg }
      #       sleep interval
      #     end
      #   end
      # else
      #   self.messages
      # end
    end
    
    # Get the dates for the available transcripts for this room
    def available_transcripts
      raise "not implemented"
      # @campfire.available_transcripts(id)
    end
    
    # Get the transcript for the given date (Returns a hash in the same format as #listen)
    #
    #   room.transcript(room.available_transcripts.first)
    #   #=> [{:message=>"foobar!",
    #         :user_id=>"99999",
    #         :person=>"Brandon",
    #         :id=>"18659245",
    #         :timestamp=>=>Tue May 05 07:15:00 -0700 2009}]
    #
    # The timestamp slot will typically have a granularity of five minutes.
    #
    def transcript(transcript_date)
      # def transcript
      #   get('transcript')['messages']
      # end
      raise "not implemented"
      # url = "room/#{id}/transcript/#{transcript_date.to_date.strftime('%Y/%m/%d')}"
      # date, time = nil, nil
      # (Hpricot(get(url).body) / ".message").collect do |message|
      #   person = (message / '.person span').first
      #   if !person
      #     # No span for enter/leave the room messages
      #     person = (message / '.person').first
      #   end
      #   body = (message / '.body div').first
      #   if d = (message / '.date span').first
      #       date = d.inner_html
      #   end
      #   if t = (message / '.time div').first
      #       time = t.inner_html
      #   end
      #   {:id => message.attributes['id'].scan(/message_(\d+)/).to_s,
      #     :person => person ? person.inner_html : nil,
      #     :user_id => message.attributes['class'].scan(/user_(\d+)/).to_s,
      #     :message => body ? body.inner_html : nil,
      #     # Use the transcript_date to fill in the correct year
      #     :timestamp => Time.parse("#{date} #{time}", transcript_date)
      #   }
      # end
    end
    
    def upload(filename)
      raise "not implemented"
      # File.open(filename, "rb") do |file|
      #   params = Multipart::MultipartPost.new({'upload' => file, 'submit' => "Upload"})
      #   verify_response post("upload.cgi/room/#{@id}/uploads/new", params.query, :multipart => true), :success
      # end
    end
    
    # Get the list of latest files for this room
    def files(count = 5)
      raise "not implemented"
      # join
      # (Hpricot(@room.body)/"#file_list li a").to_a[0,count].map do |link|
      #   @campfire.send :url_for, link.attributes['href'][1..-1], :only_path => false
      # end
    end
    
    def join
      post 'join'
    end

    def leave
      post 'leave'
    end

    def lock
      post 'lock'
    end

    def unlock
      post 'unlock'
    end

    def message(message)
      send_message message
    end

    def paste(paste)
      send_message paste, 'PasteMessage'
    end

    def play_sound(sound)
      send_message sound, 'SoundMessage'
    end


  protected
    
    def messages
      transcript.map do |transcript_message|
        {
          :id => transcript_message.id,
          :user_id => transcript_message["user_id"],
          :person => "Unknown",
          :message => transcript_message.body
        
        }
      end
    end
  
    def send_message(message, type = 'Textmessage')
      post 'speak', :body => {:message => {:body => message, :type => type}}.to_json
    end

    def get(action, options = {})
      @campfire.get room_url_for(action), options
    end

    def post(action, options = {})
      @campfire.post room_url_for(action), options
    end

    def room_url_for(action)
      "/room/#{id}/#{action}.json"
    end
  end
end
