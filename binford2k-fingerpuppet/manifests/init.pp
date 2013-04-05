class fingerpuppet {
  package { 'fingerpuppet':
    ensure   => present,
    provider => gem,
  }
}
