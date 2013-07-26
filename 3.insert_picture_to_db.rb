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

Car.all.each_with_index do |car, i|
	next if car.pics.length > 0
	pp car.pics
	
	print "#{i} "
	
	puts url = "http://car.autohome.com.cn/pic/series-s#{car.chexing_num}/#{car.chexi_num}.html"
	next
	html_stream = open(url).read.strip
	@doc = Nokogiri::HTML(html_stream)
	puts "#{i}/407\t#{url}"
	imgs = []
	@doc.xpath("//div[@class='r_tit']//img/@src").each_with_index do |img, j|
		break if j > 9
		@pic = Pic.new
		@pic.name = "#{car.maker}_#{car.chexi}_#{car.chexing}_#{j+1}"
		img = img.to_s.gsub('s_' , '')
		@pic.url = img
		
		imgs << @pic
	end
	car.pics =  imgs
	car.pic_url = url
	
	car.save

end
