#encoding: UTF-8
require 'mongoid'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'logger'
require 'pp'

Dir.glob("#{File.dirname(__FILE__)}/app/models/*.rb") do |lib|
  require lib
end


ENV['MONGOID_ENV'] = 'dev'

Mongoid.load!("config/mongoid.yml")

class IoFactory
	attr_reader :file
	def self.init file
		@file = file
		if @file.nil?
			puts 'Can Not Init File To Write'
			exit
		end #if
		File.open @file, 'a'
	end     
end #IoFactory

def create_file_to_write
	file_path = File.join('.', "picture-chery-#{Time.now.to_formatted_s(:number) }.txt")
	@file_to_write = IoFactory.init(file_path)
end #create_file_to_write

create_file_to_write


@cars = Car.all.asc(:created_at)
puts @cars.length
@cars.each_with_index do |car , c_i|
	next if c_i < 178
	car.pics.each_with_index do |item, p_i|
		#next if p_i < 1 && c_i < 1
		puts "#{c_i}/406 -#{p_i}"
		@file_to_write.puts "#{c_i}/406 -#{p_i}"
		File.open("#{item.name}.jpg", "wb") do |saved_file|
			open(item.url, 'rb') do |read_file|
			saved_file.write(read_file.read)
			end
		end
		#break
	end
	#break
end
