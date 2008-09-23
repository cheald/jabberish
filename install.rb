require 'fileutils'

config = File.dirname(__FILE__) + '/../../../config/jabberish.yml'
FileUtils.cp File.dirname(__FILE__) + '/config/jabberish.yml.tpl', config unless File.exist?(config)

puts IO.read(File.join(File.dirname(__FILE__), 'README'))