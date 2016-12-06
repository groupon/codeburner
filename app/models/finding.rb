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
  include Filterable

  validates :repo_id, presence: true
  validates :fingerprint, presence: true

  before_create :filter!

  after_save do
    CodeburnerUtil.update_repo_stats(self.repo.id)
    CodeburnerUtil.update_system_stats
  end

  attr_default  :status, 0

  has_and_belongs_to_many    :burns
  belongs_to    :repo
  belongs_to    :branch
  belongs_to    :filter

  scope :id,                  -> (finding_id)   { scope_multiselect('findings.id', finding_id) }
  scope :burn_id,             -> (burn_id)      { joins('INNER JOIN burns_findings ON findings.id = burns_findings.finding_id').where('burns_findings.burn_id = ?', burn_id) }
  scope :description,         -> (description)  { where description: description }
  scope :detail,              -> (detail)       { where detail: detail }
  scope :repo_id,             -> (repo_id)      { scope_multiselect('findings.repo_id', repo_id) }
  scope :branch_id,           -> (branch_id)    { scope_multiselect('findings.branch_id', branch_id) }
  scope :branch,              -> (branch_name)  { joins(:branch).where('branches.name = ?', branch_name) }
  scope :repo_name,           -> (repo_name)    { joins(:repo).where('lower(repos.full_name) = ? OR lower(repos.name) = ?', repo_name.downcase, repo_name.downcase) }
  scope :severity,            -> (severity)     { where severity: severity }
  scope :fingerprint,         -> (fingerprint)  { where fingerprint: fingerprint }
  scope :scanner,             -> (scanner)      { where scanner: scanner }
  scope :file,                -> (file)         { where file: file }
  scope :line,                -> (line)         { where line: line }
  scope :code,                -> (code)         { where code: code }
  scope :status,              -> (status)       { scope_multiselect('findings.status', status.to_s) }
  scope :filtered_by,         -> (filter_id)    { joins(:filter).where('filters.id = ?', filter_id)}
  scope :repo_portal,         -> (repo_portal)  { joins(:burn).where('burns.repo_portal = ?', repo_portal) }
  scope :only_current,        ->                { where current: true }

  def filter!
    hit = self.filtered_by?

    if hit.count > 0
      self.status = 3
      self.filter = hit.first
    end
  end

  def filtered_by?
    Filter.repo_id(self.repo_id) \
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
      where('findings.current = ?', true)
    end
  end

  def self.scope_repo_name name
    if name.nil?
      Finding.where("repos.full_name LIKE '%' OR repos.name LIKE '%'")
    else
      name_query = "#{name.downcase}"
      Finding.where("lower(repos.full_name) LIKE ? OR lower(repos.name) LIKE ?", name_query, name_query)
    end
  end

  def to_json
    self.attributes.merge({:branch => self.branch, :repo => self.repo, :filter => self.filter}).as_json
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
