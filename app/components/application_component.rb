class ApplicationComponent < ViewComponent::Base
  private

  def filter_attribute(value:, white_list:)
    return value if white_list.include?(value)

    raise ArgumentError, "Invalid attribute value: '#{value}'. Must be one of #{white_list.join(', ')}."
  end
end
