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

class GetCarAndDetail
  include Common
  
  def initialize(sid = "brand_1", maker = "无")
    @sid = sid
    @maker = maker
  end
  
  def read_chexi
    file_str = ""
    File.open("autohome_car_model.html","r") do |file|
      while line  = file.gets
        file_str += line
      end
    end

    @doc = Nokogiri::HTML(file_str)
    
    @doc.xpath('//ul/li').each do |item|
      if item.at_xpath("h3/a/@id").to_s == @sid
        puts "That's it#{item.at_xpath('h3/a/text()').to_s}"
        
        item.xpath('div/dl/dd').each_with_index do |object, i|
          if i < 11   # the top 11 is  shanghaidazong
            
            chexi = object.at_xpath('a/text()').to_s.strip
            puts chexi = chexi.split(' ')[0].strip
            url = object.at_xpath('a/@href').to_s.strip
            puts chexi_num = url.scan(/\d+/)[0]
            
            #get the chexing's  url 
            puts chexing_url = "http://www.autohome.com.cn/#{chexi_num}/" #http://www.autohome.com.cn/826/
            fetch_chexing(chexing_url)

            #break
            if @doc_chexing.xpath("//div[@class='tabwrap']//td[@class='name_d']/a").length == 0
              all_chexing = @doc_chexing.xpath("//select[@class= 'select-carpic-filter']/option").each do |myobj|
                puts chexing = myobj.at_xpath('text()').to_s.strip
                puts year = chexing.split(' ')[0].strip
                puts chexing = chexing[5..-1].strip
                puts chexing_num =  myobj.at_xpath('@value').to_s.strip
                puts pic_url = "http://car.autohome.com.cn/pic/series-s#{chexing_num}/#{chexi_num}.html"
                @car = Car.find_or_create_by(:chexing_num => chexing_num)
                
                @car.maker = @maker
                @car.chexi = chexi
                @car.chexing = chexing
                @car.year = year
                @car.chexi_num = chexi_num
                @car.chexing_num = chexing_num
                @car.pic_url = pic_url
                @car.status = 'init'
                @car.from_site = 'autohome'
                @car.save
              end
            else
              all_chexing = @doc_chexing.xpath("//div[@class='tabwrap']//td[@class='name_d']/a")
              all_chexing.each do |myobj|
                puts chexing =  myobj.at_xpath('@title').to_s.strip
                puts year = chexing.split(' ')[0].strip
                puts chexing = chexing[5..-1].strip
                puts chexing_num = myobj.at_xpath('@href').to_s.strip.split('/')[1]
                puts pic_url = "http://car.autohome.com.cn/pic/series-s#{chexing_num}/#{chexi_num}.html"
                @car = Car.find_or_create_by(:chexing_num => chexing_num)
                
                @car.maker = @maker
                @car.chexi = chexi
                @car.chexing = chexing
                @car.year = year
                @car.chexi_num = chexi_num
                @car.chexing_num = chexing_num
                @car.pic_url = pic_url
                @car.status = 'init'
                @car.from_site = 'autohome'
                @car.save                
              end
            end
            

            
          end
          
        end
          
        
      end
      
      #puts item.at_xpath('h3/a/text()').to_s.strip.split(' ')[0]
    end
  end

  def run
    
  end
  
  
  def save_pic
    @cars = Car.where(:maker => @maker)
    puts @cars.length
    @cars.each do |car|
      fetch_chexing(car.pic_url)
      puts car.pic_url
      imgs = []
      
      @doc_chexing.xpath("//div[@class='r_tit']//img/@src").each_with_index do |img, j|
        break if j > 9
        @pic = Pic.new
        @pic.name = "#{car.maker}_#{car.chexi}_#{car.year}_#{car.chexing}_#{j+1}"
        img = img.to_s.gsub('s_' , '')
        @pic.url = img
        imgs << @pic
      end
      
      car.pics =  imgs
      puts car.pic_num = imgs.length
      car.save
      
    end
  end

  def save_config
    create_file_to_write('config_save')
    #@cars = Car.where(:maker => @maker).desc(:created_at)
    @cars = Car.where(:maker => @maker, :parameters => nil).desc(:created_at)
    puts length = @cars.count
    #return
    
    @cars.all.each_with_index do |car, i|
      @num = 0
      #next if i < 100
      params = []
      print "#{i}/#{length} "
      puts url = "http://www.autohome.com.cn/spec/#{car.chexing_num}/config.html"
      @file_to_write.puts "#{i}-#{url}"
      html_stream = open(url).read.strip
      html_stream.encode!('utf-8', 'gbk', :invalid => :replace)
      @doc = Nokogiri::HTML(html_stream)
      #@file_to_write.puts @doc.to_s
      #break
      if @doc.css('script').length == 6
        
        puts "error"
        @file_to_write.puts "error-#{i}-#{url}"
        next
      end
      
      @doc.css('script').each do |item|
        puts item.to_s.length
      end
      
      str = @doc.css('script')[5].text.to_s
      puts "the script's length #{str.length}"
      #break  
      #替换规则-单行
      # 'var '  => '["' 行头
      str.gsub!('var ' , '{"')
      # ' = '  => '":"' 中
      str.gsub!(' = '  , '" : ')
      # '};'  => '],'  行尾
      str.gsub!('};' , '}} ,')


      str = "{\"root\" : [#{str}{\"end\" : \"yes\"}]}"

      #str = '{"sub" : "100"},'

      #str = "{\"root\" : [#{str}{\"end\" : \"yes\"}]}"
              

      s_json = JSON.parse(str)

      s_json["root"].each do |item|
        item.each do |key , value|
          puts key
          if (key == "config" || key == "option")
            puts value["result"]["paramtypeitems"].length  if key == "config" #分组
            puts value["result"]["configtypeitems"].length  if key == "option" #分组
              groups = value["result"]["paramtypeitems"] if key == "config" 
              groups = value["result"]["configtypeitems"] if key == "option" 
              
              groups.each do |g_value|
                g_value.each do |g_key, sub_g_value|
                  puts @category = sub_g_value if g_key == "name"
                  #break
                  if g_key == "paramitems" || g_key == "configitems"
                    sub_g_value.each do |item|
                      puts name = item["name"]
                      item["valueitems"].each do |i_value|
                        if car.chexing_num.to_s == i_value['specid'].to_s
                          #puts i_value['value']
                          @num += 1
                          @para = Parameter.new
                          @para.name = name
                          @para.value = i_value['value']
                          @para.category = @category
                          @para.num = @num
                          
                          params << @para
                          
                        end
                      end
                    end
                    #
                    
                  end
         
                  
                end
              end
          end
        end

      end
      
      car.parameters =  params
      car.save
      puts "save"
    end
  end
  
  def down_pic(pre_folder)
    if(File.exist?(pre_folder))
      puts "folder '#{pre_folder}' structure already exist!"
    else
      Dir.mkdir(pre_folder) #if folder not exist,then creat it.
    end  
  
    create_file_to_write('pic_download')
    @cars = Car.all.asc(:created_at)
    puts @cars.length
    @cars.each_with_index do |car , c_i|
      #next if c_i < 255
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
        File.open("./#{pre_folder}/#{filename}", "wb") do |saved_file|
          open(item.url, 'rb') do |read_file|
          saved_file.write(read_file.read)
          end
        end
        #break
      end
      #break
    end    
  end
  
  def export_report

    create_file_to_write('report')
    @cars = Car.where(:maker => @maker).desc(:created_at)
    length = @cars.count
    @title = []

    @title = ["品牌","车系", "年款", "名称", "图片前缀","张数", "来源"]

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
      qianzui = "#{car.maker}_#{car.chexi}_#{car.year}"
      @file_to_write.puts "#{car.maker}\t#{car.chexi}\t#{car.year}\t#{car.chexing}\t#{qianzui}\t#{car.pic_num}\t#{car.from_site}#{str}"
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
#    html_stream.encode!('utf-8', 'gbk', :invalid => :replace) #忽略无法识别的字符
#    rescue StandardError,Timeout::Error, SystemCallError, Errno::ECONNREFUSED #有些异常不是标准异常  
#     puts $!  
#    end
    @doc_chexing = Nokogiri::HTML(html_stream)
  end
  
  
end

sid = 'brand_1' #it's h3/a 's  id
maker = "上海大众"
folder = "shanghaidazong"

#GetCarAndDetail.new(sid, maker).read_chexi
#GetCarAndDetail.new(sid, maker).save_pic
#GetCarAndDetail.new(sid, maker).down_pic(folder)
#GetCarAndDetail.new(sid, maker).save_config
#GetCarAndDetail.new(sid, maker).export_report

