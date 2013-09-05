require 'roar/representer/json'

module CategoryRepresenter
  include Roar::Representer::JSON

  property :id
  property :name
  property :parent_id
  property :parent_name

end