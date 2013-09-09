class ClimbStrategyTest < Test::Unit::TestCase

  def setup
    @initial_strategy = BurnUnit.strategy
    BurnUnit.strategy = :climb
  end


  def teardown
    BurnUnit.strategy = @initial_strategy
  end


  def test_assert_queued_with_arguments
    Backburner.enqueue(TestJob)
    assert_queued(TestJob)
    BurnUnit.delete_matched(TestJob)

    Backburner.enqueue(TestJob, [])
    assert_queued(TestJob, [])
    assert_queued(TestJob)
    BurnUnit.delete_matched(TestJob)

    Backburner.enqueue(TestJob, true, 1, 'test')
    assert_queued(TestJob, true, 1, 'test')
    BurnUnit.delete_matched(TestJob)
  end


  def test_assert_queues_matches_correctly
    assert_queues(TestJob) do
      Backburner.enqueue(TestJob, 1)
    end
    BurnUnit.delete_matched(TestJob)

    assert_queues(TestJob, 1) do
      Backburner.enqueue(TestJob, 1)
    end
  end


  def test_climber_raises_an_error_when_beanstalk_url_is_not_set
    strategy = BurnUnit::Strategy::Climb.new

    beanstalk_url = Backburner.configuration.beanstalk_url

    Backburner.configure do |config|
      config.beanstalk_url = nil
    end

    assert_raise RuntimeError do
      strategy.send(:climber)
    end

    Backburner.configure do |config|
      config.beanstalk_url = beanstalk_url
    end
  end


  def test_delete_matched_deletes_matching_jobs
    Backburner.enqueue(TestJob)
    Backburner.enqueue(TestJob, [])
    Backburner.enqueue(TestJob, true, 1, 'test')
    assert_queued(TestJob)
    BurnUnit.delete_matched(TestJob)
    refute_queued(TestJob)
  end


  def test_job_matches_matches_jobs_correctly
    body = {
      'class' => 'TestJob',
      'args' => [],
    }
    job = stub(:body => body)

    strategy = BurnUnit.strategy
    assert strategy.send(:job_matches?, job, TestJob, [])
    refute strategy.send(:job_matches?, job, TestJob, [[]])
    refute strategy.send(:job_matches?, job, TestJob, ['test'])

    body['args'] = ['1', '2']
    assert strategy.send(:job_matches?, job, TestJob, [])
    assert strategy.send(:job_matches?, job, TestJob, ['1', '2'])
    refute strategy.send(:job_matches?, job, TestJob, [1, 2])
    refute strategy.send(:job_matches?, job, TestJob, ['1'])
    refute strategy.send(:job_matches?, job, TestJob, [[]])
    refute strategy.send(:job_matches?, job, TestJob, [['1', '2']])

    body['args'] = [[]]
    assert strategy.send(:job_matches?, job, TestJob, [])
    assert strategy.send(:job_matches?, job, TestJob, [[]])
    refute strategy.send(:job_matches?, job, TestJob, [{}])
  end


  def test_refute_queued_matches_correctly
    Backburner.enqueue(TestJob, [])
    refute_queued(TestJob, '1')
    BurnUnit.delete_matched(TestJob)
    refute_queued(TestJob, 1)

    Backburner.enqueue(TestJob, true, 1, 'test')
    refute_queued(TestJob, true, 1)
    refute_queued(TestJob, true)
    BurnUnit.delete_matched(TestJob)

    refute_queued(TestJob)
  end


  def test_refute_queues_matches_correct_args
    refute_queues(TestJob, 1) do
      Backburner.enqueue(TestJob, 1, 2)
    end

    refute_queues(TestJob, []) do
      Backburner.enqueue(TestJob, [], true)
    end
  end


  def test_refute_queues_is_not_confused_by_existing_jobs
    Backburner.enqueue(TestJob, 1)
    Backburner.enqueue(TestJob, [])
    refute_queues(TestJob) {}
    refute_queues(TestJob, 1) {}
    refute_queues(TestJob, []) {}
  end


  def test_reset_will_clear_all_jobs_from_all_tubes
    Backburner.enqueue(TestJob)
    Backburner.enqueue(OtherTestJob)
    BurnUnit.reset!
    refute_queued(TestJob)
    refute_queued(OtherTestJob)
  end


  def test_reset_will_clear_all_jobs_from_a_single_tube
    Backburner.enqueue(TestJob)
    Backburner.enqueue(OtherTestJob)
    BurnUnit.reset!(TestJob.queue)
    refute_queued(TestJob)
    assert_queued(OtherTestJob)
  end

end
