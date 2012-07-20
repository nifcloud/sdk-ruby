module NIFTY
  module Cloud
    class Base < NIFTY::Base
      LOAD_BALANCER_PROTOCOL  = ['HTTP', 'HTTPS', 'FTP']
      BALANCING_TYPE          = ['1', '2']
      NETWORK_VOLUMES         = ['10', '20', '30', '40', '100', '200']
      IP_VERSION              = ['v4', 'v6']
      FILTER_TYPE             = ['1', '2']
      LOAD_BALANCER_NAME      = /^[a-zA-Z0-9]{1,15}$/
      LOAD_BALANCERS_IGNORED_PARAMS = Regexp.union(/AvailabilityZones .member.*/, 
                                                   /HealthCheck .Timeout/)

      # API「ConfigureHealthCheck」を実行し、指定したロードバランサーのヘルスチェックの設定を変更します。
      # ロードバランサーを指定するためには、ロードバランサー名・ポート番号が必要です。削除済みのロードバランサーを指定した、
      # 管理外のロードバランサーを指定したなど、無効なロードバランサーを指定した場合は、エラーが返されます。
      # ヘルスチェックの実行結果は、API「DescribeInstanceHealth」で確認できます。
      #
      #  @option options [String] :load_balancer_name     対象のロードバランサー名(必須)
      #  @option options [Integer] :load_balancer_port    対象の待ち受けポート(必須)
      #  @option options [Integer] :load_balancer_port    対象の宛先ポート(必須)
      #  @option options [String] :target                 PING プロトコル+":"+宛先ポート(必須)
      #   許可値: TCP:宛先ポート | ICMP
      #  @option options [Integer] :interval              ヘルスチェック間隔(必須)
      #   許可値: 10 - 300
      #  @option options [Integer] :unhealthy_threshold   ヘルスチェック回数の閾値(必須)
      #   許可値: 1 - 10
      #  @option options [Integer] :healthy_threshold     ヘルスチェックの復旧判断 
      #   許可値: 1
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   configure_health_check(:load_balancer_name => 'bl1', :load_balancer_port => 80, :instance_port => 80, target => 'TCP:80', 
      #                           :interval => 300, :unhealthy_threshold => 10, :healthy_threshold => 1)
      #
      def configure_health_check( options={} )
        raise ArgumentError, "No :load_balancer_name provided." if blank?(options[:load_balancer_name])
        raise ArgumentError, "Invalid :load_balancer_name provided." unless LOAD_BALANCER_NAME =~ options[:load_balancer_name].to_s
        raise ArgumentError, "No :load_balancer_port provided." if blank?(options[:load_balancer_port])
        raise ArgumentError, "Invalid :load_balancer_port provided." unless valid_port?(options[:load_balancer_port])
        raise ArgumentError, "No :instance_port provided." if blank?(options[:instance_port])
        raise ArgumentError, "Invalid :instance_port provided." unless valid_port?(options[:instance_port])
        raise ArgumentError, "No :target provided." if blank?(options[:target])
        raise ArgumentError, "Invalid :target provided." unless /^(TCP:(\d{1,5})|ICMP)$/ =~ options[:target] 
        raise ArgumentError, "Invalid :target provided." unless options[:target].to_s == 'ICMP' || valid_port?($2)
        raise ArgumentError, "No :interval provided." if blank?(options[:interval])
        raise ArgumentError, "Invalid :interval provided." unless ('10'..'300').to_a.include?(options[:interval].to_s)
        raise ArgumentError, "No :unhealthy_threshold provided." if blank?(options[:unhealthy_threshold])
        raise ArgumentError, "Invalid :unhealthy_threshold provided." unless ('1'..'10').to_a.include?(options[:unhealthy_threshold].to_s)
        raise ArgumentError, "Invalid :healthy_threshold provided." unless blank?(options[:healthy_threshold]) || '1' == options[:healthy_threshold].to_s

        params = {'Action' => 'ConfigureHealthCheck'}
        params.merge!(opts_to_prms(options, [:load_balancer_name, :load_balancer_port, :instance_port]))
        params.merge!(opts_to_prms(options, [:target, :interval, :timeout, :unhealthy_threshold, :healthy_threshold], 'HealthCheck'))

        params.reject! {|k, v| LOAD_BALANCERS_IGNORED_PARAMS =~ k } if @@ignore_amz_params

        return response_generator(params)
      end


      # API「CreateLoadBalancer」を実行し、ロードバランサーの定義を作成します。
      # ロードバランサーの定義を作成します。1 回のリクエストで、1 つのポート定義を作成できます。
      # すでに存在するロードバランサー名を指定した、存在するポート番号を指定した場合は、エラーが返されます。
      # ロードバランサーの定義の作成に成功した場合は、以下のAPI を実行する必要があります。
      #  ・ API「RegisterInstancesWithLoadBalancer」（サーバー設定）
      #  ・ API「ConfigureHealthCheck」（ヘルスチェック設定）
      # フィルターの設定は、「すべてのアクセスを許可する」になっています。変更を行う場合は以下のAPI を実行する必要があります。
      #  ・ API「SetFilterForLoadBalancer」（フィルター設定）
      #
      #  @option options [String] :load_balancer_name     ロードバランサー名(必須)
      #   使用可能文字: 半角英数字(15文字まで)
      #  @option options [Array<Hash>] :listeners         ロードバランサー設定 
      #   <Hash> options  [String] :protocol               - プロトコル(:load_balancer_portといずれか必須)
      #                    許可値: HTTP | HTTPS | FTP
      #                   [Integer] :load_balancer_port    - 待ち受けポート(:protocolといずれか必須)
      #                   [Integer] :instance_port         - 宛先ポート
      #                   [String] :balancing_type         - ロードバランス方式 
      #                    許可値: 1(Round-Robin) | 2(Least-Connection) 
      #  @option options [Integer] :network_volume        最大ネットワーク流量
      #   許可値: 10 | 20 | 30 | 40 | 100 | 200　（単位： Mbps）
      #  @option options [String] :ip_version             グローバルIP アドレスのバージョン 
      #   許可値: v4
      #  @return [Hash] レスポンスXML解析結果
      #                   
      #  @example
      #   create_load_balancer(:load_balancer_name => 'lb1', :listeners => {:protocol => 'http'}, :network_volume => 10)
      #
      def create_load_balancer( options={} )
        raise ArgumentError, "No :load_balancer_name provided." if blank?(options[:load_balancer_name])
        raise ArgumentError, "Invalid :load_balancer_name provided." unless LOAD_BALANCER_NAME =~ options[:load_balancer_name].to_s
        raise ArgumentError, "No :listeners provided." if blank?(options[:listeners])
        [options[:listeners]].flatten.each do |member|
          raise ArgumentError, "expected each element of arr_of_hashes to be a Hash" unless member.is_a?(Hash)
          raise ArgumentError, ":protocol or :load_balancer_port must be provided." if blank?(member[:protocol])&& blank?(member[:load_balancer_port])
          raise ArgumentError, "Invalid :protocol provided." unless blank?(member[:protocol]) || LOAD_BALANCER_PROTOCOL.include?(member[:protocol].to_s.upcase)
          raise ArgumentError, "Invalid :load_balancer_port provided." unless blank?(member[:load_balancer_port]) || valid_port?(member[:load_balancer_port])
          raise ArgumentError, "Invalid :instance_port provided." unless blank?(member[:instance_port]) || valid_port?(member[:instance_port])
          raise ArgumentError, "Invalid :balancing_type provided." unless blank?(member[:balancing_type]) || BALANCING_TYPE.include?(member[:balancing_type].to_s)
        end
        raise ArgumentError, "Invalid :network_volume provided." unless blank?(options[:network_volume]) || NETWORK_VOLUMES.include?(options[:network_volume].to_s)
        raise ArgumentError, "Invalid :ip_version provided." unless blank?(options[:ip_version]) || IP_VERSION.include?(options[:ip_version].to_s)
        params = {'Action' => 'CreateLoadBalancer'}
        params.merge!(opts_to_prms(options, [:load_balancer_name, :network_volume, :ip_version]))
        params.merge!(pathhashlist('Listeners.member', options[:listeners], 
                                   {:protocol => 'Protocol', 
                                     :load_balancer_port => 'LoadBalancerPort',
                                     :instance_port => 'InstancePort', 
                                     :balancing_type => 'BalancingType'}))
        params.merge!(pathlist('AvailabilityZones.member', options[:availability_zones]))

        params.reject! {|k, v| LOAD_BALANCERS_IGNORED_PARAMS =~ k } if @@ignore_amz_params

        return response_generator(params)
      end


      # API「DeleteLoadBalancer」を実行し、指定したロードバランサーのポート定義を削除します。
      # 関連するフィルター設定・サーバー設定・ヘルスチェック設定もあわせて削除します。
      # ロードバランサーを指定するためには、ロードバランサー名が必要です。削除済みのロードバランサーを指定した、
      # 管理外のロードバランサーを指定したなど、無効なロードバランサーを指定した場合は、エラーが返されます。
      #
      #  @option options [String] :load_balancer_name   削除対象のロードバランサー名(必須)
      #  @option options [Integer] :load_balancer_port  削除対象の待ち受けポート(必須)
      #  @option options [Integer] :instance_port       削除対象の宛先ポート(必須)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   delete_load_balancer(:load_balancer_name => 'lb1', :load_balancer_port => 80, instance_port => 80)
      #
      def delete_load_balancer( options={} )
        raise ArgumentError, "No :load_balancer_name provided." if blank?(options[:load_balancer_name])
        raise ArgumentError, "Invalid :load_balancer_name provided." unless LOAD_BALANCER_NAME =~ options[:load_balancer_name].to_s
        raise ArgumentError, "No :load_balancer_port provided." if blank?(options[:load_balancer_port])
        raise ArgumentError, "Invalid :load_balancer_port provided." unless valid_port?(options[:load_balancer_port])
        raise ArgumentError, "No :instance_port provided." if blank?(options[:instance_port])
        raise ArgumentError, "Invalid :instance_port provided." unless valid_port?(options[:instance_port])

        params = {'Action' => 'DeleteLoadBalancer'}
        params.merge!(opts_to_prms(options, [:load_balancer_name, :load_balancer_port, :instance_port]))

        return response_generator(params)
      end


      # API「DeregisterInstancesFromLoadBalancer」を実行し、指定したロードバランサーから、指定したサーバーを解除します。
      # ロードバランサーを指定するためには、ロードバランサー名・ポート番号が必要です。削除済みのロードバランサーを指定した、
      # 管理外のロードバランサーを指定したなど、無効なロードバランサーを指定した場合は、エラーが返されます。
      # またサーバーを指定するためには、サーバー名が必要です。該当するロードバランサーに設定されていないサーバーを指定した、
      # 削除済みのサーバーを指定した、管理外のサーバーを指定したなど、無効なサーバーを指定した場合は、エラーが返されます。
      #
      #  @option options [String] :load_balancer_name   対象のロードバランサー名(必須)
      #  @option options [Integer] :load_balancer_port  対象の待ち受けポート(必須)
      #  @option options [Integer] :instance_port       対象の宛先ポート(必須)
      #  @option options [Array<String>]  :instances    サーバー名(必須)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   deregister_instances_from_load_balancer(:load_balancer_name => 'lb1', :load_balancer_port => 80, instance_port => 80, :instances => ['server01'])
      #
      def deregister_instances_from_load_balancer( options={} )
        raise ArgumentError, "No :load_balancer_name provided" if blank?(options[:load_balancer_name])
        raise ArgumentError, "Invalid :load_balancer_name provided." unless LOAD_BALANCER_NAME =~ options[:load_balancer_name].to_s
        raise ArgumentError, "No :load_balancer_port provided." if blank?(options[:load_balancer_port])
        raise ArgumentError, "Invalid :load_balancer_port provided." unless valid_port?(options[:load_balancer_port])
        raise ArgumentError, "No :instance_port provided." if blank?(options[:instance_port])
        raise ArgumentError, "Invalid :instance_port provided." unless valid_port?(options[:instance_port])
        raise ArgumentError, "No :instances provided." if blank?(options[:instances])

        params = {'Action' => 'DeregisterInstancesFromLoadBalancer'}
        params.merge!(opts_to_prms(options, [:load_balancer_name, :load_balancer_port, :instance_port]))
        params.merge!(pathhashlist('Instances.member', [options[:instances]].flatten.collect{|e| {:instances => e}}, {:instances => 'InstanceId'}))

        return response_generator(params)
      end


      # API「DescribeInstanceHealth」を実行し、指定したロードバランサーに設定されている、サーバーのヘルスチェック結果を取得します。ヘルスチェックは、API
      # 「ConfigureHealthCheck」で設定します。
      # ロードバランサーを指定するためには、ロードバランサー名が必要です。削除済みのロードバランサーを指定した、管理外のロードバランサーを指定したなど、
      # 無効なロードバランサーを指定した場合は、エラーが返されます。
      # またサーバーを指定するためには、サーバー名が必要です。サーバーを指定しない場合は、指定したロードバランサーに設定されているすべてのサーバーを対象として、
      # ヘルスチェック結果を取得します。
      # 削除済みのサーバーを指定した、管理外のサーバーを指定したなど、無効なサーバーを指定した場合は、エラーが返されます。
      #
      #  @option options [String] :load_balancer_name   対象のロードバランサー名(必須)
      #  @option options [Integer] :load_balancer_port  対象の待ち受けポート(必須)
      #  @option options [Integer] :instance_port       対象の宛先ポート(必須)
      #  @option options [Array<String>]  :instances    サーバー名
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   describe_instance_health(:load_balancer_name => 'bl1', :load_balancer_port => 80, :instance_port => 80, :instances => ['server01'])
      #
      def describe_instance_health( options={} )
        raise ArgumentError, "No :load_balancer_name provided" if blank?(options[:load_balancer_name])
        raise ArgumentError, "Invalid :load_balancer_name provided." unless LOAD_BALANCER_NAME =~ options[:load_balancer_name].to_s
        raise ArgumentError, "No :load_balancer_port provided." if blank?(options[:load_balancer_port])
        raise ArgumentError, "Invalid :load_balancer_port provided." unless valid_port?(options[:load_balancer_port])
        raise ArgumentError, "No :instance_port provided." if blank?(options[:instance_port])
        raise ArgumentError, "Invalid :instance_port provided." unless valid_port?(options[:instance_port])

        params = {'Action' => 'DescribeInstanceHealth'}
        params.merge!(opts_to_prms(options, [:load_balancer_name, :load_balancer_port, :instance_port]))
          params.merge!(pathhashlist('Instances.member', [options[:instances]].flatten.collect{|e| {:instances => e}}, 
                                     {:instances => 'InstanceId'})) if options.has_key?(:instances) 

        return response_generator(params)
      end
     

      # API「DescribeLoadBalancers」を実行し、指定したロードバランサーの情報を取得します。
      # ロードバランサーを指定するためには、ロードバランサー名が必要です。ロードバランサーを指定しない場合は、取得可能なすべての
      # ロードバランサー情報を取得します。
      # 削除済みのロードバランサーを指定した、管理外のロードバランサーを指定したなど、無効なロードバランサーを指定した場合は、エラーが返されます。
      #
      #  @option options [Array<String>] :load_balancer_name    ロードバランサー名
      #  @option options [Array<Integer>] :load_balancer_port  待ち受けポート
      #  @option options [Array<Integer>] :instance_port       宛先ポート
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   describe_load_balancers(:load_balancer_name => ['lb1'], :load_balancer_port => [80], :instance_port => [80])
      #
      def describe_load_balancers( options={} )
        [options[:load_balancer_name]].flatten.each do |o|
          raise ArgumentError, "Invalid :load_balancer_name provided." unless LOAD_BALANCER_NAME =~ o.to_s
        end unless blank?(options[:load_balancer_name])
        [options[:load_balancer_port]].flatten.each do |o| 
          raise ArgumentError, "Invalid :load_balancer_port provided." unless valid_port?(o) 
        end unless blank?(options[:load_balancer_port])
        [options[:instance_port]].flatten.each do |o| 
          raise ArgumentError, "Invalid :instance_port provided." unless valid_port?(o) 
        end unless blank?(options[:instance_port])

        params = {'Action' => 'DescribeLoadBalancers'}
        params.merge!(pathlist('LoadBalancerNames.member', options[:load_balancer_name]))
        params.merge!(pathlist('LoadBalancerNames.LoadBalancerPort', options[:load_balancer_port]))
        params.merge!(pathlist('LoadBalancerNames.InstancePort', options[:instance_port]))

        return response_generator(params)
      end


      # API「RegisterInstancesWithLoadBalancer」を実行し、
      # 指定したロードバランサーにサーバーを追加します。
      # ロードバランサーを指定するためには、ロードバランサー名・ポート番号が必要です。削除済みのロードバランサーを指定した、
      # 管理外のロードバランサーを指定したなど、無効なロードバランサーを指定した場合は、エラーが返されます。
      # またサーバーを指定するためには、サーバー名が必要です。IP アドレスを固定化しているサーバーを指定できます。IP アドレス
      # を固定化していないサーバーを指定した、ほかのロードバランサーに設定されているサーバーを指定した、削除済みのサーバーを指定した、
      # 管理外のサーバーを指定したなど、無効なサーバーを指定した場合は、エラーが返されます。
      #
      #  @option options [String] :load_balancer_name   対象のロードバランサー名(必須)
      #  @option options [Integer] :load_balancer_port  対象の待ち受けポート(必須)
      #  @option options [Integer] :instance_port       対象の宛先ポート(必須)
      #  @option options [Array<String>] :instances     サーバー名(必須)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   register_instances_with_load_balancer(:load_balancer_name => 'lb1', :load_balancer_port => 80, instance_port => 80, :instances => ['server01'])
      #
      def register_instances_with_load_balancer( options={} )
        raise ArgumentError, "No :load_balancer_name provided." if blank?(options[:load_balancer_name])
        raise ArgumentError, "Invalid :load_balancer_name provided." unless LOAD_BALANCER_NAME =~ options[:load_balancer_name].to_s
        raise ArgumentError, "No :load_balancer_port provided." if blank?(options[:load_balancer_port])
        raise ArgumentError, "Invalid :load_balancer_port provided." unless valid_port?(options[:load_balancer_port])
        raise ArgumentError, "No :instance_port provided." if blank?(options[:instance_port])
        raise ArgumentError, "Invalid :instance_port provided." unless valid_port?(options[:instance_port])
        raise ArgumentError, "No :instances provided." if blank?(options[:instances])

        params = {'Action' => 'RegisterInstancesWithLoadBalancer'}
        params.merge!(opts_to_prms(options, [:load_balancer_name, :load_balancer_port, :instance_port]))
        params.merge!(pathhashlist('Instances.member', [options[:instances]].flatten.collect{|e| {:instances => e}}, {:instances => 'InstanceId'}))

        return response_generator(params)
      end


      # API「RegisterPortWithLoadBalancer」を実行し、指定したロードバランサーにポートを追加します。
      # ロードバランサーを指定するためには、ロードバランサー名が必要です。削除済みのロードバランサーを指定した、
      # 管理外のロードバランサーを指定したなど、無効なロードバランサーを指定した場合は、エラーが返されます。
      # ポートの追加に成功した場合は、以下のAPI を実行する必要があります。
      #  ・ API「RegisterInstancesWithLoadBalancer」（サーバー設定）
      #  ・ API「ConfigureHealthCheck」（ヘルスチェック設定）
      # フィルターの設定は、「すべてのアクセスを許可する」になっています。変更を行う場合は以下のAPI を実行する必要があります。
      # API「SetFilterForLoadBalancer」（フィルター設定）
      #
      #  @option options [String] :load_balancer_name     対象のロードバランサー名(必須)
      #  @option options [Array<Hash>] :listeners         ロードバランサー設定 
      #   <Hash> option   [String] :protocol               - 追加するプロトコル(:load_balancer_portといずれか必須)
      #                    許可値: HTTP | HTTPS | FTP
      #                   [Integer] :load_balancer_port    - 追加する待ち受けポート(:protocolといずれか必須)
      #                   [Integer] :instance_port         - 追加する宛先ポート
      #                   [String] :balancing_type         - 追加するロードバランス方式 
      #                    許可値: 1(Round-Robin) | 2(Least-Connection)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   register_port_with_load_balancer(:load_balancer_name => 'lb1', :listeners => {:protocol => 'http', :balancing_type => 1})
      #
      def register_port_with_load_balancer( options={} )
        raise ArgumentError, "No :load_balancer_name provided." if blank?(options[:load_balancer_name])
        raise ArgumentError, "Invalid :load_balancer_name provided." unless LOAD_BALANCER_NAME =~ options[:load_balancer_name].to_s
        raise ArgumentError, "No :listeners provided." if blank?(options[:listeners])
        [options[:listeners]].flatten.each do |member|
          raise ArgumentError, "expected each element of arr_of_hashes to be a Hash" unless member.is_a?(Hash)
          raise ArgumentError, ":protocol or :load_balancer_port must be provided." if blank?(member[:protocol])&& 
            blank?(member[:load_balancer_port])
          raise ArgumentError, "Invalid :protocol provided." unless LOAD_BALANCER_PROTOCOL.include?(member[:protocol].to_s.upcase) || blank?(member[:protocol])
          raise ArgumentError, "Invalid :load_balancer_port provided." unless valid_port?(member[:load_balancer_port]) || 
            blank?(member[:load_balancer_port])
          raise ArgumentError, "Invalid :instance_port provided." unless blank?(member[:instance_port]) || 
            valid_port?(member[:instance_port])
          raise ArgumentError, "Invalid :balancing_type provided." unless blank?(member[:balancing_type]) || 
            BALANCING_TYPE.include?(member[:balancing_type].to_s) 
        end

        params = {'Action' => 'RegisterPortWithLoadBalancer'}
        params.merge!(opts_to_prms(options, [:load_balancer_name, :network_volume, :ip_version]))
        params.merge!(pathhashlist('Listeners.member', options[:listeners], 
                                   {:protocol => 'Protocol', 
                                     :load_balancer_port => 'LoadBalancerPort',
                                     :instance_port => 'InstancePort', 
                                     :balancing_type => 'BalancingType'}))

        return response_generator(params)
      end
      

      # API「SetFilterForLoadBalancer」を実行し、指定したロードバランサーにアクセスフィルターを設定します。
      # ロードバランサーを指定するためには、ロードバランサー名・ポート番号が必要です。削除済みのロードバランサーを指定した、
      # 管理外のロードバランサーを指定したなど、無効なロードバランサーを指定した場合は、エラーが返されます。
      #
      #  @option options [String] :load_balancer_name   対象のロードバランサー名(必須)
      #  @option options [Integer] :load_balancer_port  対象の待ち受けポート(必須)
      #  @option options [Integer] :instance_port       対象の宛先ポート(必須)
      #  @option options [Array<Hash>] :ip_addresses    IPアドレス設定
      #   <Hash> options  [String] :ip_address           - アクセス元IPアドレス
      #                    許可値: 特定のIPアドレス(IPv4/IPv6)
      #                   [Boolean] :add_on_filter       - 追加フラグ
      #                    許可値: true(IPアドレスを追加) | false(IPアドレスを削除)
      #  @option options [String] :filter_type          指定したアクセス元IP アドレスへの対処
      #   許可値: 1 | 2
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   set_filter_for_load_balancer(:load_balancer_name => 'lb1', :load_balancer_port => 80, :instance_port => 80, 
      #                                 :ipaddresses => {:ip_address => '111.111.111.111'}, :filter_type => 1)
      #
      def set_filter_for_load_balancer( options={} )
        raise ArgumentError, "No :load_balancer_name provided." if blank?(options[:load_balancer_name])
        raise ArgumentError, "Invalid :load_balancer_name provided." unless LOAD_BALANCER_NAME =~ options[:load_balancer_name].to_s
        raise ArgumentError, "No :load_balancer_port provided." if blank?(options[:load_balancer_port])
        raise ArgumentError, "Invalid :load_balancer_port provided." unless valid_port?(options[:load_balancer_port])
        raise ArgumentError, "No :instance_port provided." if blank?(options[:instance_port])
        raise ArgumentError, "Invalid :instance_port provided." unless valid_port?(options[:instance_port])
        raise ArgumentError, "Invalid :filter_type provided." unless blank?(options[:filter_type]) || FILTER_TYPE.include?(options[:filter_type].to_s)

        params = {'Action' => 'SetFilterForLoadBalancer'}
        params.merge!(opts_to_prms(options, [:load_balancer_name, :load_balancer_port, :instance_port, :filter_type]))

        unless blank?(options[:ip_addresses])
          [options[:ip_addresses]].flatten.each do |member|
            raise ArgumentError, "expected each element of arr_of_hashes to be a Hash" unless member.is_a?(Hash)
            begin IPAddr.new(member[:ip_address].to_s) rescue raise ArgumentError, "Invalid :ip_address provided." end unless blank?(member[:ip_address])
            raise ArgumentError, "Invalid :add_on_filter provided." unless blank?(member[:add_on_filter]) || BOOLEAN.include?(member[:add_on_filter].to_s)
          end
          params.merge!(pathhashlist('IPAddresses.member', options[:ip_addresses], 
                                     { :ip_address => 'IPAddress', :add_on_filter => 'AddOnFilter'}))
        end

        return response_generator(params)
      end

      # API「UpdateLoadBalancer」を実行し、指定したロードバランサーの定義を変更します。
      # ポート定義を更新する場合は、ポート番号もあわせて指定します。
      # 削除済みのロードバランサー名・待ち受けポートを指定した、管理外のロードバランサー名を指定した場合は、エラーが返されます。
      #
      #  @option options [String] :load_balancer_name             変更対象のロードバランサー名(必須)
      #  @option options [Array<Hash>] :listener_update           ロードバランサー設定
      #   <Hash> options  [Integer] :load_balancer_port            - 変更対象の待ち受けポート(ポート定義・ロードバランス方式を変更する場合必須) 
      #                   [Integer] :instance_port                 - 変更対象の宛先ポート(ポート定義・ロードバランス方式を変更する場合必須) 
      #                   [String] :listener_protocol              - プロトコルの更新値
      #                    許可値: HTTP | HTTPS | FTP
      #                   [Integer] :listener_load_balancer_port   - 待ち受けポートの更新値
      #                   [Integer] :listener_instance_port        - 宛先ポートの更新値
      #                   [String] :listener_balancing_type        - ロードバランス方式の更新値
      #                    許可値: 1(Round-Robin) | 2(Least-Connection) 
      #  @option options [String] :network_volume_update          最大ネットワーク流量の更新値
      #   許可値: 10 | 20 | 30 | 40 | 100 | 200　（単位： Mbps）
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   update_load_balancer(:load_balancer_name => 'lb1', :listener_update => {:listener_protocol => 'https', :balancing_type => 2}, :network_volume_update => 20)
      #
      def update_load_balancer( options={} )
        raise ArgumentError, "No :load_balancer_name provided." if blank?(options[:load_balancer_name])
        raise ArgumentError, "Invalid :load_balancer_name provided." unless LOAD_BALANCER_NAME =~ options[:load_balancer_name].to_s
        raise ArgumentError, "No :load_balancer_port provided." if blank?(options[:load_balancer_port]) && (!blank?(options[:listener_load_balancer_port]) || 
                                                                                                            !blank?(options[:listener_instance_port]) || 
                                                                                                            !blank?(options[:listener_protocol]) || 
                                                                                                            !blank?(options[:listener_balancing_type]) || 
                                                                                                            !blank?(options[:instance_port]))
        raise ArgumentError, "Invalid :load_balancer_port provided." unless blank?(options[:load_balancer_port]) || 
          valid_port?(options[:load_balancer_port])
        raise ArgumentError, "No :instance_port provided." if blank?(options[:instance_port]) && !blank?(options[:load_balancer_port])
        raise ArgumentError, "Invalid :instance_port provided." unless blank?(options[:instance_port]) || 
          valid_port?(options[:instance_port])
        raise ArgumentError, "Invalid :listener_protocol provided." unless blank?(options[:listener_protocol]) || 
          LOAD_BALANCER_PROTOCOL.include?(options[:listener_protocol].to_s.upcase)
        raise ArgumentError, "Invalid :listener_load_balancer_port provided." unless blank?(options[:listener_load_balancer_port]) || 
          valid_port?(options[:listener_load_balancer_port])
        raise ArgumentError, "Invalid :listener_instance_port provided." unless blank?(options[:listener_instance_port]) || 
          valid_port?(options[:listener_instance_port])
        raise ArgumentError, "Invalid :listener_balancing_type provided." unless blank?(options[:listener_balancing_type]) || 
          BALANCING_TYPE.include?(options[:listener_balancing_type].to_s)
        raise ArgumentError, "Invalid :network_volume_update provided." unless blank?(options[:network_volume_update]) || 
          NETWORK_VOLUMES.include?(options[:network_volume_update].to_s)

        params = {
          'Action' => 'UpdateLoadBalancer',
          'ListenerUpdate.Listener.Protocol' => options[:listener_protocol].to_s, 
          'ListenerUpdate.Listener.LoadBalancerPort' => options[:listener_load_balancer_port].to_s, 
          'ListenerUpdate.Listener.InstancePort' => options[:listener_instance_port].to_s, 
          'ListenerUpdate.Listener.BalancingType' => options[:listener_balancing_type].to_s 
        }
        params.merge!(opts_to_prms(options, [:load_balancer_name, :network_volume_update]))
        params.merge!(opts_to_prms(options, [:load_balancer_port, :instance_port], 'ListenerUpdate'))
        
        return response_generator(params)
      end
    end
  end
end
