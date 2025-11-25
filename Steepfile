# frozen_string_literal: true

target :app do
  signature "sig"

  check "app/models"
  check "app/controllers"
  check "app/components"

  configure_code_diagnostics(D::Ruby.strict)
end
