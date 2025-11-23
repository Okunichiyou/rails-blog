class ApplicationConfig
  private

  def config
    @config ||= Rails.application.config_for(config_key)
  end

  def config_key
    # Config::GoogleAuth -> :google_auth
    # ApplicationConfigTest::DummyConfig -> :dummy_config
    self.class.name.demodulize.underscore.to_sym
  end
end
