require 'forwardable'

module BurnUnit::Assertions

  extend Forwardable

  def_delegators BurnUnit.strategy, :assert_queued, :assert_queues, :job_matches?, :refute_queued, :refute_queues, :reset!

end
