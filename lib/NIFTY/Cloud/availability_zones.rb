module NIFTY
  module Cloud
    class Base < NIFTY::Base
      ZONES_IGNORED_PARAMS = Regexp.new(/ZoneName\.\d+/)

      # API「DescribeAvailabilityZones」を実行し、利用可能なゾーンの情報を取得します。常に、ゾーン「ap-japan-1a」の情報が返されます。
      #
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   describe_availability_zones(:zone_name => 'ap-japan-1a')
      #
      def describe_availability_zones( options={} )
        params = {'Action' => 'DescribeAvailabilityZones'}
        params.merge!(pathlist('ZoneName', options[:zone_name]))

        params.reject! {|k, v| ZONES_IGNORED_PARAMS =~ k } if @@ignore_amz_params

        return response_generator(params)
      end
    end
  end
end
