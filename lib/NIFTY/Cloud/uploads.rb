module NIFTY
  module Cloud
    class Base < NIFTY::Base
      ATTRIBUTE = 'test'

      # API「DescribeUploads」を実行し、アップロード中のタスク情報を返却します。
      #
      # アップロードタスクを指定するためには、タスクIDが必要です。
      #
      # タスクIDを指定した場合、指定したIDのアップロードタスクの情報が返されます。
      # タスクIDを指定しなかった場合は、現在アップロード・インポート中のすべてのタスクが返されます。
      #
      # すでにインポートが完了したタスクやキャンセル済みのタスクなど、無効なタスクIDを指定した場合は、エラーが返されます。
      #
      #  @option options [Array<String>] :conversion_task_id タスクID
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   describe_uploads(:conversion_task_id => ['d6f1ba72-0a76-4b1d-8421-a4f6089d3d7a', 'd6f1ba72-0a76-4b1d-8421-a4f6089d3d7b'])
      #
      def describe_uploads( options={} )
        params = {'Action' => 'DescribeUploads'}
        params.merge!(pathlist('ConversionTaskId', options[:conversion_task_id]))

        return response_generator(params)
      end


      # API「CancelUpload」を実行し、サーバーインポートの処理をキャンセルします。
      # アップロード済みのVMDKファイルは削除されます。
      #
      # アップロードタスクを指定するためには、タスクIDが必要です。
      # すでにインポートが完了したタスクやキャンセル済みのタスクなど、無効なタスクIDを指定した場合は、エラーが返されます。
      #
      #  @option options [String] :conversion_task_id  タスクID(必須) 
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   cancel_upload(:conversion_task_id => 'f6dd8353-eb6b-6b4fd32e4f05')
      #
      def cancel_upload( options={} )
        raise ArgumentError, "No :conversion_task_id provided." if blank?(options[:conversion_task_id])

        params = {'Action' => 'CancelUpload'}
        params.merge!(opts_to_prms(options, [:conversion_task_id]))

        return response_generator(params)
      end
    end   # end of Base class
  end     # end of Cloud module
end       # end of NIFTY module
