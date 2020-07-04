# frozen_string_literal: true

require_relative 'services/backup'
require 'yaml'
require 'byebug'

conf_name = ARGV[0]
file = "config/#{conf_name}.yml"
return puts 'Please pass conf name as param' if conf_name.nil?
return puts "Configure file #{file} not found" unless File.exists?(file)

config = YAML.safe_load(File.read(file), [Symbol])

backup = Backup.new(config)
res = backup.call
puts res
