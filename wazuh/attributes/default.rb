#
# Cookbook Name:: wazuh-api
# Attribute:: default
# Author:: Jose Luis Ruiz <support@wazuh.com.com>
#
# Copyright (c) 2016
#
default['wazuh']['dir'] = '/var/ossec'
default['wazuh']['api']['version'] = '2.0'
default['wazuh']['api']['name'] = "wazuh-API-#{node['wazuh']['api']['version']}"
default['wazuh']['api']['url'] = "https://github.com/wazuh/wazuh-API/archive/v#{node['wazuh']['api']['version']}.tar.gz"
