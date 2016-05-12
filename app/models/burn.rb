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
class Burn < ActiveRecord::Base
  validates :revision, presence: true
  validates :service_id, presence: true
  attr_default :status, 'created'
  belongs_to :service
  belongs_to :branch
  has_and_belongs_to_many :findings
  belongs_to :user

  after_save :update_caches

  scope :id,                  -> (burn_id)      { scope_multiselect('burns.id', burn_id) }
  scope :service_id,          -> (service_id)   { scope_multiselect('burns.service_id', service_id) }
  scope :service_name,        -> (service_name) { joins(:service).scope_service_name(service_name) }
  scope :service_short_name,  -> (short_name)   { joins(:service).where("services.short_name LIKE ?", short_name ||= '%') }
  scope :revision,            -> (revision)     { where("revision LIKE ?", revision ||= "%") }
  scope :code_lang,           -> (code_lang)    { where("code_lang LIKE ? OR code_lang IS NULL", code_lang ||= "%") }
  scope :repo_url,            -> (repo_url)     { where("repo_url LIKE ? OR repo_url IS NULL", repo_url ||= "%") }
  scope :status,              -> (status)       { where("status LIKE ?", status ||= "%") }
  scope :service_portal,      -> (select)       { where("burns.service_portal = ?", select) }
  scope :branch,              -> (branch)       { where("burns.branch = ?", branch ||= "%") }
  scope :pull_request,        -> (pull_request) { where("burns.pull_request = ?", pull_request ||= "%") }

  def update_caches
    Rails.cache.write('burn_list', CodeburnerUtil.get_burn_list)
    CodeburnerUtil.update_service_stats(self.service_id)
    CodeburnerUtil.update_system_stats
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
      Burn.where("services.pretty_name LIKE '%' OR services.short_name LIKE '%'")
    else
      name_query = "#{name.downcase}"
      Burn.where("lower(services.pretty_name) LIKE ? OR lower(services.short_name) LIKE ?", name_query, name_query)
    end
  end

  def to_json
    {
      :id => self.id,
      :service_name => self.service.pretty_name,
      :revision => self.revision,
      :code_lang => self[:code_lang],
      :repo_url => self[:repo_url],
      :status => self.status
    }.to_json
  end

  def repo_url
    return self[:repo_url] unless self[:repo_url].nil?

    self.update(repo_url: CodeburnerUtil.get_service_info(self.service.short_name)['repository']['url'])

    return self[:repo_url]
  end

  def code_lang
    return self[:code_lang] unless self[:code_lang].nil?

    self.update(code_lang: CodeburnerUtil.get_code_lang(self.repo_url).keys.join(', '))

    return self[:code_lang]
  end

  def ignite
    github = CodeburnerUtil.user_github(self.user)

    if self.pull_request
      repo_name = self.pull_request
    else
      repo_name = self.service.short_name
    end

    github.create_status repo_name, self.revision, 'pending', :context => 'Codeburner', :description => 'Static security analysis', :target_url => "#{Setting.email['link_host']}/\#burns" if self.report_status

    supported_langs = Setting.pipeline['tasks_for'].keys

    # this line actually triggers a service-portal lookup for the display name: .pretty_name(true)
    Rails.logger.info "IGNITION: #{self.service.pretty_name(true)} #{self.revision}"

    self.update(status: 'burning', status_reason: "started burning on #{Time.now}")

    languages = self.code_lang.split(', ')
    supported = false
    languages.each do |lang|
      if supported_langs.include? lang
        supported = true
      end
    end

    unless supported
      self.update(status: 'failed', status_reason: "#{self.code_lang} not supported")
      send_failure_notifications
      return
    end

    CodeburnerUtil.inside_github_archive(self.repo_url, self.revision) do |dir|
      pipeline_options = {
        :appname => self.service.short_name,
        :revision => self.revision,
        :target => "#{dir}/",
        :quiet => true,
        :npm_registry => Setting.pipeline['npm_registry'],
        :run_tasks => [],
        :pmd_path => Setting.pipeline['pmd_path'],
        :findsecbugs_path => Setting.pipeline['findsecbugs_path'],
        :checkmarx_server => Setting.pipeline['checkmarx_server'],
        :checkmarx_user => Setting.pipeline['checkmarx_user'],
        :checkmarx_password => Setting.pipeline['checkmarx_password'],
        :checkmarx_log => Setting.pipeline['checkmarx_log']
      }
      findings = []

      languages.each do |lang|
        pipeline_options[:run_tasks] << Setting.pipeline['tasks_for'][lang].split(",") unless Setting.pipeline['tasks_for'][lang].nil?
      end

      pipeline_options[:run_tasks] = pipeline_options[:run_tasks].flatten.uniq.compact

      Rails.logger.info "RUNNING TASKS: #{pipeline_options[:run_tasks]}"

      if pipeline_options[:run_tasks].count > 0
        # run separately and first for checkmarx to make sure it doesn't scan all our downloaded node deps later
        pipeline_options[:run_tasks] << 'Checkmarx' if Rails.env == 'test'
        if pipeline_options[:run_tasks].map{|t| t.downcase}.include?('checkmarx')
          checkmarx_options = pipeline_options
          checkmarx_options[:run_tasks] = 'Checkmarx'
          tracker = Pipeline.run(checkmarx_options)
          findings << tracker.findings
        end
        tracker = Pipeline.run(pipeline_options)
        findings << tracker.findings
      end

      self.update(status: 'done', status_reason: "completed on #{Time.now}")

      previous_stats = CodeburnerUtil.get_service_stats(self.service_id)

      if self.revision == github.commits(self.service.short_name, self.branch).first.sha
        Finding.service_id(self.service_id).update_all(:current => false)
        current = true
      else
        current = false
      end

      findings.flatten.each do |result|
        Finding.create({
          :current => current,
          :service => self.service,
          :burn => self,
          :description => result.description,
          :severity => result.severity,
          :fingerprint => result.fingerprint,
          :detail => result.detail,
          :scanner => result.source[:scanner],
          :file => result.source[:file],
          :line => result.source[:line],
          :code => result.source[:code]
          })
      end
      files,lines = CodeburnerUtil.tally_code(dir, languages)
      self.update(num_files: files, num_lines: lines)

      if self.report_status
        if self.findings.status(0).count == 0
          github.create_status repo_name, self.revision, 'success', :context => 'Codeburner', :description => 'Static security analysis', :target_url => "#{Setting.email['link_host']}/\#findings?service_id=#{self.service_id}&burn_id=#{self.id}&branch=#{self.branch}"
        else
          github.create_status repo_name, self.revision, 'failure', :context => 'Codeburner', :description => 'Static security analysis', :target_url => "#{Setting.email['link_host']}/\#findings?service_id=#{self.service_id}&burn_id=#{self.id}&branch=#{self.branch}"
        end
      end

      send_notifications(previous_stats)
    end
  rescue StandardError => e
    self.update(status: 'failed', status_reason: "error downloading github archive on #{Time.now}")
    Rails.logger.info e.message
    Rails.logger.info e.backtrace
    send_failure_notifications
  end

  def send_notifications previous_stats
    Notification.where(:burn => [self.id.to_s, 'all']).each do |notification|
      notification.notify(self.id, previous_stats)
    end
  end

  def send_failure_notifications
    CodeburnerUtil.user_github(self.user).create_status self.service.short_name, self.revision, 'error', :context => 'Codeburner', :description => 'Static security analysis', :target_url => "#{Setting.email['link_host']}/#burns" if self.report_status

    Notification.where(:burn => [self.id.to_s, 'all']).each do |notification|
      notification.fail(self.id)
    end
  end

end
