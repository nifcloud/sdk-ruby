# coding:utf-8
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
gem 'test-unit'

%w[ test/unit test/spec mocha ].each { |f|
  begin
    require f
  rescue LoadError
    abort "Unable to load required gem for test: #{f}"
  end
}

require File.dirname(__FILE__) + '/../lib/NIFTY'

