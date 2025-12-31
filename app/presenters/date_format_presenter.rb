# rbs_inline: enabled

class DateFormatPresenter
  class << self
    # @rbs (ActiveSupport::TimeWithZone) -> String
    def to_long(time)
      I18n.l(time, format: :long)
    end

    # @rbs (ActiveSupport::TimeWithZone) -> String
    def to_iso8601(time)
      time.iso8601
    end
  end
end
