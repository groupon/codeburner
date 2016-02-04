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
