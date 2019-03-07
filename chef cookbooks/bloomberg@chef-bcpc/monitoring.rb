###########################################
#
# General monitoring settings
#
###########################################
#
# Flag to indicate if node is a monitoring service provider
default['bcpc']['monitoring']['provider'] = false
# VIP for monitoring services and agents
default['bcpc']['monitoring']['vip'] = "10.17.1.16"
# CIDR of monitoring endpoints outside of cluster.
default['bcpc']['monitoring']['cidrs'] = ['10.17.1.0/24']
# Agent TCP ports that monitoring servers need to reach
default['bcpc']['monitoring']['agent_tcp_ports'] = [10050]
# List of monitoring clients external to cluster that we are monitoring
default['bcpc']['monitoring']['external_clients'] = []
# Monitoring database settings
default['bcpc']['monitoring']['mysql']['innodb_buffer_pool_size'] = '128M'
default['bcpc']['monitoring']['mysql']['innodb_buffer_pool_instances'] = 1
default['bcpc']['monitoring']['mysql']['thread_cache_size'] = nil
default['bcpc']['monitoring']['mysql']['innodb_io_capacity'] = 200
default['bcpc']['monitoring']['mysql']['innodb_log_buffer_size'] = '8M'
default['bcpc']['monitoring']['mysql']['innodb_flush_method'] = 'O_DIRECT'
default['bcpc']['monitoring']['mysql']['wsrep_slave_threads'] = 4
# slow query log settings
default['bcpc']['monitoring']['mysql']['slow_query_log'] = true
default['bcpc']['monitoring']['mysql']['slow_query_log_file'] = '/var/log/mysql/slow.log'
default['bcpc']['monitoring']['mysql']['long_query_time'] = 10
default['bcpc']['monitoring']['mysql']['log_queries_not_using_indexes'] = false
# Pagerduty integration
default['bcpc']['monitoring']['pagerduty']['enabled'] = false
# Pagerduty service key
default['bcpc']['monitoring']['pagerduty']['key'] = nil

###########################################
#
# Graphite settings
#
###########################################
#
# Graphite version
default['bcpc']['graphite']['version'] = '0.9.15'
# Graphite Server FQDN
default['bcpc']['graphite']['fqdn'] = "graphite.#{node['bcpc']['cluster_domain']}"
#
# Default retention rates
# http://graphite.readthedocs.org/en/latest/config-carbon.html#storage-schemas-conf
default['bcpc']['graphite']['retention'] = '60s:1d'
#
# Maximum number of whisper files to create per minute. This is set low to avoid
# I/O storm when new nodes are enrolled into cluster.
# Set to 'inf' (infinite) to remove limit.
default['bcpc']['graphite']['max_creates_per_min'] = '60'
# Limit the number of updates to prevent over-utilizing the disk
default['bcpc']['graphite']['max_updates_per_sec'] = '500'
# Graphite whitelist/blacklist toggle
default['bcpc']['graphite']['use_whitelist'] = {
  'enabled' => 'False',
  'whitelist' => [],
  'blacklist' => []
}
# Number of copies of metrics to store. The default (1) implies no redundancy.
default['bcpc']['graphite']['replication_factor'] = 1

###########################################
#
# Diamond settings
#
###########################################
#
# Handlers
default['bcpc']['diamond']['handlers'] = {
  'diamond.handler.graphitepickle.GraphitePickleHandler' => {
    'host' => node['bcpc']['monitoring']['vip'],
    'port' => 2014,
    'batch' => 512,
    'timeout' => 15
  }
}
# CPU Collector parameters
default['bcpc']['diamond']['collectors']['CPU']['normalize'] = 'True'
default['bcpc']['diamond']['collectors']['CPU']['percore'] = 'False'
# LoadAverage Collector parameters
default['bcpc']['diamond']['collectors']['LoadAverage']['metrics_blacklist'] = '^[01][15]_normalized$'
# List of queue names separated by whitespace to report on. If nil, report all.
default['bcpc']['diamond']['collectors']['rabbitmq']['queues'] = nil
# Regular expression or list of queues to not report on.
# If not nil, this overrides "queues".
default['bcpc']['diamond']['collectors']['rabbitmq']['queues_ignored'] = '.*'
# List of vhosts to report on. If nil, report none.
default['bcpc']['diamond']['collectors']['rabbitmq']['vhosts'] = nil
# Ceph Collector parameters
default['bcpc']['diamond']['collectors']['CephCollector']['metrics_whitelist'] = "ceph.mon.#{node['hostname']}.cluster.*"
# Openstack Collector parameters
default['bcpc']['diamond']['collectors']['cloud'] = {
  "interval" => "900",
  "path" => "openstack",
  "hostname" => "#{node['bcpc']['region_name']}",
  "db_host" => "#{node['bcpc']['management']['vip']}",
}

###########################################
#
# Zabbix settings
#
###########################################
#
default['bcpc']['zabbix']['discovery']['delay'] = 600
default['bcpc']['zabbix']['discovery']['ip_ranges'] = [node['bcpc']['management']['cidr']]
default['bcpc']['zabbix']['fqdn'] = "zabbix.#{node['bcpc']['cluster_domain']}"
default['bcpc']['zabbix']['storage_retention'] = 7
default['bcpc']['zabbix']['php_settings'] = {
    'max_execution_time' => 300,
    'memory_limit' => '256M',
    'post_max_size' => '16M',
    'upload_max_filesize' => '2M',
    'max_input_time' => 300,
    'date.timezone' => 'America/New_York'
}
# Zabbix severities to notify about.
# https://www.zabbix.com/documentation/2.4/manual/api/reference/usermedia/object
default['bcpc']['zabbix']['severity'] = 63
# Timeout for Zabbix agentd
default['bcpc']['zabbix']['agentd_timeout'] = 25
# Zabbix cache sizes
default['bcpc']['zabbix']['server_cachesize'] = '16M'
default['bcpc']['zabbix']['server_historycachesize'] = '8M'
default['bcpc']['zabbix']['server_trendcachesize'] = '16M'
default['bcpc']['zabbix']['server_historytextcachesize'] = '16M'
default['bcpc']['zabbix']['server_valuecachesize'] = '8M'
# Timeout for Zabbix server. It is slightly higher than agentd to better detect
# cause of timeout.
default['bcpc']['zabbix']['server_timeout'] = node['bcpc']['zabbix']['agentd_timeout'] + 1

###########################################
#
# Kibana settings
#
###########################################
#
# Kibana Server FQDN
default['bcpc']['kibana']['fqdn'] = "kibana.#{node['bcpc']['cluster_domain']}"

###########################################
#
# Elasticsearch settings
#
###########################################
#
# Heap memory size
default['bcpc']['elasticsearch']['heap_size'] = '256m'
# Additional Java options
default['bcpc']['elasticsearch']['java_opts'] = '-XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -verbose:gc -Xloggc:/var/log/elasticsearch/gc.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=10m'
