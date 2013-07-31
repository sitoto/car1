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
	file_path = File.join('.', "sohu-#{Time.now.to_formatted_s(:number) }.txt")
	@file_to_write = IoFactory.init(file_path)
end #create_file_to_write

create_file_to_write

=begin
	qirui_string1 = '<table id="carlistall" cellspacing="0" style="">
			<tbody>
			
					<tr><td width="14%">
						<a href="http://db.auto.sohu.com/model_1097/" target="_blank">奇瑞新QQ</a><br>
					</td>
					
					<td width="14%">
						<a href="http://db.auto.sohu.com/model_1098/" target="_blank">瑞虎3</a><br>
					</td>
					
					<td width="14%">
						<a href="http://db.auto.sohu.com/model_3095/" target="_blank">奇瑞E5</a><br>
					</td>
					
					<td width="14%">
						<a href="http://db.auto.sohu.com/model_2559/" target="_blank">风云2两厢</a><br>
					</td>
					
					<td width="14%">
						<a href="http://db.auto.sohu.com/model_2558/" target="_blank">风云2三厢</a><br>
					</td>
					
					<td width="14%">
						<a href="http://db.auto.sohu.com/model_2972/" target="_blank">旗云2</a><br>
					</td>
					
					<td width="14%">
						<a href="http://db.auto.sohu.com/model_2772/" target="_blank">瑞虎DR</a><br>
					</td>
					
				</tr><tr>
				
					<td width="14%">
						<a href="http://db.auto.sohu.com/model_2403/" target="_blank">奇瑞A3两厢</a><br>
					</td>
					
					<td width="14%">
						<a href="http://db.auto.sohu.com/model_1107/" target="_blank">奇瑞A3三厢</a><br>
					</td>
					
					<td width="14%">
						<a href="http://db.auto.sohu.com/model_2763/" target="_blank">旗云1</a><br>
					</td>
					
					<td width="14%">
						<a href="http://db.auto.sohu.com/model_1102/" target="_blank">奇瑞A1</a><br>
					</td>
					
					<td width="14%">
						<a href="http://db.auto.sohu.com/model_1094/" target="_blank">东方之子</a><br>
					</td>
					
					<td width="14%">
						<a href="http://db.auto.sohu.com/model_3246/" target="_blank">旗云5</a><br>
					</td>
					
					<td width="14%">
						<a href="http://db.auto.sohu.com/model_2973/" target="_blank">旗云3</a><br>
					</td>
					
				</tr><tr>
				
					<td width="14%">
						<a href="http://db.auto.sohu.com/model_2399/" target="_blank">奇瑞QQme</a><br>
					</td>
					
			
			</tr></tbody>
		</table>'

	@doc = Nokogiri::HTML(qirui_string1)

	@doc.xpath('//a/@href').each do |item|
		puts item
	end

	return
=end

@url_lists = %w(http://db.auto.sohu.com/model_1097/
http://db.auto.sohu.com/model_1098/
http://db.auto.sohu.com/model_3095/
http://db.auto.sohu.com/model_2559/
http://db.auto.sohu.com/model_2558/
http://db.auto.sohu.com/model_2972/
http://db.auto.sohu.com/model_2772/
http://db.auto.sohu.com/model_2403/
http://db.auto.sohu.com/model_1107/
http://db.auto.sohu.com/model_2763/
http://db.auto.sohu.com/model_1102/
http://db.auto.sohu.com/model_1094/
http://db.auto.sohu.com/model_3246/
http://db.auto.sohu.com/model_2973/
http://db.auto.sohu.com/model_2399/
)

@url_lists.each_with_index do |url, i|


# //table[@class="hid"]/a   id 里面 有年份

# //table[@class = "b jsq"]/
	html_stream = open(url).read.strip
	html_stream.encode!('utf-8', 'gbk')
	
	
	@doc = Nokogiri::HTML(html_stream)
	#<div id="CXLB"
	puts title =  @doc.at_css("div#CXLB > h2").text.strip
	
	#当前展现的车型
	@doc.xpath("//table[@class = 'b jsq']//td[@class = 'ftdleft']").each do |item|
		puts str = item.xpath("a/text()")[0]
		@file_to_write.puts  "#{title}\t#{str}"
	
	end	
	#return
	#当前 隐藏的车型
	puts @doc.xpath("//table[@class = 'hid']").length
	@doc.xpath("//table[@class = 'hid']").each do |object|
		puts year = object.at_xpath('@id') || ''
		year.to_s.gsub('tms_t_','')
		puts object.xpath("tr/td[@class = 'ftdleft']").length
		#break
		object.xpath("tr/td[@class = 'ftdleft']").each do |item|
			str = item.xpath("a/text()")[0]
			puts  "#{title}\t#{str}\t#{year}"
			@file_to_write.puts  "#{title}\t#{str}\t#{year}"
		end
	end
	#<td class="ftdleft">
	#break

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
