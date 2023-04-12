class pasture::base {

  package { 'gem':
    ensure => present,
    before => [Package['cowsay'],Package['thin']],
  }

  package { 'epel-release':
    ensure => present,
    before => Package['rubygem-thin'],
  }

  package { 'ruby-devel':
    ensure => present,
  }

  package { 'postgresql-devel':
    ensure => present,
  }

  package { 'rubygem-thin':
    ensure => present,
  }

  package { 'cowsay':
    ensure   => present,
    provider => 'gem',
  }

  package { 'thin':
    ensure   => present,
    provider => 'gem',
  }
}
