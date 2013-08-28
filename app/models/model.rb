class Model
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :chexing_name, :type => String
  field :maker_name, :type => String
  field :year, :type => String

  field :url, :type => String
  field :desc, :type => String
  
  field :status
  
  belongs_to :maker
end