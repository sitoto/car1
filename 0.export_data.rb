#encoding: UTF-8
require 'mongoid'
require 'rubygems'
require 'pp'
require_relative "common"

Dir.glob("#{File.dirname(__FILE__)}/app/models/*.rb") do |lib|
  require lib
end
ENV['MONGOID_ENV'] = 'dataserver'
Mongoid.load!("config/mongoid.yml")

class GetCarAndDetail
  include Common
  
  def initialize(maker = "", from_site ="")
    @maker = maker
    @from_site = from_site
  end

  
  def export_report(name = "report")
    puts "#{name} go...."
    create_file_to_write(name)
    if "" == @from_site
      @cars = Car.where(:maker => @maker).desc(:chexi_num)
    else
      @cars = Car.where(:maker => @maker, :from_site => @from_site).desc(:chexi_num)    
    end
    
    
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
      #@title2.sort!
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
end
maker = "进口丰田"
folder = "yiqifengtian"



GetCarAndDetail.new(maker, "sohu").export_report("sohu")
GetCarAndDetail.new(maker, "autohome").export_report("autohome")
GetCarAndDetail.new(maker, "bitauto").export_report("bitauto")
GetCarAndDetail.new(maker).export_report("all")

