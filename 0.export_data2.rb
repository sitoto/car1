﻿#encoding: UTF-8
require 'mongoid'
require 'rubygems'
require 'pp'
require_relative "common"

Dir.glob("#{File.dirname(__FILE__)}/app/models/*.rb") do |lib|
  require lib
end
ENV['MONGOID_ENV'] = 'dataserver2'
#ENV['MONGOID_ENV'] = 'local'
#ENV['MONGOID_ENV'] = 'test'
Mongoid.load!("config/mongoid.yml")

class GetCarAndDetail
  include Common
  
  def initialize(maker = "", from_site ="")
    @maker = maker
    @from_site = from_site
  end

  
  def update_export_report(name = "report")
    puts "#{name} go...."
    create_file_to_write(name)
    if "" == @from_site
      @cars = Car.where(:from_site => @from_site, :chexing_num.with_type => 16)
    else
      @cars = Car.where(:from_site => @from_site, :chexing_num.with_type => 16)  
      # {$type : 2} it means string
      # {$type : 16} it means int 16bit
      
    end
    @cars.each do |car|
      car.update_attribute(:chexing_num , car.chexing_num.to_s)
    end
    
    puts length = @cars.count
    return
    @title2 = []

    @title1 = ["num", "品牌","车系", "年款", "名称", "图片前缀","张数", "来源"]

    @cars.all.each_with_index do |car, i|
      next if car.chexing_num.is_a? Numeric
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
      @file_to_write.puts "#{car.chexing_num}\t#{car.maker}\t#{car.chexi}\t#{car.year}\t#{car.chexing}\t#{qianzui}\t#{car.pic_num}\t#{car.from_site}\t#{str}"
      #break
    end    
  
  end
    
  
  def export_report(name = "report")
    puts "#{name} go...."
    create_file_to_write(name)
=begin    
    if "" == @from_site
      @cars = Car.where(:from_site => @from_site, :chexing_num.with_type => 16)
    else
      @cars = Car.where(maker: @maker, from_site: @from_site)  
      # {$type : 2} it means string
      # {$type : 16} it means int 16bit
      
    end
=end
    @cars = Car.where( from_site: 'bitauto').in(maker: ['宝骏', '五菱']);     
    database_export
  
  end

  def database_export

    puts length = @cars.count
#    return
    @title2 = []

    @title1 = ["num",  "品牌","车系", "年款", "名称", "图片前缀","张数", "来源"]

    @cars.all.each_with_index do |car, i|
      #next if car.chexing_num.is_a? Numeric
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
    #@file_to_write.puts @title.join('$')
    @file_to_write.puts @title.join("\t")

    @cars.all.each_with_index do |car, i|
      print "#{i} "
      str = ""
      @title2.each do |title|  
        car.parameters.each do |param|
        
          if (title == param.name)# && title != "车身颜色")
            txt_str = param.value.gsub(%r[<[^>]*>], '').gsub(/\t|\n|\r/, ' ')
            txt_str = txt_str.gsub(/             .*?(     |$)/, '')
            #txt_str = CGI::unescape(txt_str)
            #txt_str.color_str_to_line
            str << txt_str
          end
        end
        str << "\t"
        
      end
      qianzui = "#{car.maker}_#{car.chexi}_#{car.year}_#{car.chexing}"
      @file_to_write.puts "#{car.chexing_num}\t#{car.maker}\t#{car.chexi}\t#{car.year}\t#{car.chexing}\t#{qianzui}\t#{car.pic_num}\t#{car.from_site}\t#{str}"
      #break
    end    
  end
  
  def export_maker_txt(from_site)
    create_file_to_write(from_site)
    @makers = Maker.all
    
    @makers.each do |maker|
      @file_to_write.puts "#{maker.sid}\t#{maker.brand_name}\t#{maker.webname}\t#{maker.maker_name}\t#{maker.from_site}"
    end
  end
  
  def export_cars_brand_empty
    cars = Car.where(brand: nil, from_site: 'autohome')
    cars.each_with_index do |car|
      puts "#{car.maker}-#{car.chexi}-#{car.chexi_num}-#{car.chexing}-#{car.chexing_num}-#{car.year}"
    end
  end
  
  def export_cars_parameter_empty
    create_file_to_write('autohome')
    cars = Car.where(from_site: 'autohome')
    cars.each_with_index do |car|
      @file_to_write.puts "#{car.brand}\t#{car.maker}\t#{car.chexi}\t#{car.chexi_num}\t#{car.chexing}\t#{car.chexing_num}\t#{car.year}"
    end
  end
  
  def delete_repeat
    i = 0
    chexing_nums = Car.where(:from_site => @from_site).distinct(:chexing_num)
    chexing_nums.each do |num|
      newcars = Car.where(:from_site => @from_site, :chexing_num => num.to_s)
      
      if newcars.length > 1
        #puts newcars.length
        i += 1
      end
      
    end
    puts "#{@from_site}'s repeat item  #{i}"
  end
 
  private  
  def create_file_to_write(name = 'file')
    file_path = File.join('.', "#{name}-#{Time.now.to_formatted_s(:number) }.txt")
    @file_to_write = IoFactory.init(file_path)
  end #create_file_to_write
end

maker = "荣威"
GetCarAndDetail.new(maker, "autohome").export_cars_parameter_empty
return
maker = "荣威"
maker = "上汽荣威"
maker = "宝骏"
GetCarAndDetail.new(maker, "autohome").export_maker_txt("bitauto")
#GetCarAndDetail.new(maker, "sohu").export_report("sohu")

#maker = "上海通用雪佛兰"
#GetCarAndDetail.new(maker, "bitauto").export_report("bitauto")

#导出 brand为空的数据
#GetCarAndDetail.new(maker, "bitauto").export_cars_brand_empty






#GetCarAndDetail.new(maker, "autohome").export_maker_txt("autohome")

#GetCarAndDetail.new().export_report
#GetCarAndDetail.new(maker, "bitauto").export_report("bitauto")
#GetCarAndDetail.new(maker, "sohu").export_report("sohu")
#GetCarAndDetail.new(maker).export_report("all")

