#encoding: UTF-8
# require_relative "common_sohu"
require_relative "common_bitauto"


# status 
# 0 : nothing
# 1 : get chexi
# 2 : get pictures url
# 3 : get config
# 4 : download pictures
# 5 : other
makers = Maker.where(:from_site => 'bitauto', :maker_name => '上汽荣威')

makers.each_with_index do |m, sindex|
	#next if sindex < 3

	sid = m.sid 
	webmaker = m.webname
	maker = m.maker_name
	folder = m.folder
	puts "#{sid}-#{maker}-#{folder}"
	from_site = "bitauto"
	GetCarAndDetail.new(sid,  maker, from_site).down_pic(folder)# if m.status < 4
	puts "#{sindex}============#{maker} finished!"

next


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

	puts "#{sindex}============#{maker} finished!"
end
