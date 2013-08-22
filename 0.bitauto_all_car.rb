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
=end

items =	[["shanghaidazhongsikeda", "上海大众斯柯达", "b_shanghaidazongshikeda"]]

items.each do |sid, maker, folder|
	puts "#{sid}-#{maker}-#{folder}"
	from_site = "bitauto"

	GetCarAndDetail.new(sid, maker, from_site).read_chexi
	GetCarAndDetail.new(sid, maker, from_site).save_pic
	GetCarAndDetail.new(sid, maker, from_site).save_config
	GetCarAndDetail.new(sid, maker, from_site).down_pic(folder)

#	GetCarAndDetail.new(sid, maker, from_site).export_report(folder)
end
