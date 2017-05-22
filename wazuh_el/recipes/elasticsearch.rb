package ['elasticsearch']

# calculation for memory allocation; 50% or 31g, whatever is smaller

directory '/mnt/elasticsearch' do
  owner 'elasticsearch'
  group 'elasticsearch'
  mode '0755'
  action :create
end


half = ((node['memory']['total'].to_i * 0.5).floor / 1024)

node.default['wazuh_el']['memmory'] = (half > 30_500 ? '30500m' : "#{half}m")

template '/etc/elasticsearch/elasticsearch.yml' do
  source 'elasticsearch.yml.erb'
  owner 'root'
  group 'elasticsearch'
  mode '0660'
  variables({hostname: node['hostname'],
            elasticsearch_cluster: node['wazuh_el']['elasticsearch_cluster'],
            node_ip: node['ipaddress']})
  notifies :restart, 'service[elasticsearch]', :delayed
end

template '/etc/elasticsearch/jvm.options' do
  source 'jvm.options.erb'
  owner 'root'
  group 'elasticsearch'
  mode '0660'
  variables({memmory: node['wazuh_el']['memmory']})
  notifies :restart, 'service[elasticsearch]', :delayed
end

phpserver = search(:node, "hostname:elk*")

file "/tmp/ip_addresses" do
  content "#{phpserver[0][:ipaddress]}"
  mode 0644
  action :create
end

service 'elasticsearch' do
  supports restart: true
  action [:enable, :start]
end
