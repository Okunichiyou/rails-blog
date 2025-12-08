ENV["RAILS_ENV"] ||= "test"

# SimpleCov must be started before loading application code
if ENV["COVERAGE"]
  require "simplecov"
  require "simplecov-cobertura"

  SimpleCov.start "rails" do
    add_filter "/test/"
    add_filter "/config/"
    add_filter "/vendor/"

    if ENV["CI"]
      formatter SimpleCov::Formatter::CoberturaFormatter
    end
  end
end

require_relative "../config/environment"
require "rails/test_help"
require_relative "support/rbs_trace_setup"

module ActiveSupport
  class TestCase
    # Disable parallelization to make rbs-trace work properly
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
