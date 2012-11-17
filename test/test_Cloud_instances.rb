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
                                    :server => 'cp.cloud.nifty.com', :path => '/api/1.7/', :user_agent => 'NIFTY Cloud API Ruby SDK',
                                    :signature_version => '2', :signature_method => 'HmacSHA256')
    @valid_instance_type = %w(mini small small2 small4 small8 medium medium4 medium8 medium16
                              large large8 large16 large24 large32 extra-large16 extra-large24 extra-large32)
    @valid_ip_type = %w(static dynamic none)
    @accounting_type = [1, 2, '1', '2']
    @windows_image_id = [12, 16, '12', '16']

    @basic_run_instances_options = {:security_group => "gr01", :image_id => 2, :key_name => 'foo', :password => 'password'}
    @basic_import_instance_options = {:ovf => "dummy"}

    @run_instances_response_body = <<-RESPONSE
    <RunInstancesResponse xmlns="https://cp.cloud.nifty.com/api/1.3/">
    　<instancesSet>
    　　<item>
    　　　<instanceId>server04</instanceId>
    　　　<imageId>CentOS 5.3 32bit Plain</imageId>
    　　　<instanceState>    
    　　　　<code>0</code>    
    　　　　<name>pending</name>    
    　　　</instanceState>    
    　　　<privateDnsName>10.0.5.113</privateDnsName>    
    　　　<dnsName/>    
    　　　<keyName>sshkey01</keyName>    
    　　　<admin />    
    　　　<instanceType>medium</instanceType>    
    　　　<launchTime>2010-05-17T11:22:33.456Z </launchTime>    
    　　　<placement>    
    　　　　<availabilityZone>ap-japan-1a</availabilityZone>    
    　　　</placement>    
         <privateIpAddress>10.0.5.113</privateIpAddress>    
         <ipAddress />    
         <privateIpAddressV6>xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx</privateIpAddressV6>    
         <ipAddressV6 />    
         <architecture>i386</architecture>    
         <rootDeviceType>disk</rootDeviceType>    
         <blockDeviceMapping />    
         <accountingType>2</accountingType>    
         <ipType>static</ipType>    
    　　</item>    
    　</instancesSet>    
    </RunInstancesResponse>    
    RESPONSE

    @describe_instances_response_body = <<-RESPONSE
    <DescribeInstancesResponse xmlns="https://cp.cloud.nifty.com/api/1.3/">                
      <requestId>320fc738-a1c7-4a2f-abcb-20813a4e997c</requestId>          
      <reservationSet>          
        <item>        
          <reservationId />      
          <ownerId />      
          <groupSet />      
          <instancesSet>      
            <item>    
              <instanceId>server01</instanceId>  
              <imageId>1</imageId>  
              <instanceState>  
                <code>80</code>
                <name>stopped</name>
              </instanceState>  
              <privateDnsName>10.10.10.10</privateDnsName>  
              <dnsName />  
              <reason />      
              <keyName>ZYP3211ssh2</keyName>      
              <admin />      
              <amiLaunchIndex />      
              <productCodes />      
              <instanceType>mini</instanceType>      
              <launchTime>2010-05-17T11:22:33.456Z</launchTime>      
              <placement>      
                <availabilityZone>ap-japan-1a</availabilityZone>    
              </placement>      
              <kernelId />      
              <ramdiskId />      
              <platform />      
              <monitoring>      
                <state>disabled</state>    
              </monitoring>      
              <subnetId />      
              <vpcId />      
              <privateIpAddress>10.10.10.10</privateIpAddress>      
              <ipAddress />      
                 <privateIpAddressV6>xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx</privateIpAddressV6>        
                 <ipAddressV6 /> 
              <stateReason /> 
              <architecture>i386</architecture> 
              <rootDeviceType>disk</rootDeviceType>      
              <rootDeviceName />      
              <blockDeviceMapping>      
                <item>    
                  <deviceName>SCSI (0:1)</deviceName>  
                  <ebs>  
                    <volumeId>disk0001</volumeId>
                    <status>attached</status>
                    <attachTime>2010-10-13T19:17:28.799+09:00</attachTime>
                    <deleteOnTermination>false</deleteOnTermination>
                  </ebs>  
                </item>    
              </blockDeviceMapping>      
              <instanceLifecycle />      
              <spotInstanceRequestId />      
              <accountingType>2</accountingType>      
              <loadbalancing />      
              <copyInfo />      
              <autoscaling />      
              <ipType>static</ipType>      
              <description>メモ情報</description>      
            </item>        
          </instancesSet>          
        </item>            
      </reservationSet>              
    </DescribeInstancesResponse>                
    RESPONSE

    @describe_instance_attribute_response_body = <<-RESPONSE
    <DescribeInstanceAttributeResponse xmlns="http://xxxx.nifty.com/xxx/xxx/">    
      <instanceId>i-10a64379</instanceId>  
      <instanceType>  
        <value>mini</value>
      </instanceType>  
    </DescribeInstanceAttributeResponse>    
    RESPONSE

    @modify_instance_attribute_response_body = <<-RESPONSE
    <ModifyInstanceAttributeResponse xmlns="https://cp.cloud.nifty.com/api/">
      <return>true</return>
    </ModifyInstanceAttributeResponse>
    RESPONSE

    @reboot_instances_response_body = <<-RESPONSE
    <RebootInstancesResponse xmlns="http://xxxx.nifty.com/xxx/xxx/">  
      <return>true</return>
    </RebootInstancesResponse>  
    RESPONSE

    @start_instances_response_body = <<-RESPONSE
    <StartInstancesResponse xmlns="https://xxxx.nifty.com/xxx/xxx/">        
      <instancesSet>      
        <item>    
          <instanceId>i-10a64379</instanceId>  
          <currentState>  
            <code>0</code>
            <name>pending</name>
          </currentState>  
          <previousState>  
            <code>80</code>
            <name>stopped</name>
          </previousState>  
        </item>    
      </instancesSet>      
    </StartInstancesResponse>            
    RESPONSE

    @stop_instances_response_body = <<-RESPONSE
    <StopInstancesResponse xmlns="http://xxxx.nifty.com/xxx/xxx/">        
      <instancesSet>      
        <item>    
          <instanceId>i-10a64379</instanceId>  
          <currentState>  
            <code>64</code>
            <name>stopping</name>
          </currentState>  
          <previousState>  
            <code>16</code>
            <name>running</name>
          </previousState>  
        </item>    
      </instancesSet>      
    </StopInstancesResponse>        
    RESPONSE

    @terminate_instances_response_body = <<-RESPONSE
    <TerminateInstancesResponse xmlns="http://xxxx.nifty.com/xxx/xxx/">      
      <instancesSet>    
        <item>  
          <instanceId>i-3ea74257</instanceId>
          <currentState />
          <previousState />
        </item>  
      </instancesSet>    
    </TerminateInstancesResponse>      
    RESPONSE

    @copy_instances_response_body = <<-RESPONSE
    <CopyInstancesResponse xmlns="https://cp.cloud.nifty.com/api/1.5/">      
      <requestId>f6dd8353-eb6b-6b4fd32e4f05</requestId>    
      <copyInstanceSet>    
        <member>  
          <instanceId>copyinstance-01</instanceId>
          <instanceState>creating</instanceState>
        </member>  
        <member>  
          <instanceId>copyinstance-02</instanceId>
          <instanceState>wait</instanceState>
        </member>  
      </copyInstanceSet>    
    </CopyInstancesResponse>      
    RESPONSE

    @cancel_copy_instances_response_body = <<-RESPONSE
    <CancelCopyInstancesResponse xmlns="https://cp.cloud.nifty.com/api/">
      <requestId>f6dd8353-eb6b-6b4fd32e4f05</requestId>
    </CancelCopyInstancesResponse>
    RESPONSE

    @import_instance_response_body = <<-RESPONSE
    <ImportInstanceResponse xmlns="https://cp.cloud.nifty.com/api/">
     <conversionTask>
      <conversionTaskId>import-n-sd-093rar3gl4</conversionTaskId>
      <expirationTime>2012-10-13T19:17:28.799+09:00</expirationTime>
      <importInstance>
       <volumes>
        <item>
         <bytesConverted>0</bytesConverted>
         <availabilityZone>east-11</availabilityZone>
         <image>
          <format>VMDK</format>
          <size>266189212314</size>
         </image>
         <description/>
         <status>active</status>
         <statusMessage/>
        </item>
       </volumes>
       <instanceId>server01</instanceId>
       <description>memo</description>
      </importInstance>
     </conversionTask>
    </ImportInstanceResponse>
    RESPONSE
  end


  # describe_instances
  specify "describe_instances - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @describe_instances_response_body, :is_a? => true)

    response = @api.describe_instances( :instance_id => "server01" )
    response.reservationSet.item[0].reservationId.should.equal nil 
    response.reservationSet.item[0].ownerId.should.equal nil
    response.reservationSet.item[0].groupSet.should.equal nil
    response.reservationSet.item[0].instancesSet.item[0].instanceId.should.equal "server01"
    response.reservationSet.item[0].instancesSet.item[0].imageId.should.equal "1"
    response.reservationSet.item[0].instancesSet.item[0].instanceState.code.should.equal "80"
    response.reservationSet.item[0].instancesSet.item[0].instanceState.name.should.equal "stopped"
    response.reservationSet.item[0].instancesSet.item[0].privateDnsName.should.equal "10.10.10.10"
    response.reservationSet.item[0].instancesSet.item[0].dnsName.should.equal nil 
    response.reservationSet.item[0].instancesSet.item[0].reason.should.equal nil
    response.reservationSet.item[0].instancesSet.item[0].keyName.should.equal "ZYP3211ssh2"
    response.reservationSet.item[0].instancesSet.item[0].admin.should.equal nil 
    response.reservationSet.item[0].instancesSet.item[0].amiLaunchIndex.should.equal nil 
    response.reservationSet.item[0].instancesSet.item[0].instanceType.should.equal "mini"
    response.reservationSet.item[0].instancesSet.item[0].launchTime.should.equal "2010-05-17T11:22:33.456Z"
    response.reservationSet.item[0].instancesSet.item[0].placement.availabilityZone.should.equal "ap-japan-1a"
    response.reservationSet.item[0].instancesSet.item[0].kernelId.should.equal nil 
    response.reservationSet.item[0].instancesSet.item[0].ramdiskId.should.equal nil
    response.reservationSet.item[0].instancesSet.item[0].platform.should.equal nil
    response.reservationSet.item[0].instancesSet.item[0].monitoring.state.should.equal "disabled"
    response.reservationSet.item[0].instancesSet.item[0].subnetId.should.equal nil
    response.reservationSet.item[0].instancesSet.item[0].vpcId.should.equal nil
    response.reservationSet.item[0].instancesSet.item[0].privateIpAddress.should.equal "10.10.10.10"
    response.reservationSet.item[0].instancesSet.item[0].ipAddress.should.equal nil
    response.reservationSet.item[0].instancesSet.item[0].privateIpAddressV6.should.equal "xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx"
    response.reservationSet.item[0].instancesSet.item[0].ipAddressV6.should.equal nil
    response.reservationSet.item[0].instancesSet.item[0].stateReason.should.equal nil
    response.reservationSet.item[0].instancesSet.item[0].architecture.should.equal "i386"
    response.reservationSet.item[0].instancesSet.item[0].blockDeviceMapping.item[0].deviceName.should.equal "SCSI (0:1)"
    response.reservationSet.item[0].instancesSet.item[0].blockDeviceMapping.item[0].ebs.volumeId.should.equal "disk0001"
    response.reservationSet.item[0].instancesSet.item[0].blockDeviceMapping.item[0].ebs.status.should.equal "attached"
    response.reservationSet.item[0].instancesSet.item[0].blockDeviceMapping.item[0].ebs.attachTime.should.equal "2010-10-13T19:17:28.799+09:00"
    response.reservationSet.item[0].instancesSet.item[0].blockDeviceMapping.item[0].ebs.deleteOnTermination.should.equal "false"
    response.reservationSet.item[0].instancesSet.item[0].instanceLifecycle.should.equal nil
    response.reservationSet.item[0].instancesSet.item[0].spotInstanceRequestId.should.equal nil
    response.reservationSet.item[0].instancesSet.item[0].accountingType.should.equal "2"
    response.reservationSet.item[0].instancesSet.item[0].loadbalancing.should.equal nil
    response.reservationSet.item[0].instancesSet.item[0].copyInfo.should.equal nil
    response.reservationSet.item[0].instancesSet.item[0].autoscaling.should.equal nil
    response.reservationSet.item[0].instancesSet.item[0].ipType.should.equal "static"
    response.reservationSet.item[0].instancesSet.item[0].description.should.equal "メモ情報"
  end

  specify "describe_instances - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with('Action' => 'DescribeInstances', 
                                   'InstanceId.1' => 'server01',
                                   'InstanceId.2' => 'server02').returns stub(:body => @describe_instances_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @describe_instances_response_body, :is_a? => true)
    response = @api.describe_instances( :instance_id => %w(server01 server02) )
  end

  specify "describe_instances - :instance_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_instances_response_body, :is_a? => true)
    lambda { @api.describe_instances(:instance_id => 12345) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_instances(:instance_id => %w(foo bar hoge)) }.should.not.raise(NIFTY::ArgumentError)
  end


  # describe_instance_attribute
  specify "describe_instance_attribute - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @describe_instance_attribute_response_body, :is_a? => true)
    response = @api.describe_instance_attribute(:instance_id => 'i-10a64379', :attribute => 'instanceType')
    response.instanceId.should.equal 'i-10a64379'
    response.instanceType.value.should.equal 'mini'
  end
  
  specify "describe_instance_attribute - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "DescribeInstanceAttribute", 
                                   "InstanceId" => "server01",
                                   "Attribute" => "instanceType").returns stub(:body => @describe_instance_attribute_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @describe_instance_attribute_response_body, :is_a? => true)
    response = @api.describe_instance_attribute(:instance_id => 'server01', :attribute => 'instanceType')
  end

  specify "describe_instance_attribute - :attribute正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_instance_attribute_response_body, :is_a? => true)
    attributes = %w(
      instanceType 
      disableApiTermination 
      blockDeviceMapping 
      accountingType 
      nextMonthAccountingType
      loadbalancing 
      copyInfo 
      autoscaling 
      ipType groupId 
      description
    )
    attributes.each do |attr|
      lambda { @api.describe_instance_attribute(:instance_id => 'i-10a64379', :attribute => attr) }.should.not.raise(NIFTY::ArgumentError)
    end
  end

  specify "describe_instance_attribute - :instance_id未指定" do
    lambda { @api.describe_instance_attribute }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_instance_attribute(:attribute => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_instance_attribute(:attribute => '') }.should.raise(NIFTY::ArgumentError)
  end

  specify "describe_instance_attribute - :attribute不正" do
    lambda { @api.describe_instance_attribute(:instance_id => 'i-10a64379', :attribute => 'hoge') }.should.raise(NIFTY::ArgumentError)
  end
    

  # modify_instance_attribute
  specify "modify_instance_attribute - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @modify_instance_attribute_response_body, :is_a? => true)
    response = @api.modify_instance_attribute(:instance_id => "i-10a64379", :attribute => 'instanceType', :value => 'small4')
    response.return.should.equal "true"
  end

  specify "modify_instance_attribute - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with('Action' => 'ModifyInstanceAttribute', 
                                   'InstanceId' => 'server01', 
                                   'Attribute' => 'instanceName',
                                   'Value' => 'server02').returns stub(:body => @modify_instance_attribute_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @modify_instance_attribute_response_body, :is_a? => true)
    response = @api.modify_instance_attribute( :instance_id => "server01", :attribute => 'instanceName', :value => 'server02' )
  end

  specify "modify_instance_attribute - :instance_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @modify_instance_attribute_response_body, :is_a? => true)
    lambda { @api.modify_instance_attribute(:instance_id => 'foo', :attribute => 'instanceType', :value => 'mini') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.modify_instance_attribute(:instance_id => 12345, :attribute => 'instanceType', :value => 'mini') }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "modify_instance_attribute - :attribute,:value正常" do
    @api.stubs(:exec_request).returns stub(:body => @modify_instance_attribute_response_body, :is_a? => true)
    { 'instanceType' => @valid_instance_type,
      'disableApiTermination' => [true, false, 'true', 'false'],
      'instanceName' => ['hoge'],
      'description' => ['hoge']
    }.each do |attr, arr|
      arr.each do |val|
        lambda { @api.modify_instance_attribute(:instance_id => "i-10a64379", :attribute => attr, :value => val) }.should.not.raise(NIFTY::ArgumentError)
      end
    end
  end

  specify "modify_instance_attribute - :instance_id未指定" do
    lambda { @api.modify_instance_attribute }.should.raise(NIFTY::ArgumentError)
    [ nil, ''].each do |id|
      lambda { @api.modify_instance_attribute(:instance_id => id) }.should.raise(NIFTY::ArgumentError)
    end
    lambda { @api.modify_instance_attribute }.should.raise(NIFTY::ArgumentError)
  end

  specify "modify_instance_attribute - :attribute未指定/不正" do
    lambda { @api.modify_instance_attribute(:instance_id => "i-10a64379") }.should.raise(NIFTY::ArgumentError)
    lambda { @api.modify_instance_attribute(:instance_id => "i-10a64379", :attribute => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.modify_instance_attribute(:instance_id => "i-10a64379", :attribute => '') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.modify_instance_attribute(:instance_id => "i-10a64379", :attribute => 'hoge') }.should.raise(NIFTY::ArgumentError)
  end

  specify "modify_instance_attribute - :value未指定/不正" do
    attribute = %w(instanceType disableApiTermination instanceName description)
    attribute.each do |attr|
      lambda { @api.modify_instance_attribute(:instance_id => "i-10a64379", :attribute => attr ) }.should.raise(NIFTY::ArgumentError)
      lambda { @api.modify_instance_attribute(:instance_id => "i-10a64379", :attribute => attr, :value => nil ) }.should.raise(NIFTY::ArgumentError)
      if attr == 'instanceType' || attr == 'disableApiTermination'
        lambda { @api.modify_instance_attribute(:instance_id => "i-10a64379", :attribute => attr, :value => '' ) }.should.raise(NIFTY::ArgumentError)
        lambda { @api.modify_instance_attribute(:instance_id => "i-10a64379", :attribute => attr, :value => 'hoge' ) }.should.raise(NIFTY::ArgumentError)
      end
    end
  end


  # run_instances
  specify "run_instances - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    response = @api.run_instances(:security_group => "gr01", :image_id => '1', :key_name => 'key', :password => 'pass')
    response.instancesSet.item[0].instanceId.should.equal 'server04'
    response.instancesSet.item[0].imageId.should.equal 'CentOS 5.3 32bit Plain'
    response.instancesSet.item[0].instanceState.code.should.equal '0'
    response.instancesSet.item[0].instanceState.name.should.equal 'pending'
    response.instancesSet.item[0].privateDnsName.should.equal '10.0.5.113'
    response.instancesSet.item[0].dnsName.should.equal nil
    response.instancesSet.item[0].keyName.should.equal 'sshkey01'
    response.instancesSet.item[0].admin.should.equal nil
    response.instancesSet.item[0].instanceType.should.equal 'medium'
    response.instancesSet.item[0].launchTime.should.equal '2010-05-17T11:22:33.456Z '
    response.instancesSet.item[0].placement.availabilityZone.should.equal 'ap-japan-1a'
    response.instancesSet.item[0].privateIpAddress.should.equal '10.0.5.113'
    response.instancesSet.item[0].ipAddress.should.equal nil
    response.instancesSet.item[0].privateIpAddressV6.should.equal 'xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx'
    response.instancesSet.item[0].ipAddressV6.should.equal nil
    response.instancesSet.item[0].architecture.should.equal 'i386'
    response.instancesSet.item[0].rootDeviceType.should.equal 'disk'
    response.instancesSet.item[0].blockDeviceMapping.should.equal nil
    response.instancesSet.item[0].accountingType.should.equal '2'
    response.instancesSet.item[0].ipType.should.equal 'static'
  end

  specify "run_instances - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with('Action' => 'RunInstances',
                                   'ImageId' => '1',
                                   'MinCount' => '1',
                                   'MaxCount' => '3',
                                   'KeyName' => 'key',
                                   'SecurityGroup.1' => 'gr1',
                                   'SecurityGroup.2' => 'gr2',
                                   'UserData' => 'data',
                                   'AddressingType' => 'type',
                                   'InstanceType' => 'mini',
                                   'Placement.GroupName' => 'gr1',
                                   'Placement.AvailabilityZone' => 'zone',
                                   'KernelId' => 'kernel',
                                   'RamdiskId' => 'ram',
                                   'BlockDeviceMapping.1.DeviceName' => 'dev1',
                                   'BlockDeviceMapping.1.VirtualName' => 'vir1',
                                   'BlockDeviceMapping.1.Ebs.SnapshotId' => 'snap1',
                                   'BlockDeviceMapping.1.Ebs.VolumeSize' => 'size1',
                                   'BlockDeviceMapping.1.Ebs.DeleteOnTermination' => 'del1',
                                   'BlockDeviceMapping.1.Ebs.NoDevice' => 'nodev1',
                                   'BlockDeviceMapping.2.DeviceName' => 'dev2',
                                   'BlockDeviceMapping.2.VirtualName' => 'vir2',
                                   'BlockDeviceMapping.2.Ebs.SnapshotId' => 'snap2',
                                   'BlockDeviceMapping.2.Ebs.VolumeSize' => 'size2',
                                   'BlockDeviceMapping.2.Ebs.DeleteOnTermination' => 'del2',
                                   'BlockDeviceMapping.2.Ebs.NoDevice' => 'nodev2',
                                   'Monitoring.Enabled' => 'en',
                                   'SubnetId' => 'sub',
                                   'DisableApiTermination' => 'false',
                                   'InstanceInitiatedShutdownBehavior' => 'aaa',
                                   'AccountingType' => '1',
                                   'InstanceId' => 'server01',
                                   'Admin' => 'admin',
                                   'Password' => 'pass',
                                   'IpType' => 'static'
                                   ).returns stub(:body => @run_instances_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    response = @api.run_instances(:image_id => 1, :min_count => 1, :max_count => 3, :key_name => 'key', :security_group => %w(gr1 gr2), :user_data => 'data',
                                 :addressing_type => 'type', :instance_type => 'mini', :group_name => 'gr1', :availability_zone => 'zone', :kernel_id => 'kernel',
                                 :ramdisk_id => 'ram', 
                                 :block_device_mapping => [{:device_name => 'dev1', :virtual_name => 'vir1', :ebs_snapshot_id => 'snap1', :ebs_volume_size => 'size1', 
                                   :ebs_delete_on_termination => 'del1', :ebs_no_device => 'nodev1'}, 
                                   {:device_name => 'dev2', :virtual_name => 'vir2', :ebs_snapshot_id => 'snap2', :ebs_volume_size => 'size2', 
                                     :ebs_delete_on_termination => 'del2', :ebs_no_device => 'nodev2'}], 
                                 :monitoring_enabled => 'en', :subnet_id => 'sub', :disable_api_termination => false, :instance_initiated_shutdown_behavior => 'aaa', 
                                 :accounting_type => 1, :instance_id => 'server01', :admin => 'admin', :password => 'pass', :ip_type => 'static')
  end

  specify "run_instances - :image_id, :key_name, :password正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    lambda { @api.run_instances(:security_group => "gr01", :image_id => 2, :key_name => 'Keyname', :password => 'password') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(:security_group => "gr01", :image_id => '10', :key_name => 'Keyname', :password => 'password') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(:security_group => "gr01", :image_id => '10', :key_name => 'Keyname', :password => 'password') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(:security_group => "gr01", :image_id => 10000, :password => 'Password') }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "run_instances - :min_count正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:min_count => 1)) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:min_count => '10')) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "run_instances - :max_count正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:max_count => 1)) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:max_count => '10')) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "run_instances - :security_group正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:security_group => 'Group1')) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:security_group => 'default(Linux)')) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:security_group => 'default(Windows)')) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:security_group => %w(Group1 Group2 Group3))) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "run_instances - :additional_info正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:additional_info => 'add')) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "run_instances - :user_data正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:user_data => 'data')) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:user_data => 'data', :base64_encoded => true)) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:user_data => 'data', :base64_encoded => false)) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "run_instances - :addressing_type正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:addressing_type => 'addressing')) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "run_instances - :instance_type正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    @valid_instance_type.each do |type|
      lambda { @api.run_instances(@basic_run_instances_options.merge(:instance_type => type)) }.should.not.raise(NIFTY::ArgumentError)
    end
  end
  
  specify "run_instances - :availability_zone正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:availability_zone => 'ap-japan-1a')) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "run_instances - :group_name正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:group_name => 'group')) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "run_instances - :kernel_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:kernel_id => 'kernel')) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "run_instances - :ramdisk_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:ramdisk_id => 'ramdisk')) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "run_instances - :block_device_mapping正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    mapping = {
      :device_name => 'dev', :virtual_name => 'virtual', :ebs_snapshot_id => 'snapshot', :ebs_volume_size => 'volsize', 
      :ebs_delete_on_termination => 'deleteOnTermination', :ebs_no_device => 'nodev'
    }
    lambda { @api.run_instances(@basic_run_instances_options.merge(:block_device_mapping => mapping)) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:block_device_mapping => [mapping, mapping])) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "run_instances - :monitoring_enabled正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:monitoring_enabled => 'enabled')) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "run_instances - :subnet_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:subnet_id => 'subnet')) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "run_instances - :disable_api_termination正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:disable_api_termination => true)) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:disable_api_termination => false)) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "run_instances - :instance_initiated_shutdown_behavior正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:instance_initiated_shutdown_behavior => 'behavior')) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "run_instances - :accounting_type正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    @accounting_type.each do |type|
      lambda { @api.run_instances(@basic_run_instances_options.merge(:accounting_type => type)) }.should.not.raise(NIFTY::ArgumentError)
    end
  end
  
  specify "run_instances - :instance_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:instance_id => 'server01')) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "run_instances - :admin正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:admin => 'admin')) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "run_instances - :ip_type正常" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    @valid_ip_type.each do |type|
      lambda { @api.run_instances(@basic_run_instances_options.merge(:ip_type => type)) }.should.not.raise(NIFTY::ArgumentError)
    end
  end
  
  specify "run_instances - :image_id未指定/不正" do
    lambda { @api.run_instances }.should.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(:image_id => '') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(:image_id => nil) }.should.raise(NIFTY::ArgumentError)
  end

  specify "run_instances - :key_name未指定/不正" do
    lambda { @api.run_instances(:image_id => 1, :key_name => "Key_name") }.should.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(:image_id => 10000, :key_name => "Key_name") }.should.raise(NIFTY::ArgumentError)
  end

  specify "run_instances - :security_group不正" do
    lambda { @api.run_instances(:image_id => 10000, :key_name => "Keyname", :security_group => "Group_name") }.should.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(:image_id => 10000, :key_name => "Keyname", :security_group => %w(Group1 Group_2)) }.should.raise(NIFTY::ArgumentError)
  end

  specify "run_instances - :instance_type不正" do
    lambda { @api.run_instances(@basic_run_instances_options.merge(:instance_type => 'type')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:instance_type => 5)) }.should.raise(NIFTY::ArgumentError)
  end

  specify "run_instances - :disable_api_termination不正" do
    lambda { @api.run_instances(@basic_run_instances_options.merge(:disable_api_termination => 'disable')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:disable_api_termination => 0)) }.should.raise(NIFTY::ArgumentError)
  end

  specify "run_instances - :accounting_type不正" do
    lambda { @api.run_instances(@basic_run_instances_options.merge(:accounting_type => 3)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:accounting_type => 'type')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "run_instances - :password未指定/不正" do
    @api.stubs(:exec_request).returns stub(:body => @run_instances_response_body, :is_a? => true)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:image_id => 1)) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:image_id => 1, :password => nil)) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:image_id => 1, :password => '')) }.should.not.raise(NIFTY::ArgumentError)
    @windows_image_id.each do |image_id|
      lambda { @api.run_instances(:image_id => image_id) }.should.raise(NIFTY::ArgumentError)
      lambda { @api.run_instances(:image_id => image_id, :password => nil) }.should.raise(NIFTY::ArgumentError)
      lambda { @api.run_instances(:image_id => image_id, :password => '') }.should.raise(NIFTY::ArgumentError)
    end
    lambda { @api.run_instances(:image_id => 1, :password => 'Pass_word') }.should.raise(NIFTY::ArgumentError)
  end

  specify "run_instances - :ip_type不正" do
    lambda { @api.run_instances(@basic_run_instances_options.merge(:ip_type => 'ip')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.run_instances(@basic_run_instances_options.merge(:ip_type => 5)) }.should.raise(NIFTY::ArgumentError)
  end


  # start_instances
  specify "start_instances - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @start_instances_response_body, :is_a? => true)

    response = @api.start_instances(:instance_id => 'i-10a64379')
    response.instancesSet.item[0].instanceId.should.equal 'i-10a64379'
    response.instancesSet.item[0].currentState.code.should.equal '0'
    response.instancesSet.item[0].currentState.name.should.equal 'pending'
    response.instancesSet.item[0].previousState.code.should.equal '80'
    response.instancesSet.item[0].previousState.name.should.equal 'stopped'
  end

  specify "start_instances - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with('Action' => 'StartInstances',
                                   'InstanceId.1' => 'server01',
                                   'InstanceId.2' => 'server02',
                                   'InstanceType.1' => 'mini',
                                   'InstanceType.2' => 'mini',
                                   'AccountingType.1' => '1',
                                   'AccountingType.2' => '1',
                                   'UserData' => 'data'
    ).returns stub(:body => @start_instances_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @start_instances_response_body, :is_a? => true)
    response = @api.start_instances( :instance_id => %w(server01 server02), :instance_type => %w(mini mini), :accounting_type => %w(1 1), :user_data => 'data')
  end

  specify "start_instances - :instance_id未指定" do
    lambda { @api.start_instances }.should.raise(NIFTY::ArgumentError)
    lambda { @api.start_instances(:instance_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.start_instances(:instance_id => '') }.should.raise(NIFTY::ArgumentError)
  end
  
  specify "start_instances - :instance_type正常" do
    @api.stubs(:exec_request).returns stub(:body => @start_instances_response_body, :is_a? => true)

    @valid_instance_type.each do |type| 
      lambda { @api.start_instances(:instance_id => 'i-10a64379', :instance_type => type) }.should.not.raise(NIFTY::ArgumentError)
    end
  end
  
  specify "start_instances - :instance_type不正" do
    lambda { @api.start_instances(:instance_id => 'i-10a64379', :instance_type => 'foo') }.should.raise(NIFTY::ArgumentError)
  end

  specify "start_instances - :accounting_type正常" do
    @api.stubs(:exec_request).returns stub(:body => @start_instances_response_body, :is_a? => true)

    lambda { @api.start_instances(:instance_id => 'i-10a64379', :accounting_type => nil) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.start_instances(:instance_id => 'i-10a64379', :accounting_type => '') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.start_instances(:instance_id => 'i-10a64379', :accounting_type => '1') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.start_instances(:instance_id => 'i-10a64379', :accounting_type => '2') }.should.not.raise(NIFTY::ArgumentError)
  end
  specify "start_instances - :accounting_type不正" do
    lambda { @api.start_instances(:instance_id => 'i-10a64379', :accounting_type => 'foo') }.should.raise(NIFTY::ArgumentError)
  end

  specify "start_instances - :user_data正常" do
    @api.stubs(:exec_request).returns stub(:body => @start_instances_response_body, :is_a? => true)
    lambda { @api.start_instances(:instance_id => 'i-10a64379', :user_data => 'data') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.start_instances(:instance_id => 'i-10a64379', :user_data => 'data', :base64_encoded => true) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.start_instances(:instance_id => 'i-10a64379', :user_data => 'data', :base64_encoded => false) }.should.not.raise(NIFTY::ArgumentError)
  end


  # stop_instances
  specify "stop_instances - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @stop_instances_response_body, :is_a? => true)

    response = @api.stop_instances(:instance_id => ['i-10a64379'])
    response.instancesSet.item[0].instanceId.should.equal 'i-10a64379'
    response.instancesSet.item[0].currentState.code.should.equal '64'
    response.instancesSet.item[0].currentState.name.should.equal 'stopping'
    response.instancesSet.item[0].previousState.code.should.equal '16'
    response.instancesSet.item[0].previousState.name.should.equal 'running'
  end

  specify "stop_instances - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with('Action' => 'StopInstances',
                                   'InstanceId.1' => 'server01',
                                   'InstanceId.2' => 'server02',
                                   'Force' => 'false'
    ).returns stub(:body => @stop_instances_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @stop_instances_response_body, :is_a? => true)
    response = @api.stop_instances( :instance_id => %w(server01 server02), :force => false )
  end

  specify "stop_instances - :instance_id未指定" do
    lambda { @api.stop_instances }.should.raise(NIFTY::ArgumentError)
    lambda { @api.stop_instances(:instance_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.stop_instances(:instance_id => '') }.should.raise(NIFTY::ArgumentError)
  end

  specify "stop_instances - :force正常" do
    @api.stubs(:exec_request).returns stub(:body => @stop_instances_response_body, :is_a? => true)

    lambda { response = @api.stop_instances(:instance_id => ['i-10a64379'], :force => true) }.should.not.raise(NIFTY::ArgumentError)
    lambda { response = @api.stop_instances(:instance_id => ['i-10a64379'], :force => false) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.stop_instances(:instance_id => ['i-10a64379'], :force => '') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.stop_instances(:instance_id => ['i-10a64379'], :force => nil) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "stop_instances - :force不正" do
    lambda { @api.stop_instances(:instance_id => ['i-10a64379'], :force => 'foo') }.should.raise(NIFTY::ArgumentError)
  end


  # reboot_instance
  specify "reboot_instances - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @reboot_instances_response_body, :is_a? => true)

    response = @api.reboot_instances(:instance_id => ['i-28a64341'])
    response.return.should.equal 'true'
  end
  
  specify "reboot_instances - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with('Action' => 'RebootInstances', 
                                   'InstanceId.1' => 'server01',
                                   'InstanceId.2' => 'server02',
                                   'Force' => 'false',
                                   'UserData' => 'data'
                                  ).returns stub(:body => @reboot_instances_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @reboot_instances_response_body, :is_a? => true)
    response = @api.reboot_instances( :instance_id => %w(server01 server02), :force => false, :user_data => 'data' )
  end

  specify "reboot_instances - :force正常" do
    @api.stubs(:exec_request).returns stub(:body => @reboot_instances_response_body, :is_a? => true)
    lambda { @api.reboot_instances(:instance_id => 'i-28a64341', :force => true) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.reboot_instances(:instance_id => 'i-28a64341', :force => false) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.reboot_instances(:instance_id => 'i-28a64341', :force => '') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.reboot_instances(:instance_id => 'i-28a64341', :force => nil) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "reboot_instances - :user_data正常" do
    @api.stubs(:exec_request).returns stub(:body => @reboot_instances_response_body, :is_a? => true)
    lambda { @api.reboot_instances(:instance_id => 'i-28a64341', :user_data => 'data') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.reboot_instances(:instance_id => 'i-28a64341', :user_data => 'data', :base64_encoded => true) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.reboot_instances(:instance_id => 'i-28a64341', :user_data => 'data', :base64_encoded => false) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "reboot_instances - :instance_id未指定" do
    lambda { @api.reboot_instances }.should.raise(NIFTY::ArgumentError)
    lambda { @api.reboot_instances(:instance_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.reboot_instances(:instance_id => '') }.should.raise(NIFTY::ArgumentError)
  end

  specify "reboot_instances - :force異常" do
    lambda { @api.reboot_instances(:instance_id => 'i-28a64341', :force => 'foo') }.should.raise(NIFTY::ArgumentError)
  end


  # terminate_instances
  specify "terminate_instances - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @terminate_instances_response_body, :is_a? => true)
    response = @api.terminate_instances(:instance_id => 'i-3ea74257')
    response.instancesSet.item[0].instanceId.should.equal 'i-3ea74257'
    response.instancesSet.item[0].currentState.should.equal nil
    response.instancesSet.item[0].previousState.should.equal nil
  end

  specify "terminate_instances - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with('Action' => 'TerminateInstances',
                                   'InstanceId.1' => 'server01',
                                   'InstanceId.2' => 'server02'
    ).returns stub(:body => @terminate_instances_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @terminate_instances_response_body, :is_a? => true)
    response = @api.terminate_instances( :instance_id => %w(server01 server02) )
  end


  specify "terminate_instances - :instance_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @terminate_instances_response_body, :is_a? => true)
    lambda { @api.terminate_instances(:instance_id => 'foo') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.terminate_instances(:instance_id => %w(foo bar hoge)) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "terminate_instances - :instance_id未指定" do
    lambda { @api.terminate_instances }.should.raise(NIFTY::ArgumentError)
    lambda { @api.terminate_instances(:instance_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.terminate_instances(:instance_id => '') }.should.raise(NIFTY::ArgumentError)
  end


  # copy_instances
  specify "copy_instances - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @copy_instances_response_body, :is_a? => true)
    response = @api.copy_instances(:security_group => "Group", :instance_id => 'server01', :instance_name => 'copyserver')
    response.copyInstanceSet.member[0].instanceId.should.equal 'copyinstance-01'
    response.copyInstanceSet.member[0].instanceState.should.equal 'creating'
    response.copyInstanceSet.member[1].instanceId.should.equal 'copyinstance-02'
    response.copyInstanceSet.member[1].instanceState.should.equal 'wait'
  end

  specify "copy_instances - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with('Action' => 'CopyInstances',
                                   'InstanceId' => 'server01',
                                   'CopyInstance.InstanceName' => 'cpy',
                                   'CopyInstance.InstanceType' => 'mini',
                                   'CopyInstance.AccountingType' => '1',
                                   'CopyInstance.ipType' => 'static',
                                   'CopyInstance.LoadBalancers.1.LoadBalancerName' => 'lb1',
                                   'CopyInstance.LoadBalancers.1.LoadBalancerPort' => '80',
                                   'CopyInstance.LoadBalancers.1.InstancePort' => '80',
                                   'CopyInstance.LoadBalancers.2.LoadBalancerName' => 'lb2',
                                   'CopyInstance.LoadBalancers.2.LoadBalancerPort' => '80',
                                   'CopyInstance.LoadBalancers.2.InstancePort' => '80',
                                   'CopyInstance.SecurityGroup.1' => 'gr1',
                                   'CopyInstance.SecurityGroup.2' => 'gr2',
                                   'CopyCount' => '2'
    ).returns stub(:body => @copy_instances_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @copy_instances_response_body, :is_a? => true)
    response = @api.copy_instances( :instance_id => "server01", :instance_name => 'cpy', :instance_type => 'mini', :accounting_type => 1, :ip_type => 'static', 
                                   :load_balancers => [{:load_balancer_name => 'lb1', :load_balancer_port => 80, :instance_port => 80}, 
                                     {:load_balancer_name => 'lb2', :load_balancer_port => 80, :instance_port => 80}], 
                                     :security_group => %w(gr1 gr2), :copy_count => 2
                                  )
  end


  specify "copy_instances - :instance_type正常" do
    @api.stubs(:exec_request).returns stub(:body => @copy_instances_response_body, :is_a? => true)

    @valid_instance_type.each do |type|
      lambda { @api.reboot_instances(:security_group => "Group", :instance_id => 'server01', :instance_name => 'copyserver', :instance_type => type) }.should.not.raise(NIFTY::ArgumentError)
    end
  end

  specify "copy_instances - :instance_type異常" do
    
    lambda { @api.copy_instances(:security_group => "Group", :instance_id => 'server01', :instance_name => 'copyserver', :instance_type => 'foo') }.should.raise(NIFTY::ArgumentError)
  end

  specify "copy_instances - :accounting_type正常" do
    @api.stubs(:exec_request).returns stub(:body => @copy_instances_response_body, :is_a? => true)
    
    @accounting_type.each do |type|
      lambda { @api.copy_instances(:security_group => "Group", :instance_id => 'server01', :instance_name => 'copyserver', :accounting_type => type) }.should.not.raise(NIFTY::ArgumentError)
    end
    lambda { @api.copy_instances(:security_group => "Group", :instance_id => 'server01', :instance_name => 'copyserver', :accounting_type => '') }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "copy_instances - :accounting_type異常" do
    lambda { @api.copy_instances(:security_group => "Group", :instance_id => 'server01', :instance_name => 'copyserver', :accounting_type => 'foo') }.should.raise(NIFTY::ArgumentError)
  end

  specify "copy_instances - load_balancers正常" do
    @api.stubs(:exec_request).returns stub(:body => @copy_instances_response_body, :is_a? => true)

    [ [nil,   nil,  nil],
      ['',    '',   ''],
      ['lb1', 80,   80]
    ].each do |val|
      lambda { @api.copy_instances(:security_group => "Group", :instance_id => 'server01', :instance_name => 'copyserver', 
                                   :load_balancers => {:load_balancer_name => val[0], 
                                     :load_balancer_port => val[1], 
                                     :instance_port => val[2]}) }.should.not.raise(NIFTY::ArgumentError)
    end
    lambda { @api.copy_instances(:security_group => "Group", :instance_id => 'server01', :instance_name => 'copyserver', :load_balancers => nil) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.copy_instances(:security_group => "Group", :instance_id => 'server01', :instance_name => 'copyserver', :load_balancers => {}) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.copy_instances(:security_group => "Group", :instance_id => 'server01', :instance_name => 'copyserver', :load_balancers => []) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "copy_instances - :security_group正常" do
    @api.stubs(:exec_request).returns stub(:body => @copy_instances_response_body, :is_a? => true)
    
    lambda { @api.copy_instances(:instance_id => 'server01', :instance_name => 'copyserver', :security_group => [nil, '', 'foo', 'bar']) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.copy_instances(:instance_id => 'server01', :instance_name => 'copyserver', :security_group => "default(Linux)") }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.copy_instances(:instance_id => 'server01', :instance_name => 'copyserver', :security_group => "default(Windows)") }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "copy_instances - :copy_count正常" do
    @api.stubs(:exec_request).returns stub(:body => @copy_instances_response_body, :is_a? => true)
    [ 
      1, '6'
    ].each do |count|
      lambda { @api.copy_instances(:security_group => "Group", :instance_id => 'server01', :instance_name => 'copyserver', :copy_count => 1) }.should.not.raise(NIFTY::ArgumentError)
      lambda { @api.copy_instances(:security_group => "Group", :instance_id => 'server01', :instance_name => 'copyserver', :copy_count => '5') }.should.not.raise(NIFTY::ArgumentError)
    end
  end

  specify "copy_instances - :copy_count不正" do
    [
      0, -1, 'foo'
    ].each do |count|
      lambda { @api.copy_instances(:security_group => "Group", :instance_id => 'server01', :instance_name => 'copyserver', :copy_count => count) }.should.raise(NIFTY::ArgumentError)
    end
  end

  specify "copy_instances - :security_group不正" do
      lambda { @api.copy_instances(:security_group => "Group_name", :instance_id => 'server01', :instance_name => 'copyserver') }.should.raise(NIFTY::ArgumentError)
  end


  # cancel_copy_instances
  specify "cancel_copy_instances - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @cancel_copy_instances_response_body, :is_a? => true)
    response = @api.cancel_copy_instances(:instance_id => 'copyserver')
    response.requestId.should.equal 'f6dd8353-eb6b-6b4fd32e4f05'
  end

  specify "cancel_copy_instances - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with('Action' => 'CancelCopyInstances', 'InstanceId' => 'server01'
                                  ).returns stub(:body => @cancel_copy_instances_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @cancel_copy_instances_response_body, :is_a? => true)
    response = @api.cancel_copy_instances( :instance_id => "server01" )
  end


  specify "cancel_copy_instances - :instance_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @cancel_copy_instances_response_body, :is_a? => true)
    lambda { @api.cancel_copy_instances(:instance_id => 'foo') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.cancel_copy_instances(:instance_id => 12345) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "cancel_copy_instances - :instance_id未指定" do
    lambda { @api.cancel_copy_instances }.should.raise(NIFTY::ArgumentError)
    lambda { @api.cancel_copy_instances(:instance_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.cancel_copy_instances(:instance_id => '') }.should.raise(NIFTY::ArgumentError)
  end

  # import_instance
  specify "import_instance - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @import_instance_response_body, :is_a? => true)
    response = @api.import_instance(:ovf => "dummy")
    response.conversionTask.conversionTaskId.should.equal "import-n-sd-093rar3gl4"
    response.conversionTask.expirationTime.should.equal "2012-10-13T19:17:28.799+09:00"
    response.conversionTask.importInstance.volumes.item[0].bytesConverted.should.equal "0"
    response.conversionTask.importInstance.volumes.item[0].availabilityZone.should.equal "east-11"
    response.conversionTask.importInstance.volumes.item[0].image.format.should.equal "VMDK"
    response.conversionTask.importInstance.volumes.item[0].image["size"].should.equal "266189212314"
    #response.conversionTask.importInstance.volumes.item[0].description.should.equal ""
    response.conversionTask.importInstance.volumes.item[0].status.should.equal "active"
    #response.conversionTask.importInstance.volumes.item[0].statusMessage.should.equal ""
    response.conversionTask.importInstance.instanceId.should.equal "server01"
    response.conversionTask.importInstance.description.should.equal "memo"
  end

  specify "import_instance - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "ImportInstance",
                                   "SecurityGroup.1" => "gr1",
                                   "SecurityGroup.2" => "gr2",
                                   "InstanceType" => "mini",
                                   "Placement.AvailabilityZone" => "east-12",
                                   "DisableApiTermination" => "false",
                                   "InstanceId" => "server01",
                                   "Ovf" => "dummy",
                                   "AccountingType" => "1",
                                   "IpType" => "static"
                                  ).returns stub(:body => @import_instance_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @import_instance_response_body, :is_a? => true)
    response = @api.import_instance(:security_group => %w(gr1 gr2), :instance_type => "mini", :availability_zone => "east-12", :disable_api_termination => "false", :instance_id => "server01", :ovf => "dummy", :accounting_type => "1", :ip_type => "static")
  end

  specify "import_instance - :security_group正常" do
    @api.stubs(:exec_request).returns stub(:body => @import_instance_response_body, :is_a? => true)
    lambda { @api.import_instance(@basic_import_instance_options.merge(:security_group => 'Group1')) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.import_instance(@basic_import_instance_options.merge(:security_group => 'default(Linux)')) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.import_instance(@basic_import_instance_options.merge(:security_group => 'default(Windows)')) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.import_instance(@basic_import_instance_options.merge(:security_group => %w(Group1 Group2 Group3))) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "import_instance - :instance_type正常" do
    @api.stubs(:exec_request).returns stub(:body => @import_instance_response_body, :is_a? => true)
    @valid_instance_type.each do |type|
      lambda { @api.import_instance(@basic_import_instance_options.merge(:instance_type => type)) }.should.not.raise(NIFTY::ArgumentError)
    end
  end
  
  specify "import_instance - :availability_zone正常" do
    @api.stubs(:exec_request).returns stub(:body => @import_instance_response_body, :is_a? => true)
    lambda { @api.import_instance(@basic_import_instance_options.merge(:availability_zone => 'ap-japan-1a')) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "import_instance - :disable_api_termination正常" do
    @api.stubs(:exec_request).returns stub(:body => @import_instance_response_body, :is_a? => true)
    lambda { @api.import_instance(@basic_import_instance_options.merge(:disable_api_termination => true)) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.import_instance(@basic_import_instance_options.merge(:disable_api_termination => false)) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "import_instance - :instance_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @import_instance_response_body, :is_a? => true)
    lambda { @api.import_instance(@basic_import_instance_options.merge(:instance_id => 'server01')) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "import_instance - :accounting_type正常" do
    @api.stubs(:exec_request).returns stub(:body => @import_instance_response_body, :is_a? => true)
    @accounting_type.each do |type|
      lambda { @api.import_instance(@basic_import_instance_options.merge(:accounting_type => type)) }.should.not.raise(NIFTY::ArgumentError)
    end
  end

  specify "import_instance - :ip_type正常" do
    @api.stubs(:exec_request).returns stub(:body => @import_instance_response_body, :is_a? => true)
    @valid_ip_type.each do |type|
      lambda { @api.import_instance(@basic_import_instance_options.merge(:ip_type => type)) }.should.not.raise(NIFTY::ArgumentError)
    end
  end

  specify "import_instance - :security_group不正" do
    lambda { @api.import_instance(:image_id => 10000, :key_name => "Keyname", :security_group => "Group_name") }.should.raise(NIFTY::ArgumentError)
    lambda { @api.import_instance(:image_id => 10000, :key_name => "Keyname", :security_group => %w(Group1 Group_2)) }.should.raise(NIFTY::ArgumentError)
  end

  specify "import_instance - :instance_type不正" do
    lambda { @api.import_instance(@basic_import_instance_options.merge(:instance_type => 'type')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.import_instance(@basic_import_instance_options.merge(:instance_type => 5)) }.should.raise(NIFTY::ArgumentError)
  end

  specify "import_instance - :disable_api_termination不正" do
    lambda { @api.import_instance(@basic_import_instance_options.merge(:disable_api_termination => 'disable')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.import_instance(@basic_import_instance_options.merge(:disable_api_termination => 0)) }.should.raise(NIFTY::ArgumentError)
  end

  specify "import_instance - :accounting_type不正" do
    lambda { @api.import_instance(@basic_import_instance_options.merge(:accounting_type => 3)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.import_instance(@basic_import_instance_options.merge(:accounting_type => 'type')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "import_instance - :ip_type不正" do
    lambda { @api.import_instance(@basic_import_instance_options.merge(:ip_type => 'ip')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.import_instance(@basic_import_instance_options.merge(:ip_type => 5)) }.should.raise(NIFTY::ArgumentError)
  end
end
