#encoding: UTF-8
require_relative "common_bitauto"

sid = 'guangqifengtian' #it's path in url ：http://car.bitauto.com/bentian/
maker = "广汽丰田"
folder = "b_guangqifengtian"
from_site = "bitauto"
=begin
GetCarAndDetail.new(sid, maker, from_site).read_chexi
GetCarAndDetail.new(sid, maker, from_site).save_pic
GetCarAndDetail.new(sid, maker, from_site).down_pic(folder)
GetCarAndDetail.new(sid, maker, from_site).save_config
=end
GetCarAndDetail.new(sid, maker, from_site).export_report(folder)

