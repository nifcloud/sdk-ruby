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

context "security_groups" do

  before do
    @api = NIFTY::Cloud::Base.new( :access_key_id => "not a key", :secret_access_key => "not a secret", 
                                     :server => 'cp.cloud.nifty.com', :path => '/api/1.7/', :user_agent => 'NIFTY Cloud API Ruby SDK',
                                     :signature_version => '2', :signature_method => 'HmacSHA256')

    @valid_ip_protocol = %w(TCP UDP ICMP SSH HTTP HTTPS SMTP POP3 IMAP)
    @valid_in_out = %w(IN In in Out Out out)

    @basic_ip_permissions = {:ip_protocol => 'HTTP', :group_name => 'gr2'}
    @basic_auth_security_params = {:group_name => 'gr1', :ip_permissions => @basic_ip_permissions}

    @create_security_group_response_body = <<-RESPONSE
    <CreateSecurityGroupResponse xmlns="https://cp.cloud.nifty.com/api/">      
      <requestId>320fc738-a1c7-4a2f-abcb-20813a4e997c</requestId>    
      <return>true</return>    
    </CreateSecurityGroupResponse>      
    RESPONSE

    @delete_security_group_response_body = <<-RESPONSE
    <DeleteSecurityGroupResponse xmlns="https://cp.cloud.nifty.com/api/">      
      <requestId>320fc738-a1c7-4a2f-abcb-20813a4e997c</requestId>    
      <return>true</return>    
    </DeleteSecurityGroupResponse>      
    RESPONSE

    @update_security_group_response_body = <<-RESPONSE
    <UpdateSecurityGroupResponse xmlns="https://cp.cloud.nifty.com/api/">      
      <requestId>320fc738-a1c7-4a2f-abcb-20813a4e997c</requestId>    
      <return>true</return>    
    </UpdateSecurityGroupResponse>      
    RESPONSE

    @describe_security_groups_response_body = <<-RESPONSE
    <DescribeSecurityGroupsResponse xmlns="https://cp.cloud.nifty.com/api/">              
      <requestId>320fc738-a1c7-4a2f-abcb-20813a4e997c</requestId>            
      <securityGroupInfo>            
        <item>          
          <ownerId />        
          <groupName>websvr2</groupName>        
          <groupDescription>webサーバー用</groupDescription>        
          <ipPermissions>        
            <item>      
              <ipProtocol>SSH</ipProtocol>    
              <fromPort>22</fromPort>    
              <toPort />    
              <inOut>IN</inOut>    
              <groups />    
              <ipRanges>    
                <item>  
                  <cidrIp>0.0.0.0/0</cidrIp>
                </item>  
              </ipRanges>    
            </item>      
            <item>      
              <ipProtocol>HTTP</ipProtocol>    
              <fromPort>80</fromPort>    
              <toPort />    
              <inOut>OUT</inOut>    
              <groups>    
                <item>  
                  <userId />
                  <groupName>Web</groupName>
                </item>  
              </groups>    
            </item>      
          </ipPermissions>        
          <instances>        
            <member>      
              <instanceId>server01</instanceId>    
              <instanceId>server02</instanceId>    
            </member>      
          </instances>        
        </item>          
      </securityGroupInfo>            
    </DescribeSecurityGroupsResponse>              
    RESPONSE

    @authorize_security_group_ingress_response_body = <<-RESPONSE
    <AuthorizeSecurityGroupIngressResponse xmlns="https://cp.cloud.nifty.com/api/">          
      <requestId>320fc738-a1c7-4a2f-abcb-20813a4e997c</requestId>        
      <return>true</return>        
    </AuthorizeSecurityGroupIngressResponse>          
    RESPONSE

    @revoke_security_group_ingress_response_body = <<-RESPONSE
    <RevokeSecurityGroupIngressResponse xmlns="https://cp.cloud.nifty.com/api/">          
      <requestId>320fc738-a1c7-4a2f-abcb-20813a4e997c</requestId>        
      <return>true</return>        
    </RevokeSecurityGroupIngressResponse>          
    RESPONSE

    @register_instances_with_security_group_response_body = <<-RESPONSE
    <RegisterInstancesWithSecurityGroupResponse xmlns="https://cp.cloud.nifty.com/api/">          
      <requestId>320fc738-a1c7-4a2f-abcb-20813a4e997c</requestId>        
      <instancesSet>        
        <item>      
          <instanceId>server01</instanceId>    
        </item>      
        <item>      
          <instanceId>server02</instanceId>    
        </item>      
      </instancesSet>        
    </RegisterInstancesWithSecurityGroupResponse>          
    RESPONSE

    @deregister_instances_from_security_group_response_body = <<-RESPONSE
    <DeregisterInstancesWithSecurityGroupResponse xmlns="https://cp.cloud.nifty.com/api/">          
      <requestId>320fc738-a1c7-4a2f-abcb-20813a4e997c</requestId>        
      <instancesSet>        
        <item>      
          <instanceId>server01</instanceId>    
        </item>      
        <item>      
          <instanceId>server02</instanceId>    
        </item>      
      </instancesSet>        
    </DeregisterInstancesWithSecurityGroupResponse>          
    RESPONSE

    @describe_security_activities_response_body = <<-RESPONSE
    <DescribeSecurityActivitiesResponse xmlns="https://cp.cloud.nifty.com/api/">                    
      <requestId>320fc738-a1c7-4a2f-abcb-20813a4e997c</requestId>
      <groupName>websrv</groupName>                  
      <log>2011-01-05T08:53:29+09:00 Altor_VNF time=1294217609140 fw_id=4 src_ip=10.0.6.201 src_port=68 dst_ip=10.0.4.11  dst_port=67 ip_proto=17 action=accept vm_id=16853 rule_id=52 type=fw
2011-01-09T11:21:53+09:00 Altor_VNF time=2297218603613 fw_id=4 src_ip=10.0.6.201 src_port=68 dst_ip=10.0.4.11  dst_port=67 ip_proto=17 action=accept vm_id=16853 rule_id=52 type=fw</log>
    </DescribeSecurityActivitiesResponse>                    
    RESPONSE
  end


  # create_security_group
  specify "create_security_group - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @create_security_group_response_body, :is_a? => true)
    response = @api.create_security_group(:group_name => 'gr1')
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.return.should.equal 'true'
  end

  specify "create_security_group - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "CreateSecurityGroup",
                                   "GroupName" => "a",
                                   "GroupDescription" => "a"
                                  ).returns stub(:body => @create_security_group_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @create_security_group_response_body, :is_a? => true)
    response = @api.create_security_group(:group_name => "a", :group_description => "a")
  end

  specify "create_security_group - :group_name正常" do
    @api.stubs(:exec_request).returns stub(:body => @create_security_group_response_body, :is_a? => true)
    lambda { @api.create_security_group(:group_name => 'Group') }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "create_security_group - :group_description正常" do
    @api.stubs(:exec_request).returns stub(:body => @create_security_group_response_body, :is_a? => true)
    lambda { @api.create_security_group(:group_name => 'foo', :group_description => 'メモ') }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "create_security_group - :group_name未指定/不正" do
    lambda { @api.create_security_group }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_security_group(:group_name => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_security_group(:group_name => '') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_security_group(:group_name => 'group_name') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_security_group(:group_name => 'default(Linux)') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.create_security_group(:group_name => 'default(Windows)') }.should.raise(NIFTY::ArgumentError)
  end
  

  # delete_security_group
  specify "delete_security_group - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @delete_security_group_response_body, :is_a? => true)
    response = @api.delete_security_group(:group_name => 'gr1')
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.return.should.equal 'true'
  end

  specify "delete_security_group - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "DeleteSecurityGroup", "GroupName" => "a"
                                  ).returns stub(:body => @delete_security_group_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @delete_security_group_response_body, :is_a? => true)
    response = @api.delete_security_group(:group_name => "a")
  end

  specify "delete_security_group - :group_name正常" do
    @api.stubs(:exec_request).returns stub(:body => @delete_security_group_response_body, :is_a? => true)
    lambda { @api.delete_security_group(:group_name => 'Group') }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "delete_security_group - :group_name未指定/不正" do
    lambda { @api.delete_security_group }.should.raise(NIFTY::ArgumentError)
    lambda { @api.delete_security_group(:group_name => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.delete_security_group(:group_name => '') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.delete_security_group(:group_name => 'Group_name') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.delete_security_group(:group_name => 'default(Linux)') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.delete_security_group(:group_name => 'default(Windows)') }.should.raise(NIFTY::ArgumentError)
  end
  

  # update_security_group
  specify "update_security_group - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @update_security_group_response_body, :is_a? => true)
    response = @api.update_security_group(:group_name => 'gr1')
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.return.should.equal 'true'
  end

  specify "update_security_group - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "UpdateSecurityGroup",
                                   "GroupName" => "a",
                                   "GroupNameUpdate" => "a",
                                   "GroupDescriptionUpdate" => "a"
                                  ).returns stub(:body => @update_security_group_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @update_security_group_response_body, :is_a? => true)
    response = @api.update_security_group(:group_name => "a", :group_name_update => "a", :group_description_update => "a")
  end

  specify "update_security_group - :group_name正常" do
    @api.stubs(:exec_request).returns stub(:body => @update_security_group_response_body, :is_a? => true)
    lambda { @api.update_security_group(:group_name => 'default(Linux)') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.update_security_group(:group_name => 'default(Windows)') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.update_security_group(:group_name => 'Group') }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "update_security_group - :group_name_update正常" do
    @api.stubs(:exec_request).returns stub(:body => @update_security_group_response_body, :is_a? => true)
    lambda { @api.update_security_group(:group_name => 'foo', :group_name_update => 'bar') }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "update_security_group - :group_description_update正常" do
    @api.stubs(:exec_request).returns stub(:body => @update_security_group_response_body, :is_a? => true)
    lambda { @api.update_security_group(:group_name => 'foo', :group_description_update => 'テスト') }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "update_security_group - :group_name未指定/不正" do
    lambda { @api.update_security_group }.should.raise(NIFTY::ArgumentError)
    lambda { @api.update_security_group(:group_name => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.update_security_group(:group_name => '') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.update_security_group(:group_name => 'Group_name') }.should.raise(NIFTY::ArgumentError)
  end


  # describe_security_groups
  specify "describe_security_groups - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @describe_security_groups_response_body, :is_a? => true)
    response = @api.describe_security_groups
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.securityGroupInfo.item[0].ownerId.should.equal nil
    response.securityGroupInfo.item[0].groupName.should.equal 'websvr2'
    response.securityGroupInfo.item[0].groupDescription.should.equal 'webサーバー用'
    response.securityGroupInfo.item[0].ipPermissions.item[0].ipProtocol.should.equal 'SSH'
    response.securityGroupInfo.item[0].ipPermissions.item[0].fromPort.should.equal '22'
    response.securityGroupInfo.item[0].ipPermissions.item[0].toPort.should.equal nil
    response.securityGroupInfo.item[0].ipPermissions.item[0].inOut.should.equal 'IN'
    response.securityGroupInfo.item[0].ipPermissions.item[0].groups.should.equal nil
    response.securityGroupInfo.item[0].ipPermissions.item[0].ipRanges.item[0].cidrIp.should.equal '0.0.0.0/0'
    response.securityGroupInfo.item[0].ipPermissions.item[1].ipProtocol.should.equal 'HTTP'
    response.securityGroupInfo.item[0].ipPermissions.item[1].fromPort.should.equal '80'
    response.securityGroupInfo.item[0].ipPermissions.item[1].toPort.should.equal nil
    response.securityGroupInfo.item[0].ipPermissions.item[1].inOut.should.equal 'OUT'
    response.securityGroupInfo.item[0].ipPermissions.item[1].groups.item[0].userId.should.equal nil
    response.securityGroupInfo.item[0].ipPermissions.item[1].groups.item[0].groupName.should.equal 'Web'
    response.securityGroupInfo.item[0].instances.member[0].instanceId[0].should.equal 'server01'
    response.securityGroupInfo.item[0].instances.member[0].instanceId[1].should.equal 'server02'
  end

  specify "describe_security_groups - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "DescribeSecurityGroups",
                                   "GroupName.1" => "a",
                                   "GroupName.2" => "a",
                                   "Filter.1.Name" => "description",
                                   "Filter.1.Value.1" => "a",
                                   "Filter.1.Value.2" => "a"
                                  ).returns stub(:body => @describe_security_groups_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @describe_security_groups_response_body, :is_a? => true)
    response = @api.describe_security_groups(:group_name => %w(a a), :filter => {:name => "description", :value => %w(a a)})
  end

  specify "describe_security_groups - :group_name正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_security_groups_response_body, :is_a? => true)
    lambda { @api.describe_security_groups(:group_name => 'Group') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_security_groups(:group_name => 'default(Linux)') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_security_groups(:group_name => 'default(Windows)') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_security_groups(:group_name => %w(Group1 Group2 group3)) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "describe_security_groups - :filter正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_security_groups_response_body, :is_a? => true)
    filter_params = {
      'Action' => 'DescribeSecurityGroups',
      'Filter.1.Name'=>'description',
      'Filter.1.Value.1'=>'foo'
    }
    @api.stubs(:make_request).with(filter_params).returns stub(nil)
    lambda { @api.describe_security_groups(:filter => {:name => 'description', :value => 'foo'}) }.should.not.raise(NIFTY::ArgumentError)
    @api.stubs(:make_request).with(filter_params.merge('Filter.1.Value.2'=>'bar', 
                                                       'Filter.2.Name'=>'group-name', 
                                                       'Filter.2.Value.1'=>'bar')).returns stub(nil)
    lambda { @api.describe_security_groups(:filter => [{:name => 'description', :value => %w(foo bar)},{:name => 'group-name', :value => 'bar'}]) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "describe_security_groups - :filter - :name不正" do
    lambda { @api.describe_security_groups(:filter => {:name => 'foo', :value => 'foo'}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_security_groups(:filter => [{:name => 'description', :value => %w(foo bar)},{:name => 'bar', :value => 'bar'}]) }.should.raise(NIFTY::ArgumentError)
  end

  
  # authorize_security_group_ingress
  specify "authorize_security_group_ingress - レスポンスを正しく解析できるか" do
    @api.stubs(:make_request).with({'Action'=>'AuthorizeSecurityGroupIngress', 
                                   'GroupName'=>'gr1', 
                                   'IpPermissions.1.IpProtocol'=>'HTTP', 
                                   'IpPermissions.1.Groups.1.GroupName'=>'gr2'}).returns stub(nil)
    @api.stubs(:exec_request).returns stub(:body => @authorize_security_group_ingress_response_body, :is_a? => true)
    response = @api.authorize_security_group_ingress(:group_name => 'gr1', :ip_permissions => {:ip_protocol => 'HTTP', :group_name => 'gr2'})
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.return.should.equal 'true'
  end

  specify "authorize_security_group_ingress - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with({'Action'=>'AuthorizeSecurityGroupIngress', 
                                   'IpPermissions.1.FromPort'=>'80', 
                                   'IpPermissions.1.Groups.1.GroupName'=>'gr1', 
                                   'IpPermissions.2.Groups.1.GroupName'=>'default(Linux)', 
                                   'IpPermissions.2.Groups.2.GroupName'=>'default(Windows)',
                                   'IpPermissions.2.Groups.1.UserId'=>'id1', 
                                   'IpPermissions.2.Groups.2.UserId'=>'id2', 
                                   'IpPermissions.1.InOut'=>'IN', 
                                   'IpPermissions.2.IpProtocol'=>'HTTP', 
                                   'IpPermissions.1.IpProtocol'=>'TCP', 
                                   'IpPermissions.1.IpRanges.1.CidrIp'=>'111.111.111.111', 
                                   'IpPermissions.1.IpRanges.2.CidrIp'=>'111.111.111.112', 
                                   'IpPermissions.1.ToPort'=>'80', 
                                   'GroupName'=>'gr1', 
    }).returns stub(nil)

    @api.stubs(:exec_request).returns stub(:body => @authorize_security_group_ingress_response_body, :is_a? => true)
    response = @api.authorize_security_group_ingress(:group_name => 'gr1', 
                                                     :ip_permissions => [
                                                       {:ip_protocol => 'TCP', :from_port => 80, :to_port => 80, :in_out => 'IN', 
                                                        :group_name => 'gr1', :cidr_ip => %w(111.111.111.111 111.111.111.112)}, 
                                                       {:ip_protocol => 'HTTP', :user_id => %w(id1 id2), :group_name => %w(default(Linux) default(Windows))}])
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.return.should.equal 'true'
  end

  specify "authorize_security_group_ingress - :ip_permissions未指定" do
      lambda { @api.authorize_security_group_ingress(:group_name => 'gr1', :ip_permissions => "") }.should.raise(NIFTY::ArgumentError)
      lambda { @api.authorize_security_group_ingress(:group_name => 'gr1', :ip_permissions => nil) }.should.raise(NIFTY::ArgumentError)
      lambda { @api.authorize_security_group_ingress(:group_name => 'gr1', :ip_permissions => {}) }.should.raise(NIFTY::ArgumentError)
  end

  specify "authorize_security_group_ingress - :ip_permissions - :ip_protocol正常" do
    @api.stubs(:exec_request).returns stub(:body => @authorize_security_group_ingress_response_body, :is_a? => true)
    @valid_ip_protocol.each do |protocol|
      lambda { @api.authorize_security_group_ingress(:group_name => 'gr1', :ip_permissions => @basic_ip_permissions.merge(:ip_protocol => protocol, :from_port => 8080)) }.should.not.raise(NIFTY::ArgumentError)
    end
  end
  
  specify "authorize_security_group_ingress - :ip_permissions - :from_port正常" do
    @api.stubs(:exec_request).returns stub(:body => @authorize_security_group_ingress_response_body, :is_a? => true)
    lambda { @api.authorize_security_group_ingress(:group_name => 'gr1', :ip_permissions => {:ip_protocol => 'HTTP', :from_port => 80, :group_name => 'gr2'}) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.authorize_security_group_ingress(:group_name => 'gr1', :ip_permissions => {:ip_protocol => 'TCP', :from_port => 443, :group_name => 'gr2'}) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.authorize_security_group_ingress(:group_name => 'gr1', :ip_permissions => {:ip_protocol => 'UDP', :from_port => 22, :group_name => 'gr2'}) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "authorize_security_group_ingress - :ip_permissions - :to_port正常" do
    @api.stubs(:exec_request).returns stub(:body => @authorize_security_group_ingress_response_body, :is_a? => true)
    lambda { @api.authorize_security_group_ingress(:group_name => 'gr1', :ip_permissions => @basic_ip_permissions.merge(:to_port => 80)) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "authorize_security_group_ingress - :ip_permissions - :in_ou正常" do
    @api.stubs(:exec_request).returns stub(:body => @authorize_security_group_ingress_response_body, :is_a? => true)
    @valid_in_out.each do |io|
      lambda { @api.authorize_security_group_ingress(:group_name => 'gr1', :ip_permissions => @basic_ip_permissions.merge(:in_out => io)) }.should.not.raise(NIFTY::ArgumentError)
    end
  end

  specify "authorize_security_group_ingress - :ip_permissions - :user_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @authorize_security_group_ingress_response_body, :is_a? => true)
    lambda { @api.authorize_security_group_ingress(:group_name => 'gr1', :ip_permissions => @basic_ip_permissions.merge(:user_id => 'user')) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.authorize_security_group_ingress(:group_name => 'gr1', :ip_permissions => @basic_ip_permissions.merge(:user_id => %w(foo bar hoge))) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "authorize_security_group_ingress - :ip_permissions - :group_name正常" do
    @api.stubs(:exec_request).returns stub(:body => @authorize_security_group_ingress_response_body, :is_a? => true)
    lambda { @api.authorize_security_group_ingress(:group_name => 'gr1', :ip_permissions => @basic_ip_permissions.merge(:group_name => 'foo')) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.authorize_security_group_ingress(:group_name => 'gr1', :ip_permissions => @basic_ip_permissions.merge(:group_name => %w(foo bar hoge))) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.authorize_security_group_ingress(:group_name => 'gr1', :ip_permissions => [@basic_ip_permissions.merge(:group_name => 'foo'), @basic_ip_permissions.merge(:group_name => 'bar')]) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "authorize_security_group_ingress - :ip_permissions - :cidr_ip正常" do
    @api.stubs(:exec_request).returns stub(:body => @authorize_security_group_ingress_response_body, :is_a? => true)
    lambda { @api.authorize_security_group_ingress(:group_name => 'gr1', :ip_permissions => @basic_ip_permissions.merge(:group_name => nil, :cidr_ip => '111.111.111.111')) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.authorize_security_group_ingress(:group_name => 'gr1', :ip_permissions => @basic_ip_permissions.merge(:group_name => nil, :cidr_ip => ['111.111.111.111', '::ffff:6f6f:6f6f'])) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "authorize_security_group_ingress - :group_name未指定" do
    lambda { @api.authorize_security_group_ingress(@basic_auth_security_params.reject{|k, v| k == :group_name}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.authorize_security_group_ingress(@basic_auth_security_params.merge(:group_name => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.authorize_security_group_ingress(@basic_auth_security_params.merge(:group_name => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "authorize_security_group_ingress - :ip_permissions - :ip_protocol不正" do
    lambda { @api.authorize_security_group_ingress(:group_name => 'foo', :ip_permissions => @basic_ip_permissions.merge(:ip_protocol => 'bar')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.authorize_security_group_ingress(:group_name => 'foo', :ip_permissions => [@basic_ip_permissions.merge(:ip_protocol => 'HTTP'), @basic_ip_permissions.merge(:ip_protocol => 'bar')]) }.should.raise(NIFTY::ArgumentError)
  end

  specify "authorize_security_group_ingress - :ip_permissions - :from_port未指定" do
    lambda { @api.authorize_security_group_ingress(:group_name => 'foo', :ip_permissions => @basic_ip_permissions.merge(:ip_protocol => 'TCP')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.authorize_security_group_ingress(:group_name => 'foo', :ip_permissions => @basic_ip_permissions.merge(:ip_protocol => 'TCP', :from_port => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.authorize_security_group_ingress(:group_name => 'foo', :ip_permissions => @basic_ip_permissions.merge(:ip_protocol => 'TCP', :from_port => '')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.authorize_security_group_ingress(:group_name => 'foo', :ip_permissions => @basic_ip_permissions.merge(:ip_protocol => 'UDP')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.authorize_security_group_ingress(:group_name => 'foo', :ip_permissions => @basic_ip_permissions.merge(:ip_protocol => 'UDP', :from_port => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.authorize_security_group_ingress(:group_name => 'foo', :ip_permissions => @basic_ip_permissions.merge(:ip_protocol => 'UDP', :from_port => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "authorize_security_group_ingress - :cidr_ip不正" do
    lambda { @api.authorize_security_group_ingress(:group_name => 'foo', :ip_permissions => @basic_ip_permissions.merge(:cidr_ip => 'foo')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.authorize_security_group_ingress(:group_name => 'foo', :ip_permissions => [@basic_ip_permissions.merge(:cidr_ip => '111.111.111.111'), @basic_ip_permissions.merge(:cidr_ip => 'foo')]) }.should.raise(NIFTY::ArgumentError)
  end


  # revoke_security_group_ingress
  specify "revoke_security_group_ingress - レスポンスを正しく解析できるか" do
    @api.stubs(:make_request).with({'Action'=>'RevokeSecurityGroupIngress', 
                                   'GroupName'=>'gr1', 
                                   'IpPermissions.1.IpProtocol'=>'HTTP', 
                                   'IpPermissions.1.Groups.1.GroupName'=>'gr2'}).returns stub(nil)
    @api.stubs(:exec_request).returns stub(:body => @revoke_security_group_ingress_response_body, :is_a? => true)
    response = @api.revoke_security_group_ingress(:group_name => 'gr1', :ip_permissions => {:ip_protocol => 'HTTP', :group_name => 'gr2'})
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.return.should.equal 'true'
  end

  specify "revoke_security_group_ingress - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with({'Action'=>'RevokeSecurityGroupIngress', 
                                   'IpPermissions.1.FromPort'=>'80', 
                                   'IpPermissions.1.Groups.1.GroupName'=>'gr1', 
                                   'IpPermissions.2.Groups.1.GroupName'=>'default(Linux)', 
                                   'IpPermissions.2.Groups.2.GroupName'=>'default(Windows)',
                                   'IpPermissions.2.Groups.1.UserId'=>'id1', 
                                   'IpPermissions.2.Groups.2.UserId'=>'id2', 
                                   'IpPermissions.2.Groups.3.UserId'=>'id3', 
                                   'IpPermissions.1.InOut'=>'IN', 
                                   'IpPermissions.2.IpProtocol'=>'HTTP', 
                                   'IpPermissions.1.IpProtocol'=>'TCP', 
                                   'IpPermissions.1.IpRanges.1.CidrIp'=>'111.111.111.111', 
                                   'IpPermissions.1.IpRanges.2.CidrIp'=>'111.111.111.112', 
                                   'IpPermissions.1.ToPort'=>'80', 
                                   'GroupName'=>'gr1', 
    }).returns stub(nil)

    @api.stubs(:exec_request).returns stub(:body => @revoke_security_group_ingress_response_body, :is_a? => true)
    response = @api.revoke_security_group_ingress(:group_name => 'gr1', 
                                                     :ip_permissions => [
                                                       {:ip_protocol => 'TCP', :from_port => 80, :to_port => 80, :in_out => 'IN', 
                                                        :group_name => 'gr1', :cidr_ip => %w(111.111.111.111 111.111.111.112)}, 
                                                       {:ip_protocol => 'HTTP', :user_id => %w(id1 id2)<<''<<'id3', :group_name => %w(default(Linux) default(Windows))}])
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.return.should.equal 'true'
  end


  specify "revoke_security_group_ingress - :ip_permissions未指定" do
      lambda { @api.revoke_security_group_ingress(:group_name => 'gr1', :ip_permissions => "") }.should.raise(NIFTY::ArgumentError)
      lambda { @api.revoke_security_group_ingress(:group_name => 'gr1', :ip_permissions => nil) }.should.raise(NIFTY::ArgumentError)
      lambda { @api.revoke_security_group_ingress(:group_name => 'gr1', :ip_permissions => {}) }.should.raise(NIFTY::ArgumentError)
  end

  specify "revoke_security_group_ingress - :ip_permissions - :ip_protocol正常" do
    @api.stubs(:exec_request).returns stub(:body => @revoke_security_group_ingress_response_body, :is_a? => true)
    @valid_ip_protocol.each do |protocol|
      lambda { @api.revoke_security_group_ingress(:group_name => 'gr1', :ip_permissions => @basic_ip_permissions.merge(:ip_protocol => protocol, :from_port => 8080)) }.should.not.raise(NIFTY::ArgumentError)
    end
  end

  specify "revoke_security_group_ingress - :ip_permissions - :from_port正常" do
    @api.stubs(:exec_request).returns stub(:body => @revoke_security_group_ingress_response_body, :is_a? => true)
    lambda { @api.revoke_security_group_ingress(:group_name => 'gr1', :ip_permissions => {:ip_protocol => 'HTTP', :from_port => 80, :group_name => 'gr2'}) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.revoke_security_group_ingress(:group_name => 'gr1', :ip_permissions => {:ip_protocol => 'TCP', :from_port => 443, :group_name => 'gr2'}) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.revoke_security_group_ingress(:group_name => 'gr1', :ip_permissions => {:ip_protocol => 'UDP', :from_port => 22, :group_name => 'gr2'}) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "revoke_security_group_ingress - :ip_permissions - :to_port正常" do
    @api.stubs(:exec_request).returns stub(:body => @revoke_security_group_ingress_response_body, :is_a? => true)
    lambda { @api.revoke_security_group_ingress(:group_name => 'gr1', :ip_permissions => @basic_ip_permissions.merge(:to_port => 80)) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "revoke_security_group_ingress - :ip_permissions - :in_ou正常" do
    @api.stubs(:exec_request).returns stub(:body => @revoke_security_group_ingress_response_body, :is_a? => true)
    @valid_in_out.each do |io|
      lambda { @api.revoke_security_group_ingress(:group_name => 'gr1', :ip_permissions => @basic_ip_permissions.merge(:in_out => io)) }.should.not.raise(NIFTY::ArgumentError)
    end
  end

  specify "revoke_security_group_ingress - :ip_permissions - :user_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @revoke_security_group_ingress_response_body, :is_a? => true)
    lambda { @api.revoke_security_group_ingress(:group_name => 'gr1', :ip_permissions => @basic_ip_permissions.merge(:user_id => 'user')) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.revoke_security_group_ingress(:group_name => 'gr1', :ip_permissions => @basic_ip_permissions.merge(:user_id => %w(foo bar hoge))) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "revoke_security_group_ingress - :ip_permissions - :group_name正常" do
    @api.stubs(:exec_request).returns stub(:body => @revoke_security_group_ingress_response_body, :is_a? => true)
    lambda { @api.revoke_security_group_ingress(:group_name => 'gr1', :ip_permissions => @basic_ip_permissions.merge(:group_name => 'foo')) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.revoke_security_group_ingress(:group_name => 'gr1', :ip_permissions => @basic_ip_permissions.merge(:group_name => %w(foo bar hoge))) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.revoke_security_group_ingress(:group_name => 'gr1', :ip_permissions => [@basic_ip_permissions.merge(:group_name => 'foo'), @basic_ip_permissions.merge(:group_name => 'bar')]) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "revoke_security_group_ingress - :ip_permissions - :cidr_ip正常" do
    @api.stubs(:exec_request).returns stub(:body => @revoke_security_group_ingress_response_body, :is_a? => true)
    lambda { @api.revoke_security_group_ingress(:group_name => 'gr1', :ip_permissions => @basic_ip_permissions.merge(:group_name => nil, :cidr_ip => '111.111.111.111')) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.revoke_security_group_ingress(:group_name => 'gr1', :ip_permissions => @basic_ip_permissions.merge(:group_name => nil, :cidr_ip => ['111.111.111.111', '::ffff:6f6f:6f6f'])) }.should.not.raise(NIFTY::ArgumentError)
  end

  specify "revoke_security_group_ingress - :group_name未指定" do
    lambda { @api.revoke_security_group_ingress(@basic_auth_security_params.reject{|k, v| k == :group_name}) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.revoke_security_group_ingress(@basic_auth_security_params.merge(:group_name => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.revoke_security_group_ingress(@basic_auth_security_params.merge(:group_name => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "revoke_security_group_ingress - :ip_permissions - :ip_protocol不正" do
    lambda { @api.revoke_security_group_ingress(:group_name => 'foo', :ip_permissions => @basic_ip_permissions.merge(:ip_protocol => 'bar')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.revoke_security_group_ingress(:group_name => 'foo', :ip_permissions => [@basic_ip_permissions.merge(:ip_protocol => 'HTTP'), @basic_ip_permissions.merge(:ip_protocol => 'bar')]) }.should.raise(NIFTY::ArgumentError)
  end

  specify "revoke_security_group_ingress - :ip_permissions - :from_port未指定" do
    lambda { @api.revoke_security_group_ingress(:group_name => 'foo', :ip_permissions => @basic_ip_permissions.merge(:ip_protocol => 'TCP')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.revoke_security_group_ingress(:group_name => 'foo', :ip_permissions => @basic_ip_permissions.merge(:ip_protocol => 'TCP', :from_port => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.revoke_security_group_ingress(:group_name => 'foo', :ip_permissions => @basic_ip_permissions.merge(:ip_protocol => 'TCP', :from_port => '')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.revoke_security_group_ingress(:group_name => 'foo', :ip_permissions => @basic_ip_permissions.merge(:ip_protocol => 'UDP')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.revoke_security_group_ingress(:group_name => 'foo', :ip_permissions => @basic_ip_permissions.merge(:ip_protocol => 'UDP', :from_port => nil)) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.revoke_security_group_ingress(:group_name => 'foo', :ip_permissions => @basic_ip_permissions.merge(:ip_protocol => 'UDP', :from_port => '')) }.should.raise(NIFTY::ArgumentError)
  end

  specify "revoke_security_group_ingress - :cidr_ip不正" do
    lambda { @api.revoke_security_group_ingress(:group_name => 'foo', :ip_permissions => @basic_ip_permissions.merge(:cidr_ip => 'foo')) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.revoke_security_group_ingress(:group_name => 'foo', :ip_permissions => [@basic_ip_permissions.merge(:cidr_ip => '111.111.111.111'), @basic_ip_permissions.merge(:cidr_ip => 'foo')]) }.should.raise(NIFTY::ArgumentError)
  end


  # register_instances_with_security_group
  specify "register_instances_with_security_group - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @register_instances_with_security_group_response_body, :is_a? => true)
    response = @api.register_instances_with_security_group(:group_name => 'gr1', :instance_id => 'server01')
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.instancesSet.item[0].instanceId.should.equal 'server01'
    response.instancesSet.item[1].instanceId.should.equal 'server02'
  end

  specify "register_instances_with_security_group - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "RegisterInstancesWithSecurityGroup",
                                   "GroupName" => "a",
                                   "InstanceId.1" => "a",
                                   "InstanceId.2" => "a"
                                  ).returns stub(:body => @register_instances_with_security_group_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @register_instances_with_security_group_response_body, :is_a? => true)
    response = @api.register_instances_with_security_group(:group_name => "a", :instance_id => %w(a a))
  end

  specify "register_instances_with_security_group - :group_name, :instance_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @register_instances_with_security_group_response_body, :is_a? => true)
    lambda { @api.register_instances_with_security_group(:group_name => 'foo', :instance_id => 'bar') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.register_instances_with_security_group(:group_name => 'default(Linux)', :instance_id => 'bar') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.register_instances_with_security_group(:group_name => 'default(Windows)', :instance_id => 'bar') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.register_instances_with_security_group(:group_name => 'foo', :instance_id => %w(bar hoge)) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "register_instances_with_security_group - :group_name未指定" do
    lambda { @api.register_instances_with_security_group }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_instances_with_security_group(:group_name => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_instances_with_security_group(:group_name => '') }.should.raise(NIFTY::ArgumentError)
  end

  specify "register_instances_with_security_group - :instance_id未指定" do
    lambda { @api.register_instances_with_security_group(:group_name => 'foo') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_instances_with_security_group(:group_name => 'foo', :instance_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.register_instances_with_security_group(:group_name => 'foo', :instance_id => '') }.should.raise(NIFTY::ArgumentError)
  end


  # deregister_instances_from_security_group
  specify "deregister_instances_from_security_group - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @deregister_instances_from_security_group_response_body, :is_a? => true)
    response = @api.deregister_instances_from_security_group(:group_name => 'gr1', :instance_id => 'server01')
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.instancesSet.item[0].instanceId.should.equal 'server01'
    response.instancesSet.item[1].instanceId.should.equal 'server02'
  end

  specify "deregister_instances_from_security_group - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "DeregisterInstancesFromSecurityGroup",
                                   "GroupName" => "a",
                                   "InstanceId.1" => "a",
                                   "InstanceId.2" => "a"
                                  ).returns stub(:body => @deregister_instances_from_security_group_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @deregister_instances_from_security_group_response_body, :is_a? => true)
    response = @api.deregister_instances_from_security_group(:group_name => "a", :instance_id => %w(a a))
  end

  specify "deregister_instances_from_security_group - :group_name, :instance_id正常" do
    @api.stubs(:exec_request).returns stub(:body => @deregister_instances_from_security_group_response_body, :is_a? => true)
    lambda { @api.deregister_instances_from_security_group(:group_name => 'foo', :instance_id => 'bar') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.deregister_instances_from_security_group(:group_name => 'default(Linux)', :instance_id => 'bar') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.deregister_instances_from_security_group(:group_name => 'default(Windows)', :instance_id => 'bar') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.deregister_instances_from_security_group(:group_name => 'foo', :instance_id => %w(bar hoge)) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "deregister_instances_from_security_group - :group_name未指定" do
    lambda { @api.deregister_instances_from_security_group }.should.raise(NIFTY::ArgumentError)
    lambda { @api.deregister_instances_from_security_group(:group_name => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.deregister_instances_from_security_group(:group_name => '') }.should.raise(NIFTY::ArgumentError)
  end

  specify "deregister_instances_from_security_group - :instance_id未指定" do
    lambda { @api.deregister_instances_from_security_group(:group_name => 'foo') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.deregister_instances_from_security_group(:group_name => 'foo', :instance_id => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.deregister_instances_from_security_group(:group_name => 'foo', :instance_id => '') }.should.raise(NIFTY::ArgumentError)
  end

  
  # describe_security_activities
  specify "describe_security_activities - レスポンスを正しく解析できるか" do
    @api.stubs(:exec_request).returns stub(:body => @describe_security_activities_response_body, :is_a? => true)
    response = @api.describe_security_activities(:group_name => 'default(Linux)')
    response.requestId.should.equal '320fc738-a1c7-4a2f-abcb-20813a4e997c'
    response.groupName.should.equal 'websrv'
    response.log.should.equal "2011-01-05T08:53:29+09:00 Altor_VNF time=1294217609140 fw_id=4 src_ip=10.0.6.201 src_port=68 dst_ip=10.0.4.11  dst_port=67 ip_proto=17 action=accept vm_id=16853 rule_id=52 type=fw\n2011-01-09T11:21:53+09:00 Altor_VNF time=2297218603613 fw_id=4 src_ip=10.0.6.201 src_port=68 dst_ip=10.0.4.11  dst_port=67 ip_proto=17 action=accept vm_id=16853 rule_id=52 type=fw"
  end

  specify "describe_security_activities - パラメータが正しく作られるか" do
    @api.stubs(:make_request).with("Action" => "DescribeSecurityActivities",
                                   "GroupName" => "default(Windows)",
                                   "ActivityDate" => "20110617",
                                   "Range.All" => "true",
                                   "Range.StartNumber" => "1",
                                   "Range.EndNumber" => "2"
                                  ).returns stub(:body => @describe_security_activities_response_body, :is_a? => true)
    @api.stubs(:exec_request).returns stub(:body => @describe_security_activities_response_body, :is_a? => true)
    response = @api.describe_security_activities(:group_name => "default(Windows)", :activity_date => "20110617", :range_all => true, :range_start_number => 1, :range_end_number => 2)
  end

  specify "describe_security_activities - :activity_date正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_security_activities_response_body, :is_a? => true)
    lambda { @api.describe_security_activities(:group_name => 'foo', :activity_date => '20110530') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_security_activities(:group_name => 'foo', :activity_date => '2011-05-30') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_security_activities(:group_name => 'foo', :activity_date => '2011/05/30') }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "describe_security_activities - :all正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_security_activities_response_body, :is_a? => true)
    lambda { @api.describe_security_activities(:group_name => 'foo', :all => true) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_security_activities(:group_name => 'foo', :all => false) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_security_activities(:group_name => 'foo', :all => 'true') }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_security_activities(:group_name => 'foo', :all => 'false') }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "describe_security_activities - :start_number, :end_number正常" do
    @api.stubs(:exec_request).returns stub(:body => @describe_security_activities_response_body, :is_a? => true)
    lambda { @api.describe_security_activities(:group_name => 'foo', :start_number => 1) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_security_activities(:group_name => 'foo', :start_number => 5) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_security_activities(:group_name => 'foo', :start_number => 1, :end_number => 100) }.should.not.raise(NIFTY::ArgumentError)
    lambda { @api.describe_security_activities(:group_name => 'foo', :start_number => 100, :end_number => 100) }.should.not.raise(NIFTY::ArgumentError)
  end
  
  specify "describe_security_activities - :group_name未指定" do
    lambda { @api.describe_security_activities }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_security_activities(:group_name => nil) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_security_activities(:group_name => '') }.should.raise(NIFTY::ArgumentError)
  end

  specify "describe_security_activities - :group_name不正" do
    lambda { @api.describe_security_activities(:group_name => 'foo', :activity_date => '2011-5-30') }.should.raise(NIFTY::ArgumentError)
  end

  specify "describe_security_activities - :range_all不正" do
    lambda { @api.describe_security_activities(:group_name => 'foo', :range_all => 'foo') }.should.raise(NIFTY::ArgumentError)
  end

  specify "describe_security_activities - :range_start_number, :range_end_number不正" do
    lambda { @api.describe_security_activities(:group_name => 'foo', :range_start_number => 'foo') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_security_activities(:group_name => 'foo', :range_start_number => 0) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_security_activities(:group_name => 'foo', :range_end_number => 'foo') }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_security_activities(:group_name => 'foo', :range_end_number => 0) }.should.raise(NIFTY::ArgumentError)
    lambda { @api.describe_security_activities(:group_name => 'foo', :range_start_number => 5, :range_end_number => 1) }.should.raise(NIFTY::ArgumentError)
  end
end
