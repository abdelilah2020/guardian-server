# frozen_string_literal: true

class Task::StealResourcesTask < Task::Abstract

  runs_every 10.minutes
  
  def run
    Service::Report.sync
  	steal_candidates.map do |distance,candidates,target|
  		binding.pry
  	end
  end

  def steal_candidates
    current_player = Account.main.player
    current_ally = current_player.ally
    current_points = current_player.points

    Village.targets.in(status: ['strong','ally',nil]).update_all(status: 'not_initialized')


    strong_player = Player.gte(points: current_points*0.6).pluck(:id) - [current_player.id]
    Village.targets.in(player_id: strong_player).update_all(status: 'strong')

    if !current_ally.nil?
      ally_players = Player.where(ally_id: current_ally.id).pluck(:id)
      Village.targets.in(player_id: ally_players).update_all(status: 'ally')
    end

    result = Village.targets.lte(next_event: Time.now).to_a + Village.targets.in(next_event: nil).to_a

    sort_by_priority(result)

  end

  def sort_by_priority(targets)
    villages = Account.main.player.villages
    distances = targets.map do |target|
      villages = villages.select{|a| target.distance(a) <= 20 }
      villages = villages.sort{|a,b| target.distance(a) <=> target.distance(b) }

      unless villages.empty?
        [
          villages.first.distance(target),
          villages,
          target
        ]
      end
    end

    distances.compact.sort{|a,b| a.first <=> b.first }
  end


end
