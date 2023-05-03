class profile::pasture::app {
  $host_name = $facts['fqdn']
  $message   = "Welcome to ${host_name}."

  if $host_name =~ 'macro' {
    $default_animal    = 'daemon'
    $database          = 'postgres://pasture:jurassic@192.168.248.115/pasturedb'
    $web_server        = 'thin'
  } elsif $host_name =~ 'micro' {
    $default_animal    = 'koala'
    $database          = 'none'
    $web_server        = 'webrick'
  } else {
    fail("The ${host_name} node name must match 'macro' or 'micro'.")
  }

  class { 'pasture':
    default_message   => $message,
    sinatra_server    => $web_server,
    default_character => $default_animal,
    db                => $database,
  }
}
