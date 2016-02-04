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

# class ServiceControllerTest < ActionController::TestCase

#   def service_ids
#     ids = []
#     services.each { |service| ids << service.id }
#     return ids
#   end

#   def all_services
#     results = {'count' => Service.count }
#     results['results'] = []
#     Service.all.reverse_order.each do |service|
#       results['results'] << service.as_json
#     end
#     return results.as_json
#   end

#   test "index lists all services" do
#     get :index

#     assert_response :success
#     assert_equal all_services, JSON.parse(@response.body), "all services not listed on /index"
#   end

#   test "shows a single service" do
#     get(:show, {:id => services(:one).id})

#     assert_response :success
#     assert_equal services(:one).as_json, JSON.parse(@response.body), "Filter isn't shown correctly"
#   end

#   test "throws a 404 on showing unknown service" do
#     get(:show, {:id => ([1...1000] - service_ids).sample})

#     assert_response :missing, "matching service found, response not 404"
#   end
# end
