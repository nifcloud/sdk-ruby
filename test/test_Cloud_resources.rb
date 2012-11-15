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

    @describe_resources_response_body = <<-RESPONSE
    <DescribeResourcesResponse xmlns="https://cp.cloud.nifty.com/api/">
     <requestId>b1d415ab-5916-49b2-a428-07ca18548c56</requestId>
     <resourceInfo>
      <instanceItemSet>
       <item>
        <type>mini</type>
        <count>5</count>
       </item>
      </instanceItemSet>
      <dynamicIpCount>1</dynamicIpCount>
      <customizeImageCount>0</customizeImageCount>
      <addDiskCount>1</addDiskCount>
      <addDiskTotalSize>100</addDiskTotalSize>
      <networkFlowAmount>1</networkFlowAmount>
      <securityGroupCount>1</securityGroupCount>
      <loadBalancerCount>1</loadBalancerCount>
      <sslCertCount>1</sslCertCount>
      <monitoringRuleCount>1</monitoringRuleCount>
      <autoScaleCount>1</autoScaleCount>
      <privateLanCount>1</privateLanCount>
      <premiumSupportSet>
       <item>
        <supportName>ヘルプデスク</supportName>
       </item>
      </premiumSupportSet>
     </resourceInfo>
    </DescribeResourcesResponse>
    RESPONSE

    @describe_service_status_response_body = <<-RESPONSE
    <DescribeServiceStatusResponse xmlns="https://cp.cloud.nifty.com/api/">
     <requestId>b1d415ab-5916-49b2-a428-07ca18548c56</requestId>
     <serviceStatusSet>
      <item>
       <date>2012/02/19</date>
       <instanceStatus>normal</instanceStatus>
       <diskStatus>abnormal</diskStatus>
       <networkStatus>stop</networkStatus>
       <controlPanelStatus>stop</controlPanelStatus>
       <storageStatus>normal</storageStatus>
      </item>
      <item>
       <date>2012/02/20</date>
       <instanceStatus>normal</instanceStatus>
       <diskStatus>normal</diskStatus>
       <networkStatus>normal</networkStatus>
       <controlPanelStatus>normal</controlPanelStatus>
       <storageStatus>normal</storageStatus>
      </item>
     </serviceStatusSet>
    </DescribeServiceStatusResponse>
    RESPONSE

    @describe_usage_response_body = <<-RESPONSE
    <DescribeUsageResponse xmlns="https://cp.cloud.nifty.com/api/">
     <requestId>b1d415ab-5916-49b2-a428-07ca18548c56</requestId>
     <yearMonth>201106</yearMonth>
     <instanceInfo>
      <instanceMonthlyRateSet>
       <item>
        <type>mini</type>
        <unit>machine</unit>
        <value>1</value>
       </item>
      </instanceMonthlyRateSet>
      <runningInstanceMeasuredRateSet>
       <item>
        <type>mini</type>
        <unit>hour</unit>
        <value>1</value>
       </item>
      </runningInstanceMeasuredRateSet>
      <stoppedInstanceMeasuredRateSet>
       <item>
        <type>mini</type>
        <unit>hour</unit>
        <value>1</value>
       </item>
      </stoppedInstanceMeasuredRateSet>
      <dynamicIpMonthlyRate>
       <unit>machine</unit>
       <value>1</value>
      </dynamicIpMonthlyRate>
      <dynamicIpMeasuredRate>
       <unit>hour</unit>
       <value>1</value>
      </dynamicIpMeasuredRate>
      <osMonthlyRate>
       <item>
        <type>windows</type>
        <unit>vCPU</unit>
        <value>1</value>
       </item>
      </osMonthlyRate>
      <osMeasuredRate>
       <item>
        <type>windows</type>
        <unit>hour</unit>
        <value>1</value>
       </item>
      </osMeasuredRate>
      <multiIpMonthlyRate>
       <unit>IP</unit>
       <value>4</value>
      </multiIpMonthlyRate>
     </instanceInfo>
     <copyInfo>
      <instanceCopy>
       <unit>times</unit>
       <value>1</value>
      </instanceCopy>
     </copyInfo>
     <imageInfo>
      <createImage>
       <unit>times</unit>
       <value>1</value>
      </createImage>
      <keepImageSet>
       <item>
        <type>linux</type>
        <unit>image</unit>
        <value>1</value>
       </item>
       <item>
        <type>windows</type>
        <unit>image</unit>
        <value>1</value>
       </item>
      </keepImageSet>
     </imageInfo>
     <volumeInfo>
      <volumeSet>
       <item>
        <type>Disk100</type>
        <unit>100GB</unit>
        <value>1</value>
       </item>
      </volumeSet>
      <volumeMeasuredRateSet>
       <item>
        <type>Disk100</type>
        <unit>hour</unit>
        <value>223</value>
       </item>
      </volumeMeasuredRateSet>
      <importInstanceDiskMonthlyRate>
       <unit>100GB</unit>
       <value>1</value>
      </importInstanceDiskMonthlyRate>
      <importInstanceDiskMeasuredRate>
       <unit>hour</unit>
       <value>1</value>
      </importInstanceDiskMeasuredRate>
     </volumeInfo>
     <networkInfo>
      <networkFlowSet>
       <item>
        <type>free</type>
        <unit>GB</unit>
        <value>1</value>
       </item>
       <item>
        <type>charge</type>
        <unit>GB</unit>
        <value>1</value>
       </item>
      </networkFlowSet>
     </networkInfo>
     <securityGroupInfo>
      <securityGroupApplyTime>
       <unit>hour</unit>
       <value>1</value>
      </securityGroupApplyTime>
      <optionSet>
       <item>
        <type>group</type>
        <unit>10groups</unit>
        <value>1</value>
       </item>
      </optionSet>
     </securityGroupInfo>
     <loadBalancerInfo>
      <vipSet>
       <item>
        <type>10</type>
        <unit>VIP</unit>
        <value>1</value>
       </item>
      </vipSet>
      <vipMeasuredRateSet>
       <item>
        <type>10</type>
        <unit>hour</unit>
        <value>501</value>
       </item>
      </vipMeasuredRateSet>
      <optionSet>
       <item>
        <type>session</type>
        <unit>hour</unit>
        <value>1</value>
       </item>
       <item>
        <type>accelerator</type>
        <unit>
        </unit>
        <value>598</value>
       </item>
      </optionSet>
     </loadBalancerInfo>
     <autoScaleInfo>
      <autoScaleCount>
       <unit>config</unit>
       <value>1</value>
      </autoScaleCount>
      <runningScaleOutInstanceSet>
       <item>
        <type>mini</type>
        <unit>hour</unit>
        <value>1</value>
       </item>
      </runningScaleOutInstanceSet>
      <stoppedScaleOutInstanceSet>
       <item>
        <type>mini</type>
        <unit>hour</unit>
        <value>1</value>
       </item>
      </stoppedScaleOutInstanceSet>
      <runningScaleOutOsSet>
       <item>
        <type>windows</type>
        <unit>hour</unit>
        <value>1</value>
       </item>
      </runningScaleOutOsSet>
      <stoppedScaleOutOsSet>
       <item>
        <type>windows</type>
        <unit>hour</unit>
        <value>1</value>
       </item>
      </stoppedScaleOutOsSet>
     </autoScaleInfo>
     <sslCertInfo>
      <createSslCertSet>
       <item>
        <type>6</type>
        <unit>cert</unit>
        <value>1</value>
       </item>
      </createSslCertSet>
     </sslCertInfo>
     <privateLanInfo>
      <privateLan>
       <unit>LAN</unit>
      </privateLan>
     </privateLanInfo>
     <chargeDetailInfo>
      <chargeDetail>
       <value>1</value>
      </chargeDetail>
     </chargeDetailInfo>
     <premiumSupportInfo>
      <premiumSupportSet>
       <item>
        <type>ヘルプデスク</type>
        <value>1</value>
       </item>
      </premiumSupportSet>
     </premiumSupportInfo>
     <multiAccountInfo>
      <multiAccount>
       <unit>account</unit>
       <value>3</value>
      </multiAccount>
     </multiAccountInfo>
     <patternAuthInfo>
      <patternAuthSet>
       <item>
        <type>child</type>
        <unit>account</unit>
        <value>4</value>
       </item>
      </patternAuthSet>
     </patternAuthInfo>
     <storageInfo>
      <storageMonthlyRate>
       <type>5TB</type>
       <value>1</value>
      </storageMonthlyRate>
      <storageMeasuredRate>
       <unit>GB</unit>
       <value>411.5</value>
      </storageMeasuredRate>
     </storageInfo>
     <mailSendInfo>
      <mailSendInitial>
       <value>1</value>
      </mailSendInitial>
      <mailSendMonthlyRate>
       <type>3000</type>
       <value>1</value>
      </mailSendMonthlyRate>
      <mailSendMeasuredRate>
       <unit>mail</unit>
       <value>999</value>
      </mailSendMeasuredRate>
      <mailSendMonthlyExceedRate>
       <unit>mail</unit>
       <value>999</value>
      </mailSendMonthlyExceedRate>
      <OptionSet>
       <item>
        <type>initial.decomail</type>
        <value>1</value>
       </item>
       <item>
        <type>decomail</type>
        <value>1</value>
       </item>
      </OptionSet>
     </mailSendInfo>
     <extraChargeInfo>
      <extraChargeMonthlyRateSet>
       <item>
        <type>Oracle11g</type>
        <unit>machine</unit>
        <value>2</value>
       </item>
      </extraChargeMonthlyRateSet>
     </extraChargeInfo>
    </DescribeUsageResponse>
    RESPONSE

    @describe_user_activities_response_body = <<-RESPONSE
    <DescribeUserActivitiesResponse xmlns="https://cp.cloud.nifty.com/api/">
     <requestId>b1d415ab-5916-49b2-a428-07ca18548c56</requestId>
     <userActivitiesSet>
      <item>
       <dateTime>2012-05-25T18:11:05.000+09:00</dateTime>
       <ipAddress>111.11.111.11</ipAddress>
       <categoryName>API（サーバー）</categoryName>
       <operator>XXX00001</operator>
       <operation>RunInstances[instanceId:ad034c3e,instanceType :,imageId:2,osname:CentOS 5.3 64bit Plain,accountingType :2]SOAP/1.7</operation>
       <result>true</result>
      </item>
      <item>
       <dateTime>2012-05-25T18:11:05.000+09:00</dateTime>
       <ipAddress>111.11.111.11</ipAddress>
       <categoryName>API（サーバー）</categoryName>
       <operator>XXX00001_child</operator>
       <operation>RunInstances[instanceId:ad034c3e,instanceType :,imageId:2,osname:CentOS 5.3 64bit Plain,accountingType :2]SOAP/1.7</operation>
       <result>true</result>
      </item>
     </userActivitiesSet>
    </DescribeUserActivitiesResponse>
    RESPONSE
  end


  # describe_resources
  specify "describe_resources - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @describe_resources_response_body, :is_a? => true)

    response = @api.describe_resources
    response.requestId.should.equal "b1d415ab-5916-49b2-a428-07ca18548c56"
    response.resourceInfo.instanceItemSet.item[0].type.should.equal "mini"
    response.resourceInfo.instanceItemSet.item[0]['count'].should.equal "5"
    response.resourceInfo.dynamicIpCount.should.equal "1"
    response.resourceInfo.customizeImageCount.should.equal "0"
    response.resourceInfo.addDiskCount.should.equal "1"
    response.resourceInfo.addDiskTotalSize.should.equal "100"
    response.resourceInfo.networkFlowAmount.should.equal "1"
    response.resourceInfo.securityGroupCount.should.equal "1"
    response.resourceInfo.loadBalancerCount.should.equal "1"
    response.resourceInfo.sslCertCount.should.equal "1"
    response.resourceInfo.monitoringRuleCount.should.equal "1"
    response.resourceInfo.autoScaleCount.should.equal "1"
    response.resourceInfo.privateLanCount.should.equal "1"
    response.resourceInfo.premiumSupportSet.item[0].supportName.should.equal "ヘルプデスク"
  end

  specify "describe_resources - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with('Action' => 'DescribeResources').returns stub(:body => @describe_resources_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @describe_resources_response_body, :is_a? => true)
    response = @api.describe_resources
  end


  # describe_service_status
  specify "describe_service_status - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @describe_service_status_response_body, :is_a? => true)
    response = @api.describe_service_status
    response.requestId.should.equal "b1d415ab-5916-49b2-a428-07ca18548c56"
    response.serviceStatusSet.item[0].date.should.equal "2012/02/19"
    response.serviceStatusSet.item[0].instanceStatus.should.equal "normal"
    response.serviceStatusSet.item[0].diskStatus.should.equal "abnormal"
    response.serviceStatusSet.item[0].networkStatus.should.equal "stop"
    response.serviceStatusSet.item[0].controlPanelStatus.should.equal "stop"
    response.serviceStatusSet.item[0].storageStatus.should.equal "normal"
    response.serviceStatusSet.item[1].date.should.equal "2012/02/20"
    response.serviceStatusSet.item[1].instanceStatus.should.equal "normal"
    response.serviceStatusSet.item[1].diskStatus.should.equal "normal"
    response.serviceStatusSet.item[1].networkStatus.should.equal "normal"
    response.serviceStatusSet.item[1].controlPanelStatus.should.equal "normal"
    response.serviceStatusSet.item[1].storageStatus.should.equal "normal"
  end

  specify "describe_service_status - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with('Action' => 'DescribeServiceStatus',
                                   'FromDate' => '2012/02/01',
                                   'ToDate' => '2012/02/10'
                                  ).returns stub(:body => @describe_service_status_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @describe_service_status_response_body, :is_a? => true)
    response = @api.describe_service_status(:from_date => '2012/02/01', :to_date => '2012/02/10')
  end

  specify "describe_service_status - :from_date正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_service_status_response_body, :is_a? => true)
    lambda { @api.describe_service_status(:from_date => '20120201') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_service_status(:from_date => '2012/02/01') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_service_status(:from_date => '2012-02-01') }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "describe_service_status - :to_date正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_service_status_response_body, :is_a? => true)
    lambda { @api.describe_service_status(:to_date => '20120201') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_service_status(:to_date => '2012/02/01') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_service_status(:to_date => '2012-02-01') }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "describe_service_status - :from_date不正" do
    lambda { @api.describe_service_status(:from_date => 'foo') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_service_status(:from_date => 12345) }.should.raise(NIFTY::ArgumentError)
  end

  specify "describe_service_status - :to_date不正" do
    lambda { @api.describe_service_status(:to_date => 'foo') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_service_status(:to_date => 12345) }.should.raise(NIFTY::ArgumentError)
  end


  # describe_usage
  specify "describe_usage - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @describe_usage_response_body, :is_a? => true)
    response = @api.describe_service_status
    response.requestId.should.equal "b1d415ab-5916-49b2-a428-07ca18548c56"
    response.yearMonth.should.equal "201106"
    response.instanceInfo.instanceMonthlyRateSet.item[0].type.should.equal "mini"
    response.instanceInfo.instanceMonthlyRateSet.item[0].unit.should.equal "machine"
    response.instanceInfo.instanceMonthlyRateSet.item[0].value.should.equal "1"
    response.instanceInfo.runningInstanceMeasuredRateSet.item[0].type.should.equal "mini"
    response.instanceInfo.runningInstanceMeasuredRateSet.item[0].unit.should.equal "hour"
    response.instanceInfo.stoppedInstanceMeasuredRateSet.item[0].type.should.equal "mini"
    response.instanceInfo.stoppedInstanceMeasuredRateSet.item[0].unit.should.equal "hour"
    response.instanceInfo.stoppedInstanceMeasuredRateSet.item[0].value.should.equal "1"
    response.instanceInfo.dynamicIpMonthlyRate.unit.should.equal "machine"
    response.instanceInfo.dynamicIpMonthlyRate.value.should.equal "1"
    response.instanceInfo.dynamicIpMeasuredRate.unit.should.equal "hour"
    response.instanceInfo.dynamicIpMeasuredRate.value.should.equal "1"
    response.instanceInfo.osMonthlyRate.item[0].type.should.equal "windows"
    response.instanceInfo.osMonthlyRate.item[0].unit.should.equal "vCPU"
    response.instanceInfo.osMonthlyRate.item[0].value.should.equal "1"
    response.instanceInfo.osMeasuredRate.item[0].type.should.equal "windows"
    response.instanceInfo.osMeasuredRate.item[0].unit.should.equal "hour"
    response.instanceInfo.osMeasuredRate.item[0].value.should.equal "1"
    response.instanceInfo.multiIpMonthlyRate.unit.should.equal "IP"
    response.instanceInfo.multiIpMonthlyRate.value.should.equal "4"
    response.copyInfo.instanceCopy.unit.should.equal "times"
    response.copyInfo.instanceCopy.value.should.equal "1"
    response.imageInfo.createImage.unit.should.equal "times"
    response.imageInfo.createImage.value.should.equal "1"
    response.imageInfo.keepImageSet.item[0].type.should.equal "linux"
    response.imageInfo.keepImageSet.item[0].unit.should.equal "image"
    response.imageInfo.keepImageSet.item[0].value.should.equal "1"
    response.imageInfo.keepImageSet.item[1].type.should.equal "windows"
    response.imageInfo.keepImageSet.item[1].unit.should.equal "image"
    response.imageInfo.keepImageSet.item[1].value.should.equal "1"
    response.volumeInfo.volumeSet.item[0].type.should.equal "Disk100"
    response.volumeInfo.volumeSet.item[0].unit.should.equal "100GB"
    response.volumeInfo.volumeSet.item[0].value.should.equal "1"
    response.volumeInfo.volumeMeasuredRateSet.item[0].type.should.equal "Disk100"
    response.volumeInfo.volumeMeasuredRateSet.item[0].unit.should.equal "hour"
    response.volumeInfo.volumeMeasuredRateSet.item[0].value.should.equal "223"
    response.volumeInfo.importInstanceDiskMonthlyRate.unit.should.equal "100GB"
    response.volumeInfo.importInstanceDiskMonthlyRate.value.should.equal "1"
    response.volumeInfo.importInstanceDiskMeasuredRate.unit.should.equal "hour"
    response.volumeInfo.importInstanceDiskMeasuredRate.value.should.equal "1"
    response.networkInfo.networkFlowSet.item[0].type.should.equal "free"
    response.networkInfo.networkFlowSet.item[0].unit.should.equal "GB"
    response.networkInfo.networkFlowSet.item[0].value.should.equal "1"
    response.networkInfo.networkFlowSet.item[1].type.should.equal "charge"
    response.networkInfo.networkFlowSet.item[1].unit.should.equal "GB"
    response.networkInfo.networkFlowSet.item[1].value.should.equal "1"
    response.securityGroupInfo.securityGroupApplyTime.unit.should.equal "hour"
    response.securityGroupInfo.securityGroupApplyTime.value.should.equal "1"
    response.securityGroupInfo.optionSet.item[0].type.should.equal "group"
    response.securityGroupInfo.optionSet.item[0].unit.should.equal "10groups"
    response.securityGroupInfo.optionSet.item[0].value.should.equal"1"
    response.loadBalancerInfo.vipSet.item[0].type.should.equal "10"
    response.loadBalancerInfo.vipSet.item[0].unit.should.equal "VIP"
    response.loadBalancerInfo.vipSet.item[0].value.should.equal "1"
    response.loadBalancerInfo.vipMeasuredRateSet.item[0].type.should.equal "10"
    response.loadBalancerInfo.vipMeasuredRateSet.item[0].unit.should.equal "hour"
    response.loadBalancerInfo.vipMeasuredRateSet.item[0].value.should.equal"501"
    response.loadBalancerInfo.optionSet.item[0].type.should.equal "session"
    response.loadBalancerInfo.optionSet.item[0].unit.should.equal "hour"
    response.loadBalancerInfo.optionSet.item[0].value.should.equal "1"
    response.loadBalancerInfo.optionSet.item[1].type.should.equal "accelerator"
    response.loadBalancerInfo.optionSet.item[1].unit.should.equal ""
    response.loadBalancerInfo.optionSet.item[1].value.should.equal "598"
    response.autoScaleInfo.autoScaleCount.unit.should.equal "config"
    response.autoScaleInfo.autoScaleCount.value.should.equal "1"
    response.autoScaleInfo.runningScaleOutInstanceSet.item[0].type.should.equal "mini"
    response.autoScaleInfo.runningScaleOutInstanceSet.item[0].unit.should.equal "hour"
    response.autoScaleInfo.runningScaleOutInstanceSet.item[0].value.should.equal "1"
    response.autoScaleInfo.stoppedScaleOutInstanceSet.item[0].type.should.equal "mini"
    response.autoScaleInfo.stoppedScaleOutInstanceSet.item[0].unit.should.equal "hour"
    response.autoScaleInfo.stoppedScaleOutInstanceSet.item[0].value.should.equal "1"
    response.autoScaleInfo.runningScaleOutOsSet.item[0].type.should.equal "windows"
    response.autoScaleInfo.runningScaleOutOsSet.item[0].unit.should.equal "hour"
    response.autoScaleInfo.runningScaleOutOsSet.item[0].value.should.equal "1"
    response.autoScaleInfo.stoppedScaleOutOsSet.item[0].type.should.equal "windows"
    response.autoScaleInfo.stoppedScaleOutOsSet.item[0].unit.should.equal "hour"
    response.autoScaleInfo.stoppedScaleOutOsSet.item[0].value.should.equal "1"
    response.sslCertInfo.createSslCertSet.item[0].type.should.equal "6"
    response.sslCertInfo.createSslCertSet.item[0].unit.should.equal "cert"
    response.sslCertInfo.createSslCertSet.item[0].value.should.equal "1"
    response.privateLanInfo.privateLan.unit.should.equal "LAN"
    response.chargeDetailInfo.chargeDetail.value.should.equal "1"
    response.premiumSupportInfo.premiumSupportSet.item[0].type.should.equal "ヘルプデスク"
    response.premiumSupportInfo.premiumSupportSet.item[0].value.should.equal "1"
    response.multiAccountInfo.multiAccount.unit.should.equal "account"
    response.multiAccountInfo.multiAccount.value.should.equal "3"
    response.patternAuthInfo.patternAuthSet.item[0].type.should.equal "child"
    response.patternAuthInfo.patternAuthSet.item[0].unit.should.equal "account"
    response.patternAuthInfo.patternAuthSet.item[0].value.should.equal "4"
    response.storageInfo.storageMonthlyRate.type.should.equal "5TB"
    response.storageInfo.storageMonthlyRate.value.should.equal "1"
    response.storageInfo.storageMeasuredRate.unit.should.equal "GB"
    response.storageInfo.storageMeasuredRate.value.should.equal "411.5"
    response.mailSendInfo.mailSendInitial.value.should.equal "1"
    response.mailSendInfo.mailSendMonthlyRate.type.should.equal "3000"
    response.mailSendInfo.mailSendMonthlyRate.value.should.equal "1"
    response.mailSendInfo.mailSendMeasuredRate.unit.should.equal "mail"
    response.mailSendInfo.mailSendMeasuredRate.value.should.equal "999"
    response.mailSendInfo.mailSendMonthlyExceedRate.unit.should.equal "mail"
    response.mailSendInfo.mailSendMonthlyExceedRate.value.should.equal "999"
    response.mailSendInfo.OptionSet.item[0].type.should.equal "initial.decomail"
    response.mailSendInfo.OptionSet.item[0].value.should.equal "1"
    response.mailSendInfo.OptionSet.item[1].type.should.equal "decomail"
    response.mailSendInfo.OptionSet.item[1].value.should.equal "1"
    response.extraChargeInfo.extraChargeMonthlyRateSet.item[0].type.should.equal "Oracle11g"
    response.extraChargeInfo.extraChargeMonthlyRateSet.item[0].unit.should.equal "machine"
    response.extraChargeInfo.extraChargeMonthlyRateSet.item[0].value.should.equal "2"
  end

  specify "describe_usage - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with('Action' => 'DescribeUsage',
                                   'YearMonth' => '2011-02',
                                   'Region' => 'east-1'
				  ).returns stub(:body => @describe_usage_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @describe_usage_response_body, :is_a? => true)
    response = @api.describe_usage(:year_month => '2011-02', :region => 'east-1')
  end

  specify "describe_usage - :year_month正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_usage_response_body, :is_a? => true)
    %w(201211 2012-11 2012/11).each do |year_month|
      lambda { @api.describe_usage(:year_month => year_month) }.should.not.raise(NIFTY::ArgumentError)
    end
  end

  specify "describe_usage - :region正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_usage_response_body, :is_a? => true)
    lambda { @api.describe_usage }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_usage(:region => 'east-1') }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "describe_usage - :year_month不正" do
    @api.stubs(:exec_request).returns stub(:body => @describe_usage_response_body, :is_a? => true)
    lambda { @api.describe_usage(:year_month => '2012.11') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_usage(:year_month => 20121103) }.should.raise(NIFTY::ArgumentError)
  end


  specify "describe_user_activities - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with('Action' => 'DescribeUserActivities',
                                   'YearMonth' => '2011-02'
				  ).returns stub(:body => @describe_usage_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @describe_usage_response_body, :is_a? => true)
    response = @api.describe_user_activities(:year_month => '2011-02')
  end

  specify "describe_user_activities - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @describe_user_activities_response_body, :is_a? => true)
    response = @api.describe_user_activities
    response.requestId.should.equal "b1d415ab-5916-49b2-a428-07ca18548c56"
    response.userActivitiesSet.item[0].dateTime.should.equal "2012-05-25T18:11:05.000+09:00"
    response.userActivitiesSet.item[0].ipAddress.should.equal "111.11.111.11"
    response.userActivitiesSet.item[0].categoryName.should.equal "API（サーバー）"
    response.userActivitiesSet.item[0].operator.should.equal "XXX00001"
    response.userActivitiesSet.item[0].operation.should.equal "RunInstances[instanceId:ad034c3e,instanceType :,imageId:2,osname:CentOS 5.3 64bit Plain,accountingType :2]SOAP/1.7"
    response.userActivitiesSet.item[0].result.should.equal "true"
    response.userActivitiesSet.item[1].dateTime.should.equal "2012-05-25T18:11:05.000+09:00"
    response.userActivitiesSet.item[1].ipAddress.should.equal "111.11.111.11"
    response.userActivitiesSet.item[1].categoryName.should.equal "API（サーバー）"
    response.userActivitiesSet.item[1].operator.should.equal "XXX00001_child"
    response.userActivitiesSet.item[1].operation.should.equal "RunInstances[instanceId:ad034c3e,instanceType :,imageId:2,osname:CentOS 5.3 64bit Plain,accountingType :2]SOAP/1.7"
    response.userActivitiesSet.item[1].result.should.equal "true"
  end

  specify "describe_user_activities - :year_month正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_user_activities_response_body, :is_a? => true)
    lambda { @api.describe_user_activities }.should.not.raise(NIFTY::ArgumentError)
    %w(201211 2012-11 2012/11).each do |year_month|
      lambda { @api.describe_user_activities(:year_month => year_month) }.should.not.raise(NIFTY::ArgumentError)
    end
  end

  specify "describe_user_activities - :year_month不正" do
    @api.stubs(:exec_request).returns stub(:body => @describe_user_activities_response_body, :is_a? => true)
    lambda { @api.describe_user_activities(:year_month => '2012.11') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_user_activities(:year_month => 20121103) }.should.raise(NIFTY::ArgumentError)
  end
end
