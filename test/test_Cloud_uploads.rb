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

context "instances" do

  before do
    @api = NIFTY::Cloud::Base.new( :access_key_id => "not a key", :secret_access_key => "not a secret",
                                    :server => 'cp.cloud.nifty.com', :path => '/api/', :user_agent => 'NIFTY Cloud API Ruby SDK',
                                    :signature_version => '2', :signature_method => 'HmacSHA256')

    @describe_uploads_response_body = <<-RESPONSE
    <DescribeUploadsResponse xmlns="https://cp.cloud.nifty.com/api/">
     <uploads>
      <item>
       <conversionTaskId>d6f1ba72-0a76-4b1d-8421-a4f6089d3d7a</conversionTaskId>
       <expirationTime>2010-10-13T19:17:28.799+09:00</expirationTime>
       <importInstance>
        <availabilityZone>east-11</availabilityZone>
        <image>
         <format>VMDK</format>
         <size>3489231321</size>
        </image>
        <instanceId>server01</instanceId>
       </importInstance>
      </item>
     </uploads>
    </DescribeUploadsResponse>
    RESPONSE

    @cancel_upload_response_body = <<-RESPONSE
    <CancelUploadResponse xmlns="https://cp.cloud.nifty.com/api/">
     <requestId>f6dd8353-eb6b-6b4fd32e4f05</requestId>
     <return>true</return>
    </CancelUploadResponse>
    RESPONSE
  end


  # describe_uploads
  specify "describe_uploads - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @describe_uploads_response_body, :is_a? => true)

    response = @api.describe_uploads( :conversion_task_id => "server01" )
    response.uploads.item[0].conversionTaskId.should.equal "d6f1ba72-0a76-4b1d-8421-a4f6089d3d7a"
    response.uploads.item[0].expirationTime.should.equal "2010-10-13T19:17:28.799+09:00"
    response.uploads.item[0].importInstance.availabilityZone.should.equal "east-11"
    response.uploads.item[0].importInstance.image.format.should.equal "VMDK"
    response.uploads.item[0].importInstance.image["size"].should.equal "3489231321"
    response.uploads.item[0].importInstance.instanceId.should.equal "server01"
  end

  specify "describe_uploads - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with('Action' => 'DescribeUploads', 
                                   'ConversionTaskId.1' => 'd6f1ba72-0a76-4b1d-8421-a4f6089d3d7a',
                                   'ConversionTaskId.2' => 'd6f1ba72-0a76-4b1d-8421-a4f6089d3d7b').returns stub(:body => @describe_uploads_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @describe_uploads_response_body, :is_a? => true)
    response = @api.describe_uploads( :conversion_task_id => %w(d6f1ba72-0a76-4b1d-8421-a4f6089d3d7a d6f1ba72-0a76-4b1d-8421-a4f6089d3d7b) )
  end

  specify "describe_uploads - :conversion_task_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_uploads_response_body, :is_a? => true)
    lambda { @api.describe_uploads }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_uploads(:conversion_task_id => 12345) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_uploads(:conversion_task_id => %w(foo bar hoge)) }.should.not.raise(NIFTY::ArgumentError)
  end


  # cancel_upload
  specify "cancel_upload - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @cancel_upload_response_body, :is_a? => true)
    response = @api.cancel_upload(:conversion_task_id => 'copyserver')
    response.requestId.should.equal "f6dd8353-eb6b-6b4fd32e4f05"
    response.return.should.equal "true"
  end

  specify "cancel_upload - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with('Action' => 'CancelUpload',
                                   'ConversionTaskId' => 'd6f1ba72-0a76-4b1d-8421-a4f6089d3d7a1'
                                  ).returns stub(:body => @cancel_upload_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @cancel_upload_response_body, :is_a? => true)
    response = @api.cancel_upload( :conversion_task_id => "d6f1ba72-0a76-4b1d-8421-a4f6089d3d7a1" )
  end

  specify "cancel_upload - :conversion_task_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @cancel_upload_response_body, :is_a? => true)
    lambda { @api.cancel_upload(:conversion_task_id => 'foo') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.cancel_upload(:conversion_task_id => 12345) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "cancel_upload - :conversion_task_id未指定" do
    lambda { @api.cancel_upload }.should.raise(NIFTY::ArgumentError)
    lambda { @api.cancel_upload(:conversion_task_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.cancel_upload(:conversion_task_id => '') }.should.raise(NIFTY::ArgumentError)
  end
end
