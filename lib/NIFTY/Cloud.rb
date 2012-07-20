module NIFTY
  module Cloud
    class Base < NIFTY::Base
      # この値が真のときNIFTY Cloud API側で無視されるパラメータは送信されない
      @@ignore_amz_params = false

      def initialize( options={} )
        @default_access_key         = ACCESS_KEY
        @default_secret_key         = SECRET_KEY
        @default_endpoint           = ENDPOINT_URL
        @default_proxy_server       = PROXY_SERVER
        @default_user_agent         = USER_AGENT
        @default_max_retry          = MAX_RETRY
        @default_connection_timeout = CONNECTION_TIMEOUT
        @default_socket_timeout     = SOCKET_TIMEOUT
        @default_signature_method   = SIGNATURE_METHOD
        @default_signature_version  = SIGNATURE_VERSION

        super(options)
      end
    end
  end
end

