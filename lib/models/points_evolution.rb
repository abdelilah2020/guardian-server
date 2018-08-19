class PointsEvolution
  include Mongoid::Document
  include Mongoid::Timestamps

  field :ocurrence, type: DateTime, default: -> { Time.now }
  field :current, type: Integer
  field :diference, type: Integer
  field :causes, type: Array
end