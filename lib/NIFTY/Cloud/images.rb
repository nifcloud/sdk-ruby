module NIFTY
  module Cloud
    class Base < NIFTY::Base
      IMAGES_MODIFY_ATTRIBUTE     = ['description', 'imageName']
      IMAGES_DESCRIBE_OWNER       = ['niftycloud', 'self']
      IMAGES_IGNORED_PARAMS       = Regexp.union(/Description/, 
                                                 /NoReboot/, 
                                                 /ExecutableBy\.\d+/, 
                                                 /LaunchPermission\.Add\.\d+\.UserId/, 
                                                 /LaunchPermission\.Add\.\d+\.Group/, 
                                                 /LaunchPermission\.Remove\.\d+\.UserId/, 
                                                 /LaunchPermission\.Remove\.\d+\.Group/, 
                                                 /ProductCode\.\d+/)

      # API「DescribeImages」を実行し、OS イメージの情報を取得します。
      # 特定のOS イメージを指定するためには、OS イメージID またはOS イメージ名が必要です。OS イメージを指定しない場合は、
      # 取得可能なすべてのOS イメージ情報を取得します。無効なOS イメージを指定した場合は、エラーが返されます。
      #
      #  @option options [Array<String>] :image_id   OSイメージID
      #  @option options [Array<String>] :image_name OSイメージ名
      #  @option options [Array<String>] :owner      OSイメージの種別
      #   許可値: niftycloud | self
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   describe_images(:image_id => [12000, 11001], :image_name => ['image01', 'image02'], :owner => ['niftycloud', 'self'])
      #
      def describe_images( options = {} )
        [options[:owner]].flatten.each{|o| raise ArgumentError, "Invalid :owner provided." unless IMAGES_DESCRIBE_OWNER.include?(o) } unless blank?(options[:owner])
        raise ArgumentError, "Invalid :image_id provided." unless blank?(options[:image_id]) || options[:image_id].to_s.to_i > 0
        
        params = {'Action' => 'DescribeImages'}
        params.merge!(pathlist("ExecutableBy", options[:executable_by]))
        params.merge!(pathlist("ImageId", options[:image_id]))
        params.merge!(pathlist("ImageName", options[:image_name]))
        params.merge!(pathlist("Owner", options[:owner]))

        params.reject! {|k, v| IMAGES_IGNORED_PARAMS =~ k } if @@ignore_amz_params

        return response_generator(params)
      end


      # API「CreateImage」を実行し、指定したサーバーをイメージ化し、カスタマイズイメージとして保存します。
      # サーバーをイメージ化するためには、サーバーを停止する必要があります。
      # カスタマイズイメージの作成には、時間がかかることがあります。このAPI のレスポンス「imageState」を確認し「pending」が返ってきた、
      # タイムアウトした場合は、API「DescribeImages」のレスポンス「imageState」でカスタマイズイメージのステータスを確認できます。
      # 処理が失敗した場合、カスタマイズイメージは保存されず、エラーが返されます。
      #
      #  @option options [String] :instance_id         イメージ化元サーバー(必須)
      #  @option options [String] :name                イメージ名(必須)
      #  @option options [Boolean] :left_instance      イメージ化元サーバーを残す
      #  @option options [String] :region_name         リージョン情報
      #  @option options [String] :availability_zone   ゾーン情報
      #   許可値: true(サーバーを残す) | false(サーバーを残さない) 
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   create_image(:instance_id => 'server01', :name => 'image01', :left_instance => true)
      #
      def create_image( options = {} )
        raise ArgumentError, "No :instance_id provided" if blank?(options[:instance_id])
        raise ArgumentError, "No :name provided" if blank?(options[:name])
        raise ArgumentError, "Invalid :left_instance provided. only 'true' or 'false' allowed." unless blank?(options[:left_instance]) || 
          BOOLEAN.include?(options[:left_instance].to_s)

        params = { 'Action' => 'CreateImage' }
        params.merge!(opts_to_prms(options, [:instance_id, :name, :description, :no_reboot, :left_instance]))
        params.merge!(opts_to_prms(options, [:region_name, :availability_zone], 'Placement'))

        params.reject! {|k, v| IMAGES_IGNORED_PARAMS =~ k } if @@ignore_amz_params

        return response_generator(params)
      end


      # API「DeleteImage」を実行し、指定したカスタマイズイメージを削除します。
      # 削除中のカスタマイズイメージを指定してサーバー作成を行った場合は、サーバー作成からエラーが返されます。
      # カスタマイズイメージを選択して作成されたサーバーのOSイメージ名は、カスタマイズイメージの削除が完了すると、イメージ化した
      # サーバーのOS 名が返されます。
      #
      #  @option options [String] :image_id 削除対象のイメージID(必須)
      #   許可値: 10000以降の数値
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   delete_image(:image_id => 10430)
      #
      def delete_image( options={} )
        raise ArgumentError, "No :image_id provided." if blank?(options[:image_id])
        raise ArgumentError, "Invalid :image_id provided." unless options[:image_id].to_s.to_i >= 10000

        params = { 
          'Action'  => 'DeleteImage',
          'ImageId' => options[:image_id].to_s
        }

        return response_generator(params)
      end


      # API「ModifyImageAttribute」を実行し、指定したカスタマイズイメージの詳細情報を更新します。1 回のリクエストで、1 つのカスタマイズイメージの情報を更新できます。
      # カスタマイズイメージを指定するためには、イメージID が必要です。削除済みのイメージID を指定した、管理外のイメージID を指定したなど、
      # 無効なイメージID を指定した場合は、エラーが返されます。
      #
      #  @option options [String] :image_id   更新対象のイメージID(必須)
      #   許可値: 10000以降の数値
      #  @option options [String] :attribute  更新対象の項目名(必須)
      #   許可値:  description | imageName 
      #  @option options [String] :attribute  更新値
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   modify_image_attribute(:image_id => 10000, :attribute => 'description', :value => 'メモ')
      #
      def modify_image_attribute( options={} )
        raise ArgumentError, "No :image_id provided." if blank?(options[:image_id])
        raise ArgumentError, "Invalid :image_id provided." unless options[:image_id].to_s.to_i >= 10000
        raise ArgumentError, "No :attribute provided." if blank?(options[:attribute])
        raise ArgumentError, "Invalid :attribute provided." unless blank?(options[:attribute]) || IMAGES_MODIFY_ATTRIBUTE.include?(options[:attribute])

        params = {'Action' => 'ModifyImageAttribute'}
        params.merge!(opts_to_prms(options, [:image_id, :attribute, :value]))
        params.merge!(pathhashlist('LaunchPermission.Add', options[:launch_permission_add], 
                                   {:user_id => 'UserId', :group => 'Group'})) unless blank?(options[:launch_permission_add])
        params.merge!(pathhashlist('LaunchPermission.Remove', options[:launch_permission_remove], 
                                   {:user_id => 'UserId', :group => 'Group'})) unless blank?(options[:launch_permission_remove])
        params.merge!(pathlist('ProductCode', options[:product_code]))

        params.reject! {|k, v| IMAGES_IGNORED_PARAMS =~ k } if @@ignore_amz_params

        return response_generator(params)
      end
    end
  end
end

