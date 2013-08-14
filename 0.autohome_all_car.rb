#encoding: UTF-8
require_relative "common_autohome"

sid = 'brand-14' #it's h3/a 's  id
maker = "东风本田"
folder = "a_dongfengbentian"
from_site = "autohome"

#GetCarAndDetail.new(sid, maker, from_site).read_chexi
#GetCarAndDetail.new(sid, maker, from_site).save_pic
#GetCarAndDetail.new(sid, maker, from_site).down_pic(folder)
GetCarAndDetail.new(sid, maker, from_site).save_config
GetCarAndDetail.new(sid, maker, from_site).export_report(folder)

#GetCarAndDetail.new(sid, maker, from_site).remove_maker
#GetCarAndDetail.new(sid, maker, from_site).export_report_test(folder)
