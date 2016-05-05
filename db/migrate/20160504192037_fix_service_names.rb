class FixServiceNames < ActiveRecord::Migration
  def change
    Service.has_burns.all.each do |service|
      burn = Burn.service_id(service.id).status('done').last

      if burn
        name = URI.parse(burn.repo_url).path[1..-1]
        service.update(:short_name => name, :pretty_name => name)
      else
        Burn.service_id(service.id).destroy_all
        ServiceStat.destroy(Service.find(service.id).service_stat.id)
        Service.destroy(service.id)
      end
    end
  end
end
