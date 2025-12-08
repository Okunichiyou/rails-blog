class UserValidator
  # @rbs (String?) -> bool
  def self.valid_email?(email)
    return false if email.nil? || email.empty?

    email.include?("@") && email.include?(".")
  end

  # @rbs (String?) -> bool
  def self.valid_password?(password)
    return false if password.nil?
    return false if password.length < 8

    has_uppercase = password.match?(/[A-Z]/)
    has_lowercase = password.match?(/[a-z]/)
    has_number = password.match?(/[0-9]/)

    has_uppercase && has_lowercase && has_number
  end

  # @rbs (String?) -> bool
  def self.valid_username?(username)
    return false if username.nil? || username.empty?
    return false if username.length < 3
    return false if username.length > 20

    username.match?(/^[a-zA-Z0-9_]+$/)
  end

  def self.valid_age?(age)
    return false if age.nil?
    return false if age < 0
    return false if age > 150

    true
  end
end
