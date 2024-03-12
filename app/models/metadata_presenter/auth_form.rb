module MetadataPresenter
  class AuthForm
    include ActiveModel::Model

    attr_accessor :username, :password

    validates :username, :password,
              presence: true, allow_blank: false

    validate :valid_credentials

    private

    def valid_credentials
      errors.add(:base, :unauthorised) unless errors.any? || authorised?
    end

    def authorised?
      # This comparison uses & so that it doesn't short circuit and
      # uses `secure_compare` so that length information isn't leaked.
      ActiveSupport::SecurityUtils.secure_compare(env_username, username) &
        ActiveSupport::SecurityUtils.secure_compare(env_password, password)
    end

    def env_username
      ENV['BASIC_AUTH_USER'].to_s
    end

    def env_password
      ENV['BASIC_AUTH_PASS'].to_s
    end
  end
end
