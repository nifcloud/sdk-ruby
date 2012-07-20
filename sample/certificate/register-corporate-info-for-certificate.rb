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
  #:agreement        => true,
  #:tdb_code         => "tdbCode",
  #:corp_name        => "corpName",
  #:corp_grade       => "corpGrade",
  #:president_name1  => "presidentName1",
  #:president_name2  => "presidentName2",
  #:zip1             => 123,
  #:zip2             => 4567,
  #:pref             => "pref",
  #:city             => "city",
  #:name1            => "name1",
  #:name2            => "name2",
  #:kana_name1       => "kanaName1",
  #:kana_name2       => "kanaName2",
  #:post_name        => "postName",
  #:division_name    => "divisionName"
}

pp response = ncs4r.register_corporate_info_for_certificate(options)

p response.tdbCode
p response.corpName
p response.corpGrade
p response.presidentName
p response.presidentName
p response.zip1
p response.zip2
p response.pref
p response.city
p response.name1
p response.name2
p response.kanaName
p response.kanaName
p response.postName
p response.divisionName
