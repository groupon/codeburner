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
