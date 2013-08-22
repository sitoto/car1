class Maker
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :sid, :type => String
  field :webname, :type => String
  field :name, :type => String
  field :folder, :type => String

  field :brand, :type => String
  
  field :status

end