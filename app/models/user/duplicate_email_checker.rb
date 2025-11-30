class User::DuplicateEmailChecker
  # @rbs (String?) -> bool
  def self.duplicate?(email)
    User::DatabaseAuthentication.exists?(email: email) ||
      User::SnsCredential.exists?(email: email)
  end
end
