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
require 'pipeline/finding'

class BurnTest < ActiveSupport::TestCase

  def setup_basic
    CodeburnerUtil.stubs(:get_service_info).returns({ 'repository' => { 'url' => 'http://fake.server/a/path', 'language' => 'Ruby'}})
    CodeburnerUtil.stubs(:tally_code).returns(1,1)
    CodeburnerUtil.stubs(:prep_node_project).returns(true)

    @github = mock('github')
    @tracker = mock('tracker')
  end

  def setup_ignite
    mock_findings = []

    Finding.all.each do |finding|
      finding_mock = mock('finding')
      finding_mock.stubs(:description).returns(finding.description)
      finding_mock.stubs(:severity).returns(finding.severity)
      finding_mock.stubs(:fingerprint).returns(finding.fingerprint)
      finding_mock.stubs(:detail).returns(finding.detail)
      finding_mock.stubs(:source).returns({:scanner => finding.scanner, :file => finding.file, :line => finding.line, :code => finding.code})
      mock_findings << finding_mock
    end

    @github.expects(:inside_github_archive).yields('test_dir').once
    GithubExplorer.expects(:new).returns(@github).once

    @tracker.expects(:findings).returns(mock_findings).once
    Pipeline.expects(:run).returns(@tracker).once
  end

  test "only valid with service and revision set" do
    burn = Burn.new
    refute burn.valid?, "Valid without service or revision"
    burn.service = services(:one)
    refute burn.valid?, "Valid without revision"
    burn.revision = '123456789'
    assert burn.valid?, 'Failed to save with service and revision set'
  end

  test "only valid with unique service and revision combo" do
    burn = Burn.new({:service => burns(:one).service, :revision => burns(:one).revision})
    refute burn.valid?, "Valid with duplicate service and revision combo"
  end

  # test "ignites properly" do
  #   setup_basic
  #   setup_ignite
  #   File.expects(:exist?).returns(true).once
  #   CodeburnerUtil.expects(:prep_node_project).returns(true).once
  #
  #   burns(:one).ignite
  #   assert_equal 'done', burns(:one).status, "Status is not done"
  # end

  test "updates code_lang and repo_url on nil" do
    setup_basic
    code_langs = { :lang1 => 100, :lang2 => 10 }
    CodeburnerUtil.expects(:get_code_lang).returns(code_langs).once
    burn = Burn.create({:service_id => services(:one).id, :revision => 'abcdefg12345'})
    assert_equal "lang1, lang2", burn.code_lang, "code_lang is not 'lang1, lang2'"
  end

  test "searchable named scopes work properly" do
    assert_equal Burn.all.sort.inspect, \
      Burn.id(nil) \
        .service_id(nil) \
        .service_name(nil) \
        .service_short_name(nil) \
        .revision(nil) \
        .code_lang(nil) \
        .repo_url(nil) \
        .status(nil) \
        .sort.inspect, "all named scopes nil is not Burn.all"
    assert_equal burns(:one, :two).sort.inspect, Burn.id("#{burns(:one).id},#{burns(:two).id}").sort.inspect, "multiselect is not #{burns(:one, :two).inspect}"
    assert_equal burns(:one).inspect, Burn.id(burns(:one).id).first.inspect, "single_select is not #{burns(:one).inspect}"
    assert_equal burns(:one).inspect, Burn.service_name('test_service').first.inspect, "service_name select is not #{burns(:one).inspect}"
  end

  test "to_json produces correct results" do
    test_json = File.read(File.join(Rails.root, 'test','fixtures','burn.json'))
    assert_equal JSON.parse(test_json)['service_name'], JSON.parse(burns(:one).to_json)['service_name'], "burns(:one).to_json doesn't equal test_json"
  end

  test "fails on unsupported code_lang" do
    burns(:four).ignite
    assert_equal 'failed', burns(:four).status, "Status is not done"
  end

  # test "fails on DownloadError" do
  #   setup_basic
  #   @github.stubs(:inside_github_archive).raises(DownloadError, 'Error downloading github archive')
  #   GithubExplorer.expects(:new).returns(@github).once
  #   burns(:two).ignite
  #   assert_equal 'failed', burns(:two).status, "ignite didn't fail on DownloadError"
  # end

end
