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

# class BurnControllerTest < ActionController::TestCase

#   def burn_ids
#     burn_ids = []
#     burns.each { |burn| burn_ids << burn.id }
#     return burn_ids
#   end

#   def stats
#     {
#       :services => Service.count,
#       :burns => Burn.count,
#       :findings => Finding.count,
#       :files => Burn.sum(:num_files),
#       :lines => Burn.sum(:num_lines)
#     }.as_json
#   end

#   def all_burns
#     results = {'count' => Burn.count }
#     results['results'] = []
#     Burn.all.each do |burn|
#       results['results'] << burn.as_json
#     end
#     return results.as_json
#   end

#   test "index lists all burns" do
#     get :index

#     assert_response :success
#     assert_equal all_burns, JSON.parse(@response.body), "index doesn't list all burns"
#   end

#   test "uses cached response for front page burn list" do
#     burn_list = CodeburnerUtil.get_burn_list
#     good_results = {
#       :count => burn_list.count,
#       :results => burn_list
#     }.as_json

#     get(:index, {:page => 1, :per_page => 10, :sort_by => 'count', :order => 'desc'})
#     assert_response :success
#     assert_equal good_results, JSON.parse(@response.body), "front page query isn't returning cached burn list"
#   end

#   test "sorts by service_name" do
#     get(:index, {:sort_by => 'service_name', :order => 'asc'})
#     results = JSON.parse(@response.body)

#     assert_response :success
#     assert_equal burns(:one).id, results['results'][0]['id'], "first burn isn't #{burns(:one).inspect}"
#   end

#   test "shows a specific burn" do
#     get(:show, {:id => burns(:one).id})
#     assert_response :success
#     assert_equal burns(:one).as_json, JSON.parse(@response.body), "burns(:one) not returned"
#   end

#   test "throws a 404 on unknown burn" do
#     get(:show, {:id => ([1...1000] - burn_ids).sample})
#     assert_response :missing, "missing burn didn't result in 404"
#   end

#   test "creates a burn" do
#     assert_difference('Burn.count') do
#       post(:create, {:service_name => 'my_non_fixture_service', :revision => '0123456789'})
#       assert_response :success
#       assert_equal 'my_non_fixture_service', JSON.parse(@response.body)['service_name'], "service names don't match on create"
#     end
#   end

#   test "returns error on duplicate burn" do
#     assert_no_difference('Burn.count') do
#       post(:create, {:service_name => burns(:one).service.short_name, :revision => burns(:one).revision})
#       assert_response(409)
#     end
#   end

#   test "fails to create a non-service portal burn with blank repo_url" do
#     assert_no_difference('Burn.count') do
#       post(:create, {:service_name => 'my_non_fixture_service', :revision => '1234', :service_portal => false})
#       assert_response(400)
#     end
#   end

#   test "creates notifications when notify is set" do
#     assert_difference('Notification.count') do
#       post(:create, {:service_name => 'my_non_fixture_service', :revision => '1234', :notify => 'test@test.com'})
#       assert_response :success
#     end
#   end
# end
