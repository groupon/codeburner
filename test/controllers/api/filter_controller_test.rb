# require 'test_helper'

# class FilterControllerTest < ActionController::TestCase

#   def filter_ids
#     filter_ids = []
#     filters.each { |filter| filter_ids << filter.id }
#     return filter_ids
#   end

#   def all_results
#     results = {'count' => Filter.count}
#     results['results'] = [filters(:two).as_json, filters(:one).as_json]
#     results['results'][0]['finding_count'] = 0
#     results['results'][1]['finding_count'] = 1
#     return results
#   end

#   test "index lists all filters" do
#     get :index
#     assert_response :success
#     assert_equal all_results, JSON.parse(@response.body), "Response isn't #{all_results.as_json.inspect}"
#   end

#   test "sorts and orders properly" do
#     results = all_results
#     results['results'] = results['results'].reverse

#     get(:index, {:sort_by => 'finding_count', :order => 'desc', })

#     assert_response :success
#     assert_equal results, JSON.parse(@response.body), "Response isn't sorted properly"
#   end

#   test "shows a single filter" do
#     get(:show, {:id => filters(:one).id})

#     assert_response :success
#     assert_equal filters(:one).as_json, JSON.parse(@response.body), "Filter isn't shown correctly"
#   end

#   test "throws a 404 on showing unknown filter" do
#     get(:show, {:id => ([1...1000] - filter_ids).sample})

#     assert_response :missing, "matching filter found, response not 404"
#   end

#   test "creates a new filter" do
#     assert_difference('Filter.count') do
#        post(:create, {:service_id => services(:one).id})
#        assert_response :success
#     end
#   end

#   test "throws error on creating invalid filter" do
#     assert_no_difference('Filter.count') do
#       post(:create, filters(:one).as_json)
#       assert_response(409)
#     end
#   end

#   test "destroys a filter" do
#     filter = Filter.create({:id => ([1...1000] - filter_ids).sample})
#     assert_difference('Filter.count', -1) do
#       delete(:destroy, {:id => filter.id})
#       assert_response :success
#     end
#   end

#   test "throws a 404 on destroying an unknown filter" do
#     delete(:destroy, {:id => ([1...1000] - filter_ids).sample})
#     assert_response :missing, "response not 404"
#   end
# end
