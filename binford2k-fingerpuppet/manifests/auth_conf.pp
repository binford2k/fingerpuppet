## Modify auth.conf to add access rules for the host running fingerpuppet.
#
# This class is one giant hack. Because auth.conf is parsed only until a match is 
# found, we simply add a copy of each existing rule we want to override directly
# before it with our own modifications to it.
#
# Parameters:
#    $privileged_hosts: a string or array representing the certname(s) to allow
#
# Caveats:
#    This is only intended for use on Puppet Enterprise where auth.conf is managed.
#
class fingerpuppet::auth_conf($privileged_hosts) {
  if ! $pe_version {
    fail('The fingerpuppet::auth_conf class is only intended for use with Puppet Enterprise. Manually configure your auth.conf file when running on Puppet Open Source.')
  }
  include ::auth_conf

  if $fact_is_puppetmaster == 'true' {
    auth_conf::acl { 'provisioner_catalog':
      path       => '^/catalog/([^/]+)$',
      regex      => true,
      acl_method => ['find'],
      allow      => flatten(['$1', $privileged_hosts]),
      order      => 009,
    }

    auth_conf::acl { 'provisioner_node':
      path       => '^/node/([^/]+)$',
      regex      => true,
      acl_method => ['find'],
      allow      => flatten(['$1', $privileged_hosts]),
      order      => 019,
    }

    auth_conf::acl { 'provisioner_resource':
      path       => '/resource',
      acl_method => ['find'],
      allow      => $privileged_hosts,
      order      => 055,
    }

    auth_conf::acl { 'provisioner_status':
      path       => '/status',
      acl_method => ['find'],
      allow      => $privileged_hosts,
      order      => 055,
    }

    auth_conf::acl { 'provisioner_certificate_status':
      path       => '/certificate_status',
      auth       => 'yes',
      acl_method => ['find','search', 'save', 'destroy'],
      allow      => flatten(['pe-internal-dashboard', $privileged_hosts]),
      order      => 084,
    }
  }

  if $fact_is_puppetconsole == 'true' {
    auth_conf::acl { 'provisioner_facts':
      path       => '/facts',
      auth       => 'yes',
      acl_method => ['save'],
      allow      => flatten([$fact_puppetmaster_certname, $privileged_hosts]),
      order      => 094,
    }
  }

}
