#encoding: UTF-8
require_relative "common_bitauto"

makers = Maker.where(:from_site => 'bitauto')
puts makers.length

makers.each_with_index do |m, mindex|
  sid = m.sid 
  webmaker = m.webname
  maker = m.maker_name
  brand = m.brand_name
  folder = m.folder
  puts "#{mindex}-#{sid}-#{maker}-#{folder}"# if sid.eql?('kairui')
#  next unless sid.eql?('jiangling')
#  next if mindex < 100
 
  from_site = "bitauto"
# do save_config
# 1. initialize
# 2. modify function

#GetCarAndDetail.new(sid, maker, webmaker, brand, from_site).read_chexi
#GetCarAndDetail.new(sid, maker, webmaker, brand, from_site).save_pic  
#  GetCarAndDetail.new(sid, maker, from_site).save_config  
#GetCarAndDetail.new(sid, maker, from_site).down_pic(folder)  

end

