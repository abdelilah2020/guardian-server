# frozen_string_literal: true

class Player
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :points, type: Integer
  field :rank, type: Integer

  has_many :villages
  belongs_to :account, optional: true
  belongs_to :ally, optional: true
end