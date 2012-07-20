#--
# ニフティクラウドSDK for Ruby
#
# Ruby Gem Name::  nifty-cloud-sdk
# Author::    NIFTY Corporation
# Copyright:: Copyright 2011 NIFTY Corporation All Rights Reserved.
# License::   Distributes under the same terms as Ruby
# Home::      http://cloud.nifty.com/api/
#++

require File.dirname(__FILE__) + '/test_helper.rb'

context "Response classes" do


  before do
    @http_xml = <<-RESPONSE
    <RebootInstancesResponse xmlns="http://cp.cloud.nifty.com/api/1.7/">
      <return>true</return>
    </RebootInstancesResponse>
    RESPONSE

    @response = NIFTY::Response.parse(:xml => @http_xml)
  end


  specify "should show the response as a formatted string when calling #inspect" do
    # sorting the response hash first since ruby 1.8.6 and ruby 1.9.1 sort the hash differently before the inspect
    @response.sort.inspect.should.equal %{[[\"return\", \"true\"], [\"xmlns\", \"http://cp.cloud.nifty.com/api/1.7/\"]]}
  end


  specify "should be a Hash" do
    @response.kind_of?(Hash).should.equal true
  end


  specify "should return its members" do
    @response.keys.length.should.equal 2
    test_array = ["return", "xmlns"].sort
    @response.keys.sort.should.equal test_array
  end
end
