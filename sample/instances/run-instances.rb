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
  #:image_id                 => "imageId",
  #:min_count                => 0,
  #:max_count                => 0,
  #:key_name                 => "keyName",
  #:security_group           => ["groupName"],
  #:additional_info          => "additionalInfo",
  #:user_data                => "userData",
  #:addressing_type          => "addressingType",
  #:instance_type            => "instanceType",
  #:availability_zone        => "availabilityZone",
  #:kernel_id                => "kernelId",
  #:ramdisk_id               => "ramdiskId",
  #:block_device_mapping     => [{ :device_name                => "deviceName", 
  #                                :virtual_name               => "virtualName",
  #                                :ebs_snapshot_id            => "snapshotId",
  #                                :ebs_volume_size            => 0,
  #                                :ebs_delete_on_termination  => false,
  #                                :ebs_no_device              => "noDevice"
  #                              }],
  #:monitoring_enabled       => false,
  #:subnet_id                => "subnetId",
  #:disable_api_termination  => false,
  #:instance_initiated_shutdown_behavior => "instanceInitiatedShutdownBehavior",
  #:accounting_type          => "accountingType",
  #:instance_id              => "instanceId",
  #:admin                    => "admin",
  #:password                 => "password",
  #:ip_type                  => "static"
}

pp response = ncs4r.run_instances(options)


p response.reservationId
p response.ownerId
p response.groupSet
p response.groupId
response.instancesSet.item.each do |instance|
  p instance.instanceId
  p instance.imageId
  p instance.instanceState.code
  p instance.instanceState.name
  p instance.privateDnsName
  p instance.dnsName
  p instance.reason
  p instance.keyName
  p instance.admin
  p instance.amiLaunchIndex
  if product_codes = instance.productCodes
    product_codes.item.each do |code|
      p code.productCode
    end
  end
  p instance.instanceType
  p instance.launchTime
  instance.placement
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
  if reason = instance.stateReason
    p reason.code
    p reason.message
  end
  p instance.architecture
  p instance.rootDeviceType
  p instance.rootDeviceName
  if instance.blockDeviceMapping
    p instance.instanceLifecycle
    p instance.spotInstanceRequestId
    p instance.accountingType
    p instance.ipType
  end
end
