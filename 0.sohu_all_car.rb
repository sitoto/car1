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
=end
items = [ ["1078","广汽丰田", "广汽丰田", "s_guangqifengtian"]]


items.each do |sid, webmaker, maker, folder|
	puts "#{sid}-#{maker}-#{folder}"

	from_site = "sohu"

#	GetCarAndDetail.new(sid, webmaker, maker, from_site).read_chexi
#	GetCarAndDetail.new(sid, webmaker, maker, from_site).save_pic
#	GetCarAndDetail.new(sid, webmaker, maker, from_site).save_config
	GetCarAndDetail.new(sid, webmaker, maker, from_site).down_pic(folder)
#	GetCarAndDetail.new(sid, webmaker, maker, from_site).export_report(folder)
end
