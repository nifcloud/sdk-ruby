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
  #:fqdn_id  => ["fqdnId"],
  #:fqdn     => ["fqdn"],
}

pp response = ncs4r.describe_ssl_certificates(options)

response.certsSet.item.each do |cert|
  p cert.fqdnId
  p cert.fqdn
  p count = cert["count"]
  p cert.certState
  if period = cert.period
    p period.startDate
    p period.endDate
  end
  p cert.keyLength
  p cert.uploadState
  p cert.description
  if cert_info = cert.certInfo
    p cert_info.organizationName
    p cert_info.organizationUnitName
    p cert_info.countryName
    p cert_info.stateName
    p cert_info.locationName
    p cert_info.emailAddress
  end
end
