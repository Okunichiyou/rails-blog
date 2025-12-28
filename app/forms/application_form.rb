class ApplicationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  # @rbs () -> ActiveModel::Name
  def model_name
    ActiveModel::Name.new(
      self.class, nil, self.class.name.sub(/Form$/, "")
    )
  end

  class << self
    # 関連モデルのバリデーションを登録する
    # 第一引数は、モデルを格納するインスタンス変数名のシンボル
    # 第二引数は、モデルのアトリビュート名をフォーム用のアトリビュート名に変換したい時に使う
    # @rbs (Symbol, ?attribute_mapping: Hash[Symbol, Symbol]) -> void
    def validates_associated(name, attribute_mapping: {})
      validate do
        model = instance_variable_get(:"@#{name}")
        next if model.nil?
        next if model.valid?

        model.errors.each do |error|
          attribute = attribute_mapping[error.attribute] || error.attribute
          errors.add(attribute, error.type, message: error.message)
        end
      end
    end
  end

  private

  # 存在確認をするインスタンスと、validateしたいオブジェクトが異なる時など、validates_associatedを使うと不都合がある時に利用する
  # @rbs (untyped, ?attribute_map: Hash[Symbol, Symbol]) -> void
  def validate_model(model, attribute_map: {})
    return if model.nil?
    return if model.valid?

    model.errors.each do |error|
      attribute = attribute_map[error.attribute] || error.attribute
      errors.add(attribute, error.type, message: error.message)
    end
  end
end
