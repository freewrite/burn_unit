require 'active_support/core_ext/string/inflections'
require 'backburner'
require 'forwardable'

module BurnUnit

  class << self
    extend Forwardable

    attr_writer :strategy

    def_delegators :strategy, :delete_matched, :reset!
  end


  def self.strategy
    @strategy ||= :climb
    if @strategy.kind_of?(BurnUnit::Strategy)
      return @strategy
    elsif @strategy.kind_of?(String) || @strategy.kind_of?(Symbol)
      return @strategy = materialize_strategy(@strategy).new
    else
      raise "Invalid BurnUnit strategy: #{@strategy}"
    end
  end

  protected

  def self.materialize_strategy(strategy_identifier)
    return "BurnUnit::Strategy::#{strategy_identifier.to_s.titleize}".constantize
  end

end

require 'burn_unit/version'
require 'burn_unit/strategy'
require 'burn_unit/assertions'
