#encoding: UTF-8
require_relative "common_sohu"

sid = '1078' #it's bitauto 's  id :#http://db.auto.sohu.com/subbrand_1073/
maker = "广汽丰田"
folder = "s_guangqifengtian"
from_site = "sohu"
=begin
GetCarAndDetail.new(sid, maker, from_site).read_chexi
GetCarAndDetail.new(sid, maker, from_site).save_pic
GetCarAndDetail.new(sid, maker, from_site).down_pic(folder)
GetCarAndDetail.new(sid, maker, from_site).save_config
=end
GetCarAndDetail.new(sid, maker, from_site).export_report(folder)
