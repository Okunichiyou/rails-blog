require "test_helper"

class ApplicationFormTest < ActiveSupport::TestCase
  test "model_name.nameはクラス名からFormサフィックスを除いたものになる" do
    form = User::EmailConfirmationForm.new

    assert_equal "User::EmailConfirmation", form.model_name.name
  end

  test "model_name.param_keyはフォームのパラメータ名として使える形式になる" do
    form = User::EmailConfirmationForm.new

    assert_equal "user_email_confirmation", form.model_name.param_key
  end

  class ValidatesAssociatedTest < ActiveSupport::TestCase
    # テスト用のモデルクラス
    class DummyModel
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :name, :string

      validates :name, presence: true
    end

    # テスト用のフォームクラス（attribute_mappingなし）
    class DummyForm < ApplicationForm
      attribute :name, :string

      attr_accessor :dummy_model

      validates_associated :dummy_model
    end

    # テスト用のフォームクラス（attribute_mappingあり）
    class DummyFormWithMapping < ApplicationForm
      attribute :user_name, :string

      attr_accessor :dummy_model

      validates_associated :dummy_model, attribute_mapping: { name: :user_name }
    end

    test "関連モデルのエラーがフォームにコピーされる" do
      form = DummyForm.new
      form.dummy_model = DummyModel.new(name: nil)

      assert_not form.valid?
      assert form.errors[:name].any?
    end

    test "attribute_mappingで指定した属性名に変換される" do
      form = DummyFormWithMapping.new
      form.dummy_model = DummyModel.new(name: nil)

      assert_not form.valid?
      assert form.errors[:user_name].any?
      assert_empty form.errors[:name]
    end

    test "関連モデルがnilの場合はエラーを追加しない" do
      form = DummyForm.new
      form.dummy_model = nil

      assert form.valid?
    end

    test "関連モデルがvalidの場合はエラーを追加しない" do
      form = DummyForm.new
      form.dummy_model = DummyModel.new(name: "テスト")

      assert form.valid?
    end
  end
end
