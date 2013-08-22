class Maker
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :sid, :type => String
  field :webname, :type => String
  field :folder, :type => String

  field :brand_name, :type => String
  field :brand_url, :type => String
  field :maker_name, :type => String
  field :maker_url, :type => String
  
  field :status

end