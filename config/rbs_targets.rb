# frozen_string_literal: true

# コントローラーは型チェック対象外（rbs_railsが型定義を生成しないため）
RBS_TARGET_DIRS = %w[app/components app/forms app/models app/presenters].freeze
