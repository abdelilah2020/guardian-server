# frozen_string_literal: true

ENV['ENV'] ||= 'development'
ENV['RACK_ENV'] = ENV['ENV'] || 'development'

namespace 'guardian' do
  desc 'Run webapp'
  task :server do
    ENV['PORT'] = ENV['PORT'] || '3000'
    sh("ENV=#{ENV['ENV']} bundle exec rackup -p #{ENV['PORT']} config/config.ru")
  end

  desc 'Run worker'
  task :worker do
    ARGV.shift
    queue = ARGV.empty? ? '' : " --queue=#{ARGV[0]}"
    sh("ENV=#{ENV['ENV']} bundle exec ruby ./bin/delayed_job.rb run#{queue}")
  end

  desc 'Run console'
  task :console do
    ARGV.shift
    queue = ARGV.empty? ? '' : " --queue=#{ARGV[0]}"
    sh("ENV=#{ENV['ENV']} bundle exec ruby ./bin/console.rb")
  end
end
