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
  
  def initialize(sid = "shanghaidazhong", maker = "无", from_site ="bitauto")
    @sid = sid
    @maker = maker
    @from_site = from_site
  end
  
  def read_chexi
    url = "http://car.bitauto.com/#{@sid}/"
    @doc = fetch_chexing(url)
   
    @doc.xpath('//div[@id="seriallist"]/dl/dd//b/a').each do |item|
    
      puts chexi = item.at_xpath('text()').to_s.strip
      if item.at_xpath('@title') != nil
        chexi = item.at_xpath('@title').to_s.strip
      end
      
      puts chexi_num = item.at_xpath('@href').to_s.strip.gsub('/', '')
      chexi_url = "http://car.bitauto.com/#{chexi_num}/"
      fetch_chexing(chexi_url)
      puts @doc_chexing.at_xpath('//title').to_s
      @doc_chexing.xpath('//div[@class="class"]//a').each_with_index do |link_year, i|
        #next if i == 0
        puts year =link_year.at_xpath('text()').to_s.strip
        next if year == "全部在售"
        puts year_url = "http://car.bitauto.com#{link_year.at_xpath('@href')}"
        fetch_chexing(year_url)
        puts @doc_chexing.at_xpath('//title').to_s

        @doc_chexing.xpath('//table[@id = "compare"]/tr/td[1]/a').each do |chexing_link|
          chexing = chexing_link.to_s.strip_tag
          chexing_url = chexing_link.at_xpath('@href').to_s.strip
          puts "#{i}-#{@maker}-#{chexi}-#{year}-#{chexing}\t#{chexing_url}"
          puts pic_url = chexing_link.at_xpath('@href').to_s + "tupian/"
          puts chexing_num = chexing_url.split('/')[-1]
          status = 'init'
          from_site = 'bitauto'
          
          @car = Car.find_or_create_by(:chexing_num => chexing_num, :from_site => from_site)
          @car.maker = @maker
          @car.chexi = chexi
          @car.chexing = chexing[5..-1].strip
          @car.year = year
          @car.chexi_num = chexi_num
          @car.chexing_num = chexing_num
          @car.pic_url = pic_url
          @car.status = status
          @car.from_site = from_site
          @car.save
        end
      end
      #puts item.at_xpath('h3/a/text()').to_s.strip.split(' ')[0]
    end
  end

  def run
    
  end
  
  
  def save_pic
    @cars = Car.where(:maker => @maker, :from_site => @from_site)
    puts @cars.length
    @cars.each_with_index do |car, i|
      fetch_chexing(car.pic_url)
      puts car.pic_url
      
      have_error = @doc_chexing.xpath('//div[@class="error_page"]').length
      if have_error == 1
        puts 'no picture'
        puts car.pic_num = 0
        car.save
      else
        puts 'have picture'
        @doc_chexing.xpath('//h3[@class="pic13_h3"]/span/a').each do |object|
          if object.at_xpath('text()').to_s == '外观'
            puts new_pic_url = object.at_xpath('@href').to_s
            fetch_img(new_pic_url)
            imgs = []
            @doc_img.xpath('//ul[@class="pic_t_box pic_150100 pic13_150100"]/li/a').each_with_index do |item, j|
              break if j > 7
              
              puts "#{i}-#{j+1}"
              puts picture_url = item.at_css('img').attr('src').to_s
              puts name = "#{car.maker}_#{car.chexi}_#{car.year}_#{car.chexing}_#{j+1}"
              
              category = item.at_css('img').attr('alt').to_s
              back = picture_url.from(-4)
              picture_url = picture_url.to(-5) + '2' + back              
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
          end
        end
      end
        
      
      
      #break if have_error == 0
      
      
    end
  end

  def save_config
    create_file_to_write('config_save')
    #@cars = Car.where(:maker => @maker).desc(:created_at)
    @cars = Car.where(:maker => @maker, :from_site => @from_site).desc(:created_at)
    puts length = @cars.count
    @cars.each_with_index do |car , i|
      puts "#{i}/#{length}"
      #next if i < 
      url = "http://car.bitauto.com/#{car.chexi_num}/#{car.chexing_num}/"

      @doc = fetch_chexing(url)
      puts @doc.at_css("h1").text
      car.parameters = nil
      @details = []

      @doc.xpath('//div[@class = "line_box car_config"]/table/tbody/tr').each_with_index do |item, ii|
        puts "#{i}/#{@total} - #{ii} "
        [
        ["th[1]/text()" , "td[1]"],
        ["th[2]/text()" , "td[2]"],
        ].each do |name, value|
          n = item.at_xpath(name).to_s
          v = item.at_xpath(value).to_s.strip_tag.strip

          unless n.eql?("")
            #puts "#{n} \t #{v}"
            para = Parameter.new()
            para.name = n
            para.value = v
            @details << para
          end
        end

      end
      car.parameters = @details
      car.save
      print "  saved"
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
  def fetch_img(detail_url)
    @doc_img = nil
    html_stream = safe_open(detail_url , retries = 3, sleep_time = 0.2, headers = {})
    @doc_img = Nokogiri::HTML(html_stream)
  end
  
  
end


