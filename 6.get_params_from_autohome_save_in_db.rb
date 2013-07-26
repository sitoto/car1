#encoding: UTF-8
require 'mongoid'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'logger'
require 'pp'

Dir.glob("#{File.dirname(__FILE__)}/app/models/*.rb") do |lib|
  require lib
end


ENV['MONGOID_ENV'] = 'dev'

Mongoid.load!("config/mongoid.yml")

class IoFactory
	attr_reader :file
	def self.init file
		@file = file
		if @file.nil?
			puts 'Can Not Init File To Write'
			exit
		end #if
		File.open @file, 'a'
	end     
end #IoFactory

def create_file_to_write
	file_path = File.join('.', "autohome-chery-#{Time.now.to_formatted_s(:number) }.txt")
	@file_to_write = IoFactory.init(file_path)
end #create_file_to_write

create_file_to_write
@cars = Car.all.desc(:created_at)
length = @cars.count

@cars.all.each_with_index do |car, i|
  @num = 0
  next if i < 100
  
	params = []
	
	print "#{i}/#{length} "
	
	puts url = "http://www.autohome.com.cn/spec/#{car.chexing_num}/config.html"
  @file_to_write.puts "#{i}-#{url}"
  
  puts car.chexing
  puts car.chexi
  
	html_stream = open(url).read.strip
	html_stream.encode!('utf-8', 'gbk')
	@doc = Nokogiri::HTML(html_stream)

  if @doc.css('script').length == 6
    
    puts "error"
    @file_to_write.puts "error-#{i}-#{url}"
    next
  end
  
  @doc.css('script').each do |item|
    puts item.to_s.length
  end
  
  str = @doc.css('script')[4].text.to_s
  puts str.length
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

end
