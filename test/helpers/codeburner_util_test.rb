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

  # test "gets code languages" do
  #   languages = {
  #     "Ruby" => 100,
  #     "Java" => 50
  #   }
  #   github = mock('github')
  #   github.responds_like(GithubExplorer.new('','',true,3,nil))
  #   GithubExplorer.expects(:new).returns(github).twice
  #   github.expects(:get_languages).returns(languages.to_json).twice
  #
  #   assert_equal languages, CodeburnerUtil.get_code_lang('http://github.com/test/path'), "languages mismatch"
  #   assert_equal languages, CodeburnerUtil.get_code_lang('http://test.com/fake/path'), "silly extra test for completion"
  # end

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
end
