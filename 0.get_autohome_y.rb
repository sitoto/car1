require 'mechanize'
require 'pp'
require 'mongoid'
require 'rubygems'
require 'nokogiri'
require "chinese_pinyin"
require_relative "common"

Dir.glob("#{File.dirname(__FILE__)}/app/models/*.rb") do |lib|
  require lib
end
ENV['MONGOID_ENV'] = 'saidan'
Mongoid.load!("config/mongoid.yml")

class GetAutohomeY
  include Common
  def initialize
    @firsturl = 'http://y.autohome.com.cn/shaidan/'
  end

  
  # 获取列表
  def getarticle
  1.upto(8).each do |i|
    url = "http://y.autohome.com.cn/shaidan/?sc=0&subsc=0&city=0&order=1&ps=80&p=#{i}"
      doc = fetch_doc(url)
      doc.xpath('//div[@class="dcard"]').each do |item|
        
        puts tag = item.at_xpath('span[@class="tags"]/text()').to_s.strip
        puts burl = item.at_xpath('div[@class="noa"]/a/@href').to_s.strip
        
        puts title =  item.at_xpath('div[@class="nob"]/a/text()').to_s.strip
        puts click_num = item.at_xpath('div[@class="noc"]/span[1]/text()').to_s.strip
        puts post_num = item.at_xpath('div[@class="noc"]/span[2]/text()').to_s.strip
        
        article = Article.find_or_create_by(from_url: burl)
        article.title = title
        article.tags = tag
        article.hits = click_num
        article.posts_count = post_num
        article.save
        
      end
    end
  end

  def gettopic
    @articles  = Article.where(:class_name => '')
    @articles.each_with_index do |art, i|
      puts "id: #{i}"
      puts art.title
      puts topic_url = art.from_url
      doc = fetch_doc(topic_url)
      puts doc.at_xpath('//title').to_s
      puts title = doc.at_xpath('//div[@id="consnav"]/span[4]/text()').to_s
      puts author = doc.at_xpath('//div[@class="conleft fl"]/ul[1]/li[1]/a/text()').to_s
      puts published_at = doc.at_xpath('//span[@xname="date"][1]/text()').to_s
      puts class_name = doc.at_xpath('//a[@id="a_bbsname"]/text()').to_s
      puts page_num = doc.at_xpath('//span[@class="fs"][1]/@title').to_s.split(' ')[1]
      
      
      art.class_name = class_name
      art.pages_count = page_num
      art.save
      if art.pages_count
        max_num = art.pages_count 
      else
        max_num = 1
      end
      1.upto(max_num).each do |i|
        next_url = topic_url.gsub('-1.html', "-#{i}.html")
        topic = Topic.find_or_create_by(url: next_url)
        topic.article = art
        topic.title = title
        topic.author = author
        topic.published_at = published_at
        topic.page_num = i

        topic.save
      end

    end
    
  
  end
  
  def getposts
    topics = Topic.where(:title.ne => '', :status.ne => 1)
    puts topics.length
    

    topics.each_with_index do |topic, i|
      puts url = topic.url
      topic.posts = []
      posts = []      
 
      doc = fetch_doc(url)
      doc.xpath('//div[@class="clearfix contstxt"]').each_with_index do  |item, j|
        puts "j:#{j}"
        post = Post.new()
        puts  author =  item.at_xpath('div[@class="conleft fl"]/ul[1]/li[1]/a/text()').to_s.strip
        puts published_at = item.at_xpath('div[@class="conright fl"]/div[@class="rconten"]/div[1]/span[@xname="date"]/text()').to_s.strip
        puts level =  item.at_xpath('div[@class="conright fl"]/div[@class="rconten"]/div[1]/div/a[@class="rightbutlz"]/@rel').to_s.strip
        puts content = item.at_xpath('div//div[@xname="content"]/div[@class="w740"]').to_s
        
        post.author = author
        post.level = level
        post.my_level = j
        post.created_at = published_at
        post.content = content
        post.page_num = topic.page_num
        topic.posts << post
      end
      topic.status = 1
      topic.save
   
      agent = Mechanize.new
      page = agent.get url
      #page.search('//div[@class="clearfix contstxt"]').each_with_index do |item, k|
      #  puts k
      #  puts author =  item.at_xpath('div[@class="conleft fl"]/ul[1]/li[1]/a/text()').to_s.strip
      #end
      

      #pp page.images
      #url ='http://club.autohome.com.cn/bbs/thread-c-0-27225033-1.html'
      #image_url = 'http://y0.autoimg.cn/vendor/215/201401/27/p_17040196878.jpg'
      #page.images_with(:src => /jpg\Z/).each do |img|
      page.images_with(:src => /userphotos/).each do |img|
        img.fetch.save
      end
      break if i > 3     
    end

  end
  
  
  def fetch_doc(url)
    html_stream = safe_open(url , retries = 3, sleep_time = 0.2, headers = {})
    begin
    html_stream.encode!('utf-8', 'gbk', :invalid => :replace) #忽略无法识别的字符
    
    #html_stream.force_encoding("gbk")
    #html_stream.encode!("utf-8")
    html_stream.encode!("utf-8",  :undef => :replace, :replace => "?", :invalid => :replace)
    rescue StandardError,Timeout::Error, SystemCallError, Errno::ECONNREFUSED #有些异常不是标准异常  
     puts $!  
    end
    Nokogiri::HTML(html_stream)
  end

  def open_http(url)
    safe_open(url , retries = 3, sleep_time = 0.2, headers = {})
  end #end of open_http
  
end

GetAutohomeY.new().getposts()