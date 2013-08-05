#encoding: UTF-8
require 'open-uri'
require 'pp'
require "cgi"

r1 = "%u6c7d%u6cb9%u673a"
r2 = "%27Stop%21%27+said+Fred"

r3 = r1.gsub(/\%u([\da-fA-F]{4})/) {|m| [$1].pack("H*").unpack("n*").pack("U*")}

puts r3
puts CGI::unescapeHTML(r1)
puts CGI::unescape(r2)
puts CGI::unescape(r3)
puts URI::unescape(r1)
puts URI::unescape(r2)

