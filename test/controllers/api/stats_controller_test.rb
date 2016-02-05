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

class Api::StatsControllerTest < ActionController::TestCase
  test "indexes correctly" do
    get(:index)
    assert_response :success
    assert_equal CodeburnerUtil.get_stats.as_json, JSON.parse(@response.body)
  end

  test "gets range" do
    CodeburnerUtil.expects(:get_history_range).returns({:start_date => 1.day.ago, :end_date => Time.now}).twice
    get(:range)
    assert_response :success
    assert_equal CodeburnerUtil.get_history_range.as_json, JSON.parse(@response.body)
  end

  test "gets resolution" do
    get(:resolution, {:start_date => 1.day.ago.to_s, :end_date => Time.now.to_s})
    assert_response :success
    assert_equal CodeburnerUtil.history_resolution(1.day.ago, Time.now).to_i, @response.body.to_i
  end

  test "gets history" do
    CodeburnerUtil.expects(:get_history).returns({:foo => 'bar'}.as_json).twice
    get(:history)
    assert_response :success
    assert_equal CodeburnerUtil.get_history.as_json, JSON.parse(@response.body)
  end

  test "gets burns" do
    get(:burns)
    assert_response :success
    assert_equal CodeburnerUtil.get_burn_history.as_json, JSON.parse(@response.body)
  end
end
