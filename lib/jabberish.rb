class JabberishAgent
	def initialize()
		@config = (YAML::load(File.open("#{RAILS_ROOT}/config/jabberish.yml").read) || {})[RAILS_ENV] || {}
		@last_messages = {}
	end
	
	def get_im_connection
		if @im_service.nil?
			DRb.start_service
			@im_service = DRbObject.new(nil, "druby://#{@config["host"]}:#{@config["port"]}")
			@im_available = true
		end

		if @im_available
			return @im_service
		else
			@last_im_connect_attempt ||= Time.now
			if @last_im_connect_attempt < 3.minutes.ago then
				return @im_service
			else
				@last_im_connect_attempt = Time.now
				return nil
			end
		end
	end

	def send_im(to, msg, throttle = false)
		begin
			return if throttle and @last_messages[to] == msg
			@last_messages[to] = msg
			conn = get_im_connection
			return if conn.nil?
			conn.deliver to, msg
			@im_available = true
		rescue DRb::DRbConnError
			@im_available = false
		end
	end		
	
	def self.deliver(to, msg, throttle = false)
		@@im ||= JabberishAgent.new
		@@im.send_im(to, msg, throttle)
	end
end