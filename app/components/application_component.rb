class ApplicationComponent < ViewComponent::Base
  private

  # @rbs (value: Symbol, white_list: Array[untyped]) -> Symbol?
  def filter_attribute(value:, white_list:)
    return value if white_list.include?(value)

    raise ArgumentError, "Invalid attribute value: '#{value}'. Must be one of #{white_list.join(', ')}."
  end
end
