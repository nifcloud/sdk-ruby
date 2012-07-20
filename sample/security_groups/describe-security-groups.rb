#!/usr/bin/env ruby
#--
# ニフティクラウドSDK for Ruby
#
# Ruby Gem Name::  nifty-cloud-sdk
# Author::    NIFTY Corporation
# Copyright:: Copyright 2011 NIFTY Corporation All Rights Reserved.
# License::   Distributes under the same terms as Ruby
# Home::      http://cloud.nifty.com/api/
#++

require 'rubygems'
require File.dirname(__FILE__) + "/../../lib/NIFTY"
require 'pp'

ACCESS_KEY = ENV["NIFTY_CLOUD_ACCESS_KEY"] || "<Your Access Key ID>"
SECRET_KEY = ENV["NIFTY_CLOUD_SECRET_KEY"] || "<Your Secret Access Key>"


ncs4r = NIFTY::Cloud::Base.new(:access_key => ACCESS_KEY, :secret_key => SECRET_KEY)

options = {
  #:group_name => ["groupName"],
  #:filter     => [{:name  => "group-name",
  #                 :value => "groupName"}]
}

pp response = ncs4r.describe_security_groups(options)

response.securityGroupInfo.item.each do |security_group|
  p security_group.ownerId
  p security_group.groupName
  p security_group.groupDescription
  p security_group.groupStatus
  if ip_permissions = security_group.ipPermissions
    ip_permissions.item.each do |ip_permission|
      p ip_permission.ipProtocol
      p ip_permission.fromPort
      p ip_permission.toPort
      p ip_permission.inOut
      if groups = ip_permission.groups
        groups.item.each do |group|
          p group.userId
          p group.groupName
        end
      end
      if ip_ranges = ip_permission.ipRanges
        ip_ranges.item.each do |ip_range|
          p ip_range.cidrIp
        end
      end
    end
  end
  if instances_set = security_group.instancesSet
    instances_set.item.each do |instance|
      p instance.instanceId
    end
  end
end
