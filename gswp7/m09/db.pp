class pasture::db {

  class { 'postgresql::server':
    listen_addresses => '*',
  }

  postgresql::server::db { 'pasturedb':
    user     => 'pasture',
    password => postgresql_password('pasture', 'jurassic'),
  }

  postgresql::server::pg_hba_rule { 'allow entire subnet to access pasturedb':
    type        => 'host',
    database    => 'pasturedb',
    user        => 'pasture',
    address     => '192.168.248.0/24',
    auth_method => 'password',
  }
}
