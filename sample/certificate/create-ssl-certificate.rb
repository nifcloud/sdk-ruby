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
  #:fqdn_id                => "fqdnId",
  #:fqdn                   => "fqdn",
  #:count                  => 0,
  #:validity_term          => 0,
  #:key_length             => 0,
  #:organization_name      => "organizationName",
  #:organization_unit_name => "organizationUnitName",
  #:country_name           => "countryName",
  #:state_name             => "stateName",
  #:location_name          => "locationName",
  #:email_address          => "emailAddress"
}

pp response = ncs4r.create_ssl_certificate(options)

p response.fqdnId
p response.fqdn
p response.validityTerm
p response.certState
