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

context "volumes" do

  before do
    @api = NIFTY::Cloud::Base.new( :access_key_id => "not a key", :secret_access_key => "not a secret", 
                                     :server => 'cp.cloud.nifty.com', :path => '/api/1.7/', :user_agent => 'NIFTY Cloud API Ruby SDK',
                                     :signature_version => '2', :signature_method => 'HmacSHA256')
    @valid_create_size  = [
      '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '15', '20',
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20
    ]
    @valid_create_type  = [
      '1', '2', '3', '4', '5', '6',
      1, 2, 3, 4, 5, 6
    ]
    @basic_create_volume_options = {:size => 1, :instance_id => 'server01'}

    @describe_volumes_response_body = <<-RESPONSE
    <DescribeVolumesResponse xmlns="http://xxxx.nifty.com/xxx/xxx/">          
      <volumeSet>        
        <item>      
          <volumeId>vol-4282672b</volumeId>    
          <size>800</size>    
          <diskType>Disk40</diskType>    
          <snapshotId/>    
          <availabilityZone>ap-japan-1a</availabilityZone>    
          <status>in-use</status>    
          <createTime>2008-05-07T11:51:50.000Z</createTime>    
          <attachmentSet>    
            <item>  
              <volumeId>vol-4282672b</volumeId>
              <instanceId>i-6058a509</instanceId>
              <device>/dev/sdh</device>
              <status>attached</status>
              <attachTime>2008-05-07T12:51:50.000Z</attachTime>
            </item>  
          </attachmentSet>    
        </item>      
      </volumeSet>        
    </DescribeVolumesResponse>          
    RESPONSE

    @create_volume_response_body = <<-RESPONSE
    <CreateVolumeResponse xmlns="http://xxxx.nifty.com/xxx/xxx/">      
          <volumeId>disk05</volumeId>
          <size>800</size>
          <snapshotId/>
          <availabilityZone>ap-japan-1a</availabilityZone>
          <status>creating</status>
          <createTime>2008-05-07T11:51:50.000Z</createTime>
    </CreateVolumeResponse>      
    RESPONSE

    @delete_volume_response_body = <<-RESPONSE
    <DeleteVolumeResponse xmlns="http://xxxx.nifty.com/xxx/xxx/">  
      <return>true</return>
    </DeleteVolumeResponse>  
    RESPONSE

    @attach_volume_response_body = <<-RESPONSE
    <AttachVolumeResponse xmlns="http://xxxx.nifty.com/xxx/xxx/">  
      <volumeId>vol-4d826724</volumeId>
      <instanceId>i-6058a509</instanceId>
      <device>SCSI(0:1)</device>
      <status>attaching</status>
      <attachTime>2008-05-07T11:51:50.000Z</attachTime>
    </AttachVolumeResponse>  
    RESPONSE

    @detach_volume_response_body = <<-RESPONSE
    <DetachVolumeResponse xmlns="http://xxxx.nifty.com/xxx/xxx/">    
      <volumeId>vol-4d826724</volumeId>  
      <instanceId>i-6058a509</instanceId>  
      <device>/dev/sdh</device>  
      <status>detaching</status>  
      <attachTime>2008-05-08T11:51:50.000Z</attachTime>  
    </DetachVolumeResponse>    
    RESPONSE
  end

  # describe_volumes
  specify "describe_volumes - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @describe_volumes_response_body, :is_a? => true)
    response = @api.describe_volumes
    response.volumeSet.item[0].volumeId.should.equal 'vol-4282672b'
    response.volumeSet.item[0]['size'].should.equal '800'
    response.volumeSet.item[0].diskType.should.equal 'Disk40'
    response.volumeSet.item[0].snapshotId.should.equal nil
    response.volumeSet.item[0].availabilityZone.should.equal 'ap-japan-1a'
    response.volumeSet.item[0].status.should.equal 'in-use'
    response.volumeSet.item[0].createTime.should.equal '2008-05-07T11:51:50.000Z'
    response.volumeSet.item[0].attachmentSet.item[0].volumeId.should.equal 'vol-4282672b'
    response.volumeSet.item[0].attachmentSet.item[0].instanceId.should.equal 'i-6058a509'
    response.volumeSet.item[0].attachmentSet.item[0].device.should.equal '/dev/sdh'
    response.volumeSet.item[0].attachmentSet.item[0].status.should.equal 'attached'
    response.volumeSet.item[0].attachmentSet.item[0].attachTime.should.equal '2008-05-07T12:51:50.000Z'
  end

  specify "describe_volumes - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "DescribeVolumes", 
                                   "VolumeId.1" => "vol1",
                                   "VolumeId.2" => "vol2"
                                  ).returns stub(:body => @describe_volumes_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @describe_volumes_response_body, :is_a? => true)
    response = @api.describe_volumes( :volume_id => %w(vol1 vol2) )
  end

  specify "describe_volumes - :volume_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_volumes_response_body, :is_a? => true)
    lambda { @api.describe_volumes(:volume_id => 'vol1') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_volumes(:volume_id => %w(vol1 vol2)) }.should.not.raise(NIFTY::ArgumentError)
  end
  

  # create_volume
  specify "create_volume - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @create_volume_response_body, :is_a? => true)
    response = @api.create_volume(@basic_create_volume_options)
    response.volumeId.should.equal 'disk05'
    response['size'].should.equal '800'
    response.snapshotId.should.equal nil
    response.availabilityZone.should.equal 'ap-japan-1a'
    response.status.should.equal 'creating'
    response.createTime.should.equal '2008-05-07T11:51:50.000Z'
  end

  specify "create_volume - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "CreateVolume",
                                   "Size" => "1",
                                   "SnapshotId" => "a",
                                   "AvailabilityZone" => "a",
                                   "VolumeId" => "a",
                                   "DiskType" => "1",
                                   "InstanceId" => "a"
                                  ).returns stub(:body => @create_volume_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @create_volume_response_body, :is_a? => true)
    response = @api.create_volume(:instance_id => "a", :size => 1, :snapshot_id => "a", :availability_zone => "a", :volume_id => "a", :disk_type => 1 )
  end

  specify "create_volume - :size, instance_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @create_volume_response_body, :is_a? => true)
    @valid_create_size.each do |size|
      lambda { @api.create_volume(:size => size, :instance_id => 'foo') }.should.not.raise(NIFTY::ArgumentError)
    end
  end
  
  specify "create_volume - :snapshot_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @create_volume_response_body, :is_a? => true)
    lambda { @api.create_volume(@basic_create_volume_options.merge(:snapshot_id => 'snapshot')) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.create_volume(@basic_create_volume_options.merge(:snapshot_id => 5)) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "create_volume - :availability_zone正常" do
    @api.stubs(:exec_request).returns stub(:body => @create_volume_response_body, :is_a? => true)
    lambda { @api.create_volume(@basic_create_volume_options.merge(:availability_zone => 'zone')) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.create_volume(@basic_create_volume_options.merge(:availability_zone => 5)) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "create_volume - :volume_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @create_volume_response_body, :is_a? => true)
    lambda { @api.create_volume(@basic_create_volume_options.merge(:volume_id => 'volume')) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.create_volume(@basic_create_volume_options.merge(:volume_id => 5)) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "create_volume - :disk_type正常" do
    @api.stubs(:exec_request).returns stub(:body => @create_volume_response_body, :is_a? => true)
    @valid_create_type.each do |type|
      lambda { @api.create_volume(@basic_create_volume_options.merge(:disk_type => type)) }.should.not.raise(NIFTY::ArgumentError)
    end
  end
  
  specify "create_volume - :size未指定" do
    lambda { @api.create_volume }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_volume(:size => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_volume(:size => '') }.should.raise(NIFTY::ArgumentError)
  end

  specify "create_volume - :disk_type不正" do
    lambda { @api.create_volume(@basic_create_volume_options.merge(:disk_type => 'type')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_volume(@basic_create_volume_options.merge(:disk_type => 10)) }.should.raise(NIFTY::ArgumentError)
  end

  specify "create_volume - :instance_id未指定" do
    lambda { @api.create_volume(:size => 1) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_volume(:size => 1, :key_name => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_volume(:size => 1, :key_name => '') }.should.raise(NIFTY::ArgumentError)
  end


  # delete_volume
  specify "delete_volume - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @delete_volume_response_body, :is_a? => true)
    response = @api.delete_volume(:volume_id => 'vol')
    response.return.should.equal 'true'
  end

  specify "delete_volume - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "DeleteVolume", "VolumeId" => "a").returns stub(:body => @delete_volume_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @delete_volume_response_body, :is_a? => true)
    response = @api.delete_volume(:volume_id => "a")
  end

  specify "delete_volume - :volume_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @delete_volume_response_body, :is_a? => true)
    lambda { @api.delete_volume(:volume_id => 'foo') }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "delete_volume - :volume_id未指定" do
      lambda { @api.delete_volume }.should.raise(NIFTY::ArgumentError)
      lambda { @api.delete_volume(:volume_id => nil) }.should.raise(NIFTY::ArgumentError)
      lambda { @api.delete_volume(:volume_id => '') }.should.raise(NIFTY::ArgumentError)
  end


  # attach_volume
  specify "attach_volume - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @attach_volume_response_body, :is_a? => true)
    response = @api.attach_volume(:volume_id => 'vol', :instance_id => 'ins')    
    response.volumeId.should.equal 'vol-4d826724'
    response.instanceId.should.equal 'i-6058a509'
    response.device.should.equal 'SCSI(0:1)'
    response.status.should.equal 'attaching'
    response.attachTime.should.equal '2008-05-07T11:51:50.000Z'
  end

  specify "attach_volume - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "AttachVolume",
                                   "VolumeId" => "a",
                                   "InstanceId" => "a",
                                   "Device" => "a"
                                  ).returns stub(:body => @attach_volume_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @attach_volume_response_body, :is_a? => true)
    response = @api.attach_volume( :instance_id => "a", :volume_id => "a", :device => "a" )
  end

  specify "attach_volume - :volume_id, instance_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @attach_volume_response_body, :is_a? => true)
    lambda { @api.attach_volume(:volume_id => 'foo', :instance_id => 'bar') }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "attach_volume - :volume_id未指定" do
    lambda { @api.attach_volume }.should.raise(NIFTY::ArgumentError)
    lambda { @api.attach_volume(:volume_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.attach_volume(:volume_id => '') }.should.raise(NIFTY::ArgumentError)
  end

  specify "attach_volume - :instance_id未指定" do
    lambda { @api.attach_volume(:volume_id => 'foo') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.attach_volume(:volume_id => 'foo', :instance_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.attach_volume(:volume_id => 'foo', :instance_id => '') }.should.raise(NIFTY::ArgumentError)
  end

  specify "attach_volume - :device正常" do
    @api.stubs(:exec_request).returns stub(:body => @attach_volume_response_body, :is_a? => true)
    lambda { @api.attach_volume(:volume_id => 'foo', :instance_id => 'bar', :device => 'dev') }.should.not.raise(NIFTY::ArgumentError)
  end


  # detach_volume
  specify "detach_volume - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @detach_volume_response_body, :is_a? => true)
    response = @api.detach_volume(:volume_id => 'vol')
    response = @api.detach_volume(:volume_id => 'vol', :instance_id => 'ins')    
    response.volumeId.should.equal 'vol-4d826724'
    response.instanceId.should.equal 'i-6058a509'
    response.device.should.equal '/dev/sdh'
    response.status.should.equal 'detaching'
    response.attachTime.should.equal '2008-05-08T11:51:50.000Z'
  end

  specify "detach_volume - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "DetachVolume",
                                   "VolumeId" => "a",
                                   "InstanceId" => "a",
                                   "Device" => "a",
                                   "Force" => "false"
                                  ).returns stub(:body => @detach_volume_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @detach_volume_response_body, :is_a? => true)
    response = @api.detach_volume( :instance_id => "a", :volume_id => "a", :device => "a", :force => false )
  end

  specify "detach_volume - :volume_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @detach_volume_response_body, :is_a? => true)
    lambda { @api.detach_volume(:volume_id => 'foo') }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "detach_volume - :volume_id未指定" do
    lambda { @api.detach_volume }.should.raise(NIFTY::ArgumentError)
    lambda { @api.detach_volume(:volume_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.detach_volume(:volume_id => '') }.should.raise(NIFTY::ArgumentError)
  end

  specify "detach_volume - :instance_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @detach_volume_response_body, :is_a? => true)
    lambda { @api.detach_volume(:volume_id => 'foo', :instance_id => 'bar') }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "detach_volume - :device正常" do
    @api.stubs(:exec_request).returns stub(:body => @detach_volume_response_body, :is_a? => true)
    lambda { @api.detach_volume(:volume_id => 'foo', :device => 'bar') }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "detach_volume - :force正常" do
    @api.stubs(:exec_request).returns stub(:body => @detach_volume_response_body, :is_a? => true)
    lambda { @api.detach_volume(:volume_id => 'foo', :force => true) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.detach_volume(:volume_id => 'foo', :force => false) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "detach_volume - :force異常" do
    lambda { @api.detach_volume(:volume_id => 'foo', :force => 'foo') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.detach_volume(:volume_id => 'foo', :force => 1) }.should.raise(NIFTY::ArgumentError)
  end

end
