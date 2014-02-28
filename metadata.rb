name             'deploy-play'
maintainer       'Sameer Arora'
maintainer_email 'sameera@bluepi.in'
license          'Apache 2.0'
description      'Deploys Play Application'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'java'

supports 'debian'
supports 'ubuntu'
supports 'centos'
supports 'redhat'

recipe 'deploy-play::default', 'Deploys Play Application on your Node'
