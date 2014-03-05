class Post
  include Mongoid::Document
  #include Mongoid::Timestamps
  
  field :author, :type => String
  field :created_at, :type => String
  field :level, :type => Integer
  field :my_level, :type => Integer
  field :page_num, :type => Integer
  field :content, :type => String
  field :words_count, :type => Integer
  
  embedded_in :topic
end