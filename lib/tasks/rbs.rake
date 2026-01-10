return unless Rails.env.development?

require "rbs_rails/rake_task"
require_relative "../../config/rbs_targets"

# 左から順に優先順位が高い型
# 例えば、manualにもgeneratedにも同じ型定義がある場合はmanualの定義を優先して、generatedの定義は削除される
RBS_TARGET_PRIORITY = %w[manual generated rbs_rails prototype].freeze

namespace :rbs do
  task setup: %i[clean collection inline prototype rbs_rails:all subtract]

  task :watch do
    dirs = RBS_TARGET_DIRS.join(" ")
    script = %Q(
      fswatch -0 #{dirs} | xargs -0 -n1 sh -c '
        bundle exec rbs-inline "$0" --output --opt-out && \
        find sig/generated -name "*.rbs" -exec sed -i "" "1,2{/^# Generated from/d; /^$/d;}" {} +
      '
    ).strip
    exec script
  end

  task :clean do
    sh "rm", "-rf", "sig/rbs_rails/"
    sh "rm", "-rf", "sig/prototype/"
    sh "rm", "-rf", "sig/generated/"
    sh "rm", "-rf", ".gem_rbs_collection/"
  end

  task :inline do
    sh "rbs-inline", *RBS_TARGET_DIRS, "--output", "--opt-out"
  end

  task :collection do
    sh "rbs", "collection", "install"
  end

  task :prototype do
    sh "rbs", "prototype", "rb", "--out-dir=sig/prototype", "--base-dir=.", *RBS_TARGET_DIRS
  end

  task :validate do
    sh "rbs", "-Isig", "validate", "--silent"
  end

  task :subtract do
    PriorityManager.new(shell_method: method(:sh)).execute
  end

  class PriorityManager
    def initialize(shell_method:)
      @shell_method = shell_method
      @priorities = RBS_TARGET_PRIORITY.map { |dir| "sig/#{dir}" }
    end

    def execute
      apply_priority_hierarchy
    end

    private

    def apply_priority_hierarchy
      @priorities.each_with_index do |higher_priority_dir, i|
        @priorities[i+1..].each do |lower_priority_dir|
          next unless Dir.exist?(higher_priority_dir)
          subtract_from(lower_priority_dir, higher_priority_dir)
        end
      end
    end

    def subtract_from(minuend, subtrahend)
      @shell_method.call("rbs", "subtract", "--write", minuend, subtrahend)
    end
  end
end

RbsRails::RakeTask.new do |task|
  # If you want to avoid generating RBS for some classes, comment in it.
  # default: nil
  #
  # task.ignore_model_if = -> (klass) { blah }

  # If you want to change the rake task namespace, comment in it.
  # default: :rbs_rails
  # task.name = :cool_rbs_rails

  # If you want to change where RBS Rails writes RBSs into, comment in it.
  # default: Rails.root / 'sig/rbs_rails'
  # task.signature_root_dir = Rails.root / 'my_sig/rbs_rails'
end
