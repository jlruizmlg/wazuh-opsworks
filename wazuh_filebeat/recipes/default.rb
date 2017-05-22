#
# Cookbook Name:: filebeat
# Recipe:: default
# Author:: Jose Luis Ruiz <jose@wazuh.com>

# add the beats repository
yum_repository 'beats' do
  description "Elastic Beats Repository"
  baseurl "https://artifacts.elastic.co/packages/5.x/yum"
  gpgkey 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
  action :create
end

package 'filebeat'

logstash_ip = []

search(:node, "hostname:elk*") do |n|
  logstash_ip << n['ipaddress']
end

template node['filebeat']['config_path'] do
  source 'filebeat.yml.erb'
  owner 'root'
  group 'root'
  mode '0640'
  variables(:servers => logstash_ip)
  notifies :restart, "service[#{node['filebeat']['service_name']}]"
end

service node['filebeat']['service_name'] do
  supports restart: true, status: true, reload: true
  action [:enable, :start]
end
