require 'test_helper'

class ServiceTest < ActiveSupport::TestCase
  def service
    @service ||= Service.new
  end

  test "only valid with short_name set" do
    refute service.valid?, "Service saved without short_name"
    service.short_name = 'test'
    assert service.valid?, "Failed to save with short name"
  end

  test "duplicate short_name is invalid" do
    duplicate_service = Service.new({:short_name => services(:one).short_name})
    refute duplicate_service.valid?, "Service valid with duplicate short_name"
  end

  test "calls CodeburnerUtil.get_service_info and returns valid pretty_name" do
    blank_service = Service.new
    blank_service.short_name = 'one'
    blank_service.service_portal = true
    CodeburnerUtil.expects(:get_service_info).returns({ 'title' => 'Test Service' }).once
    assert blank_service.pretty_name(true) == 'Test Service', 'pretty_name is not Test Service'
  end

  test "searchable named scopes work as expected" do
    assert_equal Service.all.sort.inspect, Service.id(nil).short_name(nil).pretty_name(nil).sort.inspect, "chained scopes don't equal Service.all"
    assert_equal services(:one), Service.pretty_name('Test Service').first, "Service.pretty_name('Test Service') is not services(:one)"
    assert_equal services(:one), Service.id(services(:one).id).first, "single select service doesn't work"
  end
end
