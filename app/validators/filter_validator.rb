class FilterValidator < ActiveModel::Validator
  def validate record
    hit = Filter.service_id(record.service_id) \
      .severity(record.severity) \
      .fingerprint(record.fingerprint) \
      .scanner(record.scanner) \
      .description(record.description) \
      .detail(record.detail) \
      .file(record.file) \
      .line(record.line.to_s) \
      .code(record.code)

    if hit.count > 0
      record.errors[:base] << "Duplicate filter not allowed"
    end
  end
end
