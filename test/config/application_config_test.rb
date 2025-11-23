require "test_helper"

class ApplicationConfigTest < ActiveSupport::TestCase
  class DummyConfig < ApplicationConfig
    attr_reader :value

    def initialize
      @value = config[:value]
    end
  end

  test "config_keyはクラス名からシンボルを生成する" do
    # DummyConfig -> :dummy_config
    dummy = DummyConfig.allocate
    assert_equal :dummy_config, dummy.send(:config_key)
  end

  test "存在しない設定ファイルの場合はエラーが発生する" do
    # config/dummy_config.ymlが存在しないため、エラーが発生することを確認
    error = assert_raises(RuntimeError) do
      DummyConfig.new
    end
    assert_match(/Could not load configuration/, error.message)
  end
end
