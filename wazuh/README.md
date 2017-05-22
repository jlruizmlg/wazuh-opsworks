ossec cookbook
==============

Installs OSSEC from source in a server-agent installation. See:

http://www.ossec.net/doc/manual/installation/index.html

Requirements
------------
#### Platforms
Tested on Ubuntu and ArchLinux, but should work on any Unix/Linux platform supported by OSSEC. Installation by default is done from source, so the build-essential cookbook needs to be used (see below).

This cookbook doesn't configure Windows systems yet. For information on installing OSSEC on Windows, see the [free chapter](http://www.ossec.net/ossec-docs/OSSEC-book-ch2.pdf)

#### Chef
- Chef 12+

#### Cookbooks
- apt

Attributes
----------

* `node['ossec']['dir']` - Installation directory for OSSEC, default `/var/ossec`. All existing packages use this directory so you should not change this.
* `node['ossec']['server_role']` - When using server/agent setup, this role is used to search for the OSSEC server, default `ossec_server`.
* `node['ossec']['agent_server_ip']` - The IP of the OSSEC server. The client recipe will attempt to determine this value via search. Default is nil, only required for agent installations.

###ossec.conf

OSSEC's configuration is mainly read from an XML file called `ossec.conf`. You can directly control the contents of this file using node attributes under `node['ossec']['conf']`. These attributes are mapped to XML using Gyoku. See the [Gyoku site](https://github.com/savonrb/gyoku) for details on how this works.

Chef applies attributes from all attribute files regardless of which recipes were executed. In order to make wrapper cookbooks easier to write, `node['ossec']['conf']` is divided into the three installation types mentioned below, `local`, `server`, and `agent`. You can also set attributes under `all` to apply settings across all installation types. The typed attributes are automatically deep merged over the `all` attributes in the normal Chef manner.

`true` and `false` values are automatically mapped to `"yes"` and `"no"` as OSSEC expects the latter.

`ossec.conf` makes little use of XML attributes so you can generally construct nested hashes in the usual fashion. Where an attribute is required, you can do it like this:

    default['ossec']['conf']['all']['syscheck']['directories'] = [
      { '@check_all' => true, 'content!' => '/bin,/sbin' },
      '/etc,/usr/bin,/usr/sbin'
    ]

This produces:

    <syscheck>
      <directories check_all="yes">/bin,/sbin</directories>
      <directories>/etc,/usr/bin,/usr/sbin</directories>
    </syscheck>

The default values are based on those given in the OSSEC manual. They do not include any specific rules, checks, outputs, or alerts as everyone has different requirements.

###agent.conf

OSSEC servers can also distribute configuration to agents through the centrally managed XM file called `agent.conf`. Since Chef is better at distributing configuration than OSSEC is, the cookbook leaves this file blank by default. Should you want to populate it, it is done in a similar manner to the above. Since this file is only used on servers, you can define the attributes directly under `node['ossec']['agent_conf']`. Unlike conventional XML files, `agent.conf` has multiple root nodes so `node['ossec']['agent_conf']` must be treated as an array like so.

    default['ossec']['agent_conf'] = [
      {
        'syscheck' => { 'frequency' => 4321 },
        'rootcheck' => { 'disabled' => true }
      },
      {
        '@os' => 'Windows',
        'content!' => {
          'syscheck' => { 'frequency' => 1234 }
        }
      }
    ]

This produces:

    <agent_config>
      <syscheck>
        <frequency>4321</frequency>
      </syscheck>
      <rootcheck>
        <disabled>yes</disabled>
      </rootcheck>
    </agent_config>

    <agent_config os="Windows">
      <syscheck>
        <frequency>1234</frequency>
      </syscheck>
    </agent_config>

Recipes
-------

###repository

Adds the OSSEC repository to the package agent. This recipe is included by others and should not be used directly. For highly customised setups, you should use `ossec::install_agent`.

###install_agent

Installs the agent packages but performs no explicit configuration.


###common

Puts the configuration file in place and starts the (agent or server) service. This recipe is included by other recipes and generally should not be used directly.

Note that the service will not be started if the client.keys file is missing or empty. For agents, this results in an error. For servers, this prevents ossec-remoted from starting, resulting in agents being unable to connect. Once client.keys does exist with content, simply perform another chef-client run to start the service.


###agent

OSSEC uses the term `agent` instead of client. The agent recipe includes the `pm_wazuh_ossec::agent` recipe.


###manager

Sets up a system to be an OSSEC server. This recipe will search for all nodes that have an `ossec` attribute and add them as an agent to register with the given server running ossec-authd. To allow registration with a new server after changing `agent_server_ip`, delete the client.keys file and rerun the recipe..

To manage additional agents on the server that don't run chef, or for agentless OSSEC configuration (for example, routers), add a new node for them and create the `node['ossec']['agentless']` attribute as true. For example if we have a router named gw01.example.com with the IP `192.168.100.1`:

    % knife node create gw01.example.com
    {
      "name": "gw01.example.com",
      "json_class": "Chef::Node",
      "automatic": {
      },
      "normal": {
        "hostname": "gw01",
        "fqdn": "gw01.example.com",
        "ipaddress": "192.168.100.1",
        "ossec": {
          "agentless": true
        }
      },
      "chef_type": "node",
      "default": {
      },
      "override": {
      },
      "run_list": [
      ]
    }

Enable agentless monitoring in OSSEC and register the hosts on the server. Automated configuration of agentless nodes is not yet supported by this cookbook. For more information on the commands and configuration directives required in `ossec.conf`, see the [OSSEC Documentation](http://www.ossec.net/doc/manual/agent/agentless-monitoring.html)

Usage
-----

The cookbook can be used to install OSSEC in one of the three types:

* server - use the pm_wazuh_ossec::manager recipe.
* agent - use the pm_wazuh_ossec::agent recipe
* API - use the pm_wazuh_ossec::wazuh-api recipe

For the OSSEC server, create a role, `phishme_server`. Add attributes per above as needed to customize the installation.
```
  {
    "name": "phishme_server",
    "description": "",
    "json_class": "Chef::Role",
    "default_attributes": {

    },
    "override_attributes": {

    },
    "chef_type": "role",
    "run_list": [
      "recipe[pm_wazuh_ossec::manager]"
    ],
    "env_run_lists": {

    }
  }
```

For OSSEC agents, create a role, `phishme_agent`.

```
  {
    "name": "phishme_agent",
    "description": "",
    "json_class": "Chef::Role",
    "default_attributes": {

    },
    "override_attributes": {
      "ossec": {
        "agent_server_ip": "192.168.186.135"
      }
    },
    "chef_type": "role",
    "run_list": [
      "recipe[pm_wazuh_ossec::agent]"
    ],
    "env_run_lists": {

    }
  }
```

Customization
----

The main configuration file is maintained by Chef as a template, `ossec.conf.erb`. It should just work on most installations, but can be customized for the local environment. Notably, the rules, ignores and commands may be modified.

Further reading:

* [OSSEC Documentation](http://www.ossec.net/doc/index.html)

License and Author
------------------

Copyright 2010-2015, Chef Software, Inc (<legal@chef.io>)

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
