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
# require 'test_helper'

# class FindingControllerTest < ActionController::TestCase

#   def finding_ids
#     ids = []
#     findings.each { |finding| ids << finding.id }
#     return ids
#   end

#   def all_findings
#     results = {'count' => Finding.count }
#     results['results'] = []
#     Finding.all.each do |finding|
#       results['results'] << finding.as_json
#     end
#     return results.as_json
#   end

#   test "index lists all findings" do
#     get :index

#     assert_response :success
#     assert_equal all_findings, JSON.parse(@response.body), "index doesn't list all findings"
#   end

#   test "sorts by pretty name and orders" do
#     get(:index, {:sort_by => 'service_name', :order => 'asc'})

#     assert_response :success
#     assert_equal findings(:one).as_json, JSON.parse(@response.body)['results'][0], "wrong finding is first"
#   end

#   test "searches by filtered_by" do
#     get(:index, {:filtered_by => filters(:one).id})

#     assert_response :success
#     assert_equal findings(:one).as_json, JSON.parse(@response.body)['results'][0], "not searching by filtered_by"
#   end

#   test "shows a single finding" do
#     get(:show, {:id => findings(:one).id})

#     assert_response :success
#     assert_equal findings(:one).as_json, JSON.parse(@response.body), "finding isn't shown correctly"
#   end

#   test "throws a 404 on showing unknown finding" do
#     get(:show, {:id => ([1...1000] - finding_ids).sample})

#     assert_response :missing, "matching finding found, response not 404"
#   end

#   test "updates finding status" do
#     put(:update, {:id => findings(:one).id, :status => 3})

#     assert_response :success
#     assert_equal 3, Finding.find(findings(:one).id).status, "finding status didn't change"
#   end

#   test "publishes successfully" do
#     mock_finding = mock('finding')
#     mock_finding.stubs(:publish).returns({'key': 'TEST-100'}.as_json)
#     mock_finding.stubs(:id).returns(findings(:one).id)
#     Finding.expects(:find).returns(mock_finding)

#     put(:publish, {:id => findings(:one).id, :project => 'TEST'})

#     assert_response :success
#   end

#   test "errors on failed publishing" do
#     mock_finding = mock('finding')
#     mock_finding.stubs(:publish).returns(nil)
#     mock_finding.stubs(:id).returns(findings(:one).id)
#     Finding.expects(:find).returns(mock_finding)

#     put(:publish, {:id => findings(:one).id, :project => 'BAD PROJECT'})

#     assert_response :error
#   end
# end
