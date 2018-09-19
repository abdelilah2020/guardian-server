class Task::BuildInstantTask < Task::Abstract

  belongs_to :village
  include Service::Builder

  def run
    main = Screen::Main.new(village: village.id)
    main.build_instant
    build(village.id, main.reload)
  end
end