#encoding: UTF-8
require_relative "common_sohu"
=begin
sid = '1078' 
#it's bitauto 's  id :#http://db.auto.sohu.com/subbrand_1073/
maker = "广汽丰田"
folder = "s_guangqifengtian"
sid = '1077'
maker = '一汽丰田'

#url = "http://db.auto.sohu.com/model-list-brand-all.shtml"
items = [["1104","北京现代", "北京现代", "s_beijingxiandai"]]

items = [["1103","进口现代", "进口现代", "s_jinkouxiandai"],
	 ["1071","上海大众斯柯达", "上海大众斯柯达", "s_shanghaidazongsikeda"]]
items = [ ["1070","进口斯柯达", "进口斯柯达", "s_jinkousikeda"]]
items = [ ["1078","广汽丰田", "广汽丰田", "s_guangqifengtian"]]
=end
# status 
# 0 : nothing
# 1 : get chexi
# 2 : get pictures url
# 3 : get config
# 4 : download pictures
# 5 : other
# puts Car.where(:from_site => 'sohu').length
# return
# Car.where(:from_site => 'sohu', :parameters => nil).each do |m|
# print "#{m.id} "
# end
# return
# Maker.where(:from_site => 'sohu', :maker_name => "一汽-大众").each do |m|
Maker.where(:from_site => 'sohu').each do |m|

	sid = m.sid 
	webmaker = m.webname
	maker = m.maker_name
	folder = m.folder
	puts "#{sid}-#{maker}-#{folder}"
	from_site = "sohu"

#	GetCarAndDetail.new(sid, webmaker, maker, from_site).read_chexi if m.status < 1
#	m.update_attribute(:status, 1) if m.status < 1

#	GetCarAndDetail.new(sid, webmaker, maker, from_site).save_pic if m.status < 2
#	m.update_attribute(:status, 2) if m.status < 2

#	GetCarAndDetail.new(sid, webmaker, maker, from_site).save_config  # if m.status < 3
#	m.update_attribute(:status, 3) if m.status < 3

	GetCarAndDetail.new(sid, webmaker, maker, from_site).down_pic(folder)# if m.status < 4
#	m.update_attribute(:status, 4) if m.status < 4

#	GetCarAndDetail.new(sid, webmaker, maker, from_site).export_report(folder)
	#GetCarAndDetail.new(sid, webmaker, maker, from_site).remove_maker
	#GetCarAndDetail.new(sid, webmaker, maker, from_site).export_report_test(folder)
end
