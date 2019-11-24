# frozen_string_literal: true

# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
require 'coveralls'
require 'simplecov'
require 'simplecov-console'
require 'webmock/rspec'

Coveralls.wear!('rails')
SimpleCov.formatter = SimpleCov::Formatter::Console
SimpleCov.start do
  add_filter do |source_file|
    if ARGV.empty?
      false
    else
      origin_file = source_file.filename.gsub('/spec/', '/app/').gsub('_spec.rb', '.rb')
      !SimpleCov.tested_files.include?(origin_file)
    end
  end

  add_filter do |source_file|
    source_file.filename.include?('/event/') || source_file.filename.include?('/controllers/') || source_file.filename.include?('/graphql_model/')
  end
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  Dir['./spec/helpers/*'].map { |a| require a }
  config.include(RequestStub)
  config.include(DatabaseStub)
  config.include(VillageHelper)
  config.include(ScreenHelper)
  config.include(ModelStub)

  config.before :each do |spec|
    tested_file = spec.metadata[:absolute_file_path].gsub('/spec/', '/app/').gsub('_spec.rb', '.rb')
    SimpleCov.register_tested_file(tested_file)

    allow_any_instance_of(Screen::Train).to receive(:train).and_return(nil)
    command = double('send_attack')
    allow(command).to receive(:arrival).and_return(Time.zone.now + 1.hour)
    allow(command).to receive(:origin_report=)
    allow(command).to receive(:store)

    allow_any_instance_of(Screen::Place).to receive(:send_attack).with(anything, anything).and_return(command)
    allow_any_instance_of(Report).to receive(:erase).and_return(nil)

    allow_any_instance_of(Village).to receive(:reload).and_return { |a| binding.pry }

    allow_any_instance_of(Washbullet::Client).to receive(:push_note).and_return(nil)
    allow(Service::AttackDetector).to receive(:run).and_return(nil)

    values = {
      id: BSON::ObjectId('5d56ba9919290b2e9c88210c'),
      world: ENV['STUB_WORLD'],
      username: ENV['STUB_USER'],
      password: ENV['STUB_PASS']
    }

    account = double('account', values)
    allow(Account).to receive(:main).and_return(account)
    allow(account).to receive(:world).and_return ENV['STUB_WORLD']
    allow(account).to receive_message_chain(:player, :points).and_return 3000
    allow(account).to receive_message_chain(:player, :ally).and_return nil
    allow(account).to receive_message_chain(:player, :villages).and_return [
      stub_village('my_001'),
      stub_village('my_002'),
      stub_village('my_003')
    ]

    allow(Screen::AllyContracts).to receive(:new).and_return(OpenStruct.new(
                                                               allies_ids: %w[ally1 ally2]
                                                             ))

    allow(Village).to receive(:my).and_return([
      Village.new(x: 10, y: 10)
    ])

    request_mock_defaults

    Service::StartupTasks.new.fill_units_information
    Service::StartupTasks.new.fill_buildings_information
    # allow(Screen::Place).to receive(:get_place).and_return(double('place'))
  end

  config.before :all do
    clean_db
  end

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # The settings below are suggested to provide a good initial experience
  # with RSpec, but feel free to customize to your heart's content.
  #   # This allows you to limit a spec run to individual examples or groups
  #   # you care about by tagging them with `:focus` metadata. When nothing
  #   # is tagged with `:focus`, all examples get run. RSpec also provides
  #   # aliases for `it`, `describe`, and `context` that include `:focus`
  #   # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  #   config.filter_run_when_matching :focus
  #
  #   # Allows RSpec to persist some state between runs in order to support
  #   # the `--only-failures` and `--next-failure` CLI options. We recommend
  #   # you configure your source control system to ignore this file.
  #   config.example_status_persistence_file_path = "spec/examples.txt"
  #
  #   # Limits the available syntax to the non-monkey patched syntax that is
  #   # recommended. For more details, see:
  #   #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   #   - http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#zero-monkey-patching-mode
  #   config.disable_monkey_patching!
  #
  #   # Many RSpec users commonly either run the entire suite or an individual
  #   # file, and it's useful to allow more verbose output when running an
  #   # individual spec file.
  #   if config.files_to_run.one?
  #     # Use the documentation formatter for detailed output,
  #     # unless a formatter has already been configured
  #     # (e.g. via a command-line flag).
  #     config.default_formatter = "doc"
  #   end
  #
  #   # Print the 10 slowest examples and example groups at the
  #   # end of the spec run, to help surface which specs are running
  #   # particularly slow.
  #   config.profile_examples = 10
  #
  #   # Run specs in random order to surface order dependencies. If you find an
  #   # order dependency and want to debug it, you can fix the order by providing
  #   # the seed, which is printed after each run.
  #   #     --seed 1234
  #   config.order = :random
  #
  #   # Seed global randomization in this process using the `--seed` CLI option.
  #   # Setting this allows you to use `--seed` to deterministically reproduce
  #   # test failures related to randomization by passing the same `--seed` value
  #   # as the one that triggered the failure.
  #   Kernel.srand config.seed
end
