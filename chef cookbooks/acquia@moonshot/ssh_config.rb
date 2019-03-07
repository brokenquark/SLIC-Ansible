module Moonshot
  class SSHConfig
    attr_accessor :ssh_identity_file
    attr_accessor :ssh_user

    def initialize
      @ssh_identity_file = ENV['MOONSHOT_SSH_KEY_FILE']
      @ssh_user = ENV['MOONSHOT_SSH_USER']
    end
  end
end
