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


items.each do |sid, webmaker, maker, folder|
	puts "#{sid}-#{maker}-#{folder}"
	from_site = "autohome"

#	GetCarAndDetail.new(sid, webmaker, maker, from_site).read_chexi
#	GetCarAndDetail.new(sid, webmaker, maker, from_site).save_pic
#	GetCarAndDetail.new(sid, webmaker, maker, from_site).save_config
	GetCarAndDetail.new(sid, webmaker, maker, from_site).down_pic(folder)
	#GetCarAndDetail.new(sid, webmaker, maker, from_site).export_report(folder)

	#GetCarAndDetail.new(sid, webmaker, maker, from_site).remove_maker
	#GetCarAndDetail.new(sid, webmaker, maker, from_site).export_report_test(folder)
end
