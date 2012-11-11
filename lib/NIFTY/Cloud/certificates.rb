module NIFTY
  module Cloud
    class Base < NIFTY::Base
      VALIDITY_TERM                   = ['6', '12', '24']
      KEY_LENGTH                      = ['1024', '2048']
      CERTIFICATE_DESCRIBE_ATTRIBUTE  = ['count', 'certState', 'period', 'keyLength', 'uploadState', 'description', 'certInfo', 'certAuthority']
      FILE_TYPE                       = ['1', '2', '3']
      CERT_AUTHORITY                  = ['1', '2']

      # API「CreateSslCertificate」を実行し、SSL 証明書の新規作成または更新を行います。
      # 申請法人情報が未登録の場合は、エラーが返されます。
      # パラメーター「fqdnId」を指定した場合、指定したSSL 証明書を更新します。指定したSSL 証明書の有効期間が更新可能ではない、
      # アップロードした証明書を指定した、存在しないSSL 証明書を指定した場合など、無効なSSL 証明書を指定した場合は、エラーが返されます。
      # パラメーター「fqdnId」を指定しない場合、SSL 証明書を新規作成します。作成可能なSSL 証明書の上限数を超える場合は、エラーが返されます。
      # また申請法人情報を登録するには、API「RegisterCorporateInfoForCertificate」を実行します。
      #
      #  @option options [String] :fqdn_id                  SSL証明書の識別子(必須)
      #  @option options [String] :fqdn                     FQDN(必須)
      #  @option options [Integer] :cert_authority          認証局(必須)
      #   許可値: 1 (cybertrust) | 2 (GeoTrust)
      #  @option options [Integer] :count                   SSL証明書の数量(必須)
      #   許可値: 1 - 30
      #  @option options [Integer] :validity_term           SSL証明書の有効月数(必須)
      #   許可値: 6 (半年) | 12 (1年) | 24 (2年)
      #  @option options [Integer] :key_length              SSL証明書の鍵長(必須)
      #   許可値: 1024 (1024bit) | 2048 (2048bit)
      #  @option options [String] :organization_name        申請組織名(必須)
      #  @option options [String] :organization_unit_name   申請部署名(必須)
      #  @option options [String] :state_name               事業所住所の都道府県名(必須)
      #  @option options [String] :location_name            事業所住所の市区町村名(必須)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   create_ssl_certificate(:fqdn => 'aaa.aaa.aaa', :count => 2, :validity_term => 24, :key_length => 1024, :organization_name => 'NIFTY', 
      #                           :organization_unit_name => 'Center Department', :state_name => 'Tokyo', :location_name => 'Shinagawa-ku')
      #
      def create_ssl_certificate( options={} )
        raise ArgumentError, ":fqdn_id or :fqdn must be provided." if blank?(options[:fqdn_id]) && blank?(options[:fqdn])
        unless blank?(options[:fqdn])
          raise ArgumentError, "No :cert_authority provided." if blank?(options[:cert_authority])
          raise ArgumentError, "No :count provided." if blank?(options[:count])
          raise ArgumentError, "No :validity_term provided." if blank?(options[:validity_term])
          raise ArgumentError, "No :key_length provided." if blank?(options[:key_length])
          raise ArgumentError, "No :organization_name provided." if blank?(options[:organization_name])
          raise ArgumentError, "No :organization_unit_name provided." if blank?(options[:organization_unit_name])
          raise ArgumentError, "No :state_name provided." if blank?(options[:state_name])
          raise ArgumentError, "No :location_name provided." if blank?(options[:location_name])
        end
        raise ArgumentError, "Invalid :count provided." unless blank?(options[:count]) || ('1'..'30').to_a.include?(options[:count].to_s)
        raise ArgumentError, "Invalid :cert_authority provided." unless blank?(options[:cert_authority]) || CERT_AUTHORITY.include?(options[:cert_authority].to_s)
        raise ArgumentError, "Invalid :validity_term provided." unless blank?(options[:validity_term]) || 
          VALIDITY_TERM.include?(options[:validity_term].to_s)
        raise ArgumentError, "Invalid :key_length provided." unless blank?(options[:key_length]) || KEY_LENGTH.include?(options[:key_length].to_s)

        params = {'Action' => 'CreateSslCertificate'}
        params.merge!(opts_to_prms(options, [:fqdn_id, :fqdn, :cert_authority, :count, :validity_term, :key_length]))
        params.merge!(opts_to_prms(options, [:organization_name, :organization_unit_name, :country_name, 
                                   :state_name, :location_name, :email_address], 'CertInfo'))

        return response_generator(params)
      end


      # API「DeleteSslCertificate」を実行し、指定したSSL 証明書を削除します。
      # 指定したSSL 証明書のステータスが「期限切れ」「失効」「発行エラー」以外の場合は、エラーが返されます。
      # またアップロードしたSSL証明書は、ステータスに関わらず削除できます。
      # SSL 証明書を指定するためには、SSL 証明書の発行識別子（fqdnId）が必要です。削除済みのSSL 証明書を指定した、
      # 管理外のSSL 証明書を指定したなど、無効なSSL 証明書を指定した場合は、エラーが返されます。
      #
      #  @option options [String] :fqdn_id  SSL証明書の識別子(必須)
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   delete_ssl_certificate(:fqdn_id => 111)
      #
      def delete_ssl_certificate( options={} )
        raise ArgumentError, "No :fqdn_id provided." if blank?(options[:fqdn_id])

        params = {
          'Action'  => 'DeleteSslCertificate',
          'FqdnId'  => options[:fqdn_id].to_s
        }

        return response_generator(params)
      end


      # API「DescribeSslCertificates」を実行し、指定したSSL 証明書の情報を取得します。
      # SSL証明書を指定するためには、SSL 証明書の発行識別子（fqdnId）またはFQDN が必要です。
      # 指定しない場合は、取得可能なすべてのSSL証明書の情報を取得します。
      #
      #  @option options [Array<String>] :fqdn_id   SSL証明書の識別子
      #  @option options [Array<String>] :fqdn      FQDN
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   describe_ssl_certificates(:fqdn_id => 111, :fqdn => 'aaa.aaa.aaa.')
      #
      def describe_ssl_certificates( options={} )
        params = {'Action' => 'DescribeSslCertificates'}
        params.merge!(pathlist('Fqdn', options[:fqdn]))
        params.merge!(pathlist('FqdnId', options[:fqdn_id]))

        return response_generator(params)
      end


      # API「DescribeSslCertificateAttribute」を実行し、指定したSSL証明書の詳細情報を取得します。
      # 1回のリクエストで、指定したSSL証明書のどれか1つの詳細情報を取得できます。
      # SSL証明書を指定するためには、SSL 証明書の発行識別子（fqdnId）が必要です。削除済みのSSL証明書を指定した、
      # 管理外のSSL証明書を指定したなど、無効なSSL 証明書を指定した場合は、エラーが返されます。
      #
      #  @option options [String] :fqdn_id    SSL証明書の識別子(必須)
      #  @option options [String] :attribute  取得する情報の項目名
      #   許可値: certAuthority(SSL証明書の認証局を取得) | count(SSL証明書の数量を取得) | certState(SSL証明書の発行ステータスを取得) |
      #           period(SSL証明書の有効期間を取得) | keyLength(SSL証明書の鍵長を取得) | uploadState(SSL証明書の種別を取得) |
      #           description(SSL証明書のメモ情報を取得) | certInfo(SSL証明書の発行申請情報を取得)
      #   
      #  @return [Hash] レスポンスXML解析結果
      #  
      #  @example
      #   describe_ssl_certificate_attribute(:fqdn_id => 111, :attribute => 'certInfo')
      #
      def describe_ssl_certificate_attribute( options={} )
        raise ArgumentError, "No :fqdn_id provided." if blank?(options[:fqdn_id])
        raise ArgumentError, "Invalid :attribute provided." unless blank?(options[:attribute]) || 
          CERTIFICATE_DESCRIBE_ATTRIBUTE.include?(options[:attribute].to_s)

        params = {'Action' => 'DescribeSslCertificateAttribute'}
        params.merge!(opts_to_prms(options, [:fqdn_id, :attribute]))

        return response_generator(params)
      end


      # API「DownloadSslCertificate」を実行し、指定したSSL証明書をダウンロードします。
      # 1回のリクエストで、SSL証明書のキー・CA・証明書のいずれかを取得できます。
      # SSL証明書を指定するためには、SSL 証明書の発行識別子（fqdnId）が必要です。削除済みのSSL証明書を指定した、
      # 管理外のSSL証明書を指定したなど、無効なSSL証明書を指定した場合は、エラーが返されます。
      # またSSL証明書の発行状況により、指定したファイルがダウンロードできない場合があります。
      #
      #  @option options [String] :fqdn_id    SSL証明書の識別子(必須)
      #  @option options [String] :file_type  ダウンロードするファイル種別(必須)
      #   許可値: 1 (キー) | 2 (CA) | 3 (証明書)
      #  @return [Hash] レスポンスXML解析結果
      #  
      #  @example
      #   download_ssl_certificate(:fqdn_id => 111, :file_type => 1)
      #
      def download_ssl_certificate( options={} )
        raise ArgumentError, "No :fqdn_id provided." if blank?(options[:fqdn_id])
        raise ArgumentError, "No :file_type provided." if blank?(options[:file_type])
        raise ArgumentError, "Invalid :file_type provided." unless FILE_TYPE.include?(options[:file_type].to_s)

        params = {'Action' => 'DownloadSslCertificate'}
        params.merge!(opts_to_prms(options, [:fqdn_id, :file_type]))

        return response_generator(params)
      end


      # API「ModifySslCertificateAttribute」を実行し、指定したSSL 証明書の詳細情報を更新します。1 回のリクエストで、1 つのSSL 証明書の1 つの詳細情報を更新できます。
      # SSL証明書を指定するためには、SSL 証明書の発行識別子（fqdnId）が必要です。削除済みのSSL証明書を指定した、管理外のSSL
      # 証明書を指定したなど、無効なSSL 証明書を指定した場合は、エラーが返されます。
      #
      #  @option options [String] :fqdn_id      SSL証明書の識別子(必須)
      #  @option options [String] :description  SSL 証明書のメモ情報の更新値
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   modify_ssl_certificate_attribute(:fqdn_id => 111, :description => 'For service A')
      #
      def modify_ssl_certificate_attribute( options={} )
        raise ArgumentError, "No :fqdn_id provided." if blank?(options[:fqdn_id])

        params = {
          'Action'  => 'ModifySslCertificateAttribute',
          'FqdnId'  => options[:fqdn_id].to_s,
          'Description.Value' => options[:description].to_s
        }

        return response_generator(params)
      end


      # API「RegisterCorporateInfoForCertificate」を実行し、SSL証明書を管理する申請法人情報を登録または更新します。
      # 利用規約（http://cp.cloud.nifty.com/ssl/trust.txt）をご確認の上、パラメーター「agreement」を指定します。
      #
      #  @option options [Boolean] :agreement       利用規約に同意(必須)
      #   許可値: true (同意する) | false (同意しない)
      #  @option options [String] :tdb_code         帝国データバンクコード
      #  @option options [String] :corp_name        法人名(必須)
      #   使用可能文字: 全角
      #  @option options [String] :corp_grade       法人格(必須)
      #   使用可能文字: 全角
      #   許可値: 株式会社 | 有限会社 | 社団法人 | 財団法人 | 学校法人 | 医療法人 | 医療法人社団 | 特定非営利活動法人 | 
      #           有限責任中間法人 | 中央省庁 | 地方公共団体 | 国立大学法人 | 独立行政法人 | 国家資格取得 | 協同組合 | 協同組合連合会 | 
      #           商工連合会 | 協議会 | 公団 | 公共団体 | その他法人 | その他組合 | その他団体 | その他公共機関
      #  @option options [String] :president_name1  代表者氏名（姓）(必須)
      #   使用可能文字: 全角
      #  @option options [String] :president_name2  代表者氏名（名）(必須)
      #   使用可能文字: 全角
      #  @option options [String] :zip1             郵便番号（上3桁）(必須)
      #   使用可能文字: 半角
      #  @option options [String] :zip2             郵便番号（下4桁）(必須)
      #   使用可能文字: 半角
      #  @option options [String] :pref             都道府県名(必須)
      #   使用可能文字: 全角
      #   許可値: 北海道 | 青森県 | 岩手県 | 宮城県 | 秋田県 | 山形県 | 福島県 | 茨城県 | 栃木県 | 群馬県 | 埼玉県 | 千葉県 | 
      #           東京都 | 神奈川県 | 新潟県 | 富山県 | 石川県 | 福井県 | 山梨県 | 長野県 | 岐阜県 | 静岡県 | 愛知県 | 三重県 | 
      #           滋賀県 | 京都府 | 大阪府| 兵庫県 | 奈良県 | 和歌山県 | 鳥取県 | 島根県 |岡山県 | 広島県 | 山口県 | 徳島県 | 
      #           香川県 | 愛媛県 | 高知県 | 福岡県 | 佐賀県 | 長崎県 | 熊本県 | 大分県 | 宮崎県 | 鹿児島県 | 沖縄県      
      #  @option options [String] :city             市町村名
      #   使用可能文字: 全角
      #  @option options [String] :name1            責任者氏名（姓）(必須)
      #   使用可能文字: 全角
      #  @option options [String] :name2            責任者氏名（名）(必須)
      #   使用可能文字: 全角
      #  @option options [String] :kana_name1       責任者氏名かな（姓）(必須)
      #   使用可能文字: 全角
      #  @option options [String] :kana_name2       責任者氏名かな（名）(必須)
      #   使用可能文字: 全角
      #  @option options [String] :post_name        役職名(必須)
      #   使用可能文字: 全角
      #  @option options [String] :division_name    部署名(必須)
      #   使用可能文字: 全角
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   register_corporate_info_for_certificate(:agreement => true, :corp_name => 'ニフティ', :corp_grade => '株式会社', :president_name1 => 'ニフティ', 
      #                                           :president_name2 => '太郎', :zip1 => 140, :zip2 => 8544, :pref => '東京都', :city => '品川区',
      #                                           :name1 => '山田', :name2 => '花子', :kana_name1 => 'やまだ', :kana_name2 => 'はなこ', :post_name => '部長', 
      #                                           :division_name => '技術部')
      #
      def register_corporate_info_for_certificate( options={} )
        raise ArgumentError, "No :agreement provided." if blank?(options[:agreement])
        raise ArgumentError, "Invalid :agreement provided." unless blank?(options[:agreement]) || BOOLEAN.include?(options[:agreement].to_s)
        raise ArgumentError, "No :corp_name provided." if blank?(options[:corp_name])
        raise ArgumentError, "No :corp_grade provided." if blank?(options[:corp_grade])
        raise ArgumentError, "No :president_name1 provided." if blank?(options[:president_name1])
        raise ArgumentError, "No :president_name2 provided." if blank?(options[:president_name2])
        raise ArgumentError, "No :zip1 provided." if blank?(options[:zip1])
        raise ArgumentError, "Invalid :zip1 provided." unless /^\d{3}$/ =~ options[:zip1].to_s
        raise ArgumentError, "No :zip2 provided." if blank?(options[:zip2])
        raise ArgumentError, "Invalid :zip2 provided." unless /^\d{4}$/ =~ options[:zip2].to_s
        raise ArgumentError, "No :pref provided." if blank?(options[:pref])
        raise ArgumentError, "No :city provided." if blank?(options[:city])
        raise ArgumentError, "No :name1 provided." if blank?(options[:name1])
        raise ArgumentError, "No :name2 provided." if blank?(options[:name2])
        raise ArgumentError, "No :kana_name1 provided." if blank?(options[:kana_name1])
        raise ArgumentError, "No :kana_name2 provided." if blank?(options[:kana_name2])
        raise ArgumentError, "No :post_name provided." if blank?(options[:post_name])
        raise ArgumentError, "No :division_name provided." if blank?(options[:division_name])

        params = {'Action' => 'RegisterCorporateInfoForCertificate'}
        params.merge!(opts_to_prms(options, 
                                   [:agreement, :tdb_code, :corp_name, :corp_grade, :president_name1, :president_name2, 
                                     :zip1, :zip2, :pref, :city, :name1, :name2, :kana_name1, :kana_name2, :post_name, :division_name]))

        return response_generator(params)
      end


      # API「UploadSslCertificate」を実行し、指定したSSL証明書をアップロードします。
      # 1回のリクエストで、SSL証明書のキー・CA・証明書の1 セットをアップロードできます。
      # 作成可能なSSL証明書の上限数を超える場合は、エラーが返されます。
      # またアップロードしたファイルの解析に失敗した場合は、エラーが返されます。
      # 
      #  @option options [String] :certificate  証明書ファイル(必須)
      #  @option options [String] :key          秘密鍵ファイル(必須)
      #  @option options [String] :ca           CA（認証局）ファイル
      #  @return [Hash] レスポンスXML解析結果
      #
      #  @example
      #   upload_ssl_certificate(:certificate => 'xxxxxxxxxxxxxxxxxxxxxx', :key => 'xxxxxxxxxxx')
      #
      def upload_ssl_certificate( options={} )
        raise ArgumentError, "No :certificate provided." if blank?(options[:certificate])
        raise ArgumentError, "No :key provided." if blank?(options[:key])

        params = {'Action' => 'UploadSslCertificate'}
        params.merge!(opts_to_prms(options, [:certificate, :key, :ca]))

        return response_generator(params)
      end
    end
  end
end
