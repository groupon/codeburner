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

class FindingTest < ActiveSupport::TestCase

  test "is filtered by filters" do
    filtered_finding = Finding.create({
      :service => filters(:one).service,
      :severity => filters(:one).severity,
      :fingerprint => filters(:one).fingerprint,
      :scanner => filters(:one).scanner,
      :description => filters(:one).description,
      :detail => filters(:one).detail,
      :file => filters(:one).file,
      :line => filters(:one).line.to_i,
      :code => filters(:one).code
      })

    filtered_finding.filter!
    assert_equal 3, filtered_finding.status, "status is not filtered(3)"
    assert_equal filters(:one).inspect, filtered_finding.filter.inspect, "not filtered_by correctly"
  end

  test "only valid with service, burn, and fingerprint set" do
    finding = Finding.new
    refute finding.valid?, "Valid without service or fingerprint"
    finding.service = services(:one)
    refute finding.valid?, "Valid without fingerprint or burn"
    finding.fingerprint = 'abcdefg1234567890'
    refute finding.valid?, "Valid without burn"
    finding.burn = burns(:one)
    assert finding.valid?, "Ivalid with all of service,burn,fingerprint"
  end

  test "only allows a unique combination of service and fingerprint" do
    finding = Finding.new({:service => services(:one), :fingerprint => 'abcdefg123456789'})
    refute finding.valid?, "Duplicate service/fingerprint combo valid"
  end

  test "searchable named scopes work as expected" do
    assert_equal Finding.all.sort.inspect, \
      Finding.id(nil) \
        .burn_id(nil) \
        .description(nil) \
        .service_id(nil) \
        .service_name(nil) \
        .severity(nil) \
        .fingerprint(nil) \
        .status(nil) \
        .sort.inspect, "all named scopes nil is not Finding.all"
    assert_equal Finding.all.inspect, Finding.id("#{findings(:one).id},#{findings(:two).id}").inspect, "finding multiselect is not correct for multiple values"
    assert_equal findings(:one).inspect, Finding.id(findings(:one).id).first.inspect, "finding multiselect not correct for single value"
    assert_equal findings(:one).inspect, Finding.service_name('test_service').first.inspect, "finding by service_name invalid"
  end
end
