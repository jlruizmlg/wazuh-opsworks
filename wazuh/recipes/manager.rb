package ['wazuh-manager']


bash 'Creating ossec-authd key and cert' do
  code <<-EOH
    openssl genrsa -out #{node['wazuh']['dir']}/etc/sslmanager.key 4096 &&
    openssl req -new -x509 -key #{node['wazuh']['dir']}/etc/sslmanager.key\
   -out #{node['wazuh']['dir']}/etc/sslmanager.cert -days 3650\
   -subj /CN=fqdn/
    EOH
  not_if { ::File.exist?("#{node['wazuh']['dir']}/etc/sslmanager.cert") }
end

if node['init_package'] == 'systemd'
  template 'ossec-authd init' do
    path '/lib/systemd/system/ossec-authd.service'
    source 'ossec-authd.service.erb'
    owner 'root'
    group 'root'
    mode '0644'
  end

  execute 'systemctl daemon-reload' do
    action :nothing
    subscribes :run, 'template[ossec-authd init]', :immediately
  end
elsif node['init_package'] == 'init'
  template 'ossec-authd init' do
    path '/etc/init.d/ossec-authd'
    source 'ossec-authd-init.service.erb'
    owner 'root'
    group 'root'
    mode '0755'
  end
end

service 'ossec-authd' do
  supports restart: true
  action [:enable, :start]
  subscribes :restart, 'template[ossec-authd init]'
end
