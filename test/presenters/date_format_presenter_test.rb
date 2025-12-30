require "test_helper"

class DateFormatPresenterTest < ActiveSupport::TestCase
  setup do
    @time = Time.zone.local(2025, 12, 30, 14, 30, 0)
  end

  test "to_longはI18n.lのlongフォーマットで日時を返すこと" do
    assert_equal I18n.l(@time, format: :long), DateFormatPresenter.to_long(@time)
  end

  test "to_iso8601はISO8601形式の文字列を返すこと" do
    assert_equal @time.iso8601, DateFormatPresenter.to_iso8601(@time)
  end
end
