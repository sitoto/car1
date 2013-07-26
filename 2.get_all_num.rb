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

#在产
ids = %w(83	837	2772	518	530	2324	2989	87	612	2759	854	3072	3071	996	2178	2180	2331	396)
nouse_ids = %w(2914)

#停产
tids = %w(451	84	434	478	85)
nouse_tids = %w{621}

@car = Car.new
@car.maker = "奇瑞"
@car.chexi =  "东方之子6"		
@car.chexing =  "2008款 基本型"
@car.chexi_num = 621
@car.chexing_num =  "3899"
@car.save


#停产的也搞定了
#return
tids.each do |id|
	url = "http://www.autohome.com.cn/#{id}/"
	html_stream = open(url).read.strip
	html_stream.encode!('utf-8', 'gbk')
	@doc = Nokogiri::HTML(html_stream)	
	
	puts h1 = @doc.at_css('h1').text.strip

	@doc.xpath("//div[@class='tabwrap']//td[@class='name_d']/a").each do |object|
		@car = Car.new
		@car.maker = "奇瑞"
		@car.chexi =  h1		
		@car.chexing =  object.at_xpath('@title').to_s.strip
		
		str = object.at_xpath('@href').to_s.strip.split('/')[1]
		@car.chexi_num = id
		@car.chexing_num =   str
		
		@car.save
		#break#puts object
	end
	#break
end

#return
#下面的已经完成 == ids =在产的奇瑞车
ids.each do |id|
	url = "http://www.autohome.com.cn/#{id}/"
	html_stream = open(url).read.strip
	html_stream.encode!('utf-8', 'gbk')
	@doc = Nokogiri::HTML(html_stream)
	
	puts h1 = @doc.at_css('h1').text.strip
	
	@doc.xpath('//select[@id= "SpecAll"]/option').each do |value|
		@car = Car.new
		@car.maker = "奇瑞"
		@car.chexi =  h1
		@car.chexing =  value.at_xpath('text()').to_s.strip
		@car.chexi_num = id
		@car.chexing_num =  value.at_xpath('@value').to_s.strip
		@car.save
		
		@file_to_write.puts "#{@car.maker}\t#{h1}\t#{@car.chexing}\t#{@car.chexing_num}"
	end
end
return


@url_lists = %w(
http://car.autohome.com.cn/pic/series/2914.html
http://car.autohome.com.cn/pic/series/83.html
http://car.autohome.com.cn/pic/series/837.html
http://car.autohome.com.cn/pic/series/2772.html
http://car.autohome.com.cn/pic/series/518.html
http://car.autohome.com.cn/pic/series/530.html
http://car.autohome.com.cn/pic/series/2324.html
http://car.autohome.com.cn/pic/series/2989.html
http://car.autohome.com.cn/pic/series/87.html
http://car.autohome.com.cn/pic/series/612.html
http://car.autohome.com.cn/pic/series/2759.html
http://car.autohome.com.cn/pic/series/854.html
http://car.autohome.com.cn/pic/series/3072.html
http://car.autohome.com.cn/pic/series/3071.html
http://car.autohome.com.cn/pic/series/996.html
http://car.autohome.com.cn/pic/series/2178.html
http://car.autohome.com.cn/pic/series/2180.html
http://car.autohome.com.cn/pic/series/2331.html
http://car.autohome.com.cn/pic/series/396.html
http://car.autohome.com.cn/pic/series-t/621.html
http://car.autohome.com.cn/pic/series-t/451.html
http://car.autohome.com.cn/pic/series-t/84.html
http://car.autohome.com.cn/pic/series-t/434.html
http://car.autohome.com.cn/pic/series-t/478.html
http://car.autohome.com.cn/pic/series-t/85.html
)

#@doc_chery = Nokogiri::HTML(qirui_string)
#@doc_chery.xpath('//dd/a/@href').each_with_index do |item, i|
#	puts "http://car.autohome.com.cn#{item}"
#end
#return

@url_lists.each_with_index do |url, i|

	html_stream = open(url).read.strip
	@doc = Nokogiri::HTML(html_stream)
	
	puts title =  @doc.at_css("strong.font14b").text.strip
	next

	h1 =  @doc.at_css("h1").text.strip_tag.strip
	

	@doc.xpath('//table[@id = "compare"]/tr/td[1]/a').each do |item|
		puts"#{i}/66\t#{h1}\t#{item.to_s.strip_tag}\t#{item.at_xpath('@href')}"
		@car = Car.new
		@car.h1 = h1
		@car.title = title
		@car.name = item.to_s.strip_tag
		@car.url = item.at_xpath('@href')
		@car.pic_url = item.at_xpath('@href').to_s + "tupian/"
		@car.save
	end
end
