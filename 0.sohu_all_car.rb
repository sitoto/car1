#encoding: UTF-8
require_relative "common_sohu"
=begin
sid = '1078' 
#it's bitauto 's  id :#http://db.auto.sohu.com/subbrand_1073/
maker = "广汽丰田"
folder = "s_guangqifengtian"
=end
sid = '1077'
maker = '一汽丰田'
folder = "s_yiqifengtian"

from_site = "sohu"


GetCarAndDetail.new(sid, maker, from_site).read_chexi
GetCarAndDetail.new(sid, maker, from_site).save_pic
GetCarAndDetail.new(sid, maker, from_site).down_pic(folder)
GetCarAndDetail.new(sid, maker, from_site).save_config
=begin
GetCarAndDetail.new(sid, maker, from_site).export_report(folder)
=end
