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
  #:executable_by  => ["executableUser"],
  #:image_id       => ["imageId"],
  #:image_name     => ["imageName"],
  #:owner          => ["owner"]
}

pp response = ncs4r.describe_images(options)

response.imagesSet.item.each do |image|
  p image.imageId
  p image.imageLocation
  p image.imageState
  p image.imageOwnerId
  p image.isPublic
  if product_codes = image.productCodes
    product_codes.item.each do |code|
      p code.productCode
    end
  end
  p image.architecture
  p image.imageType
  p image.kernelId
  p image.ramdiskId
  p image.platform
  if reason = image.stateReason
    p reason.code
    p reason.message
  end
  p image.imageOwnerAlias
  p image.name
  p image.description
  p image.detailDescription
  p image.redistributable
  p image.rootDeviceType
  if block_device_mapping = image.blockDeviceMapping
    block_device_mapping.item.each do |device|
      p device.deviceName
      p device.virtualName
      if ebs = device.ebs
        p ebs.volumeId
        p ebs.status
        p ebs.attachTime
        p ebs.deleteOnTermination
      end
      p device.noDevice
    end
  end
end
