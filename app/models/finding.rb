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
class Finding < ActiveRecord::Base
  validates :service_id, presence: true
  validates :fingerprint, presence: true

  before_create :filter!

  after_save do
    CodeburnerUtil.update_service_stats(self.service.id)
    CodeburnerUtil.update_system_stats
  end

  attr_default  :status, 0

  has_and_belongs_to_many    :burns
  belongs_to    :service
  belongs_to    :branch
  belongs_to    :filter

  scope :id,                  -> (finding_id)   { scope_multiselect('findings.id', finding_id) }
  scope :burn_id,             -> (burn_id)      { joins("INNER JOIN burns_findings ON findings.id = burns_findings.finding_id").where("burns_findings.burn_id LIKE ? OR burns_findings.burn_id IS NULL", burn_id ||= "%") }
  scope :description,         -> (description)  { where("findings.description LIKE ? OR findings.description IS NULL", description ||= "%") }
  scope :detail,              -> (detail)       { where("findings.detail LIKE ? OR findings.detail IS NULL", detail ||= "%" ) }
  scope :service_id,          -> (service_id)   { scope_multiselect('findings.service_id', service_id) }
  scope :branch_id,           -> (branch_id)    { scope_multiselect('findings.branch_id', branch_id) }
  scope :branch_name,         -> (branch_name)  { joins(:branch).where("branches.name LIKE ?", branch_name ||= "%") }
  scope :service_name,        -> (service_name) { joins(:service).scope_service_name(service_name) }
  scope :severity,            -> (severity)     { where("findings.severity LIKE ? OR findings.severity IS NULL", severity ||= "%") }
  scope :fingerprint,         -> (fingerprint)  { where("findings.fingerprint LIKE ?", fingerprint ||= "%") }
  scope :scanner,             -> (scanner)      { where("findings.scanner LIKE ? OR findings.scanner IS NULL", scanner ||= "%") }
  scope :file,                -> (file)         { where("findings.file LIKE ? OR findings.file IS NULL", file ||= "%") }
  scope :line,                -> (line)         { where("findings.line LIKE ? OR findings.line IS NULL", line ||= "%") }
  scope :code,                -> (code)         { where("findings.code LIKE ? OR findings.code IS NULL", code ||= "%") }
  scope :status,              -> (status)       { scope_multiselect('findings.status', status) }
  scope :filtered_by,         -> (filter_id)    { joins(:filter).where("filters.id = ?", filter_id)}
  scope :service_portal,      -> (select)       { joins(:burn).where("burns.service_portal = ?", select) }
  scope :only_current,        -> (select)       { scope_current(select) }
  scope :latest,              ->                {  }
  scope :branch,              -> (branch)       { where("findings.branch_id LIKE ?", branch ||= "%") }

  def filter!
    hit = self.filtered_by?

    if hit.count > 0
      self.status = 3
      self.filter = hit.first
    end
  end

  def filtered_by?
    Filter.service_id(self.service_id) \
      .severity(self.severity) \
      .fingerprint(self.fingerprint) \
      .scanner(self.scanner) \
      .description(self.description) \
      .detail(self.detail) \
      .file(self.file) \
      .line(self.line.to_s) \
      .code(self.code)
  end

  def self.scope_current only_current
    if only_current
      where("findings.current = ?", true)
    end
  end

  def self.scope_multiselect attribute, value
    case value
    when nil
      where("#{attribute} LIKE '%'")
    when /,/
      hash = {}
      hash[attribute] = value.split(',')
      where(hash)
    else
      where("#{attribute} LIKE ?", value)
    end
  end

  def self.scope_service_name name
    if name.nil?
      Finding.where("services.pretty_name LIKE '%' OR services.short_name LIKE '%'")
    else
      name_query = "#{name.downcase}"
      Finding.where("lower(services.pretty_name) LIKE ? OR lower(services.short_name) LIKE ?", name_query, name_query)
    end
  end

  def self.status_code
    {
      :open => 0,
      :hidden => 1,
      :published => 2,
      :filtered => 3
    }
  end

end
