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
  validates :repo_id, presence: true
  attr_default :status, 'created'
  belongs_to :repo
  belongs_to :branch
  has_and_belongs_to_many :findings
  belongs_to :user

  after_save :update_caches
  after_commit :run_worker, on: :create

  scope :id,                  -> (burn_id)      { scope_multiselect('burns.id', burn_id) }
  scope :repo_id,          -> (repo_id)   { scope_multiselect('burns.repo_id', repo_id) }
  scope :repo_name,        -> (repo_name) { joins(:repo).scope_repo_name(repo_name) }
  scope :repo_name,  -> (name)   { joins(:repo).where("repos.name LIKE ?", name ||= '%') }
  scope :revision,            -> (revision)     { where("revision LIKE ?", revision ||= "%") }
  scope :code_lang,           -> (code_lang)    { where("code_lang LIKE ? OR code_lang IS NULL", code_lang ||= "%") }
  scope :repo_url,            -> (repo_url)     { where("repo_url LIKE ? OR repo_url IS NULL", repo_url ||= "%") }
  scope :status,              -> (status)       { where("status LIKE ?", status ||= "%") }
  scope :repo_portal,      -> (select)       { where("burns.repo_portal = ?", select) }
  scope :branch_name,         -> (branch)       { joins(:branch).where("branches.name LIKE ?", branch ||= "%") }
  scope :pull_request,        -> (pull_request) { where("burns.pull_request = ?", pull_request ||= "%") }

  def update_caches
    Rails.cache.write('burn_list', CodeburnerUtil.get_burn_list)
    CodeburnerUtil.update_repo_stats(self.repo_id)
    CodeburnerUtil.update_system_stats
  end

  def run_worker
    BurnWorker.perform_async(self.id)
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

  def self.scope_repo_name name
    if name.nil?
      Burn.where("repos.full_name LIKE '%' OR repos.name LIKE '%'")
    else
      name_query = "#{name.downcase}"
      Burn.where("lower(repos.full_name) LIKE ? OR lower(repos.name) LIKE ?", name_query, name_query)
    end
  end

  def to_json
    {
      :id => self.id,
      :repo => self.repo,
      :branch => self.branch,
      :revision => self.revision,
      :code_lang => self[:code_lang],
      :repo_url => self[:repo_url],
      :status => self.status,
      :pull_request => self.pull_request,
      :created_at => self.created_at
    }.as_json
  end

  def repo_url
    return self[:repo_url] unless self[:repo_url].nil?

    self.update(repo_url: CodeburnerUtil.get_repo_info(self.repo.name)['repository']['url'])

    return self[:repo_url]
  end

  def code_lang
    return self[:code_lang] unless self[:code_lang].nil?

    self.update(code_lang: CodeburnerUtil.get_code_lang(self.repo_url).keys.join(', '))

    return self[:code_lang]
  end

  def ignite
    begin
      github = CodeburnerUtil.user_github(self.user)
      logfile = File.open(Rails.root.join("log/burns/#{self.id}.log"), 'a')
      logfile.sync = true

      github.create_status self.repo.name, self.revision, 'pending', :context => 'Codeburner', :description => 'codeburner security analysis', :target_url => "#{Setting.email['link_host']}/\#burns?id=#{self.id}" if self.report_status

      supported_langs = Setting.pipeline['tasks_for'].keys

      # this line actually triggers a repo-portal lookup for the display name: .full_name(true)
      logfile.puts "[#{Time.now}] IGNITION: #{self.repo.full_name(true)} #{self.revision}"

      self.update(status: 'burning', status_reason: "started burning on #{Time.now}")

      languages = self.code_lang.split(', ')
      supported = false
      languages.each do |lang|
        if supported_langs.include? lang
          supported = true
        end
      end

      unless supported
        logfile.puts "[#{Time.now}] Burn #{self.id} failed, #{self.code_lang} not supported"
        $redis.publish "burn:#{self.id}:log", "[#{Time.now}] Burn #{self.id} failed, #{self.code_lang} not supported"
        $redis.publish "burn:#{self.id}:log", "END_PIPELINE_LOG"
        self.update(status: 'failed', status_reason: "#{self.code_lang} not supported")
        send_failure_notifications
        return
      end

      CodeburnerUtil.inside_github_archive(self.repo_url, self.revision) do |dir|
        pipeline_options = {
          :appname => self.repo.name,
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
          :checkmarx_log => Setting.pipeline['checkmarx_log'],
          :logfile => logfile
        }
        findings = []

        languages.each do |lang|
          pipeline_options[:run_tasks] << Setting.pipeline['tasks_for'][lang].split(",") unless Setting.pipeline['tasks_for'][lang].nil?
        end

        pipeline_options[:run_tasks] = pipeline_options[:run_tasks].flatten.uniq.compact

        logfile.puts "[#{Time.now}] RUNNING TASKS: #{pipeline_options[:run_tasks]}"

        if pipeline_options[:run_tasks].count > 0
          pipeline_thread = Thread.new do
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

          log_thread = Thread.new do
            File.open(Rails.root.join("log/burns/#{self.id}.log"), 'r') do |logfile_readonly|
              while pipeline_thread.status do
                while line = logfile_readonly.gets
                  $redis.append "burn:#{self.id}:log", line if line =~ /^/
                  $redis.publish "burn:#{self.id}:log", line if line =~ /^/
                end
                sleep 1
              end
            end
          end

          [ pipeline_thread, log_thread ].each {|t| t.join}
        end

        previous_stats = CodeburnerUtil.get_repo_stats(self.repo_id)

        if self.revision == github.commits(self.repo.name, self.branch.name).first.sha
          Finding.repo_id(self.repo_id).branch_id(self.branch_id).update_all(:current => false)
          current = true
        else
          current = false
        end

        findings.flatten.each do |result|
          previous = Finding.repo_id(self.repo_id).branch(self.branch).fingerprint(result.fingerprint).order("created_at").last

          if previous
            self.findings << previous unless self.findings.include?(previous)
            previous.burns << self unless previous.burns.include?(self)
            previous.update(:current => current)
            next
          else
            f = Finding.create({
              :repo => self.repo,
              :branch => self.branch,
              :current => current,
              :description => result.description,
              :severity => result.severity,
              :fingerprint => result.fingerprint,
              :first_appeared => self.revision,
              :detail => result.detail,
              :scanner => result.source[:scanner],
              :file => result.source[:file],
              :line => result.source[:line],
              :code => result.source[:code]
              })

            if f.valid?
              f.burns << self unless f.burns.include?(self)
              self.findings << f unless self.findings.include?(f)
            end
          end
        end
        files,lines = CodeburnerUtil.tally_code(dir, languages)
        self.update(num_files: files, num_lines: lines)

        finish_lines = %Q(
[#{Time.now}] Burn #{self.id} finished

Findings:
  Open:       #{self.findings.status(0).count}
  Hidden:     #{self.findings.status(1).count}
  Filtered:   #{self.findings.status(3).count}
        )

        finish_lines.each_line do |line|
          $redis.publish "burn:#{self.id}:log", line
          logfile.puts line
        end

        $redis.publish "burn:#{self.id}:log", "\n\n"
        $redis.publish "burn:#{self.id}:log", "END_PIPELINE_LOG"

        logfile.close unless logfile.closed?

        self.update(status: 'done', status_reason: "completed on #{Time.now}", :log => File.open(Rails.root.join("log/burns/#{self.id}.log"), 'rb').read)
        File.delete(Rails.root.join("log/burns/#{self.id}.log"))

        if self.report_status
          if self.findings.status(0).count == 0
            github.create_status self.repo.name, self.revision, 'success', :context => 'Codeburner', :description => 'codeburner security analysis', :target_url => "#{Setting.email['link_host']}/\#findings?repo_id=#{self.repo_id}&burn_id=#{self.id}&branch=#{self.branch.name}&only_current=false"
          else
            github.create_status self.repo.name, self.revision, 'failure', :context => 'Codeburner', :description => 'codeburner security analysis', :target_url => "#{Setting.email['link_host']}/\#findings?repo_id=#{self.repo_id}&burn_id=#{self.id}&branch=#{self.branch.name}&only_current=false"
          end
        end

        self.send_notifications(previous_stats)
      end
    rescue StandardError => e
      logfile.puts "[#{Time.now}] error downloading github archive"
      self.update(status: 'failed', status_reason: "error downloading github archive on #{Time.now}", log: logfile.read)
      logfile.close
      File.delete(Rails.root.join("log/burns/#{self.id}.log"))
      $redis.publish "burn:#{self.id}:log", "[#{Time.now}] error downloading github archive"
      $redis.publish "burn:#{self.id}:log", "END_PIPELINE_LOG"
      Rails.logger.info e.message
      Rails.logger.info e.backtrace
      self.send_failure_notification
    ensure
      if logfile and not logfile.closed?
        self.update(:log => logfile.read)
        logfile.close
        File.delete(Rails.root.join("log/burns/#{self.id}.log"))
      end
    end
  end

  def send_notifications previous_stats
    Notification.where(:burn => [self.id.to_s, 'all']).each do |notification|
      notification.notify(self.id, previous_stats)
    end
  end

  def send_failure_notifications
    CodeburnerUtil.user_github(self.user).create_status self.repo.name, self.revision, 'error', :context => 'Codeburner', :description => 'codeburner security analysis', :target_url => "#{Setting.email['link_host']}/#burns" if self.report_status

    Notification.where(:burn => [self.id.to_s, 'all']).each do |notification|
      notification.fail(self.id)
    end
  end

end
