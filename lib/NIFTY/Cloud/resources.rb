module NIFTY
  module Cloud
    class Base < NIFTY::Base
      RESOURCES_DATE = /^\d{4}(\/|\-)?\d{2}(\/|\-)?\d{2}$/
      RESOURCES_YEAR_MONTH = /^\d{4}(\/|\-)?\d{2}$/

      # API「DescribeResources」を実行し、サービスの稼働情報を返却します。
      # コントロールパネル画面のダッシュボードに当たります。
      #
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   describe_resources()
      #
      def describe_resources( options={} )
        params = {'Action' => 'DescribeResources'}

        return response_generator(params)
      end


      # API「DescribeServiceStatus」を実行し、サービスの稼働情報を返却します。
      # コントロールパネル画面のダッシュボードに当たります。
      #
      #  @option options [String] :from_date 取得開始日
      #  @option options [String] :to_date 取得終了日
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   describe_service_status(:from_date => '2012/02/01', :to_date => '2012/02/10')
      #
      def describe_service_status( options={} )
        raise ArgumentError, "Invalid :from_date provided." unless blank?(options[:from_date]) || RESOURCES_DATE =~ options[:from_date].to_s
        raise ArgumentError, "Invalid :to_date provided." unless blank?(options[:to_date]) || RESOURCES_DATE =~ options[:to_date].to_s

        params = {'Action' => 'DescribeServiceStatus'}
        params.merge!(opts_to_prms(options, [:from_date, :to_date]))

        return response_generator(params)
      end


      # API「DescribeUsage」を実行し、リソースの利用状況を返却します。
      # コントロールパネル画面の料金明細に当たりますが、金額は含まれません。
      #
      # 存在する情報のみ、レスポンス内にタグが生成されます。
      #
      # 取得対象リージョンを設定した場合はサーバー利用情報などそのリージョンに属する個別情報を、
      # 指定しなかった場合はSSL証明書利用情報などリージョン共通情報と東日本リージョンの個別情報を返却します。
      #
      #  @option options [String] :year_month 取得対象年月
      #  @option options [String] :region     取得対象リージョン
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   describe_usage(:year_month => '2011-02', :region => 'east-1')
      #
      def describe_usage( options={} )
        raise ArgumentError, "Invalid :year_month provided." unless blank?(options[:year_month]) || RESOURCES_YEAR_MONTH =~ options[:year_month].to_s

        params = {'Action' => 'DescribeUsage'}
        params.merge!(opts_to_prms(options, [:year_month, :region]))

        return response_generator(params)
      end


      # API「DescribeUserActivities」を実行し、APIおよびコントロールパネルの利用履歴を返却します。
      # コントロールパネル画面のログ取得に当たります。
      #
      # マルチアカウントの子アカウントでは、自身の利用履歴のみ返却されます。
      # アップロード中のタスク情報を返却します。
      #
      #  @option options [String] :year_month 取得対象年月
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   describe_user_activities(:year_month => '201101')
      #
      def describe_user_activities( options={} )
        raise ArgumentError, "Invalid :year_month provided." unless blank?(options[:year_month]) || RESOURCES_YEAR_MONTH =~ options[:year_month].to_s

        params = {'Action' => 'DescribeUserActivities'}
        params.merge!(opts_to_prms(options, [:year_month]))

        return response_generator(params)
      end
    end   # end of Base class
  end     # end of Cloud module
end       # end of NIFTY module
