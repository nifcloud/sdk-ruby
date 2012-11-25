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

context "availability_zones" do

  before do
    @api = NIFTY::Cloud::Base.new( :access_key_id => "not a key", :secret_access_key => "not a secret",
                                    :server => 'cp.cloud.nifty.com', :path => '/api/1.7/', :user_agent => 'NIFTY Cloud API Ruby SDK',
                                    :signature_version => '2', :signature_method => 'HmacSHA256')

    @describe_availability_zones_response_body = <<-RESPONSE
    <DescribeAvailabilityZonesResponse xmlns="https://cp.cloud.nifty.com/api/">
    　<availabilityZoneInfo>
    　　<item>
    　　　<zoneName>east-11</zoneName>
    　　　<zoneState>available</zoneState>
    　　　<regionName>east-1</regionName>
    　　　<messageSet>
    　　　 <item>
    　　　　 <message/>
    　　　 </item>
    　　　</messageSet>
    　　　<securityGroupSupported>true</securityGroupSupported>
    　　　<isDefault>true</isDefault>
    　　</item>
    　</availabilityZoneInfo>
    </DescribeAvailabilityZonesResponse>
    RESPONSE
 end


  # describe_availability_zones
  specify "describe_availability_zones - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @describe_availability_zones_response_body, :is_a? => true)
    response = @api.describe_availability_zones(:zone_name => 'east-11')
    response.availabilityZoneInfo.item[0].zoneName.should.equal 'east-11'
    response.availabilityZoneInfo.item[0].zoneState.should.equal 'available'
    response.availabilityZoneInfo.item[0].regionName.should.equal 'east-1'
    response.availabilityZoneInfo.item[0].securityGroupSupported.should.equal 'true'
    response.availabilityZoneInfo.item[0].isDefault.should.equal 'true'
  end

  specify "describe_availability_zones - :key_name正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_availability_zones_response_body, :is_a? => true)
    lambda { @api.describe_availability_zones(:zone_name => 'foo') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_availability_zones(:zone_name => %w(foo bar)) }.should.not.raise(NIFTY::ArgumentError)
  end

end
