cookbook_file "/etc/yum.repos.d/wazuh.repo" do
  source "wazuh.repo"
  mode '0644'
  action :create
  owner 'root'
  group 'root'
end
