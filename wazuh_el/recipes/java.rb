remote_file '#{Chef::Config[:file_cache_path]}/jdk-8-linux-x64.rpm' do
  source 'https://packages.wazuh.com/java/jdk-8-linux-x64.rpm'
  action :create
end

rpm_package 'Oracle Java' do
 source '#{Chef::Config[:file_cache_path]}/jdk-8-linux-x64.rpm'
end

