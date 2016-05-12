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
class Service < ActiveRecord::Base
  validates :short_name, presence: true
  validates :short_name, uniqueness: true
  has_many :burns
  has_many :findings
  has_many :branches
  has_one  :service_stat
  has_and_belongs_to_many :users, join_table: 'services_users'
  belongs_to :webhook_user, class_name: 'User'

  after_save :update_caches

  scope :id,            -> (service_id)   { scope_multiselect("services.id", service_id) }
  scope :short_name,    -> (short_name)   { where("short_name LIKE ?",  short_name ||= "%") }
  scope :pretty_name,   -> (pretty_name)  { scope_pretty_name(pretty_name) }
  scope :service_portal,-> (select)       { where("service_portal = ?", select) }
  scope :has_burns,     ->                { scope_has_burns }
  scope :has_findings,  ->                { scope_has_findings }

  def update_caches
    CodeburnerUtil.update_system_stats
    CodeburnerUtil.update_service_stats(self.id)
  end

  def pretty_name reset=false
    return self[:pretty_name] unless reset == true

    if self[:service_portal] == true
      name = CodeburnerUtil.get_service_info(self[:short_name])['title']
      self.update(pretty_name: name) unless name.nil?
    end

    return self[:pretty_name]
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

  def to_json
    {
    :id => self[:id],
    :short_name => self[:short_name],
    :pretty_name => self[:pretty_name],
    :repo_url => "#{Setting.github['link_host']}/#{self[:short_name]}",
    :html_url => self[:html_url],
    :languages => self[:languages]
    }.as_json
  end

  def self.scope_pretty_name name
    if name.nil?
      Service.where("pretty_name LIKE '%'")
    else
      Service.where("lower(pretty_name) LIKE ?", "#{name.downcase.gsub('*','%')}")
    end
  end

  def self.scope_has_burns
    id_string = Burn.uniq.pluck(:service_id).join(",")
    Service.id(id_string)
  end

  def self.scope_has_findings
    id_string = Finding.uniq.pluck(:service_id).join(",")
    Service.id(id_string)
  end
end
