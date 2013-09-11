#encoding: UTF-8
require_relative "common_bitauto"

=begin
#sid  is  path in url ：http://car.bitauto.com/#{sid}/

sid = 'tianjinyiqifengtian' 
maker = "一汽丰田"
folder = "b_yiqifengtian"
sid = 'guangqifengtian'
maker = "广汽丰田"
folder = "b_guangqifengtian"

#items = [["tianjinyiqifengtian", "一汽丰田", "b_yiqifengtian"]]#,
items =	[["guangqifengtian", "广汽丰田", "b_guangqifengtian"],
	 ["beijingxiandai", "北京现代", "b_beijingxiandai"],
	 ["xiandai", "进口现代", "b_jinkouxiandai"],
	 ["sikeda", "进口斯柯达", "b_jinkoushidkeda"]]

items =	[["shanghaidazhongsikeda", "上海大众斯柯达", "b_shanghaidazongshikeda"]]
=end

makers = Maker.where(:from_site => 'bitauto', :maker_name => '上海通用雪佛兰', :brand_name => '雪佛兰')
puts makers.length

makers.each do |m|
	sid = m.sid 
	webmaker = m.webname
	maker = m.maker_name
	folder = m.folder
	puts "#{sid}-#{maker}-#{folder}"
	from_site = "bitauto"

#	GetCarAndDetail.new(sid, maker, from_site).read_chexi
	GetCarAndDetail.new(sid, maker, from_site).save_pic  

	GetCarAndDetail.new(sid, maker, from_site).save_config  

	GetCarAndDetail.new(sid, maker, from_site).down_pic(folder)  
	
end
return
Maker.where(:from_site => 'bitauto', :status => 3).each do |m|
	sid = m.sid 
	maker = m.maker_name
	folder = m.folder
	puts "#{sid}-#{maker}-#{folder}"
	from_site = "bitauto"

	GetCarAndDetail.new(sid, maker, from_site).read_chexi if m.status < 1
	m.update_attribute(:status, 1) if m.status < 1

	GetCarAndDetail.new(sid, maker, from_site).save_pic  if m.status < 2
	m.update_attribute(:status, 2) if m.status < 2 

	GetCarAndDetail.new(sid, maker, from_site).save_config  if m.status < 3
	m.update_attribute(:status, 3) if m.status < 3 

	GetCarAndDetail.new(sid, maker, from_site).down_pic(folder)  if m.status < 4
	m.update_attribute(:status, 4) if m.status < 4


#	GetCarAndDetail.new(sid, maker, from_site).export_report(folder)
end
