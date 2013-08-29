#encoding: UTF-8
require 'mongoid'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pp'
require "chinese_pinyin"
require_relative "common"

Dir.glob("#{File.dirname(__FILE__)}/app/models/*.rb") do |lib|
  require lib
end
ENV['MONGOID_ENV'] = 'local'
Mongoid.load!("config/mongoid.yml")

class GemWebMakers
  include Common
  
  def initialize(website)
  @website = website
  end

  def generate(website)
    case
    when website == 'autohome'
      puts 'autohome'
      get_autohome_maker
    when website == 'bitauto'
      puts 'bitauto'
      get_bitauto_maker
    when website == 'car388'
      puts 'car388'
      get_car388_maker
    when website == 'sohu'
      puts 'sohu'

    else
      puts "Oh...! There is nothing to do."
    end
  end
  def get_autohome_makers_from_cars
    puts Maker.where(:from_site => 'autohome').length
    return 
#   Car.where(:from_site => 'autohome').only(:maker).each do |u|
    Car.where(:from_site => 'autohome').distinct(:maker).each do |u|
      puts u  
      Maker.where(:from_site => 'autohome').each do |maker|
        if u == maker.maker_name 
	  puts maker.webname 
          maker.update_attribute(:status, 4)
        end
      end
    end
    Maker.where(:status => 1).each do |m|
      puts "#{m.status}-#{m.webname}"
    end
  end
  
  def run

#    generate(@website)    
    #export_maker_txt(from_site = @website)
    update_maker
    #export_chexing(@website)
    
    #export_maker(@website)
    #get_autohome_makers_from_cars
    #export_maker_txt('autohome')

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
  def get_car388_maker
  
    Model.where(:from_site => @website).delete_all
  
    create_file_to_write(@website)
    url = "http://www.car388.com/api.php/Cars/search?q=ALL"
    doc = fetch_doc(url)
    puts doc.at_xpath("//title").to_s
    doc.xpath("//li[@class='all']/p/a").each do |maker|
      puts maker_name = maker.at_xpath('strong/text()').to_s
      maker_url = maker.at_xpath('@href').to_s
      puts maker_url = "http://www.car388.com#{maker_url}"
      puts desc = maker.at_xpath('text()').to_s.strip
      
      model_doc = fetch_doc(maker_url)
      puts model_doc.xpath('//td[@width="48%"]/a').length
      puts model_doc.xpath('//div[@class="STYLE6"]/font[@color="#FF0000"]/text()').length
      #break
      model_doc.xpath('//tr[@class="tpl_list_01"]').each do |row|
        chexing = row.at_xpath('td/table/tr/td/a[@class="STYLE1"]/text()').to_s.strip
        year = row.at_xpath('td/div/font[@color="#FF0000"]/text()').to_s.strip
        chexing = chexing.gsub(/\t|\n|\r/, '').strip
        puts chexing = chexing.from(3).strip
        year = year.gsub(/\t|\n|\r/, '').strip
        puts year = year.from(3).strip
        
        
        @model = Model.find_or_create_by(:maker_name => maker_name, :chexing_name => chexing, year => year, :from_site => @website)
        @model.year = year
        @model.url = maker_url
        @model.desc = desc
        @model.save

  
        #@file_to_write.puts "#{maker_name}\t#{chexing}\t#{year}"
      end
      #break
      
    end
  end

  def get_autohome_maker
    # open the url
    url = "http://car.autohome.com.cn/zhaoche/pinpai/"
    # get it sid, brand-** ,maker , brand
    doc = fetch_doc(url)
    puts doc.at_xpath("//title").to_s
    doc.xpath("//div[@class='grade_js_top30']").each do |item|
      puts brand_name = item.at_xpath("div/div[@class='grade_js_top33']/a/text()").to_s
      puts brand_url = item.at_xpath("div/div[@class='grade_js_top33']/a/@href").to_s
      puts sid = brand_url.scan(/(?<=price\/).*(?=\.html)/)[0]
      maker_doc = fetch_doc(brand_url)
      maker_doc.xpath('//div[@class="brand_name"]/a').each do |maker|
        webname = maker.at_xpath("text()").to_s.strip
        maker_url = maker.at_xpath("@href").to_s.strip
        back = webname.scan(/(?<=\().*(?=\))/)[0]
        maker_name =  "#{back}#{webname}".strip
        maker_name.gsub!(/\(.*?\)/, '')     

        folder = Pinyin.t(maker_name, splitter: '').downcase.to_s 

        folder = "a_#{folder}"
        puts folder
        save_maker(sid, brand_name, maker_name, webname, brand_url, maker_url, folder, @website)        
      end
    end
  end
  
  def get_bitauto_maker
    Maker.where(from_site: @website).delete_all
    # open the url
    url = "http://car.bitauto.com/brandlist.html"
    # get it sid, brand-** ,maker , brand
    doc = fetch_doc(url)
    puts doc.at_xpath("//title").to_s    
    doc.xpath("//dl[@class='bybrand_list']/dd[@class='b']").each do |brand|
      puts brand_name = brand.at_xpath('div/a/text()').to_s.strip
      brand_url = brand.at_xpath('div/a/@href').to_s.strip
      puts brand_url = "http://car.bitauto.com#{brand_url}"
      #/div[@class='brand_name']/a
      puts '*'*50
      brand.xpath('following-sibling::dd[1]/h2/a').each do |maker|
        puts maker_name = maker.at_xpath('text()').to_s.strip
        maker_num = maker.at_xpath('@href').to_s.strip
        puts maker_url = "http://car.bitauto.com#{maker_num}"
        puts sid = maker_num.gsub('/', '').to_s
        
        folder = Pinyin.t(maker_name, splitter: '').downcase.to_s 
        folder = "b_#{folder}"
        webname = maker_name
        #break
        save_maker(sid, brand_name, maker_name, webname, brand_url, maker_url, folder, @website)
      end
      #break
    end
    
  end
  
  def export_chexing(from_site = 'car388')
    create_file_to_write(from_site)
    @models = Model.where(:from_site => from_site).desc(:maker_name)
    @models.each do |mm|
      @file_to_write.puts "#{mm.maker_name}\t#{mm.chexing_name}\t#{mm.year}\t#{mm.desc}"
    end
  end
  
  def export_maker(from_site)
    create_file_to_write(from_site)
    @makers = Maker.where(:from_site => from_site)
    str = "["
    @makers.each do |maker|
      str += "[\"#{maker.sid}\", \"#{maker.webname}\", \"#{maker.maker_name}\", \"#{maker.folder}\"],\n"
    end
    str += "]"
    @file_to_write.puts str
  end
  
  def export_maker_txt(from_site)
    create_file_to_write(from_site)
    @makers = Maker.where(:from_site => from_site).desc(:webname)
    
    @makers.each do |maker|
      @file_to_write.puts "#{maker.sid}\t#{maker.brand_name}\t#{maker.webname}\t#{maker.maker_name}"
    end
    
    
  end
  
  def create_file_to_write(name = 'file')
    file_path = File.join('.', "#{name}-#{Time.now.to_formatted_s(:number) }.txt")
    @file_to_write = IoFactory.init(file_path)
  end #create_file_to_write

  def fetch_doc(url)
    html_stream = safe_open(url , retries = 3, sleep_time = 0.2, headers = {})
#    begin
#    html_stream.encode!('utf-8', 'gbk', :invalid => :replace) #忽略无法识别的字符
#    rescue StandardError,Timeout::Error, SystemCallError, Errno::ECONNREFUSED #有些异常不是标准异常  
#     puts $!  
#    end
    Nokogiri::HTML(html_stream)
  end

  def open_http(url)
    safe_open(url , retries = 3, sleep_time = 0.2, headers = {})
  end #end of open_http
  
  def save_maker(sid, brand_name, maker_name, webname, brand_url, maker_url, folder,  from_site)
  
    len = Maker.where(:brand_name => brand_name, :webname => webname, :from_site => from_site).length
    
    if len == 0
      puts "#{brand_name}-#{webname}-#{maker_name}"
      @maker = Maker.find_or_create_by(:brand_name => brand_name, :webname => webname, :from_site => from_site)
      
      @maker.sid = sid
      @maker.maker_name = maker_name
      @maker.brand_url = brand_url
      @maker.maker_url = maker_url
      @maker.folder = folder
      @maker.status = 0
      @maker.save  
    end #end of save_chexing 
  end

  def update_maker
    puts @website
    puts Maker.where(:from_site => @website).length
    
#   Car.where(:from_site => 'autohome').only(:maker).each do |u|
    Car.where(from_site: @website).distinct(:maker).each do |u|
      puts u  
      #next
      Maker.where(from_site: @website).each do |maker|
        if u == maker.maker_name 
          puts maker.webname 
          maker.update_attribute(:status, 4)
        end
      end
    end
    #Maker.where(:status => 1).each do |m|
    #  puts "#{m.status}-#{m.webname}"
    #end
  end
end



GemWebMakers.new("bitauto").run
#GemWebMakers.new("car388").run


#GemWebMakers.new().generate("bitauto")
#GemWebMakers.new().generate("sohu")
#GemWebMakers.new().generate("pcauto")


