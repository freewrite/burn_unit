class BurnUnit::Strategy

  def assert_queued
    raise NotImplementedError
  end


  def assert_queues
    raise NotImplementedError
  end


  def delete_matched
    raise NotImplementedError
  end


  def refute_queued
    raise NotImplementedError
  end


  def refute_queues
    raise NotImplementedError
  end


  def reset!
    raise NotImplementedError
  end

end

require 'burn_unit/strategies/climb'
