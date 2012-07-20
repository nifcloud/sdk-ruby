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
    <DescribeAvailabilityZonesResponse xmlns="http://xxxx.nifty.com/xxx/xxx/">          
      <availabilityZoneInfo>        
        <item>      
          <zoneName>ap-japan-1a</zoneName>    
          <zoneState>available</zoneState>    
          <regionName>ap-japan-1</regionName>    
        </item>      
      </availabilityZoneInfo>        
    </DescribeAvailabilityZonesResponse>          
    RESPONSE

 end


  # describe_availability_zones
  specify "describe_availability_zones - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @describe_availability_zones_response_body, :is_a? => true)
    response = @api.describe_availability_zones(:zone_name => 'ap-japan-1a')
    response.availabilityZoneInfo.item[0].zoneName.should.equal 'ap-japan-1a'
    response.availabilityZoneInfo.item[0].zoneState.should.equal 'available'
    response.availabilityZoneInfo.item[0].regionName.should.equal 'ap-japan-1'
  end

  specify "describe_availability_zones - :key_name正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_availability_zones_response_body, :is_a? => true)
    lambda { @api.describe_availability_zones(:zone_name => 'foo') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_availability_zones(:zone_name => %w(foo bar)) }.should.not.raise(NIFTY::ArgumentError)
  end

end
