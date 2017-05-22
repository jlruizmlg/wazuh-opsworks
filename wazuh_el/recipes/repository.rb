cookbook_file "/etc/yum.repos.d/elk.repo" do
  source "wazuh.repo"
  mode '0644'
  action :create
  owner 'root'
  group 'root'
end
