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
  #:user_id        => "userId",
  #:group_name     => "group01",
  #:ip_permissions => [{:ip_protocl  => "ipProtocol", 
  #                     :from_port   => 0, 
  #                     :to_port     => 0, 
  #                     :in_out      => "inOut",
  #                     :user_id     => "userId",
  #                     :group_name  => "groupName",
  #                     :cidr_ip     => "*.*.*.*"}]
}

pp response = ncs4r.revoke_security_group_ingress(options)

p response.return
