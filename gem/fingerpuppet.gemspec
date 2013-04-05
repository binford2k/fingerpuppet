Gem::Specification.new do |s|
  s.name              = "fingerpuppet"
  s.version           = '0.0.3'
  s.date              = "2013-04-05"
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
`fingerpuppet` is a simple library and commandline tool to interact with Puppet's REST API
without needing to have Puppet itself installed. This may be integrated, for example,
into a provisioning tool to allow your provisioning process to remotely sign certificates
of newly built systems. Alternatively, you could use it to request known facts about
a node from your Puppet Master, or even to request a catalog for a node to, for example,
perform acceptance testing against a new version of Puppet before upgrading your
production master.

Install the binford2k/fingerpuppet puppet module to get a class that can automatically
configure your `auth.conf` file under Puppet Enterprise, where that file is managed.
  desc
end
