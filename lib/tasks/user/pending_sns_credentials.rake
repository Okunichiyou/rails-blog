namespace :user do
  namespace :pending_sns_credentials do
    desc "Delete expired pending SNS credentials"
    task cleanup: :environment do
      expired_count = User::PendingSnsCredential.expired.count
      User::PendingSnsCredential.expired.delete_all
      puts "Deleted #{expired_count} expired pending SNS credential(s)"
    end
  end
end
