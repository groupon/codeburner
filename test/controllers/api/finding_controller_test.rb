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

class Api::FindingControllerTest < ActionController::TestCase

  def finding_ids
    ids = []
    findings.each { |finding| ids << finding.id }
    return ids
  end

  def all_findings
    results = {'count' => Finding.count }
    results['results'] = []
    Finding.all.each do |finding|
      results['results'] << finding.as_json
    end
    return results.as_json
  end

  test "index lists all findings" do
    get :index

    assert_response :success
    assert_equal all_findings, JSON.parse(@response.body), "index doesn't list all findings"
  end

  test "sorts by pretty name and orders" do
    get(:index, {:sort_by => 'service_name', :order => 'asc'})

    assert_response :success
    assert_equal findings(:one).as_json, JSON.parse(@response.body)['results'][0], "wrong finding is first"
  end

  test "searches by filtered_by" do
    get(:index, {:filtered_by => filters(:one).id})

    assert_response :success
    assert_equal findings(:one).as_json, JSON.parse(@response.body)['results'][0], "not searching by filtered_by"
  end

  test "shows a single finding" do
    get(:show, {:id => findings(:one).id})

    assert_response :success
    assert_equal findings(:one).as_json, JSON.parse(@response.body), "finding isn't shown correctly"
  end

  test "throws a 404 on showing unknown finding" do
    get(:show, {:id => ([1...1000] - finding_ids).sample})

    assert_response :missing, "matching finding not found, response not 404"
  end

  test "updates finding status" do
    put(:update, {:id => findings(:one).id, :status => 3})

    assert_response :success
    assert_equal 3, Finding.find(findings(:one).id).status, "finding status didn't change"
  end

  test "throws a 404 on updating unknown finding" do
    put(:update, {:id => ([1...1000] - finding_ids).sample})

    assert_response :missing, "update sent for unknown finding, response not 404"
  end

  test "fails publishing to jira with no project" do
    put(:publish, {:id => findings(:one).id, :method => 'jira'})
    assert_response 400
  end

  test "fails publishing with unsupported method" do
    put(:publish, {:id => findings(:one).id, :method => 'FOOBAR'})
    assert_response 400
  end

  test "throws a 404 publishing unknown finding" do
    put(:publish, {:id => ([1...1000] - finding_ids).sample, :method => 'github'})

    assert_response :missing, "publish sent for unknown finding, response not 404"
  end

  test "throws a 500 on publishing failure" do
    github_result = mock('github_result')
    github_result.expects(:number).returns(nil).once
    github_result.expects(:html_url).returns(nil).once
    @controller.expects(:publish_to_github).returns(github_result).once

    put(:publish, {:id => findings(:one).id, :method => 'github'})
    assert_response 500
  end

  test "publishes to github" do
    github_result = mock('github_result')
    github_result.expects(:number).returns('1').once
    github_result.expects(:html_url).returns('http://test.url').once
    CodeburnerUtil.expects(:strip_github_path).returns('TestTeam/TestProject').once

    # publish_to_github call
    CodeburnerUtil.expects(:severity_to_text).returns('High').once
    $github.expects(:create_issue).returns(github_result).once

    put(:publish, {:id => findings(:one).id, :method => 'github'})
    assert_response :success
    assert_equal 2, Finding.find(findings(:one).id).status, "finding status didn't change to published"
  end

  test "publishes to jira" do
    jira_result = {'key' => '1234'}

    #publish_to_jira call
    issue = mock('mock_issue')
    issue.expects(:build).returns(issue).once
    issue.expects(:save).returns(:true)
    issue.expects(:attrs).returns(jira_result)
    CodeburnerUtil.expects(:severity_to_text).returns('High').once
    $jira.expects(:Issue).returns(issue).once

    put(:publish, {:id => findings(:one).id, :method => 'jira', :project => 'TEST'})
    assert_response :success
    assert_equal 2, Finding.find(findings(:one).id).status, "finding status didn't change to published"
  end
end
