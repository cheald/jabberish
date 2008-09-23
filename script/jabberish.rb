require 'rubygems'  
require 'drb'
require 'xmpp4r-simple'
require 'yaml'
require 'optparse'

class JabberClient
	def initialize
		options = OptionParser.new
		options.on('-e', '--env=ENVIRONMENT', 'Environment to invoke the IM client for') { |o| @env = o }
		options.parse!
	end
	
	def config
		config_file = "config/jabberish.yml"
		@@config_defs ||= (YAML::load(File.open(config_file).read) || {})[@env] || {}
	end

	def start
		pid = fork do
			messenger = Jabber::Simple.new(config["username"], config["password"])
			DRb.start_service("druby://#{config["host"]}:#{config["port"]}", messenger)
			loop do
				DRb.thread.join
			end
		end
		
		pid_path = (config["pids"] || "tmp") + "/jabberish.#{@env}.pid"
		File.open(pid_path, "w") {|f| f.write pid }
	end

	def stop
		pid_path = (config["pids"] || "tmp") + "/jabberish.#{@env}.pid"
		if File.exists? pid_path
			pid = File.open(pid_path).read.to_i
			unless pid == 0
				begin
					Process.kill "HUP", pid
					FileUtils.rm pid_path
				rescue Errno::ESRCH
					puts "Couldn't find PID #{pid}"
				end
			else
				puts "Couldn't find a PID to terminate."
			end
		else
			puts "No PID file found. Can't stop the service."
		end
	end
end

j = JabberClient.new
if ARGV.length < 1 then
	puts "Requires 'start' or 'stop'"
else
	if ARGV.first.downcase == "start" then
		j.start
	elsif ARGV.first.downcase == "stop" then
		j.stop
	end
end