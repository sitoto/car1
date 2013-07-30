class Pic
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, :type => String
  field :url, :type => String
  field :note, :type => String
  field :num

  embedded_in :car
end