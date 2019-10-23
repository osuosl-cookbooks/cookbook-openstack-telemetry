# encoding: UTF-8
#
# Cookbook Name:: openstack-telemetry
# Recipe:: default
#
# Copyright 2013, AT&T Services, Inc.
# Copyright 2013-2014, SUSE Linux GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Set to some text value if you want templated config files
# to contain a custom banner at the top of the written file
default['openstack']['telemetry']['custom_template_banner'] = '
# This file is automatically generated by Chef
# Any changes will be overwritten
'

# Set the endpoints for the telemetry services to allow all other cookbooks to
# access and use them
%w(telemetry telemetry_metric aodh).each do |ts|
  %w(public internal admin).each do |ep_type|
    default['openstack']['endpoints'][ep_type][ts]['host'] = '127.0.0.1'
    default['openstack']['endpoints'][ep_type][ts]['scheme'] = 'http'
    default['openstack']['endpoints'][ep_type][ts]['path'] = ''
    default['openstack']['endpoints'][ep_type]['telemetry']['port'] = 8777
    default['openstack']['endpoints'][ep_type]['telemetry_metric']['port'] = 8041
    default['openstack']['endpoints'][ep_type]['aodh']['port'] = 8042
    # web-service (e.g. apache) listen address (can be different from openstack
    # telemetry endpoints)
  end
  default['openstack']['bind_service']['all'][ts]['host'] = '127.0.0.1'
end
default['openstack']['bind_service']['all']['telemetry']['port'] = 8777
default['openstack']['bind_service']['all']['telemetry_metric']['port'] = 8041
default['openstack']['bind_service']['all']['aodh']['port'] = 8042

default['openstack']['telemetry']['conf_dir'] = '/etc/ceilometer'
default['openstack']['telemetry']['conf_file'] =
  ::File.join(node['openstack']['telemetry']['conf_dir'], 'ceilometer.conf')
default['openstack']['telemetry_metric']['conf_dir'] = '/etc/gnocchi'
default['openstack']['telemetry_metric']['conf_file'] =
  ::File.join(node['openstack']['telemetry_metric']['conf_dir'], 'gnocchi.conf')
default['openstack']['telemetry']['syslog']['use'] = false
default['openstack']['telemetry']['upgrade_opts'] = '--skip-gnocchi-resource-types'

default['openstack']['aodh']['conf_dir'] = '/etc/aodh'
default['openstack']['aodh']['conf_file'] =
  ::File.join(node['openstack']['aodh']['conf_dir'], 'aodh.conf')

default['openstack']['telemetry']['user'] = 'ceilometer'
default['openstack']['telemetry']['group'] = 'ceilometer'

default['openstack']['telemetry_metric']['user'] = 'gnocchi'
default['openstack']['telemetry_metric']['group'] = 'gnocchi'

default['openstack']['aodh']['user'] = 'aodh'
default['openstack']['aodh']['group'] = 'aodh'

default['openstack']['telemetry']['service_role'] = 'admin'
default['openstack']['telemetry_metric']['service_role'] = 'admin'
default['openstack']['aodh']['service_role'] = 'admin'

default['openstack']['telemetry_metric']['gnocchi-upgrade-options'] = ''

# Configuration for /etc/ceilometer/polling.yaml
default['openstack']['telemetry']['polling']['interval'] = 300
default['openstack']['telemetry']['polling']['meters'] =
  %w(
    cpu
    cpu_l3_cache
    memory.usage
    network.incoming.bytes
    network.incoming.packets
    network.outgoing.bytes
    network.outgoing.packets
    disk.device.read.bytes
    disk.device.read.requests
    disk.device.write.bytes
    disk.device.write.requests
    hardware.cpu.util
    hardware.memory.used
    hardware.memory.total
    hardware.memory.buffer
    hardware.memory.cached
    hardware.memory.swap.avail
    hardware.memory.swap.total
    hardware.system_stats.io.outgoing.blocks
    hardware.system_stats.io.incoming.blocks
    hardware.network.ip.incoming.datagrams
    hardware.network.ip.outgoing.datagrams
  )

%w(telemetry telemetry_metric aodh).each do |ts|
  # specify whether to enable SSL for ceilometer API endpoint
  default['openstack'][ts]['ssl']['enabled'] = false
  # specify server whether to enforce client certificate requirement
  default['openstack'][ts]['ssl']['cert_required'] = false
  # SSL certificate, keyfile and CA certficate file locations
  default['openstack'][ts]['ssl']['basedir'] = '/etc/ceilometer/ssl'
  # Protocol for SSL (Apache)
  default['openstack'][ts]['ssl']['protocol'] = 'All -SSLv2 -SSLv3'
  # Which ciphers to use with the SSL/TLS protocol (Apache)
  # Example: 'RSA:HIGH:MEDIUM:!LOW:!kEDH:!aNULL:!ADH:!eNULL:!EXP:!SSLv2:!SEED:!CAMELLIA:!PSK!RC4:!RC4-MD5:!RC4-SHA'
  default['openstack'][ts]['ssl']['ciphers'] = nil
  # path of the cert file for SSL.
  default['openstack'][ts]['ssl']['certfile'] = "#{node['openstack'][ts]['ssl']['basedir']}/certs/sslcert.pem"
  # path of the keyfile for SSL.
  default['openstack'][ts]['ssl']['keyfile'] = "#{node['openstack'][ts]['ssl']['basedir']}/private/sslkey.pem"
  default['openstack'][ts]['ssl']['chainfile'] = nil
  # path of the CA cert file for SSL.
  default['openstack'][ts]['ssl']['ca_certs'] = "#{node['openstack'][ts]['ssl']['basedir']}/certs/sslca.pem"
  # path of the CA cert files for SSL (Apache)
  default['openstack'][ts]['ssl']['ca_certs_path'] = "#{node['openstack'][ts]['ssl']['basedir']}/certs/"
end
case node['platform_family']
when 'rhel'
  default['openstack']['telemetry']['platform'] = {
    'common_packages' => ['openstack-ceilometer-common'],
    'gnocchi_packages' => ['openstack-gnocchi-api', 'openstack-gnocchi-metricd'],
    'gnocchi-api_service' => 'openstack-gnocchi-api',
    'gnocchi-metricd_service' => 'gnocchi-metricd',
    'agent_central_packages' => ['openstack-ceilometer-central'],
    'agent_central_service' => 'openstack-ceilometer-central',
    'agent_compute_packages' => ['openstack-ceilometer-compute'],
    'agent_compute_service' => 'openstack-ceilometer-compute',
    'agent_notification_packages' => ['openstack-ceilometer-collector'],
    'agent_notification_service' => 'openstack-ceilometer-notification',
    'ceilometer-api_wsgi_file' => '/usr/lib/python2.7/site-packages/ceilometer/api/app.wsgi',
    'gnocchi-api_wsgi_file' => '/usr/share/gnocchi-common/app.wsgi',
    'api_packages' => ['openstack-ceilometer-api'],
    'api_service' => 'openstack-ceilometer-api',
    'collector_packages' => ['openstack-ceilometer-collector'],
    'collector_service' => 'openstack-ceilometer-collector',
    'package_overrides' => '',
  }

  default['openstack']['aodh']['platform'] = {
    'aodh_packages' => ['openstack-aodh', 'openstack-aodh-api', 'openstack-aodh-evaluator',
                        'openstack-aodh-expirer', 'openstack-aodh-listener', 'openstack-aodh-notifier',
                        'python-aodhclient'],
    'aodh_services' => ['openstack-aodh-evaluator', 'openstack-aodh-notifier', 'openstack-aodh-listener'],
    'aodh-api_wsgi_file' => '/usr/share/aodh/app.wsgi',
  }

when 'debian'
  default['openstack']['telemetry']['platform'] = {
    'common_packages' => ['ceilometer-common'],
    'gnocchi_packages' => ['python-gnocchi', 'gnocchi-common', 'gnocchi-api', 'gnocchi-metricd', 'python-gnocchiclient'],
    'gnocchi-api_service' => 'gnocchi-api',
    'gnocchi-metricd_service' => 'gnocchi-metricd',
    'agent_central_packages' => ['ceilometer-agent-central'],
    'agent_central_service' => 'ceilometer-agent-central',
    'agent_compute_packages' => ['ceilometer-agent-compute'],
    'agent_compute_service' => 'ceilometer-agent-compute',
    'agent_notification_packages' => ['ceilometer-agent-notification'],
    'agent_notification_service' => 'ceilometer-agent-notification',
    'ceilometer-api_wsgi_file' => '/usr/lib/python2.7/dist-packages/ceilometer/api/app.wsgi',
    'gnocchi-api_wsgi_file' => '/usr/share/gnocchi-common/app.wsgi',
    'api_packages' => ['ceilometer-api'],
    'api_service' => 'ceilometer-api',
    'collector_packages' => ['ceilometer-collector', 'python-mysqldb'],
    'collector_service' => 'ceilometer-collector',
    'package_overrides' => '',
  }

  default['openstack']['aodh']['platform'] = {
    'aodh_packages' => ['aodh-api', 'aodh-evaluator', 'aodh-expirer', 'aodh-listener', 'aodh-notifier', 'python-ceilometerclient'],
    'aodh_services' => ['aodh-evaluator', 'aodh-notifier', 'aodh-listener'],
    'aodh-api_wsgi_file' => '/usr/share/aodh/app.wsgi' # this file come with aodh-common which aodh-api depends on
  }
end
