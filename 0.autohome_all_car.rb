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
=end
items = [["brand-12", "北京现代", "a_beijingxiandai"],
	 ["brand-12", "现代(进口)", "a_jinkouxiandai"],
	 ["brand-67", "上海大众斯柯达", "a_shanghaidazongshikeda"],
	 ["brand-67", "斯柯达(进口)", "a_jinkoushidkeda"]]

items.each do |sid, maker, folder|
	puts "#{sid}-#{maker}-#{folder}"
	from_site = "autohome"

	#GetCarAndDetail.new(sid, maker, from_site).read_chexi
	#GetCarAndDetail.new(sid, maker, from_site).save_pic
	#GetCarAndDetail.new(sid, maker, from_site).save_config
	GetCarAndDetail.new(sid, maker, from_site).down_pic(folder)
	#GetCarAndDetail.new(sid, maker, from_site).export_report(folder)

	#GetCarAndDetail.new(sid, maker, from_site).remove_maker
	#GetCarAndDetail.new(sid, maker, from_site).export_report_test(folder)
end
