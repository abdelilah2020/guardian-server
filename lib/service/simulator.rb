# frozen_string_literal: true

class Service::Simulator
  include Logging

  def self.run(attack, defence: Troop.new, wall: 0, moral: 100)
    key = (attack.to_a + defence.to_a + [wall,moral]).join(',')

    logger.info("Running simulator for #{attack}")

    result = SimulatorResult.where(key: key).first
    if result.nil?
      screen = Screen::Simulator.new
      screen.simulate(attack, defence, wall, moral)
      win = screen.atk_looses.total.zero?
      result = SimulatorResult.new(key: key, win: win)
      result.save
    end

    return result.win
  end
end
