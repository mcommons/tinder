module Tinder
  
  # == Usage
  #
  #   campfire = Tinder::Campfire.new 'mysubdomain'
  #   campfire.login 'myemail@example.com', 'mypassword'
  #
  #   room = campfire.create_room 'New Room', 'My new campfire room to test tinder'
  #   room.speak 'Hello world!'
  #   room.destroy
  #
  #   room = campfire.find_room_by_guest_hash 'abc123', 'John Doe'
  #   room.speak 'Hello world!'
  class Campfire
    include HTTParty
    
    headers    'Content-Type' => 'application/json'
        
    attr_reader :subdomain, :uri

    # Create a new connection to the campfire account with the given +subdomain+.
    #
    # == Options:
    # * +:ssl+: use SSL for the connection, which is required if you have a Campfire SSL account.
    #           Defaults to false
    # * +:proxy+: a proxy URI. (e.g. :proxy => 'http://user:pass@example.com:8000')
    #
    #   c = Tinder::Campfire.new("mysubdomain", :ssl => true)
    def initialize(subdomain, options = {})
      self.class.base_uri "https://#{subdomain}.campfirenow.com"

      if options[:proxy]
        uri = URI.parse(options[:proxy])
        self.class.http_proxy uri.host, uri.port
      end

      @logged_in = false
    end

    def post(*args)
      self.class.post(*args)
    end

    def get(*args)
      result = self.class.get(*args)
      if result["HTTP Basic"] == "Access denied."
        raise "Access denied."
      end
      result
    end
    
    # Log in to campfire using your +email+ and +password+
    def login(email, password)
      self.class.basic_auth email, "X" #API requires no pass, just an API key
      @logged_in = true
    end
    
    # Returns true when successfully logged in
    def logged_in?
      @logged_in == true
    end
  
    def logout
      @rooms = nil
      @logged_in = false
    end
    
    # Get an array of all the available rooms
    # TODO: detect rooms that are full (no link)
    def rooms
      @rooms ||= get('/rooms.json')["rooms"].map do |room|
        Room.new(self, room["id"], room["name"], room["topic"])
      end
    end
  
    # Find a campfire room by name
    def find_room_by_name(name)
      rooms.detect {|room| room.name == name }
    end

    # Find a campfire room by its guest hash
    def find_room_by_guest_hash(hash, name)
      raise "Not implemented"
      # res = post(hash, :name => name)
      # 
      # Room.new(self, room_id_from_url(res['location'])) if verify_response(res, :redirect)
    end
    
    # Creates and returns a new Room with the given +name+ and optionally a +topic+
    def create_room(name, topic = nil)
      raise "Not implemented"
      # find_room_by_name(name) if verify_response(post("account/create/room?from=lobby", {:room => {:name => name, :topic => topic}}, :ajax => true), :success)
    end
    
    def find_or_create_room_by_name(name)
      raise "Not implemented"
      # find_room_by_name(name) || create_room(name)
    end
    
    # List the users that are currently chatting in any room
    def users(*room_names)
      rooms.map(&:users).flatten.uniq.sort
    end
    
    # Get the dates of the available transcripts by room
    #
    #   campfire.available_transcripts
    #   #=> {"15840" => [#<Date: 4908311/2,0,2299161>, #<Date: 4908285/2,0,2299161>]}
    #
    def available_transcripts(room = nil)
      raise "Not implemented"
      # 
      # url = "files%2Btranscripts"
      # url += "?room_id#{room}" if room
      # transcripts = (Hpricot(get(url).body) / ".transcript").inject({}) do |result,transcript|
      #   link = (transcript / "a").first.attributes['href']
      #   (result[room_id_from_url(link)] ||= []) << Date.parse(link.scan(/\/transcript\/(\d{4}\/\d{2}\/\d{2})/).to_s)
      #   result
      # end
      # room ? transcripts[room.to_s] : transcripts
    end
    
    # Is the connection to campfire using ssl?
    def ssl?
      true
    end
  
  private
  
    # def verify_response(response, options = {})
    #   if options.is_a?(Symbol)
    #     codes = case options
    #     when :success; [200]
    #     when :redirect; 300..399
    #     else raise(ArgumentError, "Unknown response #{options}")
    #     end
    #     codes.include?(response.code.to_i)
    #   elsif options[:redirect_to]
    #     verify_response(response, :redirect) && response['location'] == options[:redirect_to]
    #   else
    #     false
    #   end
    # end
    
  end
end
