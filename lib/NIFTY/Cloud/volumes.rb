module NIFTY
  module Cloud
    class Base < NIFTY::Base
      VOLUMES_CREATE_SIZE       = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '15', '20']
      VOLUMES_CREATE_DISK_TYPE  = ['1', '2', '3', '4', '5', '6']
      VOLUMES_IGNORED_PARAMS    = Regexp.union(/SnapshotId/, 
                                               /AvailabilityZone/, 
                                               /Device/, 
                                               /Force/)
      VOLUMES_MODIFY_ATTRIBUTE    = ['accountingType']

      # API「AttachVolume」を実行し、指定したディスクをサーバーへ接続します。
      # ディスクを指定するためには、ディスク名が必要です。接続済み・削除済みのディスクを指定した、管理外のディスクを指定したなど、
      # 無効なディスクを指定した場合は、エラーが返されます。
      # またサーバーを指定するためには、サーバー名が必要です。接続済み・削除済みのサーバーを指定した、管理外のサーバーを指定したなど、
      # 無効なサーバーを指定した場合は、エラーが返されます。
      #
      #  @option options [String] :volume_id   サーバーに接続するディスク名(必須)
      #  @option options [String] :instance_id 接続先のサーバー名(必須)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   attach_volume(:volume_id => 'vol1', :instance_id => 'server01')
      #
      def attach_volume( options = {} )
        raise ArgumentError, "No :volume_id provided." if blank?(options[:volume_id])
        raise ArgumentError, "No :instance_id provided." if blank?(options[:instance_id])

        params = { 'Action' => 'AttachVolume' }
        params.merge!(opts_to_prms(options, [:volume_id, :instance_id, :device]))

        params.reject! {|k, v| VOLUMES_IGNORED_PARAMS =~ k } if @@ignore_amz_params

        return response_generator(params)
      end


      # API「CreateVolume」を実行し、ディスクを新規作成します。
      # サーバーを指定するためには、サーバー名が必要です。削除済みのサーバーを指定した、管理外のサーバーを指定した、停止済み
      # 以外のサーバーを指定したなど、無効なサーバーを指定した場合は、エラーが返されます。同様に、ディスクサイズおよびディスク
      # タイプに規定外の値を指定した、すでに存在するディスク名を指定したなどの場合は、エラーが返されます。
      #
      #  @option options [String] :size             ディスクサイズ(必須)
      #   許可値: (低速) 1(100) | 2(200) | 3(300) | 4(400) | 5(500) | 10(1000) | 15(1500) | 20(2000)
      #           (高速) 1(100) | 2(200) | 3(300) | 4(400) | 5(500) | 6(600) | 7(700) | 8(800) | 9(900) | 10(1000)　（単位： GB）
      #  @option options [String] :volume_id        ディスク名
      #  @option options [String] :disk_type        ディスクタイプ
      #   許可値: 1(disk100) | 2(disk40) | 3(disk100A) | 4(disk100B) | 5(disk40A) | 6(disk40B)
      #  @option options [String] :instance_id      サーバー名(必須)
      #  @option options [String] :accounting_type  利用料金タイプ
      #   許可値: 1(月額課金) | 2(従量課金)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   create_volume(:size => 1, :volume_id => 'vol1', :disk_type => 1, :instance_id => 'server01', :accounting_type => 1)
      #   
      def create_volume( options = {} )
        raise ArgumentError, "No :size provided." if blank?(options[:size])
        raise ArgumentError, "No :instance_id provided." if blank?(options[:instance_id])
        raise ArgumentError, "Invalid :size provided." unless blank?(options[:size]) || VOLUMES_CREATE_SIZE.include?(options[:size].to_s)
        raise ArgumentError, "Invalid :disk_type provided." unless blank?(options[:disk_type]) || VOLUMES_CREATE_DISK_TYPE.include?(options[:disk_type].to_s)
        raise ArgumentError, "Invalid :accounting_type provided." unless blank?(options[:accounting_type]) || ACCOUNTING_TYPE.include?(options[:accounting_type].to_s)

        params = {'Action' => 'CreateVolume'}
        params.merge!(opts_to_prms(options, [:size, :snapshot_id, :availability_zone, :volume_id, :disk_type, :instance_id, :accounting_type]))

        params.reject! {|k, v| VOLUMES_IGNORED_PARAMS =~ k } if @@ignore_amz_params

        return response_generator(params)
      end


      # API「DeleteVolume」を実行し、指定したディスクを削除します。
      # ディスクを指定するためには、ディスク名が必要です。接続済み・削除済みのディスクを指定した、管理外のディスクを指定したなど、
      # 無効なディスクを指定した場合は、エラーが返されます。
      # 削除には、時間がかかることがあります。
      # なお、サーバーに接続しているディスクを指定した場合には、エラーが返されます。ディスクの接続ステータスは、API
      # 「DescribeVolumes」のレスポンス「attachmentSet.status」で確認できます。
      #
      #  @option options [String] :volume_id 削除対象のディスク名(必須)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   delete_volume(:volume_id => 'vol1')
      #
      def delete_volume( options = {} )
        raise ArgumentError, "No :volume_id provided." if blank?(options[:volume_id])

        params = {
          'Action' => 'DeleteVolume',
          'VolumeId' => options[:volume_id].to_s
        }
        
        return response_generator(params)
      end
        

      # API「DescribeVolumes」を実行し、指定したディスクの情報を取得します。
      # ディスクを指定するためには、ディスク名が必要です。削除済みのディスクを指定した、管理外のディスクを指定したなど、
      # 無効なディスクを指定した場合は、エラーが返されます。
      # ディスクを指定しない場合、取得できるすべてのディスク情報を取得します。
      #
      #  @option options [Array<String>] :volume_id ディスク名
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   describe_volumes(:volume_id => ['vol1', 'vol2'])
      #
      def describe_volumes( options = {} )
        params = {'Action' => 'DescribeVolumes'}
        params.merge!(pathlist("VolumeId", options[:volume_id]))

        return response_generator(params)
      end
     

      # API「DetachVolume」を実行し、指定したディスクとサーバーの接続を解除します。
      # ディスクを指定するためには、ディスク名が必要です。解除済み・削除済みのディスクを指定した、管理外のディスクを指定したなど、
      # 無効なディスクを指定した場合は、エラーが返されます。
      # またサーバーを指定するためには、サーバー名が必要です。解除済み・削除済みのサーバーを指定した、管理外のサーバーを指定したなど、
      # 無効なサーバーを指定した場合は、エラーが返されます。サーバー名を指定せずに解除すると、指定したディスクのすべての接続情報を解除します。
      #
      #  @option options [String] :volume_id    接続解除対象のディスク名(必須)
      #  @option options [String] :instance_id  接続解除されるサーバー名
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   detach_volume(:volume_id => 'vol1', :instance_id => 'server01')
      #
      def detach_volume( options = {} )
        raise ArgumentError, "No :volume_id provided." if blank?(options[:volume_id])
        raise ArgumentError, "Invalid :force provided." unless blank?(options[:force]) || BOOLEAN.include?(options[:force].to_s)

        params = { 'Action' => 'DetachVolume' }
        params.merge!(opts_to_prms(options,[:volume_id, :instance_id, :device, :force]))

        params.reject! {|k, v| VOLUMES_IGNORED_PARAMS =~ k } if @@ignore_amz_params

        return response_generator(params)
      end


      # API「ModifyVolumeAttribute」を実行し、指定したディスクの詳細情報を更新します。利用料金タイプの更新は次月から適用されます。
      #
      #  @option options [String] :instance_id  サーバー名(必須)
      #  @option options [String] :attribute    更新対象の項目名(必須)
      #   許可値: accountingType(利用料金タイプを更新)
      #   
      #  @option options [String] :value        更新値(必須)
      #   許可値: (:attribute= accountingType) 1(月額課金) | 2(従量課金)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   modify_volume_attribute(:volume_id => 'vol01', :attribute => 'accountingType', :value => '1')
      #
      def modify_volume_attribute( options = {} )
        raise ArgumentError, "No :volume_id provided." if blank?(options[:volume_id])
        raise ArgumentError, "No :attribute provided." if blank?(options[:attribute])
        raise ArgumentError, "Invalid :attribute provided." unless VOLUMES_MODIFY_ATTRIBUTE.include?(options[:attribute].to_s)
        raise ArgumentError, "No :value provided." if blank?(options[:value])
        raise ArgumentError, "Invalid :value provided." if options[:attribute] == 'accountingType' && !ACCOUNTING_TYPE.include?(options[:value].to_s)

        params = {'Action' => 'ModifyVolumeAttribute'}
        params.merge!(opts_to_prms(options, [:volume_id, :attribute, :value]))

        params.reject! {|k, v| VOLUMES_IGNORED_PARAMS =~ k } if @@ignore_amz_params

        return response_generator(params)
      end
    end
  end
end

