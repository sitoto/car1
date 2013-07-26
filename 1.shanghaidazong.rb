#encoding: UTF-8
require 'mongoid'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pp'
require_relative "common"

Dir.glob("#{File.dirname(__FILE__)}/app/models/*.rb") do |lib|
  require lib
end
ENV['MONGOID_ENV'] = 'dev'
Mongoid.load!("config/mongoid.yml")

class GetCarAndDetail
  include Common
  
  def initialize(sid = "brand_1")
    @sid = sid
  end
  
  def read_chexi
    file_str = ""
    File.open("autohome_car_model.html","r") do |file|
      while line  = file.gets
        file_str += line
      end
    end
    puts file_str.length
    @doc = Nokogiri::HTML(file_str)
    
    @doc.xpath('//ul/li').each do |item|
      if item.at_xpath("h3/a/@id").to_s == @sid
        puts "That's it#{item.at_xpath('h3/a/text()').to_s}"
        
        item.xpath('div/dl/dd/a/text()').each_with_index do |chexi, i|
          puts chexi.to_s if i < 11   # the top 11 is  shanghaidazong
          
        end
          
        
      end
      
      #puts item.at_xpath('h3/a/text()').to_s.strip.split(' ')[0]
    end
  end

  def run
    
  end
  

  
  private  
  def create_file_to_write(name = 'file')
    file_path = File.join('.', "#{name}-#{Time.now.to_formatted_s(:number) }.txt")
    @file_to_write = IoFactory.init(file_path)
  end #create_file_to_write
end

sid = 'brand_1' #it's h3/a 's  id

GetCarAndDetail.new(sid).read_chexi

return

qirui_string1 = "<h3><a id='brand_26' href='/price/brand-26.html'>奇瑞 (394)</a></h3><div class='listtree' id='bl26' style='display:block;'><dl><dt><a id='fct_33' href='/price/brand-26-33.html' style='color:#000000;font-weight:bold'>奇瑞汽车</a></dt>
<dd><a id='series_2914' href='/price/series-2914.html' >爱卡 (2)</a></dd><dd><a id='series_83' href='/price/series-83.html' >东方之子 (41)</a></dd>
<dd><a id='series_837' href='/price/series-837.html' >风云2 (18)</a></dd><dd><a id='series_518' href='/price/series-518.html' >奇瑞A1 (12)</a></dd>
<dd><a id='series_530' href='/price/series-530.html' >奇瑞A3 (33)</a></dd><dd><a id='series_2324' href='/price/series-2324.html' >奇瑞E5 (9)</a></dd>
<dd><a id='series_2989' href='/price/series-2989.html' >奇瑞QQ (4)</a></dd><dd><a id='series_87' href='/price/series-87.html' >奇瑞QQ3 (74)</a></dd>
<dd><a id='series_612' href='/price/series-612.html' >奇瑞QQme (5)</a></dd><dd><a id='series_854' href='/price/series-854.html' >奇瑞X1 (14)</a></dd>
<dd><a id='series_996' href='/price/series-996.html' >旗云1 (10)</a></dd><dd><a id='series_2178' href='/price/series-2178.html' >旗云2 (8)</a></dd>
<dd><a id='series_2180' href='/price/series-2180.html' >旗云3 (6)</a></dd><dd><a id='series_2331' href='/price/series-2331.html' >旗云5 (5)</a></dd>
<dd><a id='series_396' href='/price/series-396.html' >瑞虎 (68)</a></dd><dd><a id='series_451' href='/price/series-451-0-3.html' >东方之子Cross (停售) (21)</a></dd>
<dd><a id='series_84' href='/price/series-84-0-3.html' >风云 (停售) (4)</a></dd><dd><a id='series_434' href='/price/series-434-0-3.html' >奇瑞A5 (停售) (18)</a></dd>
<dd><a id='series_478' href='/price/series-478-0-3.html' >奇瑞QQ6 (停售) (8)</a></dd><dd><a id='series_85' href='/price/series-85-0-3.html' >旗云 (停售) (34)</a></dd></dl></div>"

qirui_string = "<h3><em></em><span>Q</span><a id='brand_26' href='/pic/brand-26.html'>奇瑞 (20196)</a></h3><div class='listtree' id='bl26' style='display:block;'>
<dl><dt><a id='fct_33' href='/pic/brand-26-33.html' >奇瑞汽车</a></dt><dd><a id='series_2914' href='/pic/series/2914.html' >爱卡 (11)</a></dd><dd><a id='series_83' href='/pic/series/83.html' >东方之子 (1155)</a></dd><dd><a id='series_837' href='/pic/series/837.html' >风云2 (1561)</a></dd><dd><a id='series_2772' href='/pic/series/2772.html' >奇瑞@ANT (26)</a></dd><dd><a id='series_518' href='/pic/series/518.html' >奇瑞A1 (1225)</a></dd><dd><a id='series_530' href='/pic/series/530.html' >奇瑞A3 (2880)</a></dd><dd><a id='series_2324' href='/pic/series/2324.html' >奇瑞E5 (1120)</a></dd><dd><a id='series_2989' href='/pic/series/2989.html' >奇瑞QQ (703)</a></dd><dd><a id='series_87' href='/pic/series/87.html' >奇瑞QQ3 (1409)</a></dd><dd><a id='series_612' href='/pic/series/612.html' >奇瑞QQme (310)</a></dd><dd><a id='series_2759' href='/pic/series/2759.html' >奇瑞TX (35)</a></dd><dd><a id='series_854' href='/pic/series/854.html' >奇瑞X1 (1185)</a></dd><dd class='hot'><a id='series_3072' href='/pic/series/3072.html' style='color:#000000; font-weight:bold' >奇瑞α7 (74)</a></dd><dd><a id='series_3071' href='/pic/series/3071.html' >奇瑞β5 (86)</a></dd><dd><a id='series_996' href='/pic/series/996.html' >旗云1 (298)</a></dd><dd><a id='series_2178' href='/pic/series/2178.html' >旗云2 (671)</a></dd><dd><a id='series_2180' href='/pic/series/2180.html' >旗云3 (298)</a></dd><dd><a id='series_2331' href='/pic/series/2331.html' >旗云5 (680)</a></dd><dd><a id='series_396' href='/pic/series/396.html' >瑞虎 (3732)</a></dd><dd><a id='series_621' href='/pic/series-t/621.html' >东方之子6 (停售) (19)</a></dd><dd><a id='series_451' href='/pic/series-t/451.html' >东方之子Cross (停售) (760)</a></dd><dd><a id='series_84' href='/pic/series-t/84.html' >风云 (停售) (27)</a></dd><dd><a id='series_434' href='/pic/series-t/434.html' >奇瑞A5 (停售) (1001)</a></dd><dd><a id='series_478' href='/pic/series-t/478.html' >奇瑞QQ6 (停售) (397)</a></dd>
<dd><a id='series_85' href='/pic/series-t/85.html' >旗云 (停售) (533)</a></dd></dl></div>"
ids = %w(2914	83	837	2772	518	530	2324	2989	87	612	2759	854	3072	3071	996	2178	2180	2331	396)
tids = %w(621	451	84	434	478	85)

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
