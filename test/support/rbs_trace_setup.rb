# frozen_string_literal: true

require "rbs/trace"

# app/配下の.rbファイルからapp/controllersを除外
paths = Dir.glob("#{Dir.pwd}/app/**/*.rb").reject { |path| path.include?("app/controllers") || path.include?("app/jobs") }
trace = RBS::Trace.new(paths: paths)
trace.enable

Minitest.after_run do
  trace.disable
  trace.save_comments
end
