require 'coveralls'
Coveralls.wear!

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

BEANSTALK_ADDRESS = ENV['BEANSTALK_ADDRESS'] || 'beanstalk://localhost'
BEANSTALK_ADDRESSES = ENV['BEANSTALK_ADDRESSES'] || BEANSTALK_ADDRESS

require 'test/unit'
require 'mocha/setup'
require 'debugger'
require 'burn_unit'

Test::Unit::TestCase.send(:include, BurnUnit::Assertions)

class TestJob
  def self.perform(arg1 = nil, arg2 = nil, arg3 = nil); end
  def self.queue
    return self.name
  end
end

class OtherTestJob < TestJob; end


Backburner.configure do |config|
  config.beanstalk_url    = BEANSTALK_ADDRESSES
  config.tube_namespace   = 'burn_unit.test'
  config.respond_timeout  = 120
  config.default_worker   = Backburner::Workers::Simple
  config.primary_queue    = 'TestJob'
end
