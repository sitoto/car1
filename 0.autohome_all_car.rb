#encoding: UTF-8
require_relative "common_autohome"
=begin
sid = 'brand-14' 
#brand_url = "http://car.autohome.com.cn/price/#{@sid}.html"
maker = "东风本田"
folder = "a_dongfengbentian"
sid = 'brand-14' 
maker = "广汽本田"
folder = "a_guangqibentian"

items = [["brand-12", "北京现代", "北京现代", "a_beijingxiandai"],
	 ["brand-12","现代(进口)", "进口现代", "a_jinkouxiandai"],
	 ["brand-67", "上海大众斯柯达", "上海大众斯柯达", "a_shanghaidazongshikeda"],
	 ["brand-67", "斯柯达(进口)", "进口斯柯达", "a_jinkoushidkeda"]]
items = [ ["brand-12","现代(进口)", "进口现代", "a_jinkouxiandai"],
	 ["brand-67", "斯柯达(进口)", "进口斯柯达", "a_jinkoushidkeda"]]
=end
items = [["brand-3", "一汽丰田", "一汽丰田", "a_yiqifengtian"],
	 ["brand-3", "广汽丰田", "广汽丰田", "a_guangqifengtian"]]
# status 
# 0 : nothing
# 1 : get chexi
# 2 : get pictures url
# 3 : get config
# 4 : download pictures
# 5 : other
makers = Maker.where(:from_site => 'autohome', :maker_name => '上汽集团', :brand_name => '荣威')
puts makers[1].folder

makers.each do |m|
	sid = m.sid 
	webmaker = m.webname
	maker = m.maker_name
	folder = m.folder
	puts "#{sid}-#{maker}-#{folder}"
	from_site = "autohome"

	#GetCarAndDetail.new(sid, webmaker, maker, from_site).read_chexi #if m.status < 1
#	m.update_attribute(:status, 1) if m.status < 1

#	GetCarAndDetail.new(sid, webmaker, maker, from_site).save_pic #if m.status < 2
#	m.update_attribute(:status, 2) if m.status < 2

#	GetCarAndDetail.new(sid, webmaker, maker, from_site).save_config #if m.status < 3
#	m.update_attribute(:status, 3) if m.status < 3

	GetCarAndDetail.new(sid, webmaker, maker, from_site).down_pic(folder) #if m.status < 4
#	m.update_attribute(:status, 4) if m.status < 4

#	GetCarAndDetail.new(sid, webmaker, maker, from_site).export_report(folder)

	#GetCarAndDetail.new(sid, webmaker, maker, from_site).remove_maker
	#GetCarAndDetail.new(sid, webmaker, maker, from_site).export_report_test(folder)
	break
end
