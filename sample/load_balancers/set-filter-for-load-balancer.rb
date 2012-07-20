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
  #:load_balancer_name => "loadBalancerName",
  #:load_balancer_port => 0,
  #:instance_port      => 0,
  #:ip_addresses       => [{:ip_address    => "ipAddress",
  #                         :add_on_filter => false}],
  #:filter_type        => "filterType"
}

pp response = ncs4r.set_filter_for_load_balancer(options)

if filter = response.SetFilterForLoadBalancerResult.Filter
  p filter.FilterType
  filter.IPAddresses.member.each do |ipaddr|
    p ipaddr.IPAddress
  end
end
