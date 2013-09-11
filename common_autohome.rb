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
  
  def initialize(sid = "", webmaker ="" , maker = "", brand ="",  from_site ="")
    @sid = sid
    @maker = maker
    @brand = brand
    @brand_num = sid.split('-')[1].to_s 
    @webmaker = webmaker
    @from_site = from_site
  end
  
  def read_chexi
    brand_url = "http://car.autohome.com.cn/price/#{@sid}.html"
    @doc_brand =   fetch_chexing(brand_url)
    return if @doc_brand.nil?

    @doc_brand.xpath('//div[@class="brand_r"]/ul/li').each do |item|
      if item.at_xpath('div/a/text()').to_s == @webmaker
        item.xpath('div[@class="brand_car"]//a').each_with_index do |object, i|

          chexi = object.at_xpath('@title').to_s
          chexi = chexi.split('(')[0].strip
          url = object.at_xpath('@href').to_s
          chexi_num = url.scan(/\d+/)[0]
          #get the chexing's  url 
          chexing_url = "http://www.autohome.com.cn/#{chexi_num}/" #http://www.autohome.com.cn/826/

          @doc_chexing = fetch_chexing(chexing_url)

          # the new rule of autohome website 
          # data:2013-8-6
          # 1.online soon
          @doc_chexing.xpath("//div[@id='speclist10']/ul/li/div[1]/div/p/a[1]").each do |myobj|
            chexing =  myobj.at_xpath('text()').to_s.strip
            year = chexing.split(' ')[0].strip
            chexing = chexing[5..-1].strip
            chexing_num = myobj.at_xpath('@href').to_s.strip.split('/')[2].to_s
            pic_url = "http://car.autohome.com.cn/pic/series-s#{chexing_num}/#{chexi_num}.html"              
            #break
            save_chexing(@maker, chexi, chexing, year, chexi_num, chexing_num, pic_url, @from_site, status = 'init')
          end #end of online soon
          
          #break
          # 2.on sale
          @doc_chexing.xpath("//div[@id='speclist20']/ul/li/div[1]/div/p/a[1]").each do |myobj|
            chexing =  myobj.at_xpath('text()').to_s.strip
            year = chexing.split(' ')[0].strip
            chexing = chexing[5..-1].strip
            chexing_num = myobj.at_xpath('@href').to_s.strip.split('/')[2]
            pic_url = "http://car.autohome.com.cn/pic/series-s#{chexing_num}/#{chexi_num}.html"     
            #break
            save_chexing(@maker, chexi, chexing, year, chexi_num, chexing_num, pic_url, @from_site, status = 'init')
          end  #end of on sale  
          #break
          # 3.off sale
          @doc_chexing.xpath("//div[@id='drop2']//a").each do |myobj|
            year = myobj.at_xpath('text()').to_s.strip
            y = myobj.at_xpath('@data').to_s.strip
            s = chexi_num
            my_url = "http://www.autohome.com.cn/ashx/series_allspec.ashx?s=#{s}&y=#{y}"
            html_stream = open_http(my_url)
            #from json get chexing
            s_json = JSON.parse(html_stream)
            s_json["Spec"].each do |myitem|
              chexing_num = myitem["Id"]
              chexing = myitem["Name"]
              chexing = chexing[5..-1].strip
              pic_url = "http://car.autohome.com.cn/pic/series-s#{chexing_num}/#{chexi_num}.html"
              save_chexing(@maker, chexi, chexing, year, chexi_num, chexing_num, pic_url, @from_site, status = 'init')
            end
          end #end of off sale
          
          # 4. old rule
          if @doc_chexing.xpath("//div[@class='tabwrap']//td[@class='name_d']/a").length == 0
            all_chexing = @doc_chexing.xpath("//select[@class= 'select-carpic-filter']/option").each do |myobj|
              chexing = myobj.at_xpath('text()').to_s.strip
              year = chexing.split(' ')[0].strip
              chexing = chexing[5..-1].strip
              chexing_num =  myobj.at_xpath('@value').to_s.strip
              pic_url = "http://car.autohome.com.cn/pic/series-s#{chexing_num}/#{chexi_num}.html"
              save_chexing(@maker, chexi, chexing, year, chexi_num, chexing_num, pic_url, @from_site, status = 'init')
            end
          else
            all_chexing = @doc_chexing.xpath("//div[@class='tabwrap']//td[@class='name_d']/a")
            all_chexing.each do |myobj|
              chexing =  myobj.at_xpath('@title').to_s.strip
              year = chexing.split(' ')[0].strip
              chexing = chexing[5..-1].strip
              chexing_num = myobj.at_xpath('@href').to_s.strip.split('/')[1]
              pic_url = "http://car.autohome.com.cn/pic/series-s#{chexing_num}/#{chexi_num}.html"
              save_chexing(@maker, chexi, chexing, year, chexi_num, chexing_num, pic_url, @from_site, status = 'init') 
            end
          end #end of old rule

	  #Data 2013-9-10 add autohome's sale.html page,the stopsale'car lost if this year has saleing cars.
	  #add stop sale page's car
          puts chexing_sale_url = "http://www.autohome.com.cn/#{chexi_num}/sale.html" #http://www.autohome.com.cn/826/sale.html
         
          @doc_chexing = fetch_chexing(chexing_sale_url)
	  next if @doc_chexing.nil?

	  @doc_chexing.xpath("//td[@class='name_d']/a").each do |myobj|
	    chexing =  myobj.at_xpath('@title').to_s.strip
            year = chexing.split(' ')[0].strip
            chexing = chexing[5..-1].strip
            chexing_num_str =  myobj.at_xpath('@href').to_s
	    chexing_num = chexing_num_str.to_s.strip.split('/')[1]
	    pic_url = "http://car.autohome.com.cn/pic/series-s#{chexing_num}/#{chexi_num}.html"
            #puts "#{chexi}-#{chexing}-#{year}-#{chexing_num}"
	    save_chexing(@maker, chexi, chexing, year, chexi_num, chexing_num, pic_url, @from_site, status = 'init') 
	  end

                    
        end# end of object
      end #end of if
    end #end of doc_brand
  end #end of read_chexi

  
  def run
    
  end
  
  
  def save_pic
    @cars = Car.where(:maker => @maker, :from_site => @from_site, :status => 'update')
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
    @cars = Car.where(:maker => @maker, :parameters => nil, :from_site => @from_site, :status => 'update').desc(:created_at)
    #@cars = Car.where(:maker => @maker, :from_site => @from_site).desc(:created_at)
    puts length = @cars.count
    #return
    
    @cars.all.each_with_index do |car, i|
      @num = 0
      #next if i < 100
      params = []
      print "#{i}/#{length} "
      puts url = "http://www.autohome.com.cn/spec/#{car.chexing_num}/config.html"
      @file_to_write.puts "#{i}-#{url}"
      html_stream = open_http(url).strip
      html_stream.encode!('utf-8', 'gbk', :invalid => :replace)
      @doc = Nokogiri::HTML(html_stream)
      #@file_to_write.puts @doc.to_s
      #break
      if @doc.css('script').length < 7 
        
        puts "error"
        @file_to_write.puts "error-#{i}-#{url}"
        next
      end
      
      @doc.css('script').each do |item|
        puts item.to_s.length
      end
      
      str = @doc.css('script')[6].text.to_s
      puts "the script's length #{str.length}"
      next if str.length < 2000
      #break  
      #替换规则-单行
      # update 2013-9-5 add the 2 lines to delete the first 
      str.gsub!(/var levelId.*;/, '')
      str = str.strip
      # 'var '  => '["' 行头
      str.gsub!('var ' , '{"')
      # ' = '  => '":"' 中
      str.gsub!(' = '  , '" : ')
      # '};'  => '],'  行尾
      str.gsub!('};' , '}} ,')


      str = "{\"root\" : [#{str}{\"end\" : \"yes\"}]}"

      #str = '{"sub" : "100"},'

      #str = "{\"root\" : [#{str}{\"end\" : \"yes\"}]}"
              
#puts str
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
                      #puts 
                      name = item["name"]
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
    @cars = Car.where(:maker => @maker,  :from_site => @from_site, :status => 'update').desc(:created_at)
    #@cars = Car.all.asc(:created_at)
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
        
        puts item.url
         if File.exist?("./#{pre_folder}/#{filename}") 
	  puts "exist!"
	else
          download_images(pre_folder, filename, item.url)
	end
       

        #break
      end
      #break
    end    
  end
  def export_report_test(name = "report")
    create_file_to_write(name)
    @cars = Car.where(:maker => @maker, :from_site => @from_site).desc(:chexi_num)
    @cars.all.each_with_index do |car, i|
      @file_to_write.puts "#{i}\t#{car.maker}\t#{car.chexi}\t#{car.chexi_num}\t#{car.year}\t#{car.chexing}\t#{car.chexing_num}\t#{car.pic_num}\t#{car.from_site}\t#{car.status}"
    end
  end
  def remove_maker
    @cars = Car.where(:maker => @maker, :from_site => @from_site)
    @cars.delete
  end
  
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
    @file_to_write.puts @title.join('$')

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
  def create_file_to_write(name = 'file')
    file_path = File.join('.', "#{name}-#{Time.now.to_formatted_s(:number) }.txt")
    @file_to_write = IoFactory.init(file_path)
  end #create_file_to_write
  
  def download_images(pre_folder, filename, url)
    	sleep_time = 0.34
        retries = 2
      File.open("./#{pre_folder}/#{filename}", "wb") do |saved_file|
	begin
          open(url) do |read_file|
            saved_file.write(read_file.read)
          end
        rescue StandardError,Timeout::Error, SystemCallError, Errno::ECONNREFUSED 
          puts $!  
          retries -= 1  
          if retries > 0  
            sleep sleep_time and retry  
          else  
 	  #logger.error($!)
	  #错误日志
          #TODO Logging..  
          end  
        end
      end

    
  end  #end of download_images
  
  def fetch_chexing(detail_url)
    @doc_chexing = nil
    html_stream = safe_open(detail_url , retries = 5, sleep_time = 0.32, headers = {})
    return nil if html_stream.nil?
#    begin
    html_stream.encode!('utf-8', 'gbk', :invalid => :replace) #忽略无法识别的字符
#    rescue StandardError,Timeout::Error, SystemCallError, Errno::ECONNREFUSED #有些异常不是标准异常  
#     puts $!  
#    end
    @doc_chexing = Nokogiri::HTML(html_stream)
  end

  def open_http(url)
    safe_open(url , retries = 5, sleep_time = 0.43, headers = {})
  end #end of open_http

  def update_chexing(maker, chexi, chexing, year, chexi_num, chexing_num, pic_url, from_site, status = 'update')
 #   @car = Car.where(:chexing_num => chexing_num.to_s, :from_site => from_site)
 #   return if @car.length > 0
 #   @car = Car.create(:chexing_num => chexing_num.to_s, :from_site => from_site)
    @car = Car.find_or_create_by(:chexing_num => chexing_num.to_s, :from_site => from_site)
  
    @car.brand = @brand
    @car.brand_num = @brand_num
    @car.maker = maker
    @car.chexi = chexi
    @car.chexing = chexing
    @car.year = year
    @car.chexi_num = chexi_num.to_s
    @car.pic_url = pic_url
    @car.status = status

    @car.save  
  end #end of update_chexing 
  
  def save_chexing(maker, chexi, chexing, year, chexi_num, chexing_num, pic_url, from_site, status = 'init')
#    @car = Car.where(:chexing_num => chexing_num.to_s, :from_site => from_site)
#    return if @car.length > 0
#    @car = Car.create(:chexing_num => chexing_num.to_s, :from_site => from_site)
    @car = Car.find_or_create_by(:chexing_num => chexing_num.to_s, :from_site => from_site)
  
    @car.brand = @brand
    @car.brand_num = @brand_num
                    
    @car.maker = maker
    @car.chexi = chexi
    @car.chexing = chexing
    @car.year = year
    @car.chexi_num = chexi_num.to_s
    @car.pic_url = pic_url
    @car.status = status

    @car.save  
    puts "#{@brand}-#{@brand_num}-#{maker}-#{chexi}-#{chexing}-#{year}-saved!"
  end #end of save_chexing 
  
end

