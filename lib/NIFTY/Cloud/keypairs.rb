module NIFTY
  module Cloud
    class Base < NIFTY::Base
      ALPHANUMERIC = /^[a-zA-Z0-9]+$/

      # API「CreateKeyPair」を実行し、SSH キーを新規作成します。
      # SSHキーには、SSHキー名およびパスワードを設定します。SSHキー名には、同じユーザーが作るキーのうち、一意となる文字列を
      # 指定します。設定したパスワードが使用可能文字ルールに適合しない場合は、エラーが返されます。
      #
      #  @option options [String] :key_name SSHキー名(必須)
      #  @option options [String] :password パスワード(必須)
      #   使用可能文字 : 半角英数字のみ
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   create_keypair(:key_name => 'key', :password => 'pass')
      #
      def create_key_pair( options = {} )
        options = { :key_name => "" }.merge(options)
        raise ArgumentError, "No :key_name provided." if blank?(options[:key_name])
        raise ArgumentError, "Invalid :key_name provided." unless ALPHANUMERIC =~ options[:key_name].to_s
        raise ArgumentError, "No :password provided." if blank?(options[:password])
        raise ArgumentError, "Invalid :password provided." unless ALPHANUMERIC =~ options[:password].to_s

        params = {'Action' => 'CreateKeyPair'}
        params.merge!(opts_to_prms(options, [:key_name, :password]))

        return response_generator(params)
      end

      # API「DeleteKeyPair」を実行し、SSH キーの情報を削除します。
      # SSHキーを指定するためには、SSHキー名が必要です。削除済みのSSHキーを指定した、管理外のSSHキーを指定したなど、
      # 無効なSSH キーを指定した場合は、エラーが返されます。
      #
      #  @option options [String] :key_name 削除対象のSSHキー名(必須)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   delete_keypair(:key_name => 'key')
      #
      def delete_key_pair( options = {} )
        options = { :key_name => "" }.merge(options)
        raise ArgumentError, "No :key_name provided." if blank?(options[:key_name])
        raise ArgumentError, "Invalid :key_name provided." unless ALPHANUMERIC =~ options[:key_name].to_s

        params = {
          'Action'  => 'DeleteKeyPair',
          'KeyName' => options[:key_name].to_s
        }

        return response_generator(params)
      end


      # API「DescribeKeyPairs」を実行し、指定したSSH キーの情報を取得します。
      # SSHキーを指定するためには、SSHキー名が必要です。SSHキーを指定しない場合は、取得できるすべてのSSHキー情報を取得します。
      # 削除済みのSSH キーを指定した、管理外のSSH キーを指定したなど、無効なSSH キーを指定した場合は、エラーが返されます。
      #
      #  @option options [Array<String>] :key_name SSHキー名
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   describe_keypairs(:key_name => ['key1', 'key2'])
      #
      def describe_key_pairs( options = {} )
        raise ArgumentError, "Invalid :key_name provided." unless blank?(options[:key_name]) || ALPHANUMERIC =~ options[:key_name].to_s

        params = {'Action' => 'DescribeKeyPairs'}
        params.merge!(pathlist('KeyName', options[:key_name]))

        return response_generator(params)
      end
    end
  end
end

