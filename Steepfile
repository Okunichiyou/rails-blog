# frozen_string_literal: true

require_relative "config/rbs_targets"

target :app do
  signature "sig"

  RBS_TARGET_DIRS.each { |dir| check dir }
end
