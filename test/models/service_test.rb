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

class ServiceTest < ActiveSupport::TestCase
  def repo
    @repo ||= Repo.new
  end

  test "only valid with name set" do
    refute repo.valid?, "Service saved without name"
    repo.name = 'test'
    assert repo.valid?, "Failed to save with short name"
  end

  test "duplicate name is invalid" do
    duplicate_repo = Repo.new({:name => repos(:one).name})
    refute duplicate_repo.valid?, "Service valid with duplicate name"
  end

  test "calls CodeburnerUtil.get_repo_info and returns valid full_name" do
    blank_repo = Repo.new
    blank_repo.name = 'one'
    blank_repo.repo_portal = true
    CodeburnerUtil.expects(:get_repo_info).returns({ 'title' => 'Test Service' }).once
    assert blank_repo.full_name(true) == 'Test Service', 'full_name is not Test Service'
  end

  test "searchable named scopes work as expected" do
    assert_equal Repo.all.sort.inspect, Repo.id(nil).name(nil).full_name(nil).has_findings.has_burns.sort.inspect, "chained scopes don't equal Repo.all"
    assert_equal repos(:one), Repo.full_name('Test Service').first, "Repo.full_name('Test Service') is not repos(:one)"
    assert_equal repos(:one), Repo.id(repos(:one).id).first, "single select repo doesn't work"
  end
end
