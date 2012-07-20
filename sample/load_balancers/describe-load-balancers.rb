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
  #:load_balancer_name => ["loadBalancerName"],
  #:load_balancer_port => [0],
  #:instance_port      => [0]
}

pp response = ncs4r.describe_load_balancers(options)

if descriptions = response.DescribeLoadBalancersResult.LoadBalancerDescriptions
  descriptions.member.each do |description|
    p description.LoadBalancerName
    p description.DNSName
    p description.NetworkVolume
    if listener_descriptions = description.ListenerDescriptions
      listener_descriptions.member.each do |listener_description|
        listener = listener_description.Listener
        p listener.Protocol
        p listener.LoadBalancerPort
        p listener.InstancePort
        p listener.BalancingType
      end
    end
    if policy_names = descriptions.PolicyNames
      policy_names.member.each do |policy_name|
        if policies = policy_name.Policies
          if app_cookie_stickiness_policies = policies.AppCookieStickinessPolicies
            app_cookie_stickiness_policies.member.each do |policy|
              p policy.PolicyName
              p policy.CookieName
            end
          end
          if lb_cookie_stickiness_policies = policies.LBCookieStickinessPolicies
            lb_cookie_stickiness_policies.member.each do |policy|
              p policy.PolicyName
              p policy.CookieExpirationPeriod
            end
          end
        end
      end
    end
    if zones = description.AvailabilityZones
      zones.member.each do |zone|
        p zone
      end
    end
    if instances = description.Instances
      instances.member.each do |instance|
        p instance.InstanceId
      end
    end
    if health = description.HealthCheck
      p health.Target
      p health.Interval
      p health.Timeout
      p health.UnhealthyThreshold
      p health.HealthyThreshold
    end
    if filter = description.Filter
      p filter.FilterType
      if ip_addresses = filter.IPAddresses
        ip_addresses.member.each do |ip_address|
          p ip_address
        end
      end
    end
    p description.CreatedTime
  end
end
