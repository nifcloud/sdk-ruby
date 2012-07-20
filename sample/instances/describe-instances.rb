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
  #:instance_id  => ["instanceId"]
}

pp response = ncs4r.describe_instances(options)

response.reservationSet.item.each do |set|
  p set.reservationId
  p set.ownerId
  if group_set = set.groupSet
    group_set.item.each do |group|
      p group.groupId
    end
  end
  set.instancesSet.item.each do |instance|
    p instance.instanceId
    p instance.imageId
    p instance.instanceState.code
    p instance.instanceState.name
    p instance.privateDnsName
    p instance.dnsName
    p instance.reason
    p instance.keyName
    p instance.amiLaunchIndex
    if product_codes = instance.productCodes
      product_codes.item.each do |code|
        p code.productCode
      end
    end
    p instance.instanceType
    p instance.launchTime
    p instance.placement.availabilityZone
    p instance.kernelId
    p instance.ramdiskId
    p instance.platform
    if monitoring = instance.monitoring
      p monitoring.state
    end
    p instance.subnetId
    p instance.vpcId
    p instance.privateIpAddress
    p instance.ipAddress
    p instance.privateIpAddressV6
    p instance.ipAddressV6
    p instance.stateReason
    p instance.code
    p instance.message
    p instance.architecture
    p instance.rootDeviceType
    p instance.accountingType
    p instance.ipType
    if block_device_mapping = instance.blockDeviceMapping
      block_device_mapping.item.each do |device|
        p device.deviceName
        if ebs = device.ebs
          p ebs.volumeId
          p ebs.status
          p ebs.attachTime
          p ebs.deleteOnTermination
        end
      end
    end
    p instance.instanceLifecycle
    p instance.spotInstanceRequestId
    p instance.accountingType
    if loadbalancing = response.loadbalancing
      loadbalancing.item.each do |balancing|
        p balancing.loadBalancerName
        p balancing.loadBalancerPort
        p balancing.instancePort
      end
    end
    p instance.copyInfo
    if autoscaling = response.autoscaling
      p autoscaling.autoScalingGroupName
      p autoscaling.expireTime
    end
  end
end
