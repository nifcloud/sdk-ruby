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

context "images" do

  before do
    @api = NIFTY::Cloud::Base.new( :access_key_id => "not a key", :secret_access_key => "not a secret",
                                     :server => 'cp.cloud.nifty.com', :path => '/api/', :user_agent => 'NIFTY Cloud API Ruby SDK',
                                     :signature_version => '2', :signature_method => 'HmacSHA256')
    @valid_owner = %w(niftycloud self)

    @create_image_response_body = <<-RESPONSE
    <CreateImageResponse xmlns="https://cp.cloud.nifty.com/api/1.5/">      
      <RequestId>f6dd8353-eb6b-6b4fd32e4f05</RequestId>    
      <imageId>21</imageId>    
      <imageState>pending</imageState>    
    </CreateImageResponse>      
    RESPONSE

    @describe_images_response_body = <<-RESPONSE
    <DescribeImagesResponse xmlns="http://xxxx.nifty.com/xxx/xxx/">      
      <imagesSet>    
        <item>  
          <imageId>1</imageId>
          <imageState>available</imageState>
          <isPublic>true</isPublic>
          <architecture>i386</architecture>
          <imageType>machine</imageType>
          <platform>centos</platform>
          <name>CentOS 5.3 32bit Plain</name>
          <placement>
            <regionName>east-1</regionName>
            <availabilityZone>east-11</availabilityZone>
          </placement>
          <rootDeviceType>disk</rootDeviceType>
        </item>  
      </imagesSet>    
    </DescribeImagesResponse>            
    RESPONSE

    @delete_image_response_body = <<-RESPONSE
    <DeleteImageResponse xmlns="https://cp.cloud.nifty.com/api/1.5/">        
      <requestId>f6dd8353-eb6b-6b4fd32e4f05</requestId>      
    </DeleteImageResponse>        
    RESPONSE


    @modify_image_attribute_response_body = <<-RESPONSE
    <ModifyImageAttributeResponse xmlns="https://cp.cloud.nifty.com/api/1.5/">        
      <requestId>f6dd8353-eb6b-6b4fd32e4f05</requestId>      
    </ModifyImageAttributeResponse>        
    RESPONSE
  end


  # create_image
  specify "create_image - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @create_image_response_body, :is_a? => true)
    response = @api.create_image(:instance_id => 'server01', :name => 'image')
    response.RequestId.should.equal 'f6dd8353-eb6b-6b4fd32e4f05'
    response.imageId.should.equal '21'
    response.imageState.should.equal 'pending'
  end

  specify "create_image - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "CreateImage",
                                   "InstanceId" => "a",
                                   "Name" => "a",
                                   "Description" => "a",
                                   "NoReboot" => "a",
                                   "LeftInstance" => "true",
                                   "Placement.RegionName" => "east-1",
                                   "Placement.AvailabilityZone" => "east-11"
                                  ).returns stub(:body => @create_image_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @create_image_response_body, :is_a? => true)
    response = @api.create_image( :instance_id => "a", :name => "a", :description => "a", :no_reboot => "a", :left_instance => true,
      :region_name => "east-1", :availability_zone => "east-11" )
  end

  specify "create_image - :instance_id, :name正常" do
    @api.stubs(:exec_request).returns stub(:body => @create_image_response_body, :is_a? => true)
    lambda { @api.create_image(:instance_id => 'foo', :name => 'bar') }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "create_image - :description正常" do
    @api.stubs(:exec_request).returns stub(:body => @create_image_response_body, :is_a? => true)
    lambda { @api.create_image(:instance_id => 'foo', :name => 'bar', :description => 'メモ情報') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.create_image(:instance_id => 'foo', :name => 'bar', :description => 'desc') }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "create_image - :no_reboot正常" do
    @api.stubs(:exec_request).returns stub(:body => @create_image_response_body, :is_a? => true)
    lambda { @api.create_image(:instance_id => 'foo', :name => 'bar', :no_reboot => 'hoge') }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "create_image - :left_instance正常" do
    @api.stubs(:exec_request).returns stub(:body => @create_image_response_body, :is_a? => true)
    lambda { @api.create_image(:instance_id => 'foo', :name => 'bar', :left_instance => true) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.create_image(:instance_id => 'foo', :name => 'bar', :left_instance => false) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "create_image - :instance_id未指定" do
    lambda { @api.create_image }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_image(:instance_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_image(:instance_id => '') }.should.raise(NIFTY::ArgumentError)
  end

  specify "create_image - :name未指定" do
    lambda { @api.create_image(:instance_id => 'foo') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_image(:instance_id => 'foo', :name => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_image(:instance_id => 'foo', :name => '') }.should.raise(NIFTY::ArgumentError)
  end

  specify "create_image - :left_instance異常" do
    lambda { @api.create_image(:instance_id => 'foo', :name => 'bar', :left_instance => 'hoge') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_image(:instance_id => 'foo', :name => 'bar', :left_instance => 1) }.should.raise(NIFTY::ArgumentError)
  end


  # describe_images
  specify "describe_images - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @describe_images_response_body, :is_a? => true)
    response = @api.describe_images
    response.imagesSet.item[0].imageId.should.equal '1'
    response.imagesSet.item[0].imageState.should.equal 'available'
    response.imagesSet.item[0].isPublic.should.equal 'true'
    response.imagesSet.item[0].architecture.should.equal 'i386'
    response.imagesSet.item[0].imageType.should.equal 'machine'
    response.imagesSet.item[0].platform.should.equal 'centos'
    response.imagesSet.item[0].name.should.equal 'CentOS 5.3 32bit Plain'
    response.imagesSet.item[0].placement.regionName.should.equal 'east-1'
    response.imagesSet.item[0].placement.availabilityZone.should.equal 'east-11'
    response.imagesSet.item[0].rootDeviceType.should.equal 'disk'
  end

  specify "describe_images - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "DescribeImages",
                                   "ExecutableBy.1" => "a",
                                   "ExecutableBy.2" => "a",
                                   "ImageId.1" => "1",
                                   "ImageId.2" => "1",
                                   "ImageName.1" => "a",
                                   "ImageName.2" => "a",
                                   "Owner.1" => "niftycloud",
                                   "Owner.2" => "self"
                                  ).returns stub(:body => @describe_images_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @describe_images_response_body, :is_a? => true)
    response = @api.describe_images(:executable_by => %w(a a), :image_id => %w(1 1), :image_name => %w(a a), :owner => %w(niftycloud self))
  end

  specify "describe_images - :executable_by正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_images_response_body, :is_a? => true)
    lambda { @api.describe_images(:executable_by => 'exec') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_images(:executable_by => %w(ex1 ex2 ex3)) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "describe_images - :image_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_images_response_body, :is_a? => true)
    lambda { @api.describe_images(:image_id => 1) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_images(:image_id => 12000) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_images(:image_id => '12000') }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "describe_images - :image_name正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_images_response_body, :is_a? => true)
    lambda { @api.describe_images(:image_name => 'foo') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_images(:image_name => %w(name1 name2 name3)) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "describe_images - :owner正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_images_response_body, :is_a? => true)
    @valid_owner.each do |ow|
      lambda { @api.describe_images(:owner => ow) }.should.not.raise(NIFTY::ArgumentError)
      lambda { @api.describe_images(:owner => [ow, ow]) }.should.not.raise(NIFTY::ArgumentError)
    end
  end
  
  specify "describe_images - :image_id未指定" do
    lambda { @api.describe_images(:image_id => 0) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_images(:image_id => -1) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_images(:image_id => 'foo') }.should.raise(NIFTY::ArgumentError)
  end

  specify "describe_images - :owner不正" do
    lambda { @api.describe_images(:owner => 'owner') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_images(:owner => %w(niftycloud owner)) }.should.raise(NIFTY::ArgumentError)
  end


  # delete_image
  specify "delete_image - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @delete_image_response_body, :is_a? => true)
    response = @api.delete_image(:image_id => 10000)
    response.requestId.should.equal 'f6dd8353-eb6b-6b4fd32e4f05'
  end

  specify "delete_image - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "DeleteImage", "ImageId" => "10000").returns stub(:body => @delete_image_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @delete_image_response_body, :is_a? => true)
    response = @api.delete_image(:image_id => 10000)
  end

  specify "delete_image - :image_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @delete_image_response_body, :is_a? => true)
    lambda { @api.delete_image(:image_id => 10000) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.delete_image(:image_id => '12000') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.delete_image(:image_id => 10000) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "delete_image - :image_id未指定" do
    lambda { @api.delete_image }.should.raise(NIFTY::ArgumentError)
    lambda { @api.delete_image(:image_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.delete_image(:image_id => '') }.should.raise(NIFTY::ArgumentError)
  end
 

  # modify_image_attribute
  specify "modify_image_attribute - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @modify_image_attribute_response_body, :is_a? => true)
    response = @api.modify_image_attribute(:image_id => 10000, :attribute => 'imageName')
    response.requestId.should.equal 'f6dd8353-eb6b-6b4fd32e4f05'
  end

  specify "modify_image_attribute - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "ModifyImageAttribute", 
                                   "ImageId" => "10000",
                                   "Attribute" => "description", 
                                   "Value" => "a",
                                   "LaunchPermission.Add.1.UserId" => "a",
                                   "LaunchPermission.Add.2.UserId" => "a",
                                   "LaunchPermission.Remove.1.UserId" => "a",
                                   "LaunchPermission.Remove.2.UserId" => "a",
                                   "LaunchPermission.Add.1.Group" => "a",
                                   "LaunchPermission.Add.2.Group" => "a",
                                   "LaunchPermission.Remove.1.Group" => "a",
                                   "LaunchPermission.Remove.2.Group" => "a",
                                   "ProductCode.1" => "a",
                                   "ProductCode.2" => "a"
                                  ).returns stub(:body => @modify_image_attribute_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @modify_image_attribute_response_body, :is_a? => true)
    response = @api.modify_image_attribute(:image_id => 10000, :attribute => "description", :value => "a", :launch_permission_add => [{:user_id => "a", :group => "a"},{:user_id => "a", :group => "a"}], :launch_permission_remove => [{:user_id => "a", :group => "a"},{:user_id => "a", :group => "a"}], :product_code => %w(a a))
  end

  specify "modify_image_attribute - :image_id, :attribute正常" do
    @api.stubs(:exec_request).returns stub(:body => @modify_image_attribute_response_body, :is_a? => true)
    lambda { @api.modify_image_attribute(:image_id => 10000, :attribute => 'description') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.modify_image_attribute(:image_id => '10000', :attribute => 'imageName') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.modify_image_attribute(:image_id => '12000', :attribute => 'imageName') }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "modify_image_attribute - :launch_permission_add正常" do
    @api.stubs(:exec_request).returns stub(:body => @modify_image_attribute_response_body, :is_a? => true)
    lambda { @api.modify_image_attribute(:image_id => 10000, :attribute => 'description', :launch_permission_add => {:user_id => 'user', :group => 'gr1'}) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "modify_image_attribute - :launch_permission_remove常" do
    @api.stubs(:exec_request).returns stub(:body => @modify_image_attribute_response_body, :is_a? => true)
    lambda { @api.modify_image_attribute(:image_id => 10000, :attribute => 'description', :launch_permission_remove => {:user_id => 'user', :group => 'gr1'}) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "modify_image_attribute - :product_code正常" do
    @api.stubs(:exec_request).returns stub(:body => @modify_image_attribute_response_body, :is_a? => true)
    lambda { @api.modify_image_attribute(:image_id => 10000, :attribute => 'description', :product_code => 'pcode') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.modify_image_attribute(:image_id => 10000, :attribute => 'description', :product_code => %w(pc1 pc2)) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "modify_image_attribute - :image_id未指定/不正" do
    lambda { @api.modify_image_attribute }.should.raise(NIFTY::ArgumentError)
    lambda { @api.modify_image_attribute(:image_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.modify_image_attribute(:image_id => '') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.modify_image_attribute(:image_id => 0) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.modify_image_attribute(:image_id => 100) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.modify_image_attribute(:image_id => 9999) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.modify_image_attribute(:image_id => 'foo') }.should.raise(NIFTY::ArgumentError)
  end

  specify "modify_image_attribute - :attribute未指定/異常" do
    lambda { @api.modify_image_attribute(:image_id => 'foo') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.modify_image_attribute(:image_id => 'foo', :attribute => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.modify_image_attribute(:image_id => 'foo', :attribute => '') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.modify_image_attribute(:image_id => 'foo', :attribute => 'foo') }.should.raise(NIFTY::ArgumentError)
  end

end
