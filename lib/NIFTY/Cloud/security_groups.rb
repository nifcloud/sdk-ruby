module NIFTY
  module Cloud
    class Base < NIFTY::Base
      FILTER_NAME   = ['description', 'group-name']
      IP_PROTOCOL   = ['TCP', 'UDP', 'ICMP', 'SSH', 'HTTP', 'HTTPS', 'SMTP', 'POP3', 'IMAP', 'ANY']
      IN_OUT        = ['IN', 'OUT']
      DATE_FORMAT   = %r!^(\d{8}|\d{4}-\d{2}-\d{2}|\d{4}/\d{2}/\d{2})$!
      GROUP_NAME    = Regexp.union(/^[a-zA-Z0-9]+$/, 'default(Linux)', 'default(Windows)')
      SECURITY_GROUPS_IGNORED_PARAMS = Regexp.union(/UserId/, 
                                                    /IpPermissions\.\d+\.ToPort/, 
                                                    /IpPermissions\.\d+\.Groups\.\d+\.UserId/)
      SECURITY_GROUP_COURSE = ['1', '2']
      NUMERIC = /^[0-9]+$/

      # API「AuthorizeSecurityGroupIngress」を実行し、指定したファイアウォールグループへ許可ルールを追加します。
      # 許可ルールの上限数を超える場合は、エラーが返されます。
      # ファイアウォールグループを指定するためには、ファイアウォールグループ名が必要です。削除済みのファイアウォールグループを指定した、
      # 管理外のファイアウォールグループを指定したなど、無効なファイアウォールグループを指定した場合は、エラーが返されます。
      #
      #  @option options [String] :group_name           対象のファイアウォールグループ名(必須)
      #  @option options [Array<Hash>] :ip_permissions  IP許可設定
      #   <Hash> options  [String] :protocol             - 許可プロトコル名
      #                    許可値: TCP | UDP | ICMP | SSH | HTTP | HTTPS
      #                   [Integer] :from_port           - 許可ポート(:protocolがTCP、UDPの場合は必須)
      #                   [String] :in_out               - Incoming/Outgoing 指定
      #                    許可値: IN(Incoming) | OUT(Outgoing)
      #                   [Array<String>] :group_name    - 許可するファイアウォールグループ名(:cidr_ipとどちらか必須)
      #                   [Array<String>] :cidr_ip       - 許可するIP アドレス(CIDR指定可) (:group_nameとどちらか必須)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   authorize_security_group_ingress(:group_name => 'gr1', :ip_permissions => [{:protocol => 'TCP',
      #                                                                               :from_port => 80,
      #                                                                               :in_out => 'IN',
      #                                                                               :group_name => ['gr1', 'gr2'],
      #                                                                               :cidr_ip => ['111.171.200.1/22', '111.111.111.112']} ])
      #
      def authorize_security_group_ingress( options = {} )
        raise ArgumentError, "No :group_name provided." if blank?(options[:group_name])
        raise ArgumentError, "Invalid :group_name provided." unless GROUP_NAME =~ options[:group_name].to_s
        raise ArgumentError, "No :ip_permissions provided." if blank?(options[:ip_permissions])
        [options[:ip_permissions]].flatten.each do |opt|
          raise ArgumentError, "expected each element of arr_of_hashes to be a Hash" unless opt.is_a?(Hash)
          raise ArgumentError, "Invalid :ip_protocol provided." unless blank?(opt[:ip_protocol]) || IP_PROTOCOL.include?(opt[:ip_protocol].to_s.upcase)
          raise ArgumentError, "No :from_port provided." if /TCP|UDP/ =~ opt[:ip_protocol] && blank?(opt[:from_port])
          raise ArgumentError, "Invalid :from_port provided." unless blank?(opt[:from_port]) || valid_port?(opt[:from_port])
          raise ArgumentError, "Invalid :to_port provided." unless blank?(opt[:to_port]) || valid_port?(opt[:to_port])
          raise ArgumentError, "Invalid :in_out provided." unless blank?(opt[:in_out]) || IN_OUT.include?(opt[:in_out].to_s.upcase)
          raise ArgumentError, ":group_name or :cidr_ip must be provided." if blank?(opt[:group_name]) && blank?(opt[:cidr_ip])
          raise ArgumentError, "Invalid :group_name provided." unless blank?(opt[:group_name]) || GROUP_NAME =~ opt[:group_name].to_s
          [opt[:cidr_ip]].flatten.each do |ip|
            begin IPAddr.new(ip.to_s) rescue raise ArgumentError, "Invalid :cidr_ip provided." end
          end unless blank?(opt[:cidr_ip])

          opt[:user_id] = [opt[:user_id]].flatten unless blank?(opt[:user_id])
          opt[:group_name] = [opt[:group_name]].flatten unless blank?(opt[:group_name])
          opt[:cidr_ip] = [opt[:cidr_ip]].flatten unless blank?(opt[:cidr_ip])
        end unless blank?(options[:ip_permissions])

        params = {'Action' => 'AuthorizeSecurityGroupIngress'}
        params.merge!(opts_to_prms(options, [:user_id, :group_name]))
        unless blank?(options[:ip_permissions])
          params.merge!(pathhashlist('IpPermissions', options[:ip_permissions], 
                                     { :ip_protocol  => 'IpProtocol',
                                       :from_port    => 'FromPort',
                                       :to_port      => 'ToPort',
                                       :in_out       => 'InOut', 
                                       :user_id => 'Groups', 
                                       :group_name => 'Groups', 
                                       :cidr_ip => 'IpRanges'}, 
                                       { :user_id => 'UserId', 
                                         :group_name => 'GroupName', 
                                         :cidr_ip => 'CidrIp'}))
        end

        params.reject! {|k, v| SECURITY_GROUPS_IGNORED_PARAMS =~ k } if @@ignore_amz_params

        return response_generator(params)
      end


      # API「CreateSecurityGroup」を実行し、ファイアウォールグループを新規作成します。
      # ファイアウォールの有償版に申し込んでいない場合は、エラーが返されます。
      # すでに存在するファイアウォールグループ名を指定した、作成可能なファイアウォールグループの上限数を超える場合は、エラーが返されます。
      # ファイアウォールの有償版を申し込むには、コントロールパネルで設定する必要があります。
      #
      #  @option options [String] :group_name         ファイアウォールグループ名(必須)
      #   使用可能文字: 半角英数字
      #  @option options [String] :group_description  ファイアウォールグループのメモ
      #  @option options [String] :availability_zone  ゾーン情報
      #  @return [Hash] レスポンスXML解析結果
      #  
      #  @example
      #   create_security_group(:group_name => 'group01', :group_description => 'Security Group memo.')
      #
      def create_security_group( options={} )
        raise ArgumentError, "No :group_name provided." if blank?(options[:group_name])
        raise ArgumentError, "Invalid :group_name provided." unless ALPHANUMERIC =~ options[:group_name].to_s

        params = {'Action' => 'CreateSecurityGroup'}
        params.merge!(opts_to_prms(options, [:group_name, :group_description]))
        params.merge!(opts_to_prms(options, [:availability_zone], 'Placement'))

        return response_generator(params)
      end


      # API「DeleteSecurityGroup」を実行し、指定したファイアウォールグループを削除します。
      # 指定したファイアウォールグループを適用しているサーバーが存在する場合、エラーが返されます。同様に、適用しているオートスケール設定が存在する場合、
      # エラーが返されます。
      # ファイアウォールグループを指定するためには、ファイアウォールグループ名が必要です。
      # 削除済みのファイアウォールグループを指定した、管理外のファイアウォールグループを指定したなど、無効なファイアウォールグループを指定した場合は、
      # エラーが返されます。
      #
      #  @option options [String] :group_name   対象のファイアウォールグループ名(必須)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   delete_security_group(:group_name => 'group01')
      #
      def delete_security_group( options={} )
        raise ArgumentError, "No :group_name provided" if blank?(options[:group_name])
        raise ArgumentError, "Invalid :group_name provided." unless ALPHANUMERIC =~ options[:group_name].to_s

        params = { 
          'Action' => 'DeleteSecurityGroup',
          'GroupName' => options[:group_name].to_s 
        }

        return response_generator(params)
      end


      # API「DeregisterInstancesFromSecurityGroup」を実行し、指定したファイアウォールグループから、指定したサーバーをはずします。
      # ファイアウォールグループを指定するためには、ファイアウォールグループ名が必要です。削除済みのファイアウォールグループを指定した、
      # 管理外のファイアウォールグループを指定したなど、無効なファイアウォールグループを指定した場合は、エラーが返されます。
      # またサーバーを指定するためには、サーバー名が必要です。指定したファイアウォールグループに適用されていないサーバーを指定した、
      # 削除済みのサーバーを指定した、管理外のサーバーを指定したなど、無効なサーバーを指定した場合は、エラーが返されます。
      #
      #  @option options [String] :group_name           ファイアウォールグループ名(必須)
      #  @option options [Array<String>] :instance_id   サーバー名(必須)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   deregister_instances_from_security_group(:group_name => 'group01', :instance_id => ['server01', 'server02'])
      #
      def deregister_instances_from_security_group( options={} )
        raise ArgumentError, "No :group_name provided." if blank?(options[:group_name])
        raise ArgumentError, "Invalid :group_name provided." unless GROUP_NAME =~ options[:group_name].to_s
        raise ArgumentError, "No :instance_id provided." if blank?(options[:instance_id])

        params = { 
          'Action'    => 'DeregisterInstancesFromSecurityGroup',
          'GroupName' => options[:group_name].to_s
        }
        params.merge!(pathlist('InstanceId', options[:instance_id]))

        return response_generator(params)
      end


      # API「DescribeSecurityActivities」を実行し、指定したファイアウォールグループのログ情報を取得します。
      # ファイアウォールグループを指定するためには、ファイアウォールグループ名が必要です。削除済みのファイアウォールグループを指定した、
      # 管理外のファイアウォールグループを指定したなど、無効なファイアウォールグループを指定した場合は、エラーが返されます。
      #
      #  @option options [String] :group_name           ファイアウォールグループ名(必須)
      #  @option options [String] :activity_date        取得するログの絞り込み条件(日)
      #   形式: yyyymmdd | yyyy-mm-dd | yyyy/mm/dd
      #  @option options [Boolean] :range_all           指定日内のログを全件取得
      #   許可値: true(全件取得) | false(件数指())
      #  @option options [Integer] :range_start_number  取得開始件数
      #   許可値: 1 - 取得可能な最大件数
      #  @option options [Integer] :range_end_number    取得終了件数
      #   許可値: 1 - 取得可能な最大件数
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   describe_security_activities(:group_name => 'group01', :activity_date => '2011-06-08', :range_all => false, 
      #                                 :range_start_number => 1, :range_end_number => 10)
      #
      def describe_security_activities( options={} )
        raise ArgumentError, "No :group_name provided." if blank?(options[:group_name])
        raise ArgumentError, "Invalid :group_name provided." unless GROUP_NAME =~ options[:group_name].to_s
        raise ArgumentError, "Invalid :activity_date provided." unless blank?(options[:activity_date]) || DATE_FORMAT =~ options[:activity_date].to_s
        raise ArgumentError, "Invalid :range_all provided." unless blank?(options[:range_all]) || BOOLEAN.include?(options[:range_all].to_s)
        raise ArgumentError, "Invalid :range_start_number provided." unless blank?(options[:range_start_number]) || options[:range_start_number].to_s.to_i >= 1
        raise ArgumentError, "Invalid :range_end_number provided." unless blank?(options[:range_end_number]) || (options[:range_end_number]).to_s.to_i >= 1
        raise ArgumentError, "Invalid :range_end_number provided." unless blank?(options[:range_start_number]) || blank?(options[:range_end_number]) || 
          options[:range_start_number] <= options[:range_end_number]

        params = {
          'Action'            => 'DescribeSecurityActivities',
          'GroupName'         => options[:group_name].to_s,
          'ActivityDate'      => options[:activity_date].to_s,
          'Range.All'         => options[:range_all].to_s,
          'Range.StartNumber' => options[:range_start_number].to_s,
          'Range.EndNumber'   => options[:range_end_number].to_s
        }

        return response_generator(params)
      end


      # API「DescribeSecurityGroups」を実行し、指定したファイアウォールグループの設定情報を取得します。
      # ファイアウォールグループを指定するためには、ファイアウォールグループ名が必要です。指定しない場合は、取得可能なすべての
      # ファイアウォールグループの設定情報を取得します。
      #
      #  @option options [String] :group_name     ファイアウォールグループ名
      #  @option options [Array<Hash>] :filter    フィルター設定
      #   <Hash> options  [String] 絞り込み条件の項目名
      #                    許可値: description | group-name 
      #                   [String] 絞り込み条件の値 （前方一致）
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   describe_security_groups(:group_name => 'group01', :filter => [ {'description' => 'filter1'}, {'group-name' => ['filter1', 'filter2']} ])
      #
      def describe_security_groups( options={} )
        [options[:group_name]].flatten.each do |e|
          raise ArgumentError, "Invalid :group_name provided." unless GROUP_NAME =~ options[:group_name].to_s
        end unless blank?(options[:group_name])

        params = {'Action' => 'DescribeSecurityGroups'}
        params.merge!(pathlist("GroupName", options[:group_name]))
        unless blank?(options[:filter])
          [options[:filter]].flatten.each do |opt|
            raise ArgumentError, "expected each element of arr_of_hashes to be a Hash" unless opt.is_a?(Hash)
            raise ArgumentError, "Invalid :name provided." unless blank?(opt[:name]) || FILTER_NAME.include?(opt[:name].to_s) 
            
            opt[:value] = [opt[:value]].flatten unless blank?(opt[:value])
          end

          params.merge!(pathhashlist('Filter', options[:filter], {:name => 'Name', :value => 'Value'}))
        end

        return response_generator(params)
      end


      # API「RegisterInstancesWithSecurityGroup」を実行し、指定したファイアウォールグループを、指定したサーバーへ適用します。
      # ファイアウォールグループを指定するためには、ファイアウォールグループ名が必要です。削除済みのファイアウォールグループを指定した、
      # 管理外のファイアウォールグループを指定したなど、無効なファイアウォールグループを指定した場合は、エラーが返されます。
      # またサーバーを指定するためには、サーバー名が必要です。すでにファイアウォールグループに適用されているサーバーを指定した、
      # 削除済みのサーバーを指定した、管理外のサーバーを指定したなど、無効なサーバーを指定した場合は、エラーが返されます。
      #
      #  @option options [String] :group_name           ファイアウォールグループ名(必須)
      #  @option options [Array<String>] :instance_id   サーバー名(必須)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   register_instances_with_security_group(:group_name => 'group01', :instance_id => ['server02', 'server03'])
      #
      def register_instances_with_security_group( options={} )
        raise ArgumentError, "No :group_name provided." if blank?(options[:group_name])
        raise ArgumentError, "Invalid :group_name provided." unless GROUP_NAME =~ options[:group_name].to_s
        raise ArgumentError, "No :instance_id provided." if blank?(options[:instance_id])

        params = { 
          'Action'    => 'RegisterInstancesWithSecurityGroup',
          'GroupName' => options[:group_name]
        }
        params.merge!(pathlist('InstanceId', options[:instance_id]))

        return response_generator(params)
      end


      # API「RevokeSecurityGroupIngress」を実行し、指定したファイアウォールグループから許可ルールを削除します。
      # ファイアウォールグループを指定するためには、ファイアウォールグループ名が必要です。削除済みのファイアウォールグループを指定した、
      # 管理外のファイアウォールグループを指定したなど、無効なファイアウォールグループを指定した場合は、エラーが返されます。
      # また許可ルールを指定するためには、設定されている 許可プロトコル名・許可ポート・許可するファイアウォールグループまたは許可するIPアドレスが必要です。
      # 該当する許可ルールが存在しない場合は、エラーが返されます。
      #
      #  @option options [String] :group_name           対象のファイアウォールグループ名(必須)
      #  @option options [Array<Hash>] :ip_permissions  IP許可設定
      #   <Hash> options  [String] :protocol             - 許可プロトコル名
      #                    許可値: TCP | UDP | ICMP | SSH | HTTP | HTTPS
      #                   [Integer] :from_port           - 許可ポート(:protocolがTCP、UDPの場合は必須)
      #                   [String] :in_out               - Incoming/Outgoing 指定
      #                    許可値: IN(Incoming) | OUT(Outgoing) 
      #                   [Array<String>] :group_name    - 許可するファイアウォールグループ名(:cidr_ipとどちらか必須)
      #                   [Array<String>] :cidr_ip       - 許可するIP アドレス(CIDR指定可) (:group_nameとどちらか必須)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   revoke_security_group_ingress(:group_name => 'gr1', :ip_permissions => [{:protocol => 'TCP',
      #                                                                            :from_port => 80,
      #                                                                            :in_out => 'IN',
      #                                                                            :group_name => ['gr1', 'gr2'],
      #                                                                            :cidr_ip => ['111.171.200.1/22', '111.111.111.112']} ])
      #  
      def revoke_security_group_ingress( options={} )
        raise ArgumentError, "No :group_name provided." if blank?(options[:group_name])
        raise ArgumentError, "Invalid :group_name provided." unless GROUP_NAME =~ options[:group_name].to_s
        raise ArgumentError, "No :ip_permissions provided." if blank?(options[:ip_permissions])
        [options[:ip_permissions]].flatten.each do |opt|
          raise ArgumentError, "expected each element of arr_of_hashes to be a Hash" unless opt.is_a?(Hash)
          raise ArgumentError, "Invalid :ip_protocol provided." unless blank?(opt[:ip_protocol]) || IP_PROTOCOL.include?(opt[:ip_protocol].to_s.upcase)
          raise ArgumentError, "No :from_port provided." if /TCP|UDP/ =~ opt[:ip_protocol] && blank?(opt[:from_port])
          raise ArgumentError, "Invalid :from_port provided." unless blank?(opt[:from_port]) || valid_port?(opt[:from_port])
          raise ArgumentError, "Invalid :to_port provided." unless blank?(opt[:to_port]) || valid_port?(opt[:to_port])
          raise ArgumentError, "Invalid :in_out provided." unless blank?(opt[:in_out]) || IN_OUT.include?(opt[:in_out].to_s.upcase)
          raise ArgumentError, ":group_name or :cidr_ip must be provided." if blank?(opt[:group_name]) && blank?(opt[:cidr_ip])
          raise ArgumentError, "Invalid :group_name provided." unless blank?(opt[:group_name]) || GROUP_NAME =~ opt[:group_name].to_s
          [opt[:cidr_ip]].flatten.each do |ip|
            begin IPAddr.new(ip.to_s) rescue raise ArgumentError, "Invalid :cidr_ip provided." end
          end unless blank?(opt[:cidr_ip])

          opt[:user_id] = [opt[:user_id]].flatten unless blank?(opt[:user_id])
          opt[:group_name] = [opt[:group_name]].flatten unless blank?(opt[:group_name])
          opt[:cidr_ip] = [opt[:cidr_ip]].flatten unless blank?(opt[:cidr_ip])
        end unless blank?(options[:ip_permissions])

        params = {'Action' => 'RevokeSecurityGroupIngress'}
        params.merge!(opts_to_prms(options, [:user_id, :group_name]))
        unless blank?(options[:ip_permissions])
          params.merge!(pathhashlist('IpPermissions', [options[:ip_permissions]].flatten, 
                                     { :ip_protocol  => 'IpProtocol',
                                       :from_port    => 'FromPort',
                                       :to_port      => 'ToPort',
                                       :in_out       => 'InOut', 
                                       :user_id => 'Groups', 
                                       :group_name => 'Groups', 
                                       :cidr_ip => 'IpRanges'}, 
                                       { :user_id => 'UserId', 
                                         :group_name => 'GroupName', 
                                         :cidr_ip => 'CidrIp'}))
        end

        params.reject! {|k, v| SECURITY_GROUPS_IGNORED_PARAMS =~ k } if @@ignore_amz_params

        return response_generator(params)
      end


      # API「UpdateSecurityGroup」を実行し、ファイアウォールグループの設定情報を更新します。
      # ファイアウォールグループを指定するためには、ファイアウォールグループ名が必要です。削除済みのファイアウォールグループを指定した、
      # 管理外のファイアウォールグループを指定したなど、無効なファイアウォールグループを指定した場合は、エラーが返されます。
      #
      # ファイアウォールグループの設定情報の更新には、時間がかかることがあります。
      #
      # API「DescribeSecurityGroups」のレスポンス値「groupStatus」でファイアウォールグループのステータスを確認できます。
      # また、ファイアウォールグループのステータスが「適用済み」の場合、更新した情報が正しくファイアウォールグループに反映されているかの確認が必要です。
      # 同じくAPI「DescribeSecurityGroups」のレスポンス値で確認できます。
      #
      #  @option options [String] :group_name                   ファイアウォールグループ名(必須)
      #  @option options [String] :group_name_update            ファイアウォールグループ名の変更
      #  @option options [String] :group_description_update     ファイアウォールグループのメモの変更
      #  @option options [Integer] :group_log_limit_update      ファイアウォールグループのログ取得件数の変更
      #  @option options [Boolean] :group_log_filter_net_bios   WindowsサーバのBroadcast通信ログの抑止状態
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   update_security_group(:group_name => 'group01', :group_name_update => 'group02', :group_description_update => 'Security Group memo.Updated.')
      #
      def update_security_group( options={} )
        raise ArgumentError, "No :group_name provided." if blank?(options[:group_name])
        raise ArgumentError, "Invalid :group_name provided." unless GROUP_NAME =~ options[:group_name].to_s
        raise ArgumentError, "Invalid :group_name_update provided." unless blank?(options[:group_name_update]) || ALPHANUMERIC =~ options[:group_name_update].to_s
        raise ArgumentError, "Invalid :group_log_limit_update provided." unless blank?(options[:group_log_limit_update]) || NUMERIC =~ options[:group_log_limit_update].to_s
        raise ArgumentError, "Invalid :group_log_filter_net_bios provided." unless blank?(options[:group_log_filter_net_bios]) || BOOLEAN.include?(options[:group_log_filter_net_bios].to_s)

        params = {'Action' => 'UpdateSecurityGroup'}
        params.merge!(opts_to_prms(options, [:group_name, :group_name_update, :group_description_update, :group_log_limit_update, :group_log_filter_net_bios]))

        return response_generator(params)
      end


      # API「UpdateSecurityGroupOption」を実行し、ファイアウォールのオプション情報を更新します。
      #
      # 利用コースを変更する場合は、注意事項に同意しなければ、エラーが返されます。
      #
      # （※）当該APIはv1.11以降、正常応答では常に応答フィールドreturnにtrueが返されます。
      #
      #  @option options [String] :course_update                 有償・無償の指定
      #   許可値: 1(無償) | 2(有償)
      #  @option options [Boolean] :agreement                    注意事項に同意(:course_updateが2の場合は必須)
      #  @option options [Integer] :security_group_limit_update  ファイアウォールグループ数上限
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   update_security_group_option(:course_update => 2, :agreement => true)
      #
      def update_security_group_option( options={} )
        raise ArgumentError, "No :agreement provided." if options[:course_update].to_s == '2' && blank?(options[:agreement])
        raise ArgumentError, "Invalid :course_update provided." unless blank?(options[:course_update]) || SECURITY_GROUP_COURSE.include?(options[:course_update].to_s)
        raise ArgumentError, "Invalid :agreement provided." unless blank?(options[:agreement]) || BOOLEAN.include?(options[:agreement].to_s)
        raise ArgumentError, "Invalid :security_group_limit_update provided." unless blank?(options[:security_group_limit_update]) || NUMERIC =~ options[:security_group_limit_update].to_s

        params = {'Action' => 'UpdateSecurityGroupOption'}
        params.merge!(opts_to_prms(options, [:course_update, :security_group_limit_update]))
        params.merge!(opts_to_prms(options, [:agreement], 'CourseUpdate'))

        return response_generator(params)
      end


      # API「DescribeSecurityGroupOption」を実行し、ファイアウォールのオプション利用情報を取得します。
      #
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   describe_security_group_option()
      #
      def describe_security_group_option( options={} )
        params = {'Action' => 'DescribeSecurityGroupOption'}

        return response_generator(params)
      end
    end
  end
end

