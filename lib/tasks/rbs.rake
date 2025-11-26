return unless Rails.env.development?

require "rbs_rails/rake_task"

namespace :rbs do
  task setup: %i[clean collection inline prototype rbs_rails:all subtract]

  task :clean do
    sh "rm", "-rf", "sig/rbs_rails/"
    sh "rm", "-rf", "sig/prototype/"
    sh "rm", "-rf", "sig/generated/"
    sh "rm", "-rf", ".gem_rbs_collection/"
  end

  desc "Generate RBS files from inline comments (created by rbs-trace)"
  task :inline do
    sh "rbs-inline", "app", "--output", "--opt-out"
  end

  task :collection do
    sh "rbs", "collection", "install"
  end

  task :prototype do
    sh "rbs", "prototype", "rb", "--out-dir=sig/prototype", "--base-dir=.", "app"
  end

  task :subtract do
    # prototypeからrbs_railsを差し引く
    sh "rbs", "subtract", "--write", "sig/prototype", "sig/rbs_rails"

    # prototypeからgeneratedを差し引く（inlineで生成した型が優先）
    sh "rbs", "subtract", "--write", "sig/prototype", "sig/generated" if Dir.exist?("sig/generated")

    # rbs_railsからgeneratedを差し引く（inlineで生成した型が優先）
    sh "rbs", "subtract", "--write", "sig/rbs_rails", "sig/generated" if Dir.exist?("sig/generated")

    prototype_path = Rails.root.join("sig/prototype")
    rbs_rails_path = Rails.root.join("sig/rbs_rails")
    generated_path = Rails.root.join("sig/generated")
    subtrahends = Rails.root.glob("sig/*")
      .reject { |path| path == prototype_path || path == rbs_rails_path || path == generated_path }
      .map { |path| "--subtrahend=#{path}" }

    if subtrahends.any?
      sh "rbs", "subtract", "--write", "sig/prototype", "sig/rbs_rails", *subtrahends
    end
  end

  task :validate do
    sh "rbs", "-Isig", "validate", "--silent"
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
