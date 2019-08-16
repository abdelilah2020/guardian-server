# frozen_string_literal: true

describe Task::StealResourcesTask do
  subject { Task::StealResourcesTask.new }

  before :each do
    @distance = 10
    allow(Property).to receive(:get).with('STEAL_RESOURCES_DISTANCE', 10).and_return @distance

    allow(Account.main).to receive_message_chain(:player, :points).and_return 3000
    allow(Account.main).to receive_message_chain(:player, :ally).and_return nil

    allow(Account.main).to receive_message_chain(:player, :villages).and_return [
      stub_village('my_001'),
      stub_village('my_002'),
      stub_village('my_003')
    ]

    screen = train_screen(build_info: { 'spy' => OpenStruct.new(active: true) })
    allow(Screen::Train).to receive(:new).and_return(screen)
  end

  def stub_village(name, _args = {})
    stub = Village.new(name: name)
    stub
  end

  def stub_target(args = {})
    stub = double('target')
    player = stub_player(args)
    allow(stub).to receive(:distance).with(anything).and_return((@distance / 2).ceil)

    allow(stub).to receive(:player).and_return player
    allow(stub).to receive(:barbarian?).and_return false
    allow(subject).to receive(:target).and_return stub
    stub
  end

  def stub_player(args = {})
    player = double('player')
    points = args[:points] || Account.main.player.points * 0.5
    ally_id = args[:ally_id]

    ally = double('ally')
    allow(ally).to receive(:id).and_return ally_id unless ally_id.nil?

    allow(player).to receive(:ally).and_return ally unless ally_id.nil?
    allow(player).to receive(:points).and_return points
    player
  end

  it 'with strong player' do
    target = stub_target(points: Account.main.player.points * 100)
    target.should_receive(:status=).with('strong')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'with ally player' do
    allow(Account.main).to receive(:player).and_return(stub_player(ally_id: 10))
    target = stub_target(ally_id: 10)
    target.should_receive(:status=).with('ally')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'with far way barbarian village' do
    target = stub_target
    target.should_receive(:player).and_return(nil)
    allow(target).to receive(:distance).with(anything).and_return(@distance + 1)

    target.should_receive(:status=).with('far_away')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end

  it 'with player but without spy research' do
    target = stub_target
    screen = train_screen(build_info: { 'spy' => OpenStruct.new(active: false) })
    allow(Screen::Train).to receive(:new).and_return(screen)

    target.should_receive(:status=).with('waiting_spy_research')
    target.should_receive(:next_event=).with(anything)
    target.should_receive(:save)
    subject.run
  end
end
