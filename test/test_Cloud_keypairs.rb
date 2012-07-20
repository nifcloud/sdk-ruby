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

context "key_pairs" do

  before do
    @api = NIFTY::Cloud::Base.new( :access_key_id => "not a key", :secret_access_key => "not a secret", 
                                     :server => 'cp.cloud.nifty.com', :path => '/api/1.7/', :user_agent => 'NIFTY Cloud API Ruby SDK',
                                     :signature_version => '2', :signature_method => 'HmacSHA256')

    @create_key_pair_response_body = <<-RESPONSE
    <Createkey_pairResponse xmlns="http://cp.cloud.nifty.com/api/1.7/">
    <keyName>gsg-key_pair</keyName>
    <keyFingerprint>1f:51:ae:28:bf:89:e9:d8:1f:25:5d:37:2d:7d:b8:ca:9f:f5:f1:6f</keyFingerprint>
    <keyMaterial>-----BEGIN RSA PRIVATE KEY-----
    MIIEoQIBAAKCAQBuLFg5ujHrtm1jnutSuoO8Xe56LlT+HM8v/xkaa39EstM3/aFxTHgElQiJLChp
    HungXQ29VTc8rc1bW0lkdi23OH5eqkMHGhvEwqa0HWASUMll4o3o/IX+0f2UcPoKCOVUR+jx71Sg
    5AU52EQfanIn3ZQ8lFW7Edp5a3q4DhjGlUKToHVbicL5E+g45zfB95wIyywWZfeW/UUF3LpGZyq/
    ebIUlq1qTbHkLbCC2r7RTn8vpQWp47BGVYGtGSBMpTRP5hnbzzuqj3itkiLHjU39S2sJCJ0TrJx5
    i8BygR4s3mHKBj8l+ePQxG1kGbF6R4yg6sECmXn17MRQVXODNHZbAgMBAAECggEAY1tsiUsIwDl5
    91CXirkYGuVfLyLflXenxfI50mDFms/mumTqloHO7tr0oriHDR5K7wMcY/YY5YkcXNo7mvUVD1pM
    ZNUJs7rw9gZRTrf7LylaJ58kOcyajw8TsC4e4LPbFaHwS1d6K8rXh64o6WgW4SrsB6ICmr1kGQI7
    3wcfgt5ecIu4TZf0OE9IHjn+2eRlsrjBdeORi7KiUNC/pAG23I6MdDOFEQRcCSigCj+4/mciFUSA
    SWS4dMbrpb9FNSIcf9dcLxVM7/6KxgJNfZc9XWzUw77Jg8x92Zd0fVhHOux5IZC+UvSKWB4dyfcI
    tE8C3p9bbU9VGyY5vLCAiIb4qQKBgQDLiO24GXrIkswF32YtBBMuVgLGCwU9h9HlO9mKAc2m8Cm1
    jUE5IpzRjTedc9I2qiIMUTwtgnw42auSCzbUeYMURPtDqyQ7p6AjMujp9EPemcSVOK9vXYL0Ptco
    xW9MC0dtV6iPkCN7gOqiZXPRKaFbWADp16p8UAIvS/a5XXk5jwKBgQCKkpHi2EISh1uRkhxljyWC
    iDCiK6JBRsMvpLbc0v5dKwP5alo1fmdR5PJaV2qvZSj5CYNpMAy1/EDNTY5OSIJU+0KFmQbyhsbm
    rdLNLDL4+TcnT7c62/aH01ohYaf/VCbRhtLlBfqGoQc7+sAc8vmKkesnF7CqCEKDyF/dhrxYdQKB
    gC0iZzzNAapayz1+JcVTwwEid6j9JqNXbBc+Z2YwMi+T0Fv/P/hwkX/ypeOXnIUcw0Ih/YtGBVAC
    DQbsz7LcY1HqXiHKYNWNvXgwwO+oiChjxvEkSdsTTIfnK4VSCvU9BxDbQHjdiNDJbL6oar92UN7V
    rBYvChJZF7LvUH4YmVpHAoGAbZ2X7XvoeEO+uZ58/BGKOIGHByHBDiXtzMhdJr15HTYjxK7OgTZm
    gK+8zp4L9IbvLGDMJO8vft32XPEWuvI8twCzFH+CsWLQADZMZKSsBasOZ/h1FwhdMgCMcY+Qlzd4
    JZKjTSu3i7vhvx6RzdSedXEMNTZWN4qlIx3kR5aHcukCgYA9T+Zrvm1F0seQPbLknn7EqhXIjBaT
    P8TTvW/6bdPi23ExzxZn7KOdrfclYRph1LHMpAONv/x2xALIf91UB+v5ohy1oDoasL0gij1houRe
    2ERKKdwz0ZL9SWq6VTdhr/5G994CK72fy5WhyERbDjUIdHaK3M849JJuf8cSrvSb4g==
    -----END RSA PRIVATE KEY-----</keyMaterial>
    </Createkey_pairResponse>
    RESPONSE

    @describe_key_pairs_response_body = <<-RESPONSE
    <Describekey_pairsResponse xmlns="http://xxxx.nifty.com/xxx/xxx/">      
      <keySet>    
        <item>  
          <keyName>gsg-key_pair</keyName>
          <keyFingerprint>1f:51:ae:28:bf:89:e9:d8:1f:25:5d:37:2d:7d:b8:ca:9f:f5:f1:6f</keyFingerprint>
        </item>    
      </keySet>      
    </Describekey_pairsResponse>        
    RESPONSE

    @delete_key_pair_response_body = <<-RESPONSE
    <Deletekey_pairResponse xmlns="http://xxxx.nifty.com/xxx/xxx/">  
      <return>true</return>
    </Deletekey_pairResponse>  
    RESPONSE
  end


  # create_key_pair
  specify "create_key_pair - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @create_key_pair_response_body, :is_a? => true)
    response = @api.create_key_pair(:key_name => 'name', :password => 'pass')
    response.keyName.should.equal 'gsg-key_pair'
    response.keyFingerprint.should.equal '1f:51:ae:28:bf:89:e9:d8:1f:25:5d:37:2d:7d:b8:ca:9f:f5:f1:6f'
    response.keyMaterial.should.equal '-----BEGIN RSA PRIVATE KEY-----
    MIIEoQIBAAKCAQBuLFg5ujHrtm1jnutSuoO8Xe56LlT+HM8v/xkaa39EstM3/aFxTHgElQiJLChp
    HungXQ29VTc8rc1bW0lkdi23OH5eqkMHGhvEwqa0HWASUMll4o3o/IX+0f2UcPoKCOVUR+jx71Sg
    5AU52EQfanIn3ZQ8lFW7Edp5a3q4DhjGlUKToHVbicL5E+g45zfB95wIyywWZfeW/UUF3LpGZyq/
    ebIUlq1qTbHkLbCC2r7RTn8vpQWp47BGVYGtGSBMpTRP5hnbzzuqj3itkiLHjU39S2sJCJ0TrJx5
    i8BygR4s3mHKBj8l+ePQxG1kGbF6R4yg6sECmXn17MRQVXODNHZbAgMBAAECggEAY1tsiUsIwDl5
    91CXirkYGuVfLyLflXenxfI50mDFms/mumTqloHO7tr0oriHDR5K7wMcY/YY5YkcXNo7mvUVD1pM
    ZNUJs7rw9gZRTrf7LylaJ58kOcyajw8TsC4e4LPbFaHwS1d6K8rXh64o6WgW4SrsB6ICmr1kGQI7
    3wcfgt5ecIu4TZf0OE9IHjn+2eRlsrjBdeORi7KiUNC/pAG23I6MdDOFEQRcCSigCj+4/mciFUSA
    SWS4dMbrpb9FNSIcf9dcLxVM7/6KxgJNfZc9XWzUw77Jg8x92Zd0fVhHOux5IZC+UvSKWB4dyfcI
    tE8C3p9bbU9VGyY5vLCAiIb4qQKBgQDLiO24GXrIkswF32YtBBMuVgLGCwU9h9HlO9mKAc2m8Cm1
    jUE5IpzRjTedc9I2qiIMUTwtgnw42auSCzbUeYMURPtDqyQ7p6AjMujp9EPemcSVOK9vXYL0Ptco
    xW9MC0dtV6iPkCN7gOqiZXPRKaFbWADp16p8UAIvS/a5XXk5jwKBgQCKkpHi2EISh1uRkhxljyWC
    iDCiK6JBRsMvpLbc0v5dKwP5alo1fmdR5PJaV2qvZSj5CYNpMAy1/EDNTY5OSIJU+0KFmQbyhsbm
    rdLNLDL4+TcnT7c62/aH01ohYaf/VCbRhtLlBfqGoQc7+sAc8vmKkesnF7CqCEKDyF/dhrxYdQKB
    gC0iZzzNAapayz1+JcVTwwEid6j9JqNXbBc+Z2YwMi+T0Fv/P/hwkX/ypeOXnIUcw0Ih/YtGBVAC
    DQbsz7LcY1HqXiHKYNWNvXgwwO+oiChjxvEkSdsTTIfnK4VSCvU9BxDbQHjdiNDJbL6oar92UN7V
    rBYvChJZF7LvUH4YmVpHAoGAbZ2X7XvoeEO+uZ58/BGKOIGHByHBDiXtzMhdJr15HTYjxK7OgTZm
    gK+8zp4L9IbvLGDMJO8vft32XPEWuvI8twCzFH+CsWLQADZMZKSsBasOZ/h1FwhdMgCMcY+Qlzd4
    JZKjTSu3i7vhvx6RzdSedXEMNTZWN4qlIx3kR5aHcukCgYA9T+Zrvm1F0seQPbLknn7EqhXIjBaT
    P8TTvW/6bdPi23ExzxZn7KOdrfclYRph1LHMpAONv/x2xALIf91UB+v5ohy1oDoasL0gij1houRe
    2ERKKdwz0ZL9SWq6VTdhr/5G994CK72fy5WhyERbDjUIdHaK3M849JJuf8cSrvSb4g==
    -----END RSA PRIVATE KEY-----'
  end

  specify "create_key_pair - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "CreateKeyPair",
                                   "KeyName" => "a",
                                   "Password" => "a"
                                  ).returns stub(:body => @create_key_pair_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @create_key_pair_response_body, :is_a? => true)
    response = @api.create_key_pair(:key_name => "a", :password => "a")
  end

  specify "create_key_pair - :key_name, :password正常" do
    @api.stubs(:exec_request).returns stub(:body => @create_key_pair_response_body, :is_a? => true)
    lambda { @api.create_key_pair(:key_name => 'foo', :password => 'bar') }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "create_key_pair - :key_name未指定" do
    lambda { @api.create_key_pair }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_key_pair(:key_name => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_key_pair(:key_name => '') }.should.raise(NIFTY::ArgumentError)
  end

  specify "create_key_pair - :password未指定" do
    lambda { @api.create_key_pair(:key_name => 'foo') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_key_pair(:key_name => 'foo', :password => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_key_pair(:key_name => 'foo', :password => '') }.should.raise(NIFTY::ArgumentError)
  end


  # describe_key_pairs
  specify "describe_key_pairs - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @describe_key_pairs_response_body, :is_a? => true)
    response = @api.describe_key_pairs
    response.keySet.item[0].keyName.should.equal 'gsg-key_pair'
    response.keySet.item[0].keyFingerprint.should.equal '1f:51:ae:28:bf:89:e9:d8:1f:25:5d:37:2d:7d:b8:ca:9f:f5:f1:6f'
  end

  specify "describe_key_pairs - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "DescribeKeyPairs",
                                   "KeyName.1" => "a",
                                   "KeyName.2" => "a"
                                  ).returns stub(:body => @describe_key_pairs_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @describe_key_pairs_response_body, :is_a? => true)
    response = @api.describe_key_pairs(:key_name => %w(a a))
  end

  specify "describe_key_pairs - :key_name正常" do
    @api.stubs(:exec_request).returns stub(:body => @create_key_pair_response_body, :is_a? => true)
    lambda { @api.describe_key_pairs(:key_name => 'foo') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_key_pairs(:key_name => ['foo', 'bar']) }.should.not.raise(NIFTY::ArgumentError)
  end


  # delete_key_pairs
  specify "delete_key_pair - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @delete_key_pair_response_body, :is_a? => true)
    response = @api.delete_key_pair(:key_name => 'name')
    response.return.should.equal 'true'
  end

  specify "delete_key_pair - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "DeleteKeyPair",
                                   "KeyName" => "a"
                                  ).returns stub(:body => @delete_key_pair_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @delete_key_pair_response_body, :is_a? => true)
    response = @api.delete_key_pair(:key_name => "a")
  end

  specify "delete_key_pair - :key_name正常" do
    @api.stubs(:exec_request).returns stub(:body => @delete_key_pair_response_body, :is_a? => true)
    lambda { @api.delete_key_pair(:key_name => 'foo') }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "delete_key_pair - :key_name未指定" do
    lambda { @api.delete_key_pair }.should.raise(NIFTY::ArgumentError)
    lambda { @api.delete_key_pair(:key_name => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.delete_key_pair(:key_name => '') }.should.raise(NIFTY::ArgumentError)
  end

end
