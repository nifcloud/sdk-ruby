# coding:utf-8
#--
# ニフティクラウドSDK for Ruby
#
# Ruby Gem Name::  nifty-cloud-sdk
# Author::    NIFTY Corporation
# Copyright:: Copyright 2011 NIFTY Corporation All Rights Reserved.
# License::   Distributes under the same terms as Ruby
# Home::      http://cloud.nifty.com/api/
#++

require File.dirname(__FILE__) + '/test_helper.rb'

context "certificates" do
  before do
    @api = NIFTY::Cloud::Base.new( :access_key_id => "not a key", :secret_access_key => "not a secret" ,
                                     :server => 'cp.cloud.nifty.com', :path => '/api/1.7/', :user_agent => 'NIFTY Cloud API Ruby SDK',
                                     :signature_version => '2', :signature_method => 'HmacSHA256')

    @basic_reg_corp_info_params = {
      :agreement => true, :corp_name => 'corpname', :corp_grade => 'grade', 
      :president_name1 => 'pre1', :president_name2 => 'pre2', :zip1 => 123, :zip2 => 4567, :pref => 'TOKYO',
      :city => 'city', :name1 => 'name1', :name2 => 'name2', :kana_name1 => 'kana1', :kana_name2 => 'kana2',
      :post_name => 'post', :division_name => 'div'
    }
    @basic_create_ssl_cert = {
      :fqdn => 'ccc.aaa.com', :cert_authority => 1, :count => 1, :validity_term => 6, :key_length => 1024, :organization_name => 'org', 
      :organization_unit_name => 'orgunit', :state_name => 'TOKYO', :location_name => 'loc'
    }
    @basic_upload_ssl_cert = {:certificate => 'cert', :key => 'key'}

    @valid_validity_term = [6, 12, 24, '6', '12', '24']
    @valid_key_length = [1024, 2048, '1024', '2048']
    @valid_attribute = %w(certAuthority count certState period keyLength uploadState description certInfo)
    @valid_file_type = [1, 2, 3, '1', '2', '3']
    @valid_cert_authority = [1, 2, '1', '2']

    @register_corporate_info_for_certificate_response_body = <<-RESPONSE
    <RegisterCorporateInfoForCertificateResponse xmlns="https://cp.cloud.nifty.com/api/">      
      <requestId>320fc738-a1c7-4a2f-abcb-20813a4e997c</requestId>    
      <tdbCode />    
      <corpName>サンプル</corpName>    
      <corpGrade>株式会社</corpGrade>    
      <presidentName1>山田</presidentName1>    
      <presidentName2>太郎</presidentName2>    
      <zip1>123</zip1>    
      <zip2>4567</zip2>    
      <pref>TOKYO</pref>    
      <city>品川区</city>    
      <name1>山田</name1>    
      <name2>花子</name2>    
      <kanaName1>やまだ</kanaName1>    
      <kanaName2>はなこ</kanaName2>    
      <postName>部長</postName>    
      <divisionName>技術部</divisionName>    
    </RegisterCorporateInfoForCertificateResponse>      
    RESPONSE

    @create_ssl_certificate_response_body = <<-RESPONSE
    <CreateSslCertificateResponse xmlns="https://cp.cloud.nifty.com/api/">      
      <requestId>320fc738-a1c7-4a2f-abcb-20813a4e997c</requestId>    
      <fqdnId>1</fqdnId>    
      <fqdn>ccc.aaa.com</fqdn>    
      <validityTerm>24</validityTerm>    
      <certState>waiting</certState>    
    </CreateSslCertificateResponse>      
    RESPONSE

    @describe_ssl_certificates_response_body = <<-RESPONSE
    <DescribeSslCertificatesResponse xmlns="https://cp.cloud.nifty.com/api/">        
      <requestId>320fc738-a1c7-4a2f-abcb-20813a4e997c</requestId>      
      <certsSet>      
        <item>    
          <fqdnId>2</fqdnId>  
          <fqdn>ccc.aaa.com</fqdn>  
          <count>2</count>  
          <certState>valid</certState>  
          <period>  
            <startDate>2011-02-01</startDate>
            <endDate>2013-01-31</endDate>
          </period>  
          <keyLength>1024</keyLength>  
          <uploadState>false</uploadState>  
          <description />  
          <certInfo>  
            <countryName>JP</countryName>
            <stateName>TOKYO</stateName>
            <locationName>Shinagawa-ku</locationName>
            <organizationName>NIFTY Co.,LTD</organizationName>
            <organizationUnitName>Center Department</organizationUnitName>
            <commonName>Center Department</commonName>
            <emailAddress>admin@nifty.co.jp</emailAddress>
          </certInfo>  
        </item>    
      </certsSet>      
    </DescribeSslCertificatesResponse>        
    RESPONSE

    @describe_ssl_certificate_attribute_response_body = <<-RESPONSE
    <DescribeSslCertificateAttributeResponse xmlns="https://cp.cloud.nifty.com/api/">      
      <requestId>320fc738-a1c7-4a2f-abcb-20813a4e997c</requestId>    
      <fqdnId>2</fqdnId>    
      <fqdn>ccc.aaa.com</fqdn>    
      <certState>    
        <value>valid</value>  
      </certState>    
    </DescribeSslCertificateAttributeResponse>      
    RESPONSE

    @modify_ssl_certificate_attribute_response_body = <<-RESPONSE
    <UpdateSslCertificateResponse xmlns="https://cp.cloud.nifty.com/api/">      
      <requestId>320fc738-a1c7-4a2f-abcb-20813a4e997c</requestId>    
      <return>true</return>    
    </UpdateSslCertificateResponse>      
    RESPONSE

    @delete_ssl_certificate_response_body = <<-RESPONSE
    <DeleteSslCertificateResponse xmlns="https://cp.cloud.nifty.com/api/">      
      <requestId>320fc738-a1c7-4a2f-abcb-20813a4e997c</requestId>    
      <fqdn>ccc.aaa.com</fqdn>    
    </DeleteSslCertificateResponse>      
    RESPONSE

    @upload_ssl_certificate_response_body = <<-RESPONSE
    <UploadSslCertificateResponse xmlns="https://cp.cloud.nifty.com/api/">      
      <requestId>320fc738-a1c7-4a2f-abcb-20813a4e997c</requestId>    
      <fqdnId>2</fqdnId>    
      <fqdn>ccc.aaa.com</fqdn>    
      <keyFingerPrint>xxxxxxxxxxxxx</keyFingerPrint>    
    </UploadSslCertificateResponse>      
    RESPONSE

    @download_ssl_certificate_response_body = <<-RESPONSE
    <DownloadSslCertificateResponse xmlns="https://cp.cloud.nifty.com/api/">      
      <requestId>320fc738-a1c7-4a2f-abcb-20813a4e997c</requestId>    
      <fqdnId>2</fqdnId>    
      <fqdn>ccc.aaa.com</fqdn>    
      <fileData>・・・・・・・・・</fileData>    
    </DownloadSslCertificateResponse>      
    RESPONSE
  end


  # register_corporate_info_for_certificate
  specify "register_corporate_info_for_certificate - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @register_corporate_info_for_certificate_response_body, :is_a? => true)
    response = @api.register_corporate_info_for_certificate(:agreement => true, :corp_name => 'foo', :corp_grade => 'bar', 
                                                            :president_name1 => 'hoge', :president_name2 => 'hoge', :zip1 => 123, :zip2 => 4567, 
                                                            :pref => 'TOKYO', :city => 'foo', :name1 => 'name1', :name2 => 'name2', 
                                                            :kana_name1 => 'kana1', :kana_name2 => 'kana2', :post_name => 'post', :division_name => 'div')
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.tdbCode.should.equal nil
    response.corpName.should.equal 'サンプル'
    response.corpGrade.should.equal '株式会社'
    response.presidentName1.should.equal '山田'
    response.presidentName2.should.equal '太郎'
    response.zip1.should.equal '123'
    response.zip2.should.equal '4567'
    response.pref.should.equal 'TOKYO'
    response.city.should.equal '品川区'
    response.name1.should.equal '山田'
    response.name2.should.equal '花子'
    response.kanaName1.should.equal 'やまだ'
    response.kanaName2.should.equal 'はなこ'
    response.postName.should.equal '部長'
    response.divisionName.should.equal '技術部'
  end

  specify "register_corporate_info_for_certificate - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "RegisterCorporateInfoForCertificate",
                                   "Agreement" => "true",
                                   "TdbCode" => "a",
                                   "CorpName" => "ニフティ",
                                   "CorpGrade" => "株式会社",
                                   "PresidentName1" => "ニフティ",
                                   "PresidentName2" => "太郎",
                                   "Zip1" => "140",
                                   "Zip2" => "8544",
                                   "Pref" => "東京都",
                                   "City" => "品川区",
                                   "Name1" => "山田",
                                   "Name2" => "花子",
                                   "KanaName1" => "やまだ",
                                   "KanaName2" => "はなこ",
                                   "PostName" => "部長",
                                   "DivisionName" => "技術部"
                                  ).returns stub(:body => @register_corporate_info_for_certificate_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @register_corporate_info_for_certificate_response_body, :is_a? => true)
    response = @api.register_corporate_info_for_certificate(:agreement => true, :tdb_code => "a", :corp_name => "ニフティ", :corp_grade => "株式会社", :president_name1 => "ニフティ", :president_name2 => "太郎", :zip1 => "140", :zip2 => "8544", :pref => "東京都", :city => "品川区", :name1 => "山田", :name2 => "花子", :kana_name1 => "やまだ", :kana_name2 => "はなこ", :post_name => "部長", :division_name => "技術部")
  end

  specify "register_corporate_info_for_certificate - 必須パラメータ正常" do
    @api.stubs(:exec_request).returns stub(:body => @register_corporate_info_for_certificate_response_body, :is_a? => true)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:agreement => false)) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:zip1 => '999')) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:zip2 => '8888')) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "register_corporate_info_for_certificate - :tdb_code正常" do
    @api.stubs(:exec_request).returns stub(:body => @register_corporate_info_for_certificate_response_body, :is_a? => true)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:tdb_code => 'code')) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "register_corporate_info_for_certificate - :agreement未指定/不正" do
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.reject{|k,v| k == :agreement}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:agreement => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:agreement => '')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:agreement => 'foo')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "register_corporate_info_for_certificate - :corp_name未指定" do
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.reject{|k,v| k == :corp_name}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:corp_name => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:corp_name => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "register_corporate_info_for_certificate - :corp_grade未指定" do
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.reject{|k,v| k == :corp_grade}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:corp_grade => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:corp_grade => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "register_corporate_info_for_certificate - :president_name1未指定" do
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.reject{|k,v| k == :president_name1}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:president_name1 => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:president_name1 => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "register_corporate_info_for_certificate - :president_name2未指定" do
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.reject{|k,v| k == :president_name2}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:president_name2 => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:president_name2 => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "register_corporate_info_for_certificate - :zip1未指定" do
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.reject{|k,v| k == :zip1}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:zip1 => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:zip1 => '')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:zip1 => 12)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:zip1 => 1234)) }.should.raise(NIFTY::ArgumentError)
  end

  specify "register_corporate_info_for_certificate - :zip2未指定" do
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.reject{|k,v| k == :zip2}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:zip2 => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:zip2 => '')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:zip2 => 123)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:zip2 => 12345)) }.should.raise(NIFTY::ArgumentError)
  end

  specify "register_corporate_info_for_certificate - :pref未指定" do
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.reject{|k,v| k == :pref}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:pref => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:pref => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "register_corporate_info_for_certificate - :city未指定" do
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.reject{|k,v| k == :city}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:city => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:city => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "register_corporate_info_for_certificate - :name1未指定" do
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.reject{|k,v| k == :name1}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:name1 => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:name1 => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "register_corporate_info_for_certificate - :name2未指定" do
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.reject{|k,v| k == :name2}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:name2 => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:name2 => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "register_corporate_info_for_certificate - :kana_name1未指定" do
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.reject{|k,v| k == :kana_name1}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:kana_name1 => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:kana_name1 => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "register_corporate_info_for_certificate - :kana_name2未指定" do
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.reject{|k,v| k == :kana_name2}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:kana_name2 => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:kana_name2 => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "register_corporate_info_for_certificate - :post_name未指定" do
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.reject{|k,v| k == :post_name}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:post_name => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:post_name => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "register_corporate_info_for_certificate - :division_name未指定" do
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.reject{|k,v| k == :division_name}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:division_name => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_corporate_info_for_certificate(@basic_reg_corp_info_params.merge(:division_name => '')) }.should.raise(NIFTY::ArgumentError)
  end


  # create_ssl_certificate
  specify "create_ssl_certificate - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @create_ssl_certificate_response_body, :is_a? => true)
    response = @api.create_ssl_certificate(:fqdn_id => 'fqdn')
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.fqdnId.should.equal '1'
    response.fqdn.should.equal 'ccc.aaa.com'
    response.validityTerm.should.equal '24'
    response.certState.should.equal 'waiting'
  end

  specify "create_ssl_certificate - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "CreateSslCertificate",
                                   "FqdnId" => "a",
                                   "Fqdn" => "aaa.aaa.aaa",
                                   "CertAuthority" => "1",
                                   "Count" => "1",
                                   "ValidityTerm" => "6",
                                   "KeyLength" => "1024",
                                   "CertInfo.OrganizationName" => "a",
                                   "CertInfo.OrganizationUnitName" => "a",
                                   "CertInfo.CountryName" => "a",
                                   "CertInfo.StateName" => "a",
                                   "CertInfo.LocationName" => "a",
                                   "CertInfo.EmailAddress" => "a"
                                  ).returns stub(:body => @create_ssl_certificate_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @create_ssl_certificate_response_body, :is_a? => true)
    response = @api.create_ssl_certificate(:fqdn_id => "a", :fqdn => "aaa.aaa.aaa", :cert_authority => 1, :count => 1, :validity_term => 6, :key_length => 1024, :organization_name => "a", :organization_unit_name => "a", :country_name => "a", :state_name => "a", :location_name => "a", :email_address => "a")
  end

  specify "create_ssl_certificate - :fqdn_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @create_ssl_certificate_response_body, :is_a? => true)
    lambda { @api.create_ssl_certificate(:fqdn_id => 3) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "create_ssl_certificate - :必須パラメータ正常" do
    @api.stubs(:exec_request).returns stub(:body => @create_ssl_certificate_response_body, :is_a? => true)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:count => 15)) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:count => 30)) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:count => '20')) }.should.not.raise(NIFTY::ArgumentError)
    @valid_cert_authority.each do |ca|
      lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:cert_authority => ca)) }.should.not.raise(NIFTY::ArgumentError)
    end
    @valid_validity_term.each do |term|
      lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:validity_term => term)) }.should.not.raise(NIFTY::ArgumentError)
    end
    @valid_key_length.each do |len|
      lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:key_length => len)) }.should.not.raise(NIFTY::ArgumentError)
    end
  end

  specify "create_ssl_certificate - :country_name正常" do
    @api.stubs(:exec_request).returns stub(:body => @create_ssl_certificate_response_body, :is_a? => true)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:country_name => 'JP')) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "create_ssl_certificate - :email_address正常" do
    @api.stubs(:exec_request).returns stub(:body => @create_ssl_certificate_response_body, :is_a? => true)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:email_address => 'aaa@bbb.com')) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "create_ssl_certificate - :fqdn_id, fqdn未指定" do
    lambda { @api.create_ssl_certificate }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(:fqdn_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(:fqdn_id => '') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(:fqdn => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(:fqdn => '') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(:fqdn_id => '', :fqdn => '') }.should.raise(NIFTY::ArgumentError)
  end

  specify "create_ssl_certificate - :cert_authority未指定/不正" do
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.reject{|k,v| k == :cert_authority}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:cert_authority => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:cert_authority => '')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:cert_authority => 'hoge')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:cert_authority => 3)) }.should.raise(NIFTY::ArgumentError)
  end

  specify "create_ssl_certificate - :count未指定" do
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.reject{|k,v| k == :count}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:count => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:count => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "create_ssl_certificate - :validity_term未指定" do
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.reject{|k,v| k == :validity_term}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:validity_term => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:validity_term => '')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:validity_term => 36)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:validity_term => 'foo')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "create_ssl_certificate - :key_length未指定" do
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.reject{|k,v| k == :key_length}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:key_length => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:key_length => '')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:key_length => 4072)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:key_length => 'foo')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "create_ssl_certificate - :organization_name未指定" do
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.reject{|k,v| k == :organization_name}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:organization_name => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:organization_name => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "create_ssl_certificate - :organization_unit_name未指定" do
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.reject{|k,v| k == :organization_unit_name}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:organization_unit_name => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:organization_unit_name => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "create_ssl_certificate - :state_name未指定" do
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.reject{|k,v| k == :state_name}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:state_name => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:state_name => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "create_ssl_certificate - :location_name未指定" do
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.reject{|k,v| k == :location_name}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:location_name => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_ssl_certificate(@basic_create_ssl_cert.merge(:location_name => '')) }.should.raise(NIFTY::ArgumentError)
  end


  # describe_ssl_certificates
  specify "describe_ssl_certificates - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @describe_ssl_certificates_response_body, :is_a? => true)
    response = @api.describe_ssl_certificates
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.certsSet.item[0].fqdnId.should.equal '2'
    response.certsSet.item[0].fqdn.should.equal 'ccc.aaa.com'
    response.certsSet.item[0]['count'].should.equal '2'
    response.certsSet.item[0].certState.should.equal 'valid'
    response.certsSet.item[0].period.startDate.should.equal '2011-02-01'
    response.certsSet.item[0].period.endDate.should.equal '2013-01-31'
    response.certsSet.item[0].keyLength.should.equal '1024'
    response.certsSet.item[0].uploadState.should.equal 'false'
    response.certsSet.item[0].description.should.equal nil
    response.certsSet.item[0].certInfo.countryName.should.equal 'JP'
    response.certsSet.item[0].certInfo.stateName.should.equal 'TOKYO'
    response.certsSet.item[0].certInfo.locationName.should.equal 'Shinagawa-ku'
    response.certsSet.item[0].certInfo.organizationName.should.equal 'NIFTY Co.,LTD'
    response.certsSet.item[0].certInfo.organizationUnitName.should.equal 'Center Department'
    response.certsSet.item[0].certInfo.commonName.should.equal 'Center Department'
    response.certsSet.item[0].certInfo.emailAddress.should.equal 'admin@nifty.co.jp'
  end

  specify "describe_ssl_certificates - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "DescribeSslCertificates",
                                   "FqdnId.1" => "a",
                                   "FqdnId.2" => "a",
                                   "Fqdn.1" => "aaa.aaa.aaa",
                                   "Fqdn.2" => "aaa.aaa.aaa"
                                  ).returns stub(:body => @describe_ssl_certificates_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @describe_ssl_certificates_response_body, :is_a? => true)
    response = @api.describe_ssl_certificates(:fqdn_id => %w(a a), :fqdn => %w(aaa.aaa.aaa aaa.aaa.aaa))
  end

  specify "describe_ssl_certificates - :fqdn正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_ssl_certificates_response_body, :is_a? => true)
    lambda { @api.describe_ssl_certificates(:fqdn => 'ccc.aaa.com') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_ssl_certificates(:fqdn => %w(ccc.aaa.com aaa.bbb.com)) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "describe_ssl_certificates - :fqdn_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_ssl_certificates_response_body, :is_a? => true)
    lambda { @api.describe_ssl_certificates(:fqdn_id => 2) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_ssl_certificates(:fqdn_id => [2, 3, 4]) }.should.not.raise(NIFTY::ArgumentError)
  end


  # describe_ssl_certificate_attribute
  specify "describe_ssl_certificate_attribute - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @describe_ssl_certificate_attribute_response_body, :is_a? => true)
    response = @api.describe_ssl_certificate_attribute(:fqdn_id => 'fqdn')
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.fqdnId.should.equal '2'
    response.fqdn.should.equal 'ccc.aaa.com'
    response.certState.value.should.equal 'valid'
  end

  specify "describe_ssl_certificate_attribute - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "DescribeSslCertificateAttribute",
                                   "FqdnId" => "a",
                                   "Attribute" => "certInfo"
                                  ).returns stub(:body => @describe_ssl_certificate_attribute_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @describe_ssl_certificate_attribute_response_body, :is_a? => true)
    response = @api.describe_ssl_certificate_attribute(:fqdn_id => "a", :attribute => "certInfo")
  end

  specify "describe_ssl_certificate_attribute - :attribute正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_ssl_certificate_attribute_response_body, :is_a? => true)
    @valid_attribute.each do |attr|
      lambda { @api.describe_ssl_certificate_attribute(:fqdn_id => 2, :attribute => attr) }.should.not.raise(NIFTY::ArgumentError)
    end
  end
  
  specify "describe_ssl_certificate_attribute - :fqdn_id未指定" do
    lambda { @api.describe_ssl_certificate_attribute }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_ssl_certificate_attribute(:fqdn_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_ssl_certificate_attribute(:fqdn_id => '') }.should.raise(NIFTY::ArgumentError)
  end

  specify "describe_ssl_certificate_attribute - :attribute不正" do
    lambda { @api.describe_ssl_certificate_attribute(:fqdn_id => 2, :attribute => 'attr') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_ssl_certificate_attribute(:fqdn_id => 2, :attribute => 64) }.should.raise(NIFTY::ArgumentError)
  end


  # modify_ssl_certificate_attribute
  specify "modify_ssl_certificate_attribute - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @modify_ssl_certificate_attribute_response_body, :is_a? => true)
    response = @api.modify_ssl_certificate_attribute(:fqdn_id => 'fqdn')
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.return.should.equal 'true'
  end

  specify "modify_ssl_certificate_attribute - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "ModifySslCertificateAttribute",
                                   "FqdnId" => "a",
                                   "Description.Value" => "a"
                                  ).returns stub(:body => @modify_ssl_certificate_attribute_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @modify_ssl_certificate_attribute_response_body, :is_a? => true)
    response = @api.modify_ssl_certificate_attribute(:fqdn_id => "a", :description => "a")
  end

  specify "modify_ssl_certificate_attribute - :description正常" do
    @api.stubs(:exec_request).returns stub(:body => @modify_ssl_certificate_attribute_response_body, :is_a? => true)
    lambda { @api.modify_ssl_certificate_attribute(:fqdn_id => 2, :description => 'メモ') }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "modify_ssl_certificate_attribute - :fqdn_id未指定" do
    lambda { @api.modify_ssl_certificate_attribute }.should.raise(NIFTY::ArgumentError)
    lambda { @api.modify_ssl_certificate_attribute(:fqdn_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.modify_ssl_certificate_attribute(:fqdn_id => '') }.should.raise(NIFTY::ArgumentError)
  end


  # delete_ssl_certificate
  specify "delete_ssl_certificate - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @delete_ssl_certificate_response_body, :is_a? => true)
    response = @api.delete_ssl_certificate(:fqdn_id => 'fqdn')
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.fqdn.should.equal 'ccc.aaa.com'
  end

  specify "delete_ssl_certificate - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "DeleteSslCertificate", "FqdnId" => "a"
                                  ).returns stub(:body => @delete_ssl_certificate_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @delete_ssl_certificate_response_body, :is_a? => true)
    response = @api.delete_ssl_certificate(:fqdn_id => "a")
  end

  specify "delete_ssl_certificate - :fqdn_id未指定" do
    lambda { @api.delete_ssl_certificate }.should.raise(NIFTY::ArgumentError)
    lambda { @api.delete_ssl_certificate(:fqdn_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.delete_ssl_certificate(:fqdn_id => '') }.should.raise(NIFTY::ArgumentError)
  end


  # upload_ssl_certificate
  specify "upload_ssl_certificate - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @upload_ssl_certificate_response_body, :is_a? => true)
    response = @api.upload_ssl_certificate(:certificate => 'foo', :key => 'bar')
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.fqdnId.should.equal '2'
    response.fqdn.should.equal 'ccc.aaa.com'
    response.keyFingerPrint.should.equal 'xxxxxxxxxxxxx'
  end

  specify "upload_ssl_certificate - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "UploadSslCertificate",
                                   "Certificate" => "a",
                                   "Key" => "a",
                                   "Ca" => "a"
                                  ).returns stub(:body => @upload_ssl_certificate_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @upload_ssl_certificate_response_body, :is_a? => true)
    response = @api.upload_ssl_certificate(:certificate => "a", :key => "a", :ca => "a")
  end

  specify "upload_ssl_certificate - :ca正常" do
    @api.stubs(:exec_request).returns stub(:body => @upload_ssl_certificate_response_body, :is_a? => true)
    lambda { @api.upload_ssl_certificate(@basic_upload_ssl_cert.merge(:ca => 'foo')) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "upload_ssl_certificate - :certificate未指定" do
    lambda { @api.upload_ssl_certificate }.should.raise(NIFTY::ArgumentError)
    lambda { @api.upload_ssl_certificate(:certificate => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.upload_ssl_certificate(:certificate => '') }.should.raise(NIFTY::ArgumentError)
  end

  specify "upload_ssl_certificate - :key未指定" do
    lambda { @api.upload_ssl_certificate(:certificate => 'foo') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.upload_ssl_certificate(:certificate => 'foo', :key => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.upload_ssl_certificate(:certificate => 'foo', :key => '') }.should.raise(NIFTY::ArgumentError)
  end


  # download_ssl_certificate
  specify "download_ssl_certificate - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @download_ssl_certificate_response_body, :is_a? => true)
    response = @api.download_ssl_certificate(:fqdn_id => 'fqdn', :file_type => 1)
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.fqdnId.should.equal '2'
    response.fqdn.should.equal 'ccc.aaa.com'
    response.fileData.should.equal '・・・・・・・・・'
  end

  specify "download_ssl_certificate - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "DownloadSslCertificate",
                                   "FqdnId" => "a",
                                   "FileType" => "1"
                                  ).returns stub(:body => @download_ssl_certificate_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @download_ssl_certificate_response_body, :is_a? => true)
    response = @api.download_ssl_certificate(:fqdn_id => "a", :file_type => 1)
  end

  specify "download_ssl_certificate - :必須パラメータ正常" do
    @api.stubs(:exec_request).returns stub(:body => @download_ssl_certificate_response_body, :is_a? => true)
    @valid_file_type.each do |type|
      lambda { @api.download_ssl_certificate(:fqdn_id => 'foo', :file_type => type) }.should.not.raise(NIFTY::ArgumentError)
    end
  end
  
  specify "download_ssl_certificate - :fqdn_id未指定" do
    lambda { @api.download_ssl_certificate }.should.raise(NIFTY::ArgumentError)
    lambda { @api.download_ssl_certificate(:fqdn_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.download_ssl_certificate(:fqdn_id => '') }.should.raise(NIFTY::ArgumentError)
  end

  specify "download_ssl_certificate - :file_type未指定" do
    lambda { @api.download_ssl_certificate(:fqdn_id => 'foo') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.download_ssl_certificate(:fqdn_id => 'foo', :file_type => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.download_ssl_certificate(:fqdn_id => 'foo', :file_type => '') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.download_ssl_certificate(:fqdn_id => 'foo', :file_type => 4) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.download_ssl_certificate(:fqdn_id => 'foo', :file_type => 'foo') }.should.raise(NIFTY::ArgumentError)
  end
end
