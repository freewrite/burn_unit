require 'test_helper'

class BurnUnitTest < Test::Unit::TestCase

  def setup
    @initial_strategy = BurnUnit.strategy
  end


  def teardown
    BurnUnit.strategy = @initial_strategy
  end


  def test_strategy_defaults_to_mock
    assert_kind_of BurnUnit::Strategy, BurnUnit.strategy
    assert_kind_of BurnUnit::Strategy::Mock, BurnUnit.strategy
  end


  def test_strategy_can_be_configured
    BurnUnit.strategy = :climb
    assert_kind_of BurnUnit::Strategy, BurnUnit.strategy
    assert_kind_of BurnUnit::Strategy::Climb, BurnUnit.strategy

    BurnUnit.strategy = :mock
    assert_kind_of BurnUnit::Strategy::Mock, BurnUnit.strategy
  end


  def test_an_error_is_raised_if_strategy_is_invalid
    BurnUnit.strategy = :magic
    assert_raise NameError do
      BurnUnit.strategy
    end
  end

end
