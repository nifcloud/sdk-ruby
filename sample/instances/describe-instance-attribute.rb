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
  #:instance_id  => "instanceId",
  #:attribute    => "attribute"
}

pp response = ncs4r.describe_instance_attribute(options)

p response.instanceId
if instance_type = response.instanceType
  p instance_type.value
end
if kernel_id = response.kernelId
  p kernel_id.value
end
if ramdisk = response.ramdiskId
  p ramdisk_id.value
end
if user_data = response.userData
  p user_data.value
end
if disable_api_termination = response.disableApiTermination
  p disable_api_termination.value
end
if instance_initiated_shutdown_behavior = response.instanceInitiatedShutdownBehavior
  p instance_initiated_shutdown_behavior.value
end
if root_device_name = response.rootDeviceName
  p root_device_name.value
end
if block_device_mapping = response.blockDeviceMapping
  block_device_mapping.item.each do |mapping|
    p mapping.deviceName
    if ebs = mapping.ebs
      p ebs.volumeId
      p ebs.status
      p ebs.attachTime
      p ebs.deleteOnTermination
    end
  end
end
if accounting_type = response.accountingType
  p accounting_type.value
end
if loadbalancing = response.loadbalancing
  loadbalancing.item.each do |balancing|
    p balancing.loadBalancerName
    p balancing.loadBalancerPort
    p balancing.instancePort
  end
end
if copy_info = response.copyInfo
  p copy_info.value
end
if autoscaling = response.autoscaling
  p autoscaling.autoScalingGroupName
  p autoscaling.expireTime
end
