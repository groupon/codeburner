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

class CodeburnerUtilTest < ActiveSupport::TestCase
  def service_json
    @service_json ||= File.read('test/fixtures/service.json')
  end

  test "converts severity to text" do
    assert_equal "High", CodeburnerUtil.severity_to_text(3)
  end

  test "goes inside_github_archive" do
    tempfile = Tempfile.new('testfile')
    $github.expects(:archive_link).returns(tempfile)

    begin
      CodeburnerUtil.inside_github_archive('http://some_url/', 'abcdefg') do |dir|
        true
      end
    ensure
      File.unlink tempfile
    end
  end

  test "escalates StandardError on failure" do
    FileUtils.expects(:remove_entry_secure).returns(true)
    Dir.expects(:mktmpdir).raises(StandardError)

    assert_raises StandardError do
      CodeburnerUtil.inside_github_archive('http://some_url', 'abcdefg'){|a| true}
    end
  end

  test "gets service info" do
    result = mock('service_info_result')
    result.expects(:body).returns(services(:one).attributes.to_json.to_s)
    RestClient.expects(:get).returns(result)

    assert_equal services(:one).attributes, CodeburnerUtil.get_service_info('test_service'), "service info differs"
  end

  # TODO: add a real test here w/ simulated Sawyer::Resource for the octokit return
  test "gets code lang" do
    expected = {
      "Ruby" => 100,
    }
    $github.expects(:languages).returns({"Ruby" => 100})

    assert_equal expected, CodeburnerUtil.get_code_lang('test/test'), "this test isn't ideal"
  end

  test "tallies code" do
    filelist = {
      'Ruby' => ['Gemfile','Gemfile.lock','*.rb','*.haml','*.erb'],
      'JavaScript' => ['package.json','*.js'],
      'CoffeeScript' => ['package.json'],
      'Java' => ['*.java'],
      'Python' => ['*.py'],
      'Other' => []
    }
    filelist.each do |key, files|
      files.each do |file|
        exclude = ''
        exclude = '-not -path some_dir/node_modules/*' if file == '*.js'
        CodeburnerUtil.expects(:`).with("find some_dir/ -name #{file} #{exclude}| wc -l").returns("      10    \n").once
        CodeburnerUtil.expects(:`).with("find some_dir/ -name #{file} #{exclude}| xargs wc -l").returns("    5000    \n").once
      end
      assert_equal CodeburnerUtil.tally_code('some_dir', key.split(',')), [ 10*files.count, 5000*files.count ], "num_files and num_lines tallies are incorrect"
    end
  end

  test "creates new system_stat on first run" do
    SystemStat.expects(:first).returns(nil)
    CodeburnerUtil.expects(:get_history_range).returns(true)

    assert_difference('SystemStat.count') do
      CodeburnerUtil.update_system_stats
    end
  end

  test "gets service history range" do
    service_id = services(:one).id
    mock_stat = mock('mock_stat')
    mock_stat.expects(:versions).returns(ServiceStat.all)
    mock_service = mock('mock_service')
    mock_service.expects(:service_stat).returns(mock_stat)
    Service.expects(:find).returns(mock_service)
    CodeburnerUtil.get_history_range service_id
  end

  test "returns correct history resolution" do
    assert_equal 4.hour, CodeburnerUtil.history_resolution(1.day.ago, Time.now)
    assert_equal 12.hours, CodeburnerUtil.history_resolution(7.days.ago, Time.now)
    assert_equal 1.day, CodeburnerUtil.history_resolution(21.days.ago, Time.now)
    assert_equal 3.days, CodeburnerUtil.history_resolution(1.month.ago, Time.now)
    assert_equal 5.days, CodeburnerUtil.history_resolution(3.months.ago, Time.now)
    assert_equal 1.week, CodeburnerUtil.history_resolution(9.months.ago, Time.now)
  end

  test "gets system history" do
    mock_stat = mock('mock_stat')
    mock_stat.expects(:versions).returns(SystemStat.all)
    mock_stat.expects(:version_at).returns(SystemStat.first).twice
    SystemStat.expects(:first).returns(mock_stat)

    assert_equal 1, CodeburnerUtil.get_history[:services][0][1]
  end

  test "gets service history" do
    mock_stat = mock('mock_stat')
    mock_stat.expects(:versions).returns(ServiceStat.all)
    mock_stat.expects(:version_at).returns(ServiceStat.first)
    mock_where = mock('mock_where')
    mock_where.expects(:first).returns(mock_stat)
    ServiceStat.expects(:where).returns(mock_where)

    assert_equal 1, CodeburnerUtil.get_history(Time.now.to_s,Time.now.to_s,1.hour,nil,services(:one).id)[:burns][0][1]
  end

  test "gets burn history" do
    assert_equal Burn.count, CodeburnerUtil.get_burn_history[0][1]
    assert_equal Burn.count, CodeburnerUtil.get_burn_history(Time.now.to_s, Time.now.to_s)[0][1]
  end
end
