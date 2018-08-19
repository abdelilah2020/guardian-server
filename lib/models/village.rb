# frozen_string_literal: true

class Village
  include Mongoid::Document
  include AbstractCoordinate
  include Mongoid::Timestamps

  field :name, type: String
  field :points, type: Integer

  field :status, type: String
  field :next_event, type: DateTime

  belongs_to :player, optional: true
  embeds_many :evolution, class_name: 'PointsEvolution'

  scope :targets, -> { not_in(player_id: [ Account.main.player.id ]) }

  has_many :reports, inverse_of: :target

  before_save do |news|
    if evolution.empty?
      evolution << PointsEvolution.new(current: points, diference: 0, causes: ['startup'])
    else
      diference = self.points - evolution.last.current
      unless diference.zero?
        evolution << PointsEvolution.new(current: points, diference: diference)
      end
    end
  end

  def latest_valid_report
    Report.where(target: self, read: false).nin(resources: [nil]).order(ocurrence: 'desc').first
  end

  def to_s
    "#{x}|#{y}"
  end
end