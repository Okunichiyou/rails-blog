class SampleComponentPreview < ViewComponent::Preview
  def default
    render(SampleComponent.new)
  end
end
