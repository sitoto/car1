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
    @brand_num = sid 
    @webmaker = webmaker
    @from_site = from_site
  end
  
  def read_chexi
   puts  url = "http://car.bitauto.com/#{@sid}/"
    @doc = fetch_chexing(url)
    @doc.xpath('//div[@id="seriallist"]/div/dl/dd//b/a').each do |item|
    
      puts chexi = item.at_xpath('text()').to_s.strip
      if item.at_xpath('@title') != nil
        chexi = item.at_xpath('@title').to_s.strip
      end
      
      puts chexi_num = item.at_xpath('@href').to_s.strip.gsub('/', '')
      chexi_url = "http://car.bitauto.com/#{chexi_num}/"
      @doc_chexing = fetch_chexing(chexi_url)
=begin
      # get cars which on sale
      @doc_chexing.xpath('//div[@class="pdL10"]/a[1]').each_with_index do |chexing_link, i|
        chexing = chexing_link.to_s.strip_tag
	year = chexing.split(' ')[0].to_s.strip
        new_chexing = chexing.gsub(year, '').gsub(chexi, '').gsub(" ", '').strip
        chexing_url = chexing_link.at_xpath('@href').to_s.strip
	new_chexi = chexi.gsub(@maker.to_s, '').strip

        puts "#{i}-#{@maker}-#{year}-#{new_chexi}-#{new_chexing}"
        pic_url = "http://car.bitauto.com#{chexing_link.at_xpath('@href').to_s}tupian/"
        chexing_num = chexing_url.split('/')[-1].to_s
        status = 'init'
        from_site = 'bitauto'

        save_chexing(@maker, new_chexi, new_chexing, year, chexi_num, chexing_num, pic_url, @from_site, status = 'init')
      end
=end
      years = []
      first_year = @doc_chexing.at_xpath('//div[@class="class"]//a[2]/@href').to_s.strip
#      @doc_chexing.xpath('//div[@class="class"]//a').each_with_index do |link_year, i|
#       years <<  "http://car.bitauto.com#{link_year.at_xpath('@href')}"
      years << "http://car.bitauto.com#{first_year}"
      @doc_year = fetch_chexing(years[0])
      @doc_year.xpath('//em[@class="h3_spcar"]//a').each do |other_year|
        puts year_txt = other_year.at_xpath('text()').to_s.strip
        next if year_txt == "全部在售"
        puts year = other_year.at_xpath('@href').to_s.strip
        year = year.gsub('#car_list', '')
        years << year
      end
      years.uniq!

#      end
#break
#next
    
      # get cars form year
#      @doc_chexing.xpath('//div[@class="class"]//a').each_with_index do |link_year, i|
      years.each_with_index do |link_year_url, i|
        #next if i == 0
        year = "#{link_year_url.split('/')[-1]}款"  #link_year.at_xpath('text()').to_s.strip

        year_url = link_year_url
        @doc_year = fetch_chexing(year_url)

        @doc_year.xpath('//table[@id = "compare"]/tr/td[1]/a').each do |chexing_link|
          chexing = chexing_link.to_s.strip_tag
	  new_chexing = chexing.gsub(year, '').gsub(chexi, '').gsub(" ", '').strip
          chexing_url = chexing_link.at_xpath('@href').to_s.strip
	  new_chexi = chexi.gsub(@maker.to_s, '').strip

          puts "#{i}-#{@maker}-#{new_chexi}-#{year}-#{new_chexing}"
          pic_url = chexing_link.at_xpath('@href').to_s + "tupian/"
          chexing_num = chexing_url.split('/')[-1].to_s
          status = 'init'
          from_site = 'bitauto'

          save_chexing(@maker, new_chexi, new_chexing, year, chexi_num, chexing_num, pic_url, @from_site, status = 'init')
          
       end
      end
      #puts item.at_xpath('h3/a/text()').to_s.strip.split(' ')[0]
    end
  end

  def run
    
  end
  
  
  def save_pic
    @cars = Car.where(maker: @maker, brand: @brand,  pics: nil, from_site: @from_site).asc(:created_at)

    puts @cars.length
    @cars.each_with_index do |car, i|
      @doc_pic_url = fetch_chexing(car.pic_url)
      puts car.pic_url
      
      have_error = @doc_pic_url.xpath('//div[@class="error_page"]').length
      if have_error == 1
        puts 'no picture'
        puts car.pic_num = 0
        car.save
      else
        puts 'have picture'
        @doc_pic_url.xpath('//h3[@class="pic13_h3"]/span/a').each do |object|
          if object.at_xpath('text()').to_s == '外观'
            puts new_pic_url = object.at_xpath('@href').to_s
            @doc_img = fetch_img(new_pic_url)
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
      #next if c_i < 303
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
  
 
  private  
  def create_file_to_write(name = 'file')
    file_path = File.join('.', "#{name}-#{Time.now.to_formatted_s(:number) }.txt")
    @file_to_write = IoFactory.init(file_path)
  end #create_file_to_write

  def save_chexing(maker, chexi, chexing, year, chexi_num, chexing_num, pic_url, from_site, status = 'init')
   # @car = Car.where(:chexing_num => chexing_num.to_s, :from_site => from_site)
    #return if @car.length > 0
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
    puts "#{@brand}-#{@brand_num}-#{maker}-#{year}-#{chexi}-#{chexing}-saved!"
  end #end of save_chexing 
  


  def download_images(pre_folder, filename, url)
    retries = 2
    sleep_time = 0.22
    begin
      File.open("./#{pre_folder}/#{filename}", "wb") do |saved_file|
        open(url, 'rb') do |read_file|
        saved_file.write(read_file.read)
        end
      end  
    rescue OpenURI::HTTPError, StandardError,Timeout::Error, SystemCallError, Errno::ECONNREFUSED
      puts $! 
      @file_to_write.puts $! 
      retries -= 1  
      if retries > 0  
        sleep sleep_time and retry  
      else  
        #logger.error($!)
        #错误日志
        #TODO Logging..  
      end  
   end
    
  end  #end of download_images
  
  def fetch_chexing(detail_url)
    html_stream = safe_open(detail_url , retries = 3, sleep_time = 0.2, headers = {})
#    begin
#    html_stream.encode!('utf-8', 'gbk', :invalid => :replace) #忽略无法识别的字符
#    rescue StandardError,Timeout::Error, SystemCallError, Errno::ECONNREFUSED #有些异常不是标准异常  
#     puts $!  
#    end
    Nokogiri::HTML(html_stream)
  end  
  def fetch_img(detail_url)
    html_stream = safe_open(detail_url , retries = 3, sleep_time = 0.2, headers = {})
    Nokogiri::HTML(html_stream)
  end
  
end

