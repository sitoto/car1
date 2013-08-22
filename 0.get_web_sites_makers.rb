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
ENV['MONGOID_ENV'] = 'local'
Mongoid.load!("config/mongoid.yml")

class GemWebMakers
  include Common
  
  def initialize()
  end

  def generate(website)
    case
    when website == 'autohome'
      puts 'autohome'
      get_autohome_maker
    when website == 'bitauto'
      puts 'bitauto'
    when website == 'sohu'
      puts 'sohu'

    else
      puts "Oh...! There is nothing to do."
    end
  end
  
=begin
%w(featured rated).each do |name|
 define_method(name) do
 @videos = Video.order('random()').first(32)
 @page_title = t("videos.#{name}")
 render :show
 end
end
=end  
  
  
  def export_report(name = "report")
    create_file_to_write(name)
    @cars = Car.where(:maker => @maker, :from_site => @from_site).desc(:chexi_num)
    length = @cars.count
    @title2 = []

    @title1 = ["品牌","车系", "年款", "名称", "图片前缀","张数", "来源"]

    @cars.all.each_with_index do |car, i|
      print "#{i} "
      car.parameters.each do |param|
          #str << "#{param.value}\t"
          @title2 << param.name
          #puts "#{param.name}\t#{param.value}"
      end
      @title2.uniq!
      
    end
    @title = @title1 + @title2
    @file_to_write.puts @title.join(' ')

    @cars.all.each_with_index do |car, i|
      print "#{i} "
      str = ""
      @title2.each do |title|  
        car.parameters.each do |param|
        
          if (title == param.name && title != "车身颜色")
            txt_str = param.value
            #txt_str = CGI::unescape(txt_str)
            #txt_str.color_str_to_line
            str << txt_str
          end
        end
        str << "\t"
        
      end
      qianzui = "#{car.maker}_#{car.chexi}_#{car.year}_#{car.chexing}"
      @file_to_write.puts "#{car.maker}\t#{car.chexi}\t#{car.year}\t#{car.chexing}\t#{qianzui}\t#{car.pic_num}\t#{car.from_site}\t#{str}"
      #break
    end    
  end
   
  
  private  
  def get_autohome_maker
    # open the url
    url = "http://car.autohome.com.cn/zhaoche/pinpai/"
    # get it sid, brand-** ,maker , brand
    doc = fetch_doc(url)
    puts doc.at_xpath("//title").to_s
    doc.xpath("//div[@class='grade_js_top30']").each do |item|
      puts brand = item.at_xpath("div/div[@class='grade_js_top33']/a/text()").to_s
      puts url = item.at_xpath("div/div[@class='grade_js_top33']/a/@href").to_s
    end
  end
  
  
  def create_file_to_write(name = 'file')
    file_path = File.join('.', "#{name}-#{Time.now.to_formatted_s(:number) }.txt")
    @file_to_write = IoFactory.init(file_path)
  end #create_file_to_write

  def fetch_doc(url)
    html_stream = safe_open(url , retries = 3, sleep_time = 0.2, headers = {})
#    begin
    html_stream.encode!('utf-8', 'gbk', :invalid => :replace) #忽略无法识别的字符
#    rescue StandardError,Timeout::Error, SystemCallError, Errno::ECONNREFUSED #有些异常不是标准异常  
#     puts $!  
#    end
    Nokogiri::HTML(html_stream)
  end

  def open_http(url)
    safe_open(url , retries = 3, sleep_time = 0.2, headers = {})
  end #end of open_http
  
  def save_maker(sid, webname, name, folder, brand,  from_site, status = 'init')
    @maker = Maker.find_or_create_by()
          
    @maker.save  
  end #end of save_chexing 
  
end


GemWebMakers.new().generate("autohome")
GemWebMakers.new().generate("bitauto")
GemWebMakers.new().generate("sohu")
GemWebMakers.new().generate("pcauto")


