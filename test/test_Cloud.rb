#!ruby -W0
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

context "Base" do

  before do
    @modify_instance_attribute_response_body = <<-RESPONSE
    <ModifyInstanceAttributeResponse xmlns="https://cp.cloud.nifty.com/api/">
      <return>true</return>
    </ModifyInstanceAttributeResponse>
    RESPONSE

    @error_response_body = <<-RESPONSE
    <Response>
      <Errors>
        <Error>
          <Code>Client.InvalidInstanceID.NotFound</Code>
          <Message>The instance ID 'noserver' does not exist.</Message>
        </Error>
      </Errors>
      <RequestID>4908b840-5d2c-42b7-a151-abeb01d4c755</RequestID>
    </Response>
    RESPONSE

    @options = {
      :access_key_id      => "accesskey",
      :secret_access_key  => "secretkey",
      :use_ssl            => true,
      :server             => "cp.cloud.nifty.com",
      :path               => "/api/1.7",
      :proxy_server       => nil,
      :port               => 443, 
      :connection_timeout => 30,
      :socket_timeout     => 30,
      :user_agent         => "useragent",
      :max_retry          => 3,
      :signature_version  => "2", 
      :signature_method   => "HmacSHA256" 
    }
  end

  specify "オプション不正" do
    # No access key
    lambda { @api = NIFTY::Cloud::Base.new(@options.merge(:access_key => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api = NIFTY::Cloud::Base.new(@options.merge(:access_key => "")) }.should.raise(NIFTY::ArgumentError)

    # No secret key
    lambda { @api = NIFTY::Cloud::Base.new(@options.merge(:secret_key => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api = NIFTY::Cloud::Base.new(@options.merge(:secret_key => "")) }.should.raise(NIFTY::ArgumentError)

    # No use ssl
    lambda { @api = NIFTY::Cloud::Base.new(@options.merge(:use_ssl => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api = NIFTY::Cloud::Base.new(@options.merge(:use_ssl => "")) }.should.raise(NIFTY::ArgumentError)

    # Invalid use ssl
    lambda { @api = NIFTY::Cloud::Base.new(@options.merge(:use_ssl => false)) }.should.raise(NIFTY::ArgumentError)

    # No server
    lambda { @api = NIFTY::Cloud::Base.new(@options.merge(:server => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api = NIFTY::Cloud::Base.new(@options.merge(:server => "")) }.should.raise(NIFTY::ArgumentError)

    # No path
    lambda { @api = NIFTY::Cloud::Base.new(@options.merge(:path => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api = NIFTY::Cloud::Base.new(@options.merge(:path => "")) }.should.raise(NIFTY::ArgumentError)

    # Invalid signature version
    lambda { @api = NIFTY::Cloud::Base.new(@options.merge(:signature_version => "-1")) }.should.raise(NIFTY::ArgumentError)
    lambda { @api = NIFTY::Cloud::Base.new(@options.merge(:signature_version => "3")) }.should.raise(NIFTY::ArgumentError)

    # Invalid signature method
    lambda { @api = NIFTY::Cloud::Base.new(@options.merge(:signature_method => "HmacSHA2")) }.should.raise(NIFTY::ArgumentError)
  end

  specify "オプション正常" do
    @options.merge!(:access_key_id => 'access', :secret_access_key => 'secret', :use_ssl => true,
      :server => 'cp.cloud.nifty.com', :path => '/api/1.7/')
    @api = NIFTY::Cloud::Base.new(@options)
    @api.use_ssl.should.equal true
    @api.server.should.equal 'cp.cloud.nifty.com'
    @api.path.should.equal '/api/1.7/'

    # max retry
    @options[:max_retry] = 3 
    @api = NIFTY::Cloud::Base.new(@options)
    @api.max_retry.should.equal 3

    # connection timeout
    @options[:connection_timeout] = 30
    @api = NIFTY::Cloud::Base.new(@options)
    @api.connection_timeout.should.equal 30
    @options[:connection_timeout] = -1
    @api = NIFTY::Cloud::Base.new(@options)
    @api.connection_timeout.should.equal -1 
    
    # socket timeout
    @options[:socket_timeout] = 30
    @api = NIFTY::Cloud::Base.new(@options)
    @api.socket_timeout.should.equal 30
    @options[:socket_timeout] = 0
    @api = NIFTY::Cloud::Base.new(@options)
    @api.socket_timeout.should.equal 0

    # user agent
    @options[:user_agent] = 'user'
    @api = NIFTY::Cloud::Base.new(@options)
    @api.user_agent.should.equal 'user'

    # signature version
    @options[:signature_version] = '0'
    lambda {
      @api = NIFTY::Cloud::Base.new(@options)
      @api.signature_version.should.equal '0'
      @api.stubs(:exec_request).returns stub(:body => @modify_instance_attribute_response_body, :is_a? => true)
      @api.describe_instances
    }.should.not.raise(NIFTY::ConfigurationError)
    @options[:signature_version] = '1'
    lambda {
      @api = NIFTY::Cloud::Base.new(@options)
      @api.signature_version.should.equal '1'
      @api.stubs(:exec_request).returns stub(:body => @modify_instance_attribute_response_body, :is_a? => true)
      @api.describe_instances
    }.should.not.raise(NIFTY::ConfigurationError)
    @options[:signature_method] = 'HmacSHA1'
    @options[:signature_version] = '2'
    lambda {
      @api = NIFTY::Cloud::Base.new(@options)
      @api.signature_version.should.equal '2'
      @api.stubs(:exec_request).returns stub(:body => @modify_instance_attribute_response_body, :is_a? => true)
      @api.describe_instances
    }.should.not.raise(NIFTY::ConfigurationError)

    # signature method
    @options[:signature_method] = 'HmacSHA1'
    lambda {
      @api = NIFTY::Cloud::Base.new(@options)
      @api.signature_method.should.equal 'HmacSHA1'
      @api.stubs(:exec_request).returns stub(:body => @modify_instance_attribute_response_body, :is_a? => true)
      @api.describe_instances
    }.should.not.raise(NIFTY::ConfigurationError)
    @options[:signature_method] = 'HmacSHA256'
    lambda {
      @api = NIFTY::Cloud::Base.new(@options)
      @api.signature_method.should.equal 'HmacSHA256'
      @api.stubs(:exec_request).returns stub(:body => @modify_instance_attribute_response_body, :is_a? => true)
      @api.describe_instances
    }.should.not.raise(NIFTY::ConfigurationError)
  end

  specify "pathhashlist引数不正" do
    @options.merge!(:access_key_id => 'access', :secret_access_key => 'secret', :use_ssl => true,
                    :server => 'cp.cloud.nifty.com', :path => '/api/1.7/', :signature_version => 2, :signature_method => 'HmacSHA256')
    @api = NIFTY::Cloud::Base.new(@options)
    lambda { @api.run_instances(:image_id => '1', :key_name => 'key', :password => 'pass', :instance_id => 'serv', :block_device_mapping => 'mapping') }.should.raise(NIFTY::ArgumentError)
  end

  specify "pathkvlist引数不正" do
    @options.merge!(:access_key_id => 'access', :secret_access_key => 'secret', :use_ssl => true,
                    :server => 'cp.cloud.nifty.com', :path => '/api/1.7/', :signature_version => 2, :signature_method => 'HmacSHA256')
    @api = NIFTY::Cloud::Base.new(@options)
    lambda { @api.describe_security_groups(:group_name => 'gr1', :filter => 'filter') }.should.raise(NIFTY::ArgumentError)
  end

  specify "レスポンスエラー" do
    @options.merge!(:access_key_id => 'access', :secret_access_key => 'secret', :use_ssl => true,
                    :server => 'cp.cloud.nifty.com', :path => '/api/1.7/', :signature_version => 2, :signature_method => 'HmacSHA256')
    @api = NIFTY::Cloud::Base.new(@options)
    @api.stubs(:exec_request).returns stub(:body => @error_response_body, :is_a? => false)
    lambda { @api.describe_instances(:instance_id => 'noserver') }.should.raise(NIFTY::ResponseError)
    begin
      @api.describe_instances(:instance_id => 'noserver')
    rescue => e
      e.error_code.should.equal 'Client.InvalidInstanceID.NotFound'
      e.error_message.should.equal "The instance ID 'noserver' does not exist."
    end
  end
end
