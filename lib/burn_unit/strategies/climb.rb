require 'stalk_climber'

class BurnUnit::Strategy::Climb < BurnUnit::Strategy

  TEST_TUBE = 'burn_unit.test'

  attr_writer :test_tube

  def assert_queued(job_class, *args)
    queued_assertion(:assert, job_class, args)
  end


  def assert_queues(job_class, *args, &block)
    queues_assertion(:assert, job_class, args, &block)
  end


  def delete_matched(job_class, *args)
    climber.each do |job|
     job.delete if job_matches?(job, job_class, args)
    end
  end


  def refute_queued(job_class, *args)
    queued_assertion(:refute, job_class, args)
  end


  def refute_queues(job_class, *args, &block)
    queues_assertion(:refute, job_class, args, &block)
  end


  def reset!(tube = nil)
    climber.each do |job|
      next unless tube.nil? || Backburner::Job.expand_tube_name(tube) == job.tube
      job.delete
    end
  end


  def test_tube
    return @test_tube || TEST_TUBE
  end

  protected

  def climber
    return @climber unless @climber.nil?
    unless beanstalk_url = Backburner.configuration.beanstalk_url
      raise "Backburner beanstalk_url has not been configured!"
    end
    return @climber = StalkClimber::Climber.new(beanstalk_url, test_tube)
  end


  def job_matches?(job, expected_class, expected_args)
    return false unless job.body['class'] == expected_class.to_s
    return expected_args.empty? ? true : job.body['args'] == expected_args
  end


  def queued_assertion(assertion_method, job_class, args)
    found = BurnUnit.climber.detect { |job| job_matches?(job, job_class, args) }
    is_refute = assertion_method == :refute
    public_send(assertion_method, found, "Assertion failed: #{is_refute ? 'Found' : 'No'} job queued with class of #{job_class} and args: [#{args.join(', ')}]#{"\n#{found.inspect}" if is_refute}")
  end


  def queues_assertion(assertion_method, job_class, args, &block)
    min_ids = BurnUnit.climber.max_job_ids
    yield
    max_ids = BurnUnit.climber.max_job_ids
    found = false
    min_ids.each do |connection, min_id|
      testable_ids = (min_id..max_ids[connection]).to_a
      found = connection.fetch_jobs(testable_ids).compact.detect { |job| job_matches?(job, job_class, args) }
      break if found
    end
    is_refute = assertion_method == :refute
    public_send(assertion_method, found, "Assertion failed: #{is_refute ? 'Found' : 'No'} job queued with class of #{job_class} and args: [#{args.join(', ')}]#{"\n#{found.inspect}" if is_refute}")
  end

end
