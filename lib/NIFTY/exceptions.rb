#--
# エラークラス
#++

module NIFTY
  # 基底エラークラス
  class Error < RuntimeError; end

  #--
  # クライアントエラー
  #++
  # 引数エラークラス
  class ArgumentError < Error; end
  # ユーザー定義値エラークラス
  class ConfigurationError < Error; end
  # レスポンス解析エラークラス
  class ResponseFormatError < Error; end

  # ニフティクラウドAPIエラークラス
  class ResponseError < Error
    # ニフティクラウドAPIから返却されるエラーコード
    attr_reader :error_code
    # ニフティクラウドAPIから返却されるエラーメッセージ
    attr_reader :error_message

    def initialize(error_code=nil, error_message=nil)
      @error_code     = error_code
      @error_message  = error_message
      super(error_message)
    end
  end
end
