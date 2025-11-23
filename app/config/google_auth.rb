class GoogleAuth < ApplicationConfig
  attr_reader :client_id, :client_secret

  def initialize
    @client_id = config[:client_id]
    @client_secret = config[:client_secret]
  end
end
