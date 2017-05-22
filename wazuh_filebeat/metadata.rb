name             'wazuh_filebeat'
maintainer       'Jose Luis Ruiz'
maintainer_email 'jose@wazuh.com'
license          'Apache 2.0'
description      'Installs and configures filebeat'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

supports 'centos'

depends 'yum'
