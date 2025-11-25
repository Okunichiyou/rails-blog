# frozen_string_literal: true

require "rbs/trace"

trace = RBS::Trace.new
trace.enable

Minitest.after_run do
  trace.disable
  trace.save_comments
end
