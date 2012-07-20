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
  #:load_balancer_name   => "loadBalancerName",
  #:load_balancer_port   => 0,
  #:instance_port        => 0,
  #:target               => "target",
  #:interval             => 0,
  #:timeout              => 30,
  #:unhealthy_threshold  => 30,
  #:healthy_threshold    => 30
}

pp response = ncs4r.configure_health_check(options)

if health = response.ConfigureHealthCheckResult.HealthCheck
  p health.Target
  p health.Interval
  p health.Timeout
  p health.UnhealthyThreshold
  p health.HealthyThreshold
end
