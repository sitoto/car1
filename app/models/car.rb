class Car
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :maker,   type: String
  field :chexi,   type: String
  field :chexing, type: String
  field :year,    type: String
  
  field :chexi_num    #import , http://www.autohome.com.cn/826/ 826 = chexi_num ;  => get the model
  
  field :chexing_num  #import , http://www.autohome.com.cn/spec/1969/  1969 = chexing_num
                      #import , http://www.autohome.com.cn/spec/1969/config.html      ≈‰÷√“≥√Ê
  
                      
                      
  field :pic_url      #import , http://car.autohome.com.cn/pic/series-s1969/826.html  826 = chexi; 1969 = chexing
                      #import , http://car.autohome.com.cn/pic/series-s#{chexing}/#{chexi}.html  826 = chexi; 1969 = chexing
                      
  field :status,  type: String
  field :from_site, type: String
  field :pic_num
  
  embeds_many :pics
  embeds_many :parameters
end
