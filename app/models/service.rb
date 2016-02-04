class Service < ActiveRecord::Base
  validates :short_name, presence: true
  validates :short_name, uniqueness: true
  has_many :burns
  has_many :findings
  has_one  :service_stat

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
