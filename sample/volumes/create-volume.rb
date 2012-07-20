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
  #:size               => "size",
  #:snapshot_id        => "snapshotId",
  #:availability_zone  => "availabilityZone",
  #:volume_id          => "volumeId",
  #:disk_type          => "diskType",
  #:instance_id        => "instanceId"
}

pp response = ncs4r.create_volume(options)
p response.volumeId
p response["size"]
p response.diskType
p response.snapshotId
p response.availabilityZone
p response.status
p response.createTime
