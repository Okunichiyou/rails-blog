class Page::SampleComponentPreview < ViewComponent::Preview
  def default
    render(Page::SampleComponent.new)
  end
end
