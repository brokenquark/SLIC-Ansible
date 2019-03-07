# Configure scheduler configuration XML files
Chef::Resource::File.send(:include, Bcpc_Hadoop::Hadoop_Helpers)

fair_share_queue "default" do
  min_cores = node["bcpc"]["hadoop"]["yarn"]["scheduler"]["fair"]["min-vcores"]
  min_mb = node["bcpc"]["hadoop"]["yarn"]["scheduler"]["minimum-allocation-mb"]

  attributes({'type' => 'parent'})
  weight 1.0
  minResources "#{min_mb*min_cores}mb, #{min_cores}vcores"
  action :register
end

file "/etc/hadoop/conf/fair-scheduler.xml" do
  mode 0644
  content lazy {
    # Merge the fair_scheduler_queue environment overrides
    # into the definitions from fair_scheduler_queue resources.
    # Definitions in the node attribute take precedence over the resources.
    queue_defs = node.run_state[:fair_scheduler_queue] || {}
    queue_overrides = node[:bcpc][:hadoop][:yarn][:fair_scheduler_queue] || {}

    fair_scheduler_xml(
      queue_defs.merge(queue_overrides),
      node[:bcpc][:hadoop][:yarn][:fairSchedulerOpts],
      node[:bcpc][:hadoop][:yarn][:queuePlacementPolicy]
    )
  }
end

template "/etc/hadoop/conf/capacity-scheduler.xml" do
  source "generic_site.xml.erb"
  mode 0644
  variables(:options =>
            node[:bcpc][:hadoop][:yarn][:scheduler][:capacity][:xml])
end
