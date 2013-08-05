#encoding: UTF-8
require 'mongoid'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pp'
require "cgi"
require_relative "common"

Dir.glob("#{File.dirname(__FILE__)}/app/models/*.rb") do |lib|
  require lib
end
ENV['MONGOID_ENV'] = 'local'
Mongoid.load!("config/mongoid.yml")

class GetCarAndDetail
  include Common
  
  def initialize(sid = "", maker = "", from_site ="")
    @sid = sid
    @maker = maker
    @from_site = from_site
  end
  
  def read_chexi
    url = "http://db.auto.sohu.com/subbrand_#{@sid}/"
    url = "http://db.auto.sohu.com/model-list-brand-all.shtml"
    
    @doc = fetch_chexing(url)
    status = 'init'
    @doc.xpath('//div[@class="blk_meta"]/div[@class="meta_con"]').each do |m_item|
      
      next if m_item.at_xpath("div[@class='brand_name']/a/text()").to_s.strip != @maker.to_s
      m_item.xpath('ul/li//a[@class="name"]').each do |item|
#        next
        puts chexi = item.at_xpath('text()').to_s.strip
        
        if item.at_xpath('@title') != nil
          chexi = item.at_xpath('@title').to_s.strip
        end
        chexi_url = item.at_xpath('@href').to_s.strip
        chexi_url = "http://db.auto.sohu.com#{chexi_url}"
        chexi_num = chexi_url.split('/')[-1].split('_')[-1]

        fetch_chexing(chexi_url)
        puts @doc_chexing.at_xpath('//title').to_s

        
        @doc_chexing.xpath("//div[@id='trm_data']/table").each do |object|
          if object.at_xpath('@id').nil?
            puts "show"
            #puts object.to_s
            #break
            object.xpath("tr/td[@class = 'ftdleft']").each do |item|
              puts chexing = item.xpath("a/text()")[0].to_s
              puts chexing_num = item.xpath("a/@href")[0].to_s
              puts chexing_num = chexing_num.scan(/\d+/)[0].to_s
              #http://db.auto.sohu.com/model_2251/photo_m120004.shtml

              puts year = chexing[0..5].strip
              puts chexing = chexing[5..-1].strip
              puts pic_url = "http://db.auto.sohu.com/model_#{chexi_num}/photo_m#{chexing_num}.shtml"
              

              @car = Car.find_or_create_by(:chexing_num => chexing_num, :from_site => @from_site)
              @car.maker = @maker
              @car.chexi = chexi
              @car.chexing = chexing
              @car.year = year
              @car.chexi_num = chexi_num
              @car.chexing_num = chexing_num
              @car.pic_url = pic_url
              @car.status = status
              @car.save
            end
          else
            puts "no #{object.at_xpath('@id')}"
            puts object.xpath("tr/td[@class = 'ftdleft']").length
            #break
            object.xpath("tr/td[@class = 'ftdleft']").each do |item|
              chexing = item.xpath("a/text()")[0].to_s.strip
              
              if object.at_xpath('@id') 
                year = object.at_xpath('@id')
                year = year.to_s.gsub('tms_t_','')
                year = "#{year}款"       
              else
                puts year = chexing[0..5].strip
                puts chexing = chexing[5..-1].strip        
              end
              
              puts chexing_num = item.xpath("a/@href")[0].to_s
              puts chexing_num = chexing_num.scan(/\d+/)[0].to_s
              
              puts pic_url = "http://db.auto.sohu.com/model_#{chexi_num}/photo_m#{chexing_num}.shtml"
              
              @car = Car.find_or_create_by(:chexing_num => chexing_num, :from_site => @from_site)
              @car.maker = @maker
              @car.chexi = chexi
              @car.chexing = chexing
              @car.year = year
              @car.chexi_num = chexi_num
              @car.chexing_num = chexing_num
              @car.pic_url = pic_url
              @car.status = status
              @car.save    
            end
          end
        end #end of object
        next
        #当前展现的车型
        @doc_chexing.xpath("//table[@class = 'b jsq']//td[@class = 'ftdleft']").each do |item|
          puts chexing = item.xpath("a/text()")[0].to_s
          puts chexing_num = item.xpath("a/@href")[0].to_s
          puts chexing_num = chexing_num.scan(/\d+/)[0].to_s
          #http://db.auto.sohu.com/model_2251/photo_m120004.shtml
          
          puts year = chexing[0..5]
          puts chexing = chexing[5..-1].strip
          puts pic_url = "http://db.auto.sohu.com/model_#{chexi_num}/photo_m#{chexing_num}.shtml"
          
          @car = Car.find_or_create_by(:chexing_num => chexing_num, :from_site => @from_site)
          @car.maker = @maker
          @car.chexi = chexi
          @car.chexing = chexing
          @car.year = year
          @car.chexi_num = chexi_num
          @car.chexing_num = chexing_num
          @car.pic_url = pic_url
          @car.status = status
          @car.save
            
          
        end	

        #当前 隐藏的车型
        puts @doc_chexing.xpath("//table[@class = 'hid']").length
        @doc_chexing.xpath("//table[@class = 'hid']").each do |object|

          puts object.xpath("tr/td[@class = 'ftdleft']").length
          #break
          object.xpath("tr/td[@class = 'ftdleft']").each do |item|
            chexing = item.xpath("a/text()")[0].to_s.strip
            
            if object.at_xpath('@id') 
              year = object.at_xpath('@id')
              year = year.to_s.gsub('tms_t_','')
              year = "#{year}款"       
            else
              puts year = chexing[0..5].strip
              puts chexing = chexing[5..-1].strip        
            end
            
            puts chexing_num = item.xpath("a/@href")[0].to_s
            puts chexing_num = chexing_num.scan(/\d+/)[0].to_s
            
            puts pic_url = "http://db.auto.sohu.com/model_#{chexi_num}/photo_m#{chexing_num}.shtml"
            
            @car = Car.find_or_create_by(:chexing_num => chexing_num, :from_site => @from_site)
            @car.maker = @maker
            @car.chexi = chexi
            @car.chexing = chexing
            @car.year = year
            @car.chexi_num = chexi_num
            @car.chexing_num = chexing_num
            @car.pic_url = pic_url
            @car.status = status
            @car.save

          end
        end
        #break
      end #end of m_item
      #puts item.at_xpath('h3/a/text()').to_s.strip.split(' ')[0]
    end #end of @doc.xpath
  end

  def run
    
  end
  
  
  def save_pic
  #http://m4.auto.itc.cn/car/800/51/12/Img2321251_800.jpg
  #http://m4.auto.itc.cn/car/150/51/12/Img2321251_150.jpg
    @cars = Car.where(:maker => @maker, :from_site => @from_site)
    puts @cars.length
    @cars.each_with_index do |car, i|
      fetch_chexing(car.pic_url)
      puts car.pic_url
      
      puts have_error = @doc_chexing.xpath('//a[@class="thisA"]').length

      if have_error == 0
        puts 'no picture'
        puts car.pic_num = 0
        car.save
      else
        puts 'have picture'
        imgs = []
        @doc_chexing.xpath('//div[@class="bd"][1]//img').each_with_index do |object, j|
          puts picture_url = object.at_xpath('@src').to_s
          puts picture_url = picture_url.gsub('150', 'f')
          #puts picture_url = picture_url.gsub('150', '800')
          puts name = "#{car.maker}_#{car.chexi}_#{car.year}_#{car.chexing}_#{j+1}"
              
          puts "#{i}-#{j+1}"          
          category = object.at_xpath('@alt').to_s
          @pic = Pic.new
          @pic.name = name
          @pic.url = picture_url
          @pic.note = category
          @pic.num = j
          imgs << @pic
        end
        car.pics =  imgs
        puts car.pic_num = imgs.length
        car.save 
        print "saved"
        end
      end
      
  end

  def save_config
  #http://db.auto.sohu.com/PARA/TRIMDATA/trim_data_101893.json
  #http://db.auto.sohu.com/PARA/TRIMDATA/trim_data_101893.json
    create_file_to_write('config_save')
    #@cars = Car.where(:maker => @maker).desc(:created_at)
    @cars = Car.where(:maker => @maker, :from_site => @from_site).desc(:created_at)
    puts length = @cars.count
    @cars.each_with_index do |car , i|
      puts "#{i}/#{length}"
      #next if i < 
      puts url = "http://db.auto.sohu.com/model_#{car.chexi_num}/trim_#{car.chexing_num}.shtml"

      @doc = fetch_chexing(url)
      car.parameters = nil
      @details = []    
      
      id_strs = []
      id_names = []
      id_values = []
      puts @doc.at_css("h1").text
      @doc.xpath("//table[@id='trimArglist']/tbody/tr").each do |item|
        id_str = item.at_xpath("@id").to_s
        if id_str[0..4] == "SIP_C"
          id_strs << id_str
          id_name = item.at_xpath("th[@class='th1']//text()").to_s.strip_sohu_txt_tag.gsub('：', '')
          id_names << id_name
        end
      end
      next if id_strs.length != id_names.length
      puts json_url = "http://db.auto.sohu.com/PARA/TRIMDATA/trim_data_#{car.chexing_num}.json"
      json_html = safe_open(json_url , retries = 3, sleep_time = 0.2, headers = {})
      #json_html.encode!('utf-8', 'gbk', :invalid => :replace)
      
      json_html = json_html.gsub("'", '"').gsub('%d7', '*')
      #puts json_html
      #break
      s_json = JSON.parse(json_html)
      
      id_strs.each_with_index do |ids, j|
        code_str = s_json[ids]
        if code_str.nil?
          #puts ""
          id_values << ""
        else
          #puts "#{CGI::unescape(code_str)}"
          r3 = code_str.gsub(/\%u([\da-fA-F]{4})/) {|m| [$1].pack("H*").unpack("n*").pack("U*")}
          r3 = r3.gsub('\%d', '*')
          id_values << CGI::unescape(r3)
        end
      end
      id_strs.each_with_index do |id, k|
        puts name = id_names[k]
        puts value = id_values[k]
        #value.encode!('utf-8',  :invalid => :replace)
        
        
        para = Parameter.new()
        para.name = name
        para.value = value
        para.num = k
        para.category = id
        @details << para
      end
      #搞定。。。明天继续存数据库
      car.parameters = @details
      car.save
      print " #{url} saved"
#break      

    end
  end
  
  def down_pic(pre_folder)
    if(File.exist?(pre_folder))
      puts "folder '#{pre_folder}' structure already exist!"
    else
      Dir.mkdir(pre_folder) #if folder not exist,then creat it.
    end  
  
    create_file_to_write('pic_download')
    @cars = Car.where(:maker => @maker, :from_site => @from_site)
    puts @cars.length
    @cars.each_with_index do |car , c_i|
      #next if c_i < 199
      car.pics.each_with_index do |item, p_i|
        #next if p_i < 1 && c_i < 1
        puts "#{c_i} -#{p_i}"
        @file_to_write.puts "#{c_i} -#{p_i}"
        houzui = item.url.strip.from(-4)
        puts filename = item.name + houzui
        filename.gsub!("/", "_")
        filename.gsub!("\\", "_")
        filename.gsub!("*", "_")
        filename.gsub!('"', "_")
        puts item.url
        
        download_images(pre_folder, filename, item.url)
        #break
      end
      #break
    end    
  end
  
  def export_report

    create_file_to_write('report')
    @cars = Car.where(:maker => @maker, :from_site => @from_site).desc(:created_at)
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
    @file_to_write.puts @title.join('$')

    @cars.all.each_with_index do |car, i|
      print "#{i} "
      str = ""
      @title2.each do |title|  
        car.parameters.each do |param|
        
          if (title == param.name && title != "车身颜色")
            txt_str = param.value
            txt_str = CGI::unescape(txt_str)
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
  def create_file_to_write(name = 'file')
    file_path = File.join('.', "#{name}-#{Time.now.to_formatted_s(:number) }.txt")
    @file_to_write = IoFactory.init(file_path)
  end #create_file_to_write
  
  def fetch_chexing(detail_url)
    @doc_chexing = nil
    html_stream = safe_open(detail_url , retries = 3, sleep_time = 0.2, headers = {})
#    begin
    html_stream.encode!('utf-8', 'gbk', :invalid => :replace) #忽略无法识别的字符
#    rescue StandardError,Timeout::Error, SystemCallError, Errno::ECONNREFUSED #有些异常不是标准异常  
#     puts $!  
#    end
    @doc_chexing = Nokogiri::HTML(html_stream)
  end  
  
  def download_images(pre_folder, filename, url)
    begin
      File.open("./#{pre_folder}/#{filename}", "wb") do |saved_file|
        open(url, 'rb') do |read_file|
        saved_file.write(read_file.read)
        end
      end  
    rescue OpenURI::HTTPError, StandardError,Timeout::Error, SystemCallError, Errno::ECONNREFUSED
      puts $! 
      @file_to_write.puts $! 
    end
    
  end
  
  def fetch_img(detail_url)
    @doc_img = nil
    html_stream = safe_open(detail_url , retries = 3, sleep_time = 0.2, headers = {})
    @doc_img = Nokogiri::HTML(html_stream)
  end
  
  
end

#http://db.auto.sohu.com/subbrand_1073/
sid = '1073' #it's bitauto 's  id
maker = "上海大众"
folder = "s_shanghaidazong"
from_site = "sohu"

#GetCarAndDetail.new(sid, maker, from_site).read_chexi
#GetCarAndDetail.new(sid, maker, from_site).save_pic
#GetCarAndDetail.new(sid, maker, from_site).down_pic(folder)
GetCarAndDetail.new(sid, maker, from_site).save_config
GetCarAndDetail.new(sid, maker, from_site).export_report

