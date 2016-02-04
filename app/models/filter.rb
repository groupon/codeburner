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
class Filter < ActiveRecord::Base
  include ActiveModel::Validations

  belongs_to :service
  has_many :findings

  validates_with FilterValidator

  scope :service_id,  -> (service_id)   { where("filters.service_id = ? OR filters.service_id IS NULL", service_id ||= '') }
  scope :severity,    -> (severity)     { where("filters.severity = ? OR filters.severity IS NULL", severity ||= '') }
  scope :fingerprint, -> (fingerprint)  { where("filters.fingerprint = ? OR filters.fingerprint IS NULL", fingerprint ||= '') }
  scope :scanner,     -> (scanner)      { where("filters.scanner = ? OR filters.scanner IS NULL", scanner ||= '') }
  scope :description, -> (description)  { where("filters.description = ? OR filters.description IS NULL", description ||= '') }
  scope :detail,      -> (detail)       { where("filters.detail = ? OR filters.detail IS NULL", detail ||= '') }
  scope :file,        -> (file)         { where("filters.file = ? OR filters.file IS NULL", file ||= '') }
  scope :line,        -> (line)         { where("filters.line = ? OR filters.line IS NULL", line ||= '') }
  scope :code,        -> (code)         { where("filters.code = ? OR filters.code IS NULL", code ||= '') }

  def filter_existing!
    if self.line.nil?
      line = nil
    else
      line = self.line.to_i
    end

    Rails.logger.info 'FILTERING EXISTING: #{self.inspect}'

    findings = Finding.service_id(self.service_id) \
      .severity(self.severity) \
      .fingerprint(self.fingerprint) \
      .scanner(self.scanner) \
      .description(self.description) \
      .detail(self.detail) \
      .file(self.file) \
      .line(line) \
      .code(self.code)

    findings.where('status NOT IN (?)', [1,2]).update_all(status: 3, filter_id: self[:id])

    service_ids = []
    findings.each {|finding| service_ids << finding.service_id}

    service_ids.uniq.each do |service_id|
      CodeburnerUtil.update_service_stats service_id
    end

    CodeburnerUtil.update_system_stats
  end

end
