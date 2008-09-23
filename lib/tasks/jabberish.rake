namespace :jabberish do
	desc "Start the Jabberish DRb server"
	task :start do |t|
		system "ruby vendor/plugins/jabberish/script/jabberish.rb start -e #{RAILS_ENV || "development"}"
	end

	desc "Stop the Jabberish DRb server"
	task :stop do |t|
		system "ruby vendor/plugins/jabberish/script/jabberish.rb stop -e #{RAILS_ENV || "development"}"
	end

	desc "Restart the Jabberish DRb server"
	task :restart => [:stop, :start]
end