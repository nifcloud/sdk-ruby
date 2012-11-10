module NIFTY
  module Cloud
    # 各種設定
    #
    # 環境変数から各種設定値を取得します。
    # 環境変数から取得できなかった場合はデフォルト値が適用されます。
    #  VAR = ENV['VAR'] || デフォルト値

    # 公開キー
    ACCESS_KEY = ENV['NIFTY_CLOUD_ACCESS_KEY']                  || '<default access key>'
    # 秘密キー
    SECRET_KEY = ENV['NIFTY_CLOUD_SECRET_KEY']                  || '<default secret key>'

    # APIのエンドポイント
    #  @example 
    #  'https://example.com/test/'
    ENDPOINT_URL  = ENV['NIFTY_CLOUD_ENDPOINT_URL']             || 'https://cp.cloud.nifty.com/api/'

    # プロキシサーバーのURL(デフォルト： nil)
    #  形式： //<username>:<password>@<hostname>:<port>
    #  @example 
    #   '//user:password@proxy.example.com:8080'
    PROXY_SERVER = ENV['NIFTY_CLOUD_PROXY_SERVER']

    # ユーザーエージェント
    USER_AGENT          = ENV['NIFTY_CLOUD_USER_AGENT']         || 'NIFTY Cloud API Ruby SDK'
    # 最大リトライ回数
    MAX_RETRY           = ENV['NIFTY_CLOUD_MAX_RETRY']          || 3
    # 接続タイムアウト(秒)
    CONNECTION_TIMEOUT  = ENV['NIFTY_CLOUD_CONNECTION_TIMEOUT'] || 30
    # ソケットタイムアウト(秒)
    SOCKET_TIMEOUT      = ENV['NIFTY_CLOUD_SOCKET_TIMEOUT']     || 30

    # 認証バージョン
    #   0 | 1 | 2
    SIGNATURE_VERSION = ENV['NIFTY_CLOUD_SIGNATURE_VERSION']    || '2'
    # APIの認証ロジック
    #   HmacSHA1 | HmacSHA256
    SIGNATURE_METHOD  = ENV['NIFTY_CLOUD_SIGNATURE_METHOD']     || 'HmacSHA256'
  end
end
