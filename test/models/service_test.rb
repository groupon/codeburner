#
#The MIT License (MIT)
#
#Copyright (c) 2016, Groupon, Inc.
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
#
require 'test_helper'

class ServiceTest < ActiveSupport::TestCase
  def service
    @service ||= Service.new
  end

  test "only valid with short_name set" do
    refute service.valid?, "Service saved without short_name"
    service.short_name = 'test'
    assert service.valid?, "Failed to save with short name"
  end

  test "duplicate short_name is invalid" do
    duplicate_service = Service.new({:short_name => services(:one).short_name})
    refute duplicate_service.valid?, "Service valid with duplicate short_name"
  end

  test "calls CodeburnerUtil.get_service_info and returns valid pretty_name" do
    blank_service = Service.new
    blank_service.short_name = 'one'
    blank_service.service_portal = true
    CodeburnerUtil.expects(:get_service_info).returns({ 'title' => 'Test Service' }).once
    assert blank_service.pretty_name(true) == 'Test Service', 'pretty_name is not Test Service'
  end

  test "searchable named scopes work as expected" do
    assert_equal Service.all.sort.inspect, Service.id(nil).short_name(nil).pretty_name(nil).has_findings.has_burns.sort.inspect, "chained scopes don't equal Service.all"
    assert_equal services(:one), Service.pretty_name('Test Service').first, "Service.pretty_name('Test Service') is not services(:one)"
    assert_equal services(:one), Service.id(services(:one).id).first, "single select service doesn't work"
  end
end
