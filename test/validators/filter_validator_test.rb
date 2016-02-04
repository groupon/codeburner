require 'test_helper'

class FilterValidatorTest < ActiveSupport::TestCase
  test "drops duplicate filters" do
    filter = Filter.new({
      :service => filters(:one).service,
      :severity => filters(:one).severity,
      :fingerprint => filters(:one).fingerprint,
      :scanner => filters(:one).scanner,
      :description => filters(:one).description,
      :detail => filters(:one).detail,
      :file => filters(:one).file,
      :line => filters(:one).line,
      :code => filters(:one).code
      })
    refute filter.valid?, "duplicate filter should be invalid"
  end
end
