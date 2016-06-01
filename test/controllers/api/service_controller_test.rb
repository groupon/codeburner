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

class Api::ServiceControllerTest < ActionController::TestCase

  def repo_ids
    ids = []
    repos.each { |repo| ids << repo.id }
    return ids
  end

  def all_repos
    results = {'count' => Repo.count }
    results['results'] = []
    Repo.all.reverse_order.each do |repo|
      results['results'] << repo.as_json
    end
    return results.as_json
  end

  test "index lists all repos" do
    get :index

    assert_response :success
    assert_equal all_repos, JSON.parse(@response.body), "all repos not listed on /index"
  end

  test "shows a single repo" do
    get(:show, {:id => repos(:one).id})

    assert_response :success
    assert_equal repos(:one).as_json, JSON.parse(@response.body), "Filter isn't shown correctly"
  end

  test "throws a 404 on showing unknown repo" do
    get(:show, {:id => ([1...1000] - repo_ids).sample})

    assert_response :missing, "matching repo not found, response not 404"
  end

  test "shows stats" do
    get(:stats, {:id => repos(:one).id})
    assert_response :success
    assert_equal CodeburnerUtil.get_repo_stats(repos(:one).id).as_json, JSON.parse(@response.body), "stats don't match"
  end

  test "throws a 404 on stats for unknown repo" do
    get(:stats, {:id => ([1...1000] - repo_ids).sample})

    assert_response :missing, "matching repo not found, response not 404"
  end

  # TODO: figure out a "real" way to do these range tests
  test "gets history range" do
    CodeburnerUtil.expects(:get_history_range).returns({:start_date => 1.day.ago.to_s, :end_date => Time.now.to_s}.as_json).twice
    get(:history_range, {:id => repos(:one).id})
    assert_response :success
    assert_equal CodeburnerUtil.get_history_range(repos(:one).id).as_json, JSON.parse(@response.body), "range is incorrect"
  end

  test "gets history resolution" do
    start_date = 1.day.ago
    end_date = Time.now
    get(:history_resolution, {:id => repos(:one).id, :start_date => start_date.to_s, :end_date => end_date.to_s})
    assert_response :success
    assert_equal CodeburnerUtil.history_resolution(start_date, end_date).to_i, @response.body.to_i, "resolution is incorrect"
  end

  test "gets history" do
    CodeburnerUtil.expects(:get_history).returns({:burns => 1, :open_findings => 1}.as_json).twice
    get(:history, {:id => repos(:one).id})
    assert_response :success
    assert_equal CodeburnerUtil.get_history, JSON.parse(@response.body)
  end

  test "history fails on unknown repo" do
    get(:history, {:id => ([1...1000] - repo_ids).sample})

    assert_response :missing, "matching repo not found, 404 not thrown"
  end

  test "gets burn history" do
    get(:burns, {:id => repos(:one).id})

    assert_response :success
    assert_equal CodeburnerUtil.get_burn_history(nil, nil, repos(:one).id).as_json, JSON.parse(@response.body), "burn history not equal"
  end

  test "fails burn history on unknown repo" do
    get(:burns, {:id => ([1...1000] - repo_ids).sample})

    assert_response :missing
  end
end
