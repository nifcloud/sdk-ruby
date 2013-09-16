module NIFTY
  module Cloud
    class Base < NIFTY::Base
      INSTANCE_TYPE                 = ['mini', 'small', 'small2', 'small4', 'small8', 'medium', 'medium4', 'medium8', 'medium16',
                                       'large', 'large8', 'large16', 'large24', 'large32', 'extra-large16', 'extra-large24', 'extra-large32',
                                       'double-large32', 'double-large48', 'double-large64']
      ACCOUNTING_TYPE               = ['1', '2']
      BOOLEAN                       = ['true', 'false']
      IP_TYPE                       = ['static', 'dynamic', 'none']
      INSTANCES_DESCRIBE_ATTRIBUTE  = [
        'instanceType', 'disableApiTermination', 'blockDeviceMapping', 'accountingType', 'nextMonthAccountingType',
        'loadbalancing', 'copyInfo', 'autoscaling', 'ipType', 'groupId', 'description']
      INSTANCES_MODIFY_ATTRIBUTE    = ['instanceType', 'disableApiTermination', 'instanceName', 'description', 'ipType', 'groupId', 'accountingType']
      INSTANCES_IGNORED_PARAMS      = Regexp.union(/MinCount/, 
                                                   /MaxCount/, 
                                                   /AddisionalInfo/, 
                                                   /UserData/, 
                                                   /AddressingType/, 
                                                   /Placement.GroupName/, 
                                                   /KernelId/, 
                                                   /RamdiskId/,
                                                   /BlockDeviceMapping.*/, 
                                                   /Monitoring\.Enabled/, 
                                                   /SubnetId/, 
                                                   /InstanceInitiatedShutdownBehavior/)
      WINDOWS_IMAGE_ID              = ['12', '16']

      # API「DescribeInstanceAttribute」を実行し、指定したサーバーの詳細情報を取得します。1回のリクエストで、指定したサーバーのどれか1つの詳細情報を取得できます。
      # サーバーを指定するためには、サーバー名が必要です。削除済みのサーバーを指定した、管理外のサーバーを指定したなど、
      # 無効なサーバーを指定した場合は、エラーが返されます。
      #
      #  @option options  [String] :instance_id  サーバー名(必須)
      #  @option options  [String] :attribute    取得対象の項目名
      #   許可値: instanceType | disableApiTermination | blockDeviceMapping | accountingType | nextMonthAccountingType | loadbalancing | copyInfo | autoscaling | ipType | groupId | description
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example 
      #   describe_instance_attribute(:instance_id => 'server01', :attribute => 'instanceType')
      #
      def describe_instance_attribute( options = {} )
        raise ArgumentError, "No :instance_id provided." if blank?(options[:instance_id])
        raise ArgumentError, "Invalid :attribute provided." unless blank?(options[:attribute]) || INSTANCES_DESCRIBE_ATTRIBUTE.include?(options[:attribute].to_s)

        params = {'Action' => 'DescribeInstanceAttribute'}
        params.merge!(opts_to_prms(options, [:instance_id, :attribute]))

        return response_generator(params)
      end


      # API「DescribeInstances」を実行し、指定したサーバーの情報を取得します。1 回のリクエストで、複数のサーバー情報を取得できます。
      # サーバーを指定するためには、サーバー名が必要です。サーバーを指定しない場合は、取得可能なすべてのサーバー情報を取
      # 得します。削除済みのサーバーを指定した、管理外のサーバーを指定したなど、無効なID を指定した場合は、エラーが返されます。
      #
      #  @option options [Array<String>] :instance_id サーバー名
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example 
      #   describe_instances(:instance_id => 'server01')
      #
      def describe_instances( options = {} )
        params = {'Action' => 'DescribeInstances'}
        params.merge!(pathlist('InstanceId', options[:instance_id]))

        return response_generator(params)
      end


      # API「ModifyInstanceAttribute」を実行し、指定したサーバーの詳細情報を更新します。1 回のリクエストで、1 つのサーバーの情報を更新できます。
      # サーバーを指定するためには、サーバー名が必要です。削除済みのサーバーを指定した、管理外のサーバーを指定したなど、
      # 無効なサーバーを指定した場合は、エラーが返されます。
      # なお、起動済みのサーバーを指定した場合は、エラーが返されます。サーバーのステータスは、API「DescribeInstances」のレスポン
      # ス値「instanceState」で確認できます。
      #
      #  @option options [String] :instance_id  サーバー名(必須)
      #  @option options [String] :attribute    更新対象の項目名(必須)
      #   許可値: instanceType(サーバータイプを更新) | disableApiTermination(API からのサーバー削除可否を更新) | instanceName(サーバー名を更新) | 
      #           description(メモ情報を更新) | ipType(IP アドレスの固定化タイプを更新) | groupId(ファイアウォールグループを更新) |
      #           accountingType(利用料金タイプを更新)
      #   
      #  @option options [String] :value        更新値(必須)
      #   許可値: (:attribute= instanceType) mini | small | small2 | small4 | small8 | medium | medium4 | medium8 | medium16 | large | large8 | large16 | large24 | large32 | extra-large16 | extra-large24 | extra-large32
      #           (:attribute= disableApiTermination) true | false 
      #           (:attribute= ipType) static | dynamic | none
      #           (:attribute= accountingType) 1(月額課金) | 2(従量課金)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   modify_instance_attribute(:instance_id => 'server01', :attribute => 'instanceType', :value => 'mini')
      #
      def modify_instance_attribute( options = {} )
        raise ArgumentError, "No :instance_id provided." if blank?(options[:instance_id])
        raise ArgumentError, "No :attribute provided." if blank?(options[:attribute])
        raise ArgumentError, "Invalid :attribute provided." unless INSTANCES_MODIFY_ATTRIBUTE.include?(options[:attribute].to_s)
        raise ArgumentError, "No :value provided." if blank?(options[:value])
        raise ArgumentError, "Invalid :value provided." if options[:attribute] == 'instanceType' && !INSTANCE_TYPE.include?(options[:value].to_s)
        raise ArgumentError, "Invalid :value provided." if options[:attribute] == 'disableApiTermination' && !BOOLEAN.include?(options[:value].to_s)
        raise ArgumentError, "Invalid :value provided." if options[:attribute] == 'ipType' && !IP_TYPE.include?(options[:value].to_s)
        raise ArgumentError, "Invalid :value provided." if options[:attribute] == 'accountingType' && !ACCOUNTING_TYPE.include?(options[:value].to_s)

        params = {'Action' => 'ModifyInstanceAttribute'}
        params.merge!(opts_to_prms(options, [:instance_id, :attribute, :value]))

        return response_generator(params)
      end


      # API「RebootInstances」を実行し、指定したサーバーを再起動します。
      # サーバーを指定するためには、サーバー名が必要です。削除済みのサーバーを指定した、管理外のサーバーを指定したなど、
      # 無効なサーバーを指定した場合は、エラーが返されます。
      # サーバーの再起動には、時間がかかることがあります。サーバーのステータスは、API「DescribeInstances」のレスポンス値
      # 「instanceState」で確認できます。
      #
      #  @option options [Array<String>] :instance_id  サーバー名(必須) 
      #  @option options [Boolean] :force              強制オプション
      #   許可値: true(強制実行) | false(強制実行しない)
      #  @option options [String] :user_data           サーバー起動時スクリプト
      #  @option options [Boolean] :base64_encoded     サーバー起動時スクリプトを自動的にBase64 エンコードするかどうか
      #   許可値: true(base64エンコーディングする) | false(base64エンコーディングしない)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   reboot_instances(:instance_id => ['server01', 'server02'], :force => false)
      #
      def reboot_instances( options={} )
        raise ArgumentError, "No :instance_id provided." if blank?(options[:instance_id])
        raise ArgumentError, "Invalid :force provided." unless blank?(options[:force]) || BOOLEAN.include?(options[:force].to_s)

        user_data = extract_user_data(options)
        options[:user_data] = user_data

        params = {
          'Action' => 'RebootInstances',
          'Force' => options[:force].to_s
        }
        params.merge!(pathlist('InstanceId', options[:instance_id]))
        params.merge!(opts_to_prms(options, [:user_data]))

        return response_generator(params)
      end


      # API「RunInstances」を実行し、サーバーを新規作成します。1 回のリクエストで、1 つのサーバーを作成できます。
      # サーバーの作成には、時間がかかることがあります。このAPI のレスポンス「instanceState」を確認し「pending」が返ってきた、
      # タイムアウトした場合は、API「DescribeInstances」のレスポンス値「instanceState」でサーバーのステータスを確認できます。
      # 処理が失敗した場合、サーバーは作成されず、エラーが返されます。
      # またファイアウォール機能を提供していない環境でファイアウォールグループを指定して実行した場合は、エラーが返されます。
      #
      #  @option options [String] :image_id                   OSイメージID名(必須)
      #  @option options [String] :key_name                   SSHキー名
      #  @option options [Array<String>] :security_group      適用するファイアフォールグループ名
      #  @option options [String] :user_data                  サーバー起動時スクリプト
      #  @option options [Boolean] :base64_encoded            サーバー起動時スクリプトを自動的にBase64 エンコードするかどうか
      #   許可値: true(base64エンコーディングする) | false(base64エンコーディングしない)
      #  @option options [String] :instance_type              サーバータイプ
      #   許可値: mini | small | small2 | small4 | small8 | medium | medium4 | medium8 | medium16 | large | large8 | large16 | large24 | large32 | extra-large16 | extra-large24 | extra-large32
      #  @option options [Boolean] :disable_api_termination   APIからのサーバー削除の可否 
      #   許可値: true(削除不可) | false(削除可)
      #  @option options [String] :accounting_type            利用料金タイプ
      #   許可値: 1(月額課金) | 2(従量課金)
      #  @option options [String] :instance_id                サーバー名
      #  @option options [String] :admin                      管理者アカウント
      #  @option options [String] :password                   管理者アカウントパスワード
      #   許可値: 半角英数字
      #  @option options [String] :ip_type                    IPアドレスタイプ
      #   許可値: static | dynamic | none
      #  @option options [Boolean] :agreement                 Red Hat Enterprise Linux 5.8 64bit / 6.3 64bit を指定した場合の同意
      #   許可値: true (同意する) | false (同意しない)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   run_instances(:image_id => 1, :key_name => 'foo', :security_group => ['gr1', 'gr2'], :instance_type => 'mini',
      #                 :instance_id => 'server01', :password => 'pass', :ip_type => 'static')
      #
      def run_instances( options={} )
        options = {:base64_encoded => false}.merge(options)

        raise ArgumentError, "No :image_id provided." if blank?(options[:image_id])
        raise ArgumentError, "Invalid :image_id provided." unless options[:image_id].to_s.to_i > 0
        raise ArgumentError, "Invalid :key_name provided." unless blank?(options[:key_name]) || ALPHANUMERIC =~ options[:key_name].to_s
        #raise ArgumentError, "No :security_group provided." if blank?(options[:security_group])
        raise ArgumentError, "Invalid :security_group provided." unless blank?(options[:security_group]) || GROUP_NAME =~ options[:security_group].to_s
        raise ArgumentError, "No :password provided." if WINDOWS_IMAGE_ID.include?(options[:image_id].to_s) && blank?(options[:password])
        raise ArgumentError, "Invalid :password provided." unless blank?(options[:password]) || ALPHANUMERIC =~ options[:password].to_s
        raise ArgumentError, "Invalid :instance_type provided." unless blank?(options[:instance_type]) || INSTANCE_TYPE.include?(options[:instance_type].to_s)
        raise ArgumentError, "Invalid :disable_api_termination provided." unless blank?(options[:disable_api_termination]) || 
          BOOLEAN.include?(options[:disable_api_termination].to_s)
        raise ArgumentError, "Invalid :accounting_type provided." unless blank?(options[:accounting_type]) || ACCOUNTING_TYPE.include?(options[:accounting_type].to_s)
        raise ArgumentError, "Invalid :ip_type provided." unless blank?(options[:ip_type]) || IP_TYPE.include?(options[:ip_type].to_s)
        raise ArgumentError, ":base64_encoded must be 'true' or 'false'." unless [true, false].include?(options[:base64_encoded])
        raise ArgumentError, "Invalid :agreement provided." unless blank?(options[:agreement]) || BOOLEAN.include?(options[:agreement].to_s)

        user_data = extract_user_data(options)
        options[:user_data] = user_data

        params = {
          'Action' => 'RunInstances',
          'Monitoring.Enabled' => options[:monitoring_enabled].to_s
        }
        params.merge!(pathlist('SecurityGroup', options[:security_group]))
        params.merge!(pathhashlist('BlockDeviceMapping', options[:block_device_mapping], 
                                   {:device_name => 'DeviceName', :virtual_name => 'VirtualName', :ebs_snapshot_id => 'Ebs.SnapshotId', 
                                     :ebs_volume_size => 'Ebs.VolumeSize', :ebs_delete_on_termination => 'Ebs.DeleteOnTermination', 
                                     :ebs_no_device => 'Ebs.NoDevice' })) unless blank?(options[:block_device_mapping])
        params.merge!(opts_to_prms(options, [:image_id, :min_count, :max_count, :key_name, :additional_info, :user_data, :addressing_type,
                                        :instance_type, :kernel_id, :ramdisk_id, :subnet_id, :disable_api_termination, :instance_initiated_shutdown_behavior,
                                        :accounting_type, :instance_id, :admin, :password, :ip_type, :agreement]))
        params.merge!(opts_to_prms(options, [:availability_zone, :group_name], 'Placement'))

        params.reject! {|k, v| INSTANCES_IGNORED_PARAMS =~ k } if @@ignore_amz_params

        return response_generator(params)
      end


      # API「StartInstances」を実行し、指定したサーバーを起動します。
      # サーバーを指定するためには、サーバー名が必要です。削除済みのサーバーを指定した、管理外のサーバーを指定したなど、
      # 無効なサーバーを指定した場合は、エラーが返されます。
      # サーバーの起動には、時間がかかることがあります。このAPI のレスポンス「currentState.name」を確認して「pending」が返ってきた場
      # 合は、API「DescribeInstances」のレスポンス値「instanceState」でサーバーのステータスを確認できます。
      #
      #  @option options [Array<String>] :instance_id      サーバー名(必須)
      #  @option options [Array<String>] :instance_type    サーバータイプ
      #   許可値: mini | small | small2 | small4 | small8 | medium | medium4 | medium8 | medium16 | large | large8 | large16 | large24 | large32 | extra-large16 | extra-large24 | extra-large32
      #  @option options [Array<String>] :accounting_type  利用料金タイプ
      #  @option options [String] :user_data               サーバー起動時スクリプト
      #  @option options [Boolean] :base64_encoded         サーバー起動時スクリプトを自動的にBase64 エンコードするかどうか
      #   許可値: true(base64エンコーディングする) | false(base64エンコーディングしない)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   start_instances(:instance_id => ['server01', 'server02'], :instance_type => ['mini', 'small'], :accounting_type => 2)
      #
      def start_instances( options={} )
        raise ArgumentError, "No :instance_id provided." if blank?(options[:instance_id])
        [options[:instance_type]].flatten.each do |p| 
          raise ArgumentError, "Invalid :instance_type provided." unless INSTANCE_TYPE.include?(p.to_s)
        end unless blank?(options[:instance_type])
        [options[:accounting_type]].flatten.each do |p| 
          raise ArgumentError, "Invalid :accounting_type provided." unless ACCOUNTING_TYPE.include?(p.to_s)
        end unless blank?(options[:accounting_type])

        user_data = extract_user_data(options)
        options[:user_data] = user_data

        params = {'Action' => 'StartInstances'}
        params.merge!(pathlist('InstanceId', options[:instance_id]))
        params.merge!(pathlist('InstanceType', options[:instance_type]))
        params.merge!(pathlist('AccountingType', options[:accounting_type]))
        params.merge!(opts_to_prms(options, [:user_data]))

        return response_generator(params)
      end


      # API「StopInstances」を実行し、指定したサーバーを停止します。
      # サーバーを指定するためには、サーバー名が必要です。削除済みのサーバーを指定した、管理外のサーバーを指定したなど、
      # 無効なサーバーを指定した場合は、エラーが返されます。
      # サーバーの停止には、時間がかかることがあります。このAPI のレスポンス「currentState.name」を確認して「pending」が返ってきた
      # 場合は、API「DescribeInstances」のレスポンス値「instanceState」でサーバーのステータスを確認できます。
      # なお、強制オプションに「true」を指定して実行した際に、サーバーが停止できない状態などのエラーが返されることがあります。
      # 強制オプションに「true」を指定して実行した場合には、システムチェックや修復を行うことをおすすめします。
      #
      #  @option options [Array<String>] :instance_id  サーバー名(必須) 
      #  @option options [Boolean] :force              強制オプション
      #   許可値: true | false
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   stop_instances(:instance_id => ['server01', 'server02'], :force => false)
      #
      def stop_instances( options={} )
        raise ArgumentError, "No :instance_id provided." if blank?(options[:instance_id])
        raise ArgumentError, "Invalid :force provided." unless blank?(options[:force]) || BOOLEAN.include?(options[:force].to_s)

        params = {
          'Action' => 'StopInstances',
          'Force' => options[:force].to_s
        }
        params.merge!(pathlist('InstanceId', options[:instance_id]))

        return response_generator(params)
      end


      # API「TerminateInstances」を実行し、指定したサーバーを削除します。
      # サーバーを指定するためには、サーバー名が必要です。削除済みのサーバーを指定した、管理外のサーバーを指定したなど、
      # 無効なサーバーを指定した場合は、エラーが返されます。
      # サーバーの削除には、時間がかかることがあります。このAPI のレスポンス「currentState.name」を確認して「pending」が返ってきた
      # 場合は、API「DescribeInstances」のレスポンス値「instanceState」でサーバーのステータスを確認できます。
      # また、API「DescribeInstances」のレスポンスに該当情報がない場合は、削除処理は成功しています。
      #
      #  @option options [Array<String>] :instance_id サーバー名(必須) 
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example 
      #   terminate_instances(:instance_id => ['server01', 'server02'])
      #
      def terminate_instances( options={} )
        raise ArgumentError, "No :instance_id provided." if blank?(options[:instance_id])
        
        params = {'Action' => 'TerminateInstances'}
        params.merge!(pathlist('InstanceId', options[:instance_id]))

        return response_generator(params)
      end


      # API「CopyInstances」を実行し、指定したサーバーのコピーを作成します。
      # 停止中のサーバーのみ指定ができます。コピー後のサーバー名は、指定したコピー後のサーバー名の後ろに「-連番」が付加され
      # た名称になります。
      # サーバーを指定するためには、サーバー名が必要です。停止中以外のサーバーを指定した、管理外のサーバーを指定したなど、
      # 無効なサーバーを指定した場合は、エラーが返されます。
      # またファイアウォール機能を提供していない環境でファイアウォールグループを指定して実行した場合は、エラーが返されます。
      #
      #  @option options [String] :instance_id            コピー元のサーバー名(必須) 
      #  @option options [String] :instance_name          コピー後のサーバー名(必須) 
      #  @option options [String] :instance_type          サーバータイプ
      #   許可値: mini | small | small2 | small4 | small8 | medium | medium4 | medium8 | medium16 | large | large8 | large16 | large24 | large32 | extra-large16 | extra-large24 | extra-large32
      #  @option options [String] :accounting_type        利用料金タイプ
      #   許可値: 1(月額課金) | 2(従量課金)
      #  @option options [Array<Hash>] :load_balancers    ロードバランサー設定
      #   <Hash> options  [String] :load_balancer_name     - ロードバランサー名
      #                   [Integer] :load_balancer_port    - 待ち受けポート
      #                   [Integer] :instance_port         - 宛先ポート
      #  @option options [Array<String>] :security_group  ファイアウォールグループ名
      #  @option options [Integer] :copy_count            コピー台数
      #  @option options [String] :region_name            リージョン情報
      #  @option options [String] :availability_zone      ゾーン情報
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   copy_instances(:instance_id => 'server01', :instance_name => 'copyserver', :instance_type => 'mini', :accounting_type => 2,
      #                   :load_balancers => [{:load_balancer_name => 'lb1'}, {:load_balancer_port => 80, :instance_port => 80}], 
      #                   :security_group => ['gr1', 'gr2'], :copy_count => 1)
      #
      def copy_instances( options={} )
        raise ArgumentError, "No :instance_id provided." if blank?(options[:instance_id])
        raise ArgumentError, "No :instance_name provided." if blank?(options[:instance_name])
        raise ArgumentError, "Invalid :instance_type provided." unless blank?(options[:instance_type]) || INSTANCE_TYPE.include?(options[:instance_type].to_s)
        raise ArgumentError, "Invalid :accounting_type provided." unless blank?(options[:accounting_type]) || ACCOUNTING_TYPE.include?(options[:accounting_type].to_s)
        raise ArgumentError, "Invalid :ip_type provided." unless blank?(options[:ip_type]) || IP_TYPE.include?(options[:ip_type].to_s)
        unless blank?(options[:load_balancers])
          [options[:load_balancers]].flatten.each do |opt|
            raise ArgumentError, "expected each element of arr_of_hashes to be a Hash" unless opt.is_a?(Hash)
            unless blank?(opt[:load_balancer_name]) && blank?(opt[:load_balancer_port]) && blank?(opt[:instance_port])
              raise ArgumentError, "No :load_balancer_name provided." if blank?(opt[:load_balancer_name])
              raise ArgumentError, "Invalid :load_balancer_name provided." unless LOAD_BALANCER_NAME =~ opt[:load_balancer_name].to_s
              raise ArgumentError, "No :load_balancer_port provided." if blank?(opt[:load_balancer_port])
              raise ArgumentError, "Invalid :load_balancer_port provided." unless valid_port?(opt[:load_balancer_port])
              raise ArgumentError, "No :instance_port provided." if blank?(opt[:instance_port])
              raise ArgumentError, "Invalid :instance_port provided." unless valid_port?(opt[:instance_port])
            end
          end
        end
        #raise ArgumentError, "No :security_group provided." if blank?(options[:security_group])
        raise ArgumentError, "Invalid :security_group provided." unless blank?(options[:security_group]) || GROUP_NAME =~ options[:security_group].to_s
        raise ArgumentError, "Invalid :copy_count provided." unless blank?(options[:copy_count]) || options[:copy_count].to_s.to_i >= 1
        
        params = {
          'Action' => 'CopyInstances', 
          'CopyInstance.ipType' => options[:ip_type].to_s
        }
        params.merge!(pathhashlist('CopyInstance.LoadBalancers', 
                                   options[:load_balancers], 
                                   {:load_balancer_name => 'LoadBalancerName', 
                                     :load_balancer_port => 'LoadBalancerPort', 
                                     :instance_port => 'InstancePort'})) unless blank?(options[:load_balancers])
        params.merge!(pathlist('CopyInstance.SecurityGroup', options[:security_group]))
        params.merge!(opts_to_prms(options, [:instance_id, :copy_count]))
        params.merge!(opts_to_prms(options, [:instance_name, :instance_type, :accounting_type], 'CopyInstance'))
        params.merge!(opts_to_prms(options, [:region_name, :availability_zone], 'CopyInstance.Placement'))

        return response_generator(params)
      end


      # API「CancelCopyInstances」を実行し、指定したサーバーの作成（コピーによる作成）をキャンセルします。
      # 作成待ちのサーバーのみ指定ができます。
      # サーバーを指定するためには、サーバー名が必要です。作成待ち以外のサーバーを指定した、管理外のサーバーを指定したなど、
      # 無効なサーバーを指定した場合は、エラーが返されます。
      #
      #  @option options [String] :instance_id キャンセル対象のサーバー名(必須) 
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   cancel_copy_instances(:instance_id => 'server01')
      #
      def cancel_copy_instances( options={} )
        raise ArgumentError, "No :instance_id provided." if blank?(options[:instance_id])

        params = {
          'Action' => 'CancelCopyInstances',
          'InstanceId' => options[:instance_id].to_s
        }

        return response_generator(params)
      end


      # API「ImportInstance」を実行し、指定したOVFファイルの情報に基づいて、サーバーインポートを予約します。
      # 1回のリクエストで1台のサーバーが予約可能です。
      #
      # イメージ（VMDKファイル）は、別途アップロード領域へアップロードしてください（このAPIのレスポンスに含まれるタスクIDを指定します）。
      #
      # サーバーの作成には、時間がかかることがあります。
      # API「DescribeInstances」のレスポンス値「instanceState」でサーバーのステータスを確認できます。
      #
      # インポートしたサーバーは通常ほかのサーバー作成と同様に課金されますが、ニフティクラウドの基本ディスク容量（Linux:30GB、Windows:40GB）を超えるディスクを持つ場合は100GB単位で追加料金が発生します。
      #
      # ニフティクラウドがサポートしないOS製品である、複数OSのサーバーであるなどの場合はインポートできず、エラーが返されます。
      #
      # インポートしたサーバーは、APIからの削除が可能です。
      # APIからの削除を禁止したい場合は、インポート完了後にAPI「ModifyInstanceAttribute」を実行してください。
      #
      #  @option options [Array<String>] :security_group      適用するファイアフォールグループ名
      #  @option options [String] :instance_type              サーバータイプ
      #   許可値: mini | small | small2 | small4 | small8 | medium | medium4 | medium8 | medium16 | large | large8 | large16 | large24 | large32 | extra-large16 | extra-large24 | extra-large32
      #  @option options [String] :availability_zone
      #  @option options [Boolean] :disable_api_termination   APIからのサーバー削除の可否 
      #   許可値: true(削除不可) | false(削除可)
      #  @option options [String] :instance_id                サーバー名
      #  @option options [String] :ovf                        OVFデータ 
      #  @option options [String] :accounting_type            利用料金タイプ
      #   許可値: 1(月額課金) | 2(従量課金)
      #  @option options [String] :ip_type                    IPアドレスタイプ
      #   許可値: static | dynamic | none
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   import_instance(:ovf => "<?xml ersion='1.0' encoding='UTF-8'><ovf ovf:Enve…</ovf:Envelope>")
      #
      def import_instance( options={} )
        raise ArgumentError, "No :ovf provided." if blank?(options[:ovf])
        #raise ArgumentError, "No :security_group provided." if blank?(options[:security_group])
        raise ArgumentError, "Invalid :security_group provided." unless blank?(options[:security_group]) || GROUP_NAME =~ options[:security_group].to_s
        raise ArgumentError, "Invalid :instance_type provided." unless blank?(options[:instance_type]) || INSTANCE_TYPE.include?(options[:instance_type].to_s)
        raise ArgumentError, "Invalid :disable_api_termination provided." unless blank?(options[:disable_api_termination]) || 
          BOOLEAN.include?(options[:disable_api_termination].to_s)
        raise ArgumentError, "Invalid :accounting_type provided." unless blank?(options[:accounting_type]) || ACCOUNTING_TYPE.include?(options[:accounting_type].to_s)
        raise ArgumentError, "Invalid :ip_type provided." unless blank?(options[:ip_type]) || IP_TYPE.include?(options[:ip_type].to_s)

        params = {'Action' => 'ImportInstance'}
        params.merge!(pathlist('SecurityGroup', options[:security_group]))
        params.merge!(opts_to_prms(options, [:instance_type, :disable_api_termination, :instance_id, :ovf, :accounting_type, :ip_type]))
        params.merge!(opts_to_prms(options, [:availability_zone], 'Placement'))

        return response_generator(params)
      end
    end   # end of Base class
  end     # end of Cloud module
end       # end of NIFTY module
