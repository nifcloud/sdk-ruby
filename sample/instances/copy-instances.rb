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
  #:instance_id      => "instanceId",
  #:instance_name    => "instanceName",
  #:instance_type    => "instanceType",
  #:accounting_type  => "accountingType",
  #:ip_type          => "static",
  #:load_balancers   => [{ :load_balancer_name => "loadBalancerName",
  #                        :load_balancer_port => 0,
  #                        :instance_port      => 0,
  #                      }],
  #:group_id         => "groupId",
  #:copy_count       => 2
}

pp response = ncs4r.copy_instances(options)

response.copyInstanceSet.member.each do |instance|
  p instance.instanceId
  p instance.instanceState
end
