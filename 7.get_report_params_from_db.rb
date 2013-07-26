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
	file_path = File.join('.', "autohome-chery-#{Time.now.to_formatted_s(:number) }.txt")
	@file_to_write = IoFactory.init(file_path)
end #create_file_to_write

create_file_to_write
@cars = Car.all.desc(:created_at)
length = @cars.count
@title = []

@title = ["车系", "车型"]

@cars.all.each_with_index do |car, i|
  print "#{i} "
  car.parameters.each do |param|
      #str << "#{param.value}\t"
      @title << param.name
      #puts "#{param.name}\t#{param.value}"
  end
  @title.uniq!
  
end
@file_to_write.puts @title.join('$')

@cars.all.each_with_index do |car, i|
  print "#{i} "
  str = ""
  @title.each do |title|  
    car.parameters.each do |param|
    
      if title == param.name
        str << "#{param.value}"
      end
    end
    str << "\t"
    
  end
  @file_to_write.puts "#{car.chexi}\t#{car.chexing}\t#{str}"
  #break
end