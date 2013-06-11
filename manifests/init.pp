# Class: puppet-apt-cacher-ng
#
# This module manages puppet-apt-cacher-ng
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class apt_cacher_ng (
  $my_class            = params_lookup('my_class'),
  $source              = params_lookup('source'),
  $source_dir          = params_lookup('source_dir'),
  $source_dir_purge    = params_lookup('source_dir_purge'),
  $template            = params_lookup('template'),
  $service_autorestart = params_lookup('service_autorestart', 'global'),
  $options             = params_lookup('options'),
  $absent              = params_lookup('absent'),
  $disable             = params_lookup('disable'),
  $disableboot         = params_lookup('disableboot'),
  $exchange_hostkeys   = params_lookup('exchange_hostkeys'),
  $monitor             = params_lookup('monitor', 'global'),
  $monitor_tool        = params_lookup('monitor_tool', 'global'),
  $monitor_target      = params_lookup('monitor_target', 'global'),
  $puppi               = params_lookup('puppi', 'global'),
  $puppi_helper        = params_lookup('puppi_helper', 'global'),
  $firewall            = params_lookup('firewall', 'global'),
  $firewall_tool       = params_lookup('firewall_tool', 'global'),
  $firewall_src        = params_lookup('firewall_src', 'global'),
  $firewall_dst        = params_lookup('firewall_dst', 'global'),
  $debug               = params_lookup('debug', 'global'),
  $audit_only          = params_lookup('audit_only', 'global'),
  $package             = params_lookup('package'),
  $service             = params_lookup('service'),
  $service_status      = params_lookup('service_status'),
  $process             = params_lookup('process'),
  $process_args        = params_lookup('process_args'),
  $process_user        = params_lookup('process_user'),
  $config_dir          = params_lookup('config_dir'),
  $config_file         = params_lookup('config_file'),
  $config_file_mode    = params_lookup('config_file_mode'),
  $config_file_owner   = params_lookup('config_file_owner'),
  $config_file_group   = params_lookup('config_file_group'),
  $config_file_init    = params_lookup('config_file_init'),
  $pid_file            = params_lookup('pid_file'),
  $data_dir            = params_lookup('data_dir'),
  $log_dir             = params_lookup('log_dir'),
  $log_file            = params_lookup('log_file'),
  $cache_dir           = params_lookup('cache_dir'),
  $port                = params_lookup('port'),
  $protocol            = params_lookup('protocol')) inherits apt_cacher_ng::params {
  # check and convert parameters
  $bool_source_dir_purge = any2bool($source_dir_purge)
  $bool_service_autorestart = any2bool($service_autorestart)
  $bool_absent = any2bool($absent)
  $bool_disable = any2bool($disable)
  $bool_disableboot = any2bool($disableboot)
  $bool_monitor = any2bool($monitor)
  $bool_puppi = any2bool($puppi)
  $bool_firewall = any2bool($firewall)
  $bool_debug = any2bool($debug)
  $bool_audit_only = any2bool($audit_only)

  # ## Definition of some variables used in the module
  $manage_package = $apt_cacher_ng::bool_absent ? {
    true  => 'absent',
    false => 'present',
  }

  $manage_service_enable = $apt_cacher_ng::bool_disableboot ? {
    true    => false,
    default => $apt_cacher_ng::bool_disable ? {
      true    => false,
      default => $apt_cacher_ng::bool_absent ? {
        true  => false,
        false => true,
      },
    },
  }

  $manage_service_ensure = $apt_cacher_ng::bool_disable ? {
    true    => 'stopped',
    default => $apt_cacher_ng::bool_absent ? {
      true    => 'stopped',
      default => 'running',
    },
  }

  $manage_service_autorestart = $apt_cacher_ng::bool_service_autorestart ? {
    true  => 'Service[apt-cacher-ng]',
    false => undef,
  }

  $manage_file = $apt_cacher_ng::bool_absent ? {
    true    => 'absent',
    default => 'present',
  }

  if $apt_cacher_ng::bool_absent == true or $apt_cacher_ng::bool_disable == true or $apt_cacher_ng::bool_disableboot == true {
    $manage_monitor = false
  } else {
    $manage_monitor = true
  }

  if $apt_cacher_ng::bool_absent == true or $apt_cacher_ng::bool_disable == true {
    $manage_firewall = false
  } else {
    $manage_firewall = true
  }

  $manage_audit = $apt_cacher_ng::bool_audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $apt_cacher_ng::bool_audit_only ? {
    true  => false,
    false => true,
  }

  $manage_file_source = $apt_cacher_ng::source ? {
    ''      => undef,
    default => $apt_cacher_ng::source,
  }

  $manage_file_content = $apt_cacher_ng::template ? {
    ''      => undef,
    default => template($apt_cacher_ng::template),
  }

  # ## Managed resources
  package { 'apt-cacher-ng':
    ensure => $apt_cacher_ng::manage_package,
    name   => $apt_cacher_ng::package,
  }

  service { 'apt-cacher-ng':
    ensure    => $apt_cacher_ng::manage_service_ensure,
    name      => $apt_cacher_ng::service,
    enable    => $apt_cacher_ng::manage_service_enable,
    hasstatus => $apt_cacher_ng::service_status,
    pattern   => $apt_cacher_ng::process,
    require   => Package['apt-cacher-ng'],
  }

  file { 'acng.conf':
    ensure  => $apt_cacher_ng::manage_file,
    path    => $apt_cacher_ng::config_file,
    mode    => $apt_cacher_ng::config_file_mode,
    owner   => $apt_cacher_ng::config_file_owner,
    group   => $apt_cacher_ng::config_file_group,
    require => Package['apt-cacher-ng'],
    notify  => $apt_cacher_ng::manage_service_autorestart,
    source  => $apt_cacher_ng::manage_file_source,
    content => $apt_cacher_ng::manage_file_content,
    replace => $apt_cacher_ng::manage_file_replace,
    audit   => $apt_cacher_ng::manage_audit,
  }

  file { $cache_dir:
    ensure => directory,
    owner  => 'apt-cacher-ng',
    group  => 'apt-cacher-ng',
    mode   => '2755',
  }

  # The whole apt-cacher-ng configuration directory can be recursively overriden
  if $apt_cacher_ng::source_dir {
    file { 'apt-cacher-ng.dir':
      ensure  => directory,
      path    => $apt_cacher_ng::config_dir,
      require => Package['apt-cacher-ng'],
      notify  => $apt_cacher_ng::manage_service_autorestart,
      source  => $apt_cacher_ng::source_dir,
      recurse => true,
      purge   => $apt_cacher_ng::bool_source_dir_purge,
      replace => $apt_cacher_ng::manage_file_replace,
      audit   => $apt_cacher_ng::manage_audit,
    }
  }

  # ## Include custom class if $my_class is set
  if $apt_cacher_ng::my_class {
    include $apt_cacher_ng::my_class
  }

  # ## Provide puppi data, if enabled ( puppi => true )
  if $apt_cacher_ng::bool_puppi == true {
    $classvars = get_class_args()

    puppi::ze { 'apt-cacher-ng':
      ensure    => $apt_cacher_ng::manage_file,
      variables => $classvars,
      helper    => $apt_cacher_ng::puppi_helper,
    }
  }
  
  ### Service monitoring, if enabled ( monitor => true )
  if $apt_cacher_ng::bool_monitor == true {
    monitor::port { "apt-cacher-ng_${apt_cacher_ng::protocol}_${apt_cacher_ng::port}":
      protocol => $apt_cacher_ng::protocol,
      port     => $apt_cacher_ng::port,
      target   => $apt_cacher_ng::monitor_target,
      tool     => $apt_cacher_ng::monitor_tool,
      enable   => $apt_cacher_ng::manage_monitor,
    }
    monitor::process { 'apt_cacher_ng_process':
      process  => $apt_cacher_ng::process,
      service  => $apt_cacher_ng::service,
      pidfile  => $apt_cacher_ng::pid_file,
      user     => $apt_cacher_ng::process_user,
      argument => $apt_cacher_ng::process_args,
      tool     => $apt_cacher_ng::monitor_tool,
      enable   => $apt_cacher_ng::manage_monitor,
    }
  }
  
  ### Firewall management, if enabled ( firewall => true )
  if $apt_cacher_ng::bool_firewall == true {
    firewall { "apt_cacher_ng_${apt_cacher_ng::protocol}_${apt_cacher_ng::port}":
      source      => $apt_cacher_ng::firewall_src,
      destination => $apt_cacher_ng::firewall_dst,
      protocol    => $apt_cacher_ng::protocol,
      port        => $apt_cacher_ng::port,
      action      => 'allow',
      direction   => 'input',
      tool        => $apt_cacher_ng::firewall_tool,
      enable      => $apt_cacher_ng::manage_firewall,
    }
  }
}
