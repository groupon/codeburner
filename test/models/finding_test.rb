require 'test_helper'

class FindingTest < ActiveSupport::TestCase

  test "is filtered by filters" do
    filtered_finding = Finding.create({
      :service => filters(:one).service,
      :severity => filters(:one).severity,
      :fingerprint => filters(:one).fingerprint,
      :scanner => filters(:one).scanner,
      :description => filters(:one).description,
      :detail => filters(:one).detail,
      :file => filters(:one).file,
      :line => filters(:one).line.to_i,
      :code => filters(:one).code
      })

    filtered_finding.filter!
    assert_equal 3, filtered_finding.status, "status is not filtered(3)"
    assert_equal filters(:one).inspect, filtered_finding.filter.inspect, "not filtered_by correctly"
  end

  test "only valid with service, burn, and fingerprint set" do
    finding = Finding.new
    refute finding.valid?, "Valid without service or fingerprint"
    finding.service = services(:one)
    refute finding.valid?, "Valid without fingerprint or burn"
    finding.fingerprint = 'abcdefg1234567890'
    refute finding.valid?, "Valid without burn"
    finding.burn = burns(:one)
    assert finding.valid?, "Ivalid with all of service,burn,fingerprint"
  end

  test "only allows a unique combination of service and fingerprint" do
    finding = Finding.new({:service => services(:one), :fingerprint => 'abcdefg123456789'})
    refute finding.valid?, "Duplicate service/fingerprint combo valid"
  end

  test "searchable named scopes work as expected" do
    assert_equal Finding.all.sort.inspect, \
      Finding.id(nil) \
        .burn_id(nil) \
        .description(nil) \
        .service_id(nil) \
        .service_name(nil) \
        .severity(nil) \
        .fingerprint(nil) \
        .status(nil) \
        .sort.inspect, "all named scopes nil is not Finding.all"
    assert_equal Finding.all.inspect, Finding.id("#{findings(:one).id},#{findings(:two).id}").inspect, "finding multiselect is not correct for multiple values"
    assert_equal findings(:one).inspect, Finding.id(findings(:one).id).first.inspect, "finding multiselect not correct for single value"
    assert_equal findings(:one).inspect, Finding.service_name('test_service').first.inspect, "finding by service_name invalid"
  end

  test "publishes to jira successfully" do
    jira = mock('jira')
    mock_issue = mock('Issue')
    GrouponJira.expects(:new).returns(jira).twice

    jira.expects(:Issue).returns(mock_issue).twice
    mock_issue.expects(:build).returns(mock_issue).twice
    mock_issue.expects(:save).returns(true).once
    mock_issue.expects(:attrs).returns(true).once

    assert_equal true, findings(:one).publish, "finding result is incorrect"
    assert_equal 2, findings(:one).status, ":one status is not 2"

    mock_issue.expects(:save).returns(nil).once

    assert_equal nil, findings(:two).publish, "isn't returning empty hash on publish == nil"
  end
end
