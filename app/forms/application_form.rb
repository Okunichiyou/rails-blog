class ApplicationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  # @rbs () -> ActiveModel::Name
  def model_name
    ActiveModel::Name.new(
      self.class, nil, self.class.name.sub(/Form$/, "")
    )
  end
end
