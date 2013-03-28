Gem::Specification.new do |s|
  s.name              = "fingerpuppet"
  s.version           = '0.0.1'
  s.date              = "2013-03-28"
  s.summary           = "A simple library and tool to interact with Puppet's REST API without needing Puppet itself installed."
  s.homepage          = "http://github.com/binford2k/fingerpuppet"
  s.email             = "binford2k@gmail.com"
  s.authors           = ["Ben Ford"]
  s.has_rdoc          = false
  s.require_path      = "lib"
  s.executables       = %w( fingerpuppet )
  s.files             = %w( README.md LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.description       = <<-desc
  A simple library and tool to interact with Puppet's REST API without needing Puppet itself installed.
  desc
end