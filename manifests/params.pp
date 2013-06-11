class apt_cacher_ng::params {
  $package = $::operatingsystem ? {
    default => 'apt-cacher-ng',
  }

  $service = $::operatingsystem ? {
    default => 'apt-cacher-ng',
  }

  $service_status = $::operatingsystem ? {
    default => true,
  }

  $process = $::operatingsystem ? {
    default => 'apt-cacher-ng',
  }

  $process_args = $::operatingsystem ? {
    default => '',
  }

  $process_user = $::operatingsystem ? {
    default => 'apt-cacher-ng',
  }

  $config_dir = $::operatingsystem ? {
    default => '/etc/apt-cacher-ng',
  }

  $config_file = $::operatingsystem ? {
    default => '/etc/apt-cacher-ng/acng.conf',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_init = $::operatingsystem ? {
    default => '/etc/default/apt-cacher-ng',
  }

  $pid_dir = $::operatingsystem ? {
    default => '/var/run/apt-cacher-ng',
  }

  $pid_file = $::operatingsystem ? {
    default => '/var/run/apt-cacher-ng/pid',
  }

  $log_dir = $::operatingsystem ? {
    default => '/var/log/apt-cacher-ng',
  }

  $log_file = $::operatingsystem ? {
    default => '/var/log/apt-cacher-ng/apt-cacher.log',
  }
  
  $err_file = $::operatingsystem ? {
    default => '/var/log/apt-cacher-ng/apt-cacher.err',
  }

  $cache_dir = $::operatingsystem ? {
    default => '/var/cache/apt-cacher-ng',
  }

  $port = '3142'
  $protocol = 'tcp'

  # General Settings
  $my_class = ''
  $source = ''
  $source_dir = ''
  $source_dir_purge = false
  $template = 'apt_cacher_ng/acng.conf.erb'
  $options = ''
  $service_autorestart = true
  $absent = false
  $disable = false
  $disableboot = false

  # ## General module variables that can have a site or per module default
  $monitor = false
  $monitor_tool = ''
  $monitor_target = $::ipaddress
  $firewall = false
  $firewall_tool = ''
  $firewall_src = '0.0.0.0/0'
  $firewall_dst = $::ipaddress
  $puppi = false
  $puppi_helper = 'standard'
  $debug = false
  $audit_only = false
}