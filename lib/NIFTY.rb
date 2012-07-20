#--
# ニフティクラウドSDK for Ruby
#
# Ruby Gem Name::  nifty-cloud-sdk
# Author::    NIFTY Corporation
# Copyright:: Copyright 2011 NIFTY Corporation All Rights Reserved.
# License::   Distributes under the same terms as Ruby
# Home::      http://cloud.nifty.com/api/
#++

%w[ base64 cgi openssl digest/sha1 net/https net/http rexml/document time ostruct ipaddr logger ].each { |f| require f }

begin
  require 'URI' unless defined? URI
rescue Exception => e
  # nothing
end

begin
  require 'xmlsimple' unless defined? XmlSimple
rescue Exception => e
  require 'xml-simple' unless defined? XmlSimple
end

# Hashの値をドット表記で取得可能とするための、Hashクラスに独自のメソッド定義を行う
#
# @example 次のような形でHashの値を取得することができる
#   foo[:bar] => "baz"
#   foo.bar => "baz"
class Hash
  def method_missing(meth, *args, &block)
    if args.size == 0
      self[meth.to_s] || self[meth.to_sym]
    end
  end

  def type
    self['type']
  end

  def has?(key)
    self[key] && !self[key].to_s.empty?
  end

  def does_not_have?(key)
    self[key].nil? || self[key].to_s.empty?
  end
end


module NIFTY
  LOG = Logger.new(STDOUT)
  #LOG.level = Logger::DEBUG
  LOG.level = Logger::INFO

  # 署名パラメータ文字列生成
  #  urlencodeが真の場合はURLエンコードを行い、偽の場合はエンコードしない
  #
  def NIFTY.encode(secret_key, str, key_type, urlencode=true)
    digest = OpenSSL::Digest::Digest.new(key_type)
    b64_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, secret_key, str)).strip

    if urlencode
      return CGI::escape(b64_hmac)
    else
      return b64_hmac
    end
  end

  # HTTPリクエストの生成、実行、レスポンス解析を行う共通クラス
  class Base
    DEFAULT_CONNECTION_TIMEOUT  = 30
    DEFAULT_SOCKET_TIMEOUT      = 30
    DEFAULT_PORT                = 443
    DEFAULT_CONTENT_TYPE        = 'application/x-www-form-urlencoded;charset=UTF-8'
    PROTOCOL_HTTPS              = 'https'
    SIGNATURE_METHOD_SHA1       = 'HmacSHA1'
    SIGNATURE_METHOD_SHA256     = 'HmacSHA256'
    PORT_RANGE                  = (0..65535)
    SIGNATURE_VERSION           = ["0", "1", "2"]

    attr_reader :access_key, :secret_key, :use_ssl, :server, :path, :proxy_server, :port, :connection_timeout, :socket_timeout,
      :user_agent, :max_retry, :signature_version, :signature_method

    # オプションを指定してニフティクラウドAPIクライアントを生成します。
    #
    #  @option options [String] :access_key           公開キー
    #  @option options [String] :secret_key           秘密キー
    #  @option options [Boolean] :use_ssl             SSL暗号化(true or false)
    #  @option options [String] :server               APIホスト
    #  @option options [String] :path                 APIパス
    #  @option options [String] :proxy_server         プロキシサーバーのURL
    #  @option options [String] :port                 接続先ポート番号
    #  @option options [Integer] :connection_timeout  接続タイムアウト(秒)
    #  @option options [Integer] :socket_timeout      ソケットタイムアウト(秒)
    #  @option options [String] :user_agent           ユーザーエージェント
    #  @option options [Integer] :max_retry           最大リトライ回数
    #  @option options [String] :signature_version    認証バージョン
    #  @option options [String] :signature_method     APIの認証ロジック
    #
    #  @return [Base] ニフティクラウドAPIクライアントオブジェクト
    #
    def initialize( options = {} )
      @default_host = @default_path = @default_port = nil

      if blank?(options[:server])
        # options[:server]の指定がない場合はデフォルトのエンドポイントを使用する
        raise ConfigurationError, "No ENDPOINT_URL provided." if blank?(@default_endpoint)
        uri = URI.parse(@default_endpoint)
        raise ConfigurationError, "Invalid ENDPOINT_URL provided." unless PROTOCOL_HTTPS == uri.scheme
        @default_host     = uri.host || (raise ConfigurationError, "Invalid ENDPOINT_URL provided.")
        @default_path     = uri.path
        @default_port     = uri.port
      end

      options = { 
        :access_key         => @default_access_key,
        :secret_key         => @default_secret_key,
        :use_ssl            => true,
        :server             => @default_host,
        :path               => @default_path,
        :proxy_server       => @default_proxy_server,
        :port               => @default_port,
        :connection_timeout => @default_connection_timeout,
        :socket_timeout     => @default_socket_timeout,
        :user_agent         => @default_user_agent,
        :max_retry          => @default_max_retry,
        :signature_version  => @default_signature_version,
        :signature_method   => @default_signature_method
      }.merge(options)

      options[:port] = DEFAULT_PORT if blank?(options[:port])

      raise ArgumentError, "No :access_key provided." if blank?(options[:access_key])
      raise ArgumentError, "No :secret_key provided." if blank?(options[:secret_key])
      raise ArgumentError, "No :use_ssl provided." if blank?(options[:use_ssl])
      raise ArgumentError, "Invalid :use_ssl provided. only 'true' allowed." unless true == options[:use_ssl]
      raise ArgumentError, "No :server provided." if blank?(options[:server])
      raise ArgumentError, "No :path provided." if blank?(options[:path])
      raise ArgumentError, "Invalid :port provided." unless valid_port?(options[:port])
      raise ArgumentError, "Invalid :signature_version provided." unless SIGNATURE_VERSION.include?(options[:signature_version].to_s)
      raise ArgumentError, "Invalid :signature_method provided." unless [SIGNATURE_METHOD_SHA1, SIGNATURE_METHOD_SHA256].include?(options[:signature_method].to_s)

      @access_key         = options[:access_key].to_s
      @secret_key         = options[:secret_key].to_s
      @use_ssl            = options[:use_ssl]
      @server             = options[:server].to_s
      @path               = options[:path].to_s
      @proxy_server       = options[:proxy_server].to_s
      @port               = options[:port].to_i
      @connection_timeout = options[:connection_timeout].to_s.to_i
      @socket_timeout     = options[:socket_timeout].to_s.to_i
      @user_agent         = options[:user_agent].to_s
      @max_retry          = options[:max_retry].to_s.to_i
      @signature_version  = options[:signature_version].to_s
      @signature_method   = options[:signature_method].to_s

      make_http
    end

    private
    def make_http
      proxy = @proxy_server ? URI.parse(@proxy_server) : OpenStruct.new
      @http = Net::HTTP::Proxy( proxy.host,
                               proxy.port,
                               proxy.user,
                               proxy.password ).new(@server, @port)

      LOG.debug("[URL]https://#{@server}#{":" + @port.to_s unless @port == 443}#{@path}")
      LOG.debug("[PROXY]#{@proxy_server}") unless blank?(@proxy_server)

      @http.use_ssl = @use_ssl
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @http.open_timeout = (@connection_timeout >= 0) ? @connection_timeout : DEFAULT_CONNECTION_TIMEOUT
      @http.read_timeout = (@socket_timeout > 0) ? @socket_timeout : DEFAULT_SOCKET_TIMEOUT
    end

    # :user_dataオプションを指定された際、:base64_encodedオプションの値がtrueならば
    # :user_dataに対しBase64エンコードを行う
    private
    def extract_user_data( options = {} )
      return unless options[:user_data]
      if options[:user_data]
        if options[:base64_encoded]
          return Base64.encode64(options[:user_data]).gsub(/\n/, "").strip
        else
          return options[:user_data]
        end
      end
    end

    # パラメータ名のリストを生成したい場合に使用する
    #
    # @example
    #   入力: key = 'ImageId', 
    #         arr = ['123', '456'])
    #   出力: {"ImageId.1"=>"123", "ImageId.2"=>"456"}
    #
    private
    def pathlist(key, arr)
      raise ArgumentError, "expected a key that is a String" unless key.is_a?(String)
      raise ArgumentError, "unexpected a key that is empty" if key.empty?

      params = {}
      [arr].flatten.delete_if{ |value| blank?(value) }.each_with_index{ |value, i| params["#{key}.#{i+1}"] = value.to_s }

      return params
    end

    # パラメータグループのリストを生成したい場合に使用する
    #
    # @example
    #   入力: key           = 'People', 
    #         arr_of_hashes = [{:name=>'jon', :age=>'22'}, {:name=>'chris'}], 
    #         mappings      = {:name => 'Name', :age => 'Age'}
    #   出力: {"People.1.Name"=>"jon", "People.1.Age"=>'22', 'People.2.Name'=>'chris'}
    #
    private
    def pathhashlist(key, arr_of_hashes, mappings, key_name_mappings={})
      arr_of_hashes = [arr_of_hashes].flatten
      raise ArgumentError, "expected a key that is a String" unless key.is_a?(String)
      raise ArgumentError, "unexpected a key that is empty" if key.empty?
      arr_of_hashes.each{|h| raise ArgumentError, "expected each element of arr_of_hashes to be a Hash" unless h.is_a?(Hash)}
      raise ArgumentError, "expected a mappings that is an Hash" unless mappings.is_a?(Hash)
      raise ArgumentError, "expected a key_name_mappings that is an Hash" unless blank?(key_name_mappings) || key_name_mappings.is_a?(Hash)

      params = {}
      i = 0
      arr_of_hashes.each do |hash|
        param_size = params.size
        hash.each do |attribute, value|
          next if blank?(attribute) || blank?(mappings[attribute]) || blank?(value)
          if value.is_a? Array
            j = 0
            value.each do |item|
              next if blank?(item)
              param_name = "#{key}.#{i+1}.#{mappings[attribute]}.#{j+1}"
              param_name << ".#{key_name_mappings[attribute]}" unless blank?(key_name_mappings[attribute])
              params[param_name] = item.to_s
              j += 1
            end
          else
            params["#{key}.#{i+1}.#{mappings[attribute]}"] = value.to_s
          end
        end
        i += 1 if params.size > param_size
      end

      return params
    end

    # オプションで指定されたキー名を送信用パラメータのキー名に変換し、パラメータを生成する
    # prefixが指定されている場合はキー名の先頭に付加する
    # 
    # @example
    #   入力: options = {:opt1 => "val1", :opt2 => "val2", :opt3 => "val3"}, 
    #         arr     = [:opt1, :opt2], 
    #         prefix  = "Param"
    #   出力: {"Param.Opt1 => "val1", "Param.Opt2" => "val2"}
    # 
    private
    def opts_to_prms( options={}, arr=nil, prefix=nil)
      params = {}
      arr = options.keys if arr.nil?
      arr.each do |o|
        key = o.to_s.split('_').collect { |s| s.capitalize }.join
        key.insert(0, "#{prefix}.") unless blank?(prefix)
        params[key] = options[o].to_s unless blank?(options[o])
      end

      return params
    end

    # オブジェクトの文字列表現が空の場合は
    # trueを返却する
    private
    def blank?( obj )
      obj.to_s.empty?
    end

    # ポートチェック
    #  ポート番号が正しい場合はtrue、そうでなければfalseを返却する
    private
    def valid_port?( port )
      return false unless /^\d+$/ =~ port.to_s
      return PORT_RANGE.include?(port.to_s.to_i)
    end

    # HTTPリクエスト生成
    private
    def make_request(params)
      params.reject! { |key, value| blank?(value) }

      params.merge!( {'SignatureVersion'  => @signature_version,
                    'SignatureMethod'     => @signature_method,
                    'AccessKeyId'         => @access_key,
                    'Version'             => VERSION,
                    'Timestamp'           => Time.now.getutc.iso8601.sub(/Z/, sprintf(".%03dZ",(Time.now.getutc.usec/1000)))} )

      @encoded_params = params.sort.collect { |param|
        "#{CGI::escape(param[0])}=#{CGI::escape(param[1])}"
      }.join("&").gsub('+', '%20').gsub('%7E', '~')

      sig = get_auth_param(params, @secret_key)

      query = "#{@encoded_params}&Signature=#{sig}"

      LOG.debug("[QUERY]#{query}")

      req = Net::HTTP::Post.new(@path)
      req.content_type = DEFAULT_CONTENT_TYPE
      req['User-Agent'] = @user_agent unless blank?(@user_agent)
      req.body = query

      return req
    end

    # HTTPリクエスト実行
    private
    def exec_request(req)
      retry_cnt = 0
      sleep_time = 300 / 1000.0

      begin
        @http.start do
          return @http.request(req)
        end
      rescue TimeoutError => e
        # タイムアウトが発生した場合はリトライする
        raise e if retry_cnt >= @max_retry
        sleep(sleep_time)
        LOG.warn("HTTP retry. #{e.message}")
        retry_cnt += 1
        retry
      end
    end

    # 署名パラメータ設定
    private
    def get_auth_param(params, secret_key)
      if params["SignatureVersion"].to_i < 2
        key_type = SIGNATURE_METHOD_SHA1
      else
        key_type = params["SignatureMethod"]
      end

      canonical_string = make_canonical(params)
      LOG.debug("[SIGN]" + canonical_string.gsub(/\n/, "(\\n)"))

      return NIFTY.encode(secret_key, canonical_string, key_type.downcase.gsub(/hmac/, ''))
    end

    # 署名パラメータ生成用文字列の生成
    private
    def make_canonical(params=[])
      case params["SignatureVersion"]
      when '0'
        return "#{params['Action']}#{params['Timestamp']}"
      when '1'
        return params.sort.join
      when '2'
        return ['POST', @server, @path, @encoded_params].join("\n")
      end
    end
        
    # レスポンスXMLの解析を行う
    # エラーレスポンスの場合は例外を発生させる
    private
    def response_generator( params={} )

      LOG.debug('[ACTION]' + params['Action'])
      http_response = exec_request(make_request(params))

      return Response.parse(:xml => http_response.body) unless response_error?(http_response)
    end

    # レスポンスのエラーチェック
    private
    def response_error?(response)

      #LOG.debug('[BODY]' + response.body)

      # 正常レスポンスの場合はfalseを返却する
      return false if response.is_a?(Net::HTTPSuccess)

      # XML形式チェック
      # 形式が不正な場合は例外を発生させる
      begin
        doc = REXML::Document.new(response.body)

        # エラーXML形式：
        # <?xml version="1.0"?><Response><Errors><Error><Code>Client.InvalidInstanceID.NotFound</Code><Message>The instance ID 'foo' does not exist.</Message>
        # </Error></Errors><RequestID>291cef62-3e86-414b-900e-17246eccfae8</RequestID></Response>
        error_code    = doc.root.elements['Errors'].elements['Error'].elements['Code'].text
        error_message = doc.root.elements['Errors'].elements['Error'].elements['Message'].text
      rescue
        raise ResponseFormatError, "Unexpected error format. response.body is: #{response.body}"
      end

      raise ResponseError.new(error_code, error_message)
    end
  end   # end of Base class
end     # end of NIFTY module

Dir[File.join(File.dirname(__FILE__), 'NIFTY/**/*.rb')].sort.each { |lib| require lib }
