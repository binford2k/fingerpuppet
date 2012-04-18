#!/usr/bin/env ruby

require 'optparse'
require 'restapi.rb'

options = {}
optparse = OptionParser.new { |opts|
	opts.banner = "Usage : restapi.rb <commandstring>

		Steps for using the API:
			1:) restapi.rb --init --certname my.cert.name --server my.server.name
					Builds the config file
					Generates the certificate and CSR
					Submits the CSR to the Puppetmaster

			2:) On puppetmaster: puppet cert sign my.cert.name

			3:) restapi.rb --install
					Downloads the signed certificate and installs it

			4:) ...

			5:) Profit!

		Your Puppetmaster must be configured to allow requests other than certificate requests.
		See http://docs.puppetlabs.com/guides/rest_auth_conf.html for more information.

		The certname can be specified with --certname or with optional CERTNAME argument to many options. 

"
 
	options[:show]=false
	opts.on("-d", "--debug", "runs in debug mode") do |debug|
		options[:debug] = true
		#restAPI.debug
	end

	opts.on("-h", "--help", "Displays this help") do
		puts opts
		exit
	end

	opts.on("--server SERVER", "The server address of your Puppetmaster.") do |server|
		options[:server] = server
	end

	opts.on("--certname CERTNAME", "The certname you wish to use when connecting to your Puppetmaster") do |certname|
		options[:certname] = certname
	end

	opts.on("--file FILENAME", "The filename for use by other options.") do |filename|
		options[:filename] = filename
	end

	opts.on("--state STATE", "The desired state you want to set.") do |state|
		options[:state] = state
	end

	opts.separator('')

	opts.on("--init", "Initialize application. Generate config file, certificate and submit CSR. Requires --certname and --server.") do
		options[:action] = 'init'
	end

	opts.on("--install", "Download and install signed certificate.") do
		options[:action] = 'install'
	end

	opts.separator('')

	opts.on("--catalog", "Download the catalog compiled for your app's certname. Quite often just the default Node.") do
		options[:action] = 'catalog'
	end

	opts.on("--delete [CERTNAME]", "Remove certificate and facts about a node from Puppetmaster.") do |certname|
		options[:action] = 'delete'
		options[:certname] ||= certname
	end

	opts.on("--facts [CERTNAME]", "Retrieve the facts known about a given certname.") do |certname|
		options[:action] = 'facts'
		options[:certname] ||= certname
	end

	opts.on("--insert [CERTNAME]", "Send facts for a given certname to the Puppetmaster. Requires --file.") do |certname|
		options[:action] = 'insert'
		options[:certname] ||= certname
	end

	opts.on("--node [CERTNAME]", "Retrieve the node information (including facts) known about a given certname.") do |certname|
		options[:action] = 'node'
		options[:certname] ||= certname
	end

	opts.on("--search QUERY", Array, "Retrieve the nodes matching a comma separated query string (e.g. kernel=Linux,virtual=vmware)") do |query|
		options[:action] = 'search'
		options[:query]  = query
	end

	opts.separator('')

	opts.on("--certificate [CERTNAME]", "Retrieve the certificate for a given certname or 'ca'.") do |certname|
		options[:action] = 'certificate'
		options[:certname] ||= certname
	end

	opts.on("--cert_status [CERTNAME]", "Retrieve the certificate status for a given certname. Set the status by using --status.") do |certname|
		options[:action] = 'certificate_status'
		options[:certname] ||= certname
	end

	opts.on("--cert_revocation_list", "Retrieve and display the certifiacte revocation list from the master.") do
		options[:action] = 'certificate_revocation_list'
	end

	opts.on("--sign [CERTNAME]", "Instruct the Puppetmaster to sign a certificate. Requires significate privileges in auth.conf.") do |certname|
		options[:action] = 'sign'
		options[:certname] ||= certname
	end

	opts.separator('')

	opts.on("--file_metadata PATH", "Retrieve the metadata for a file.") do |path|
		options[:action] = 'file_metadata'
		options[:argument] = path
	end

	opts.on("--getfile PATH", "Download a file from the Puppetmaster. Save to --file or output on stdout.") do |path|
		options[:action] = 'getfile'
		options[:argument] = path
	end

	opts.separator('')

	opts.on("--resource RESOURCE", "Returns a list of resources (e.g. user) or information about a resource (e.g. 'user/elvis')") do |resource|
		options[:action] = 'resource'
		options[:argument] = resource
	end

	opts.on("--report [CERTNAME]", "Sends a YAML report to the Puppetmaster. Requires --file.") do |certname|
		options[:action] = 'report'
		options[:certname] ||= certname
	end

	opts.on("--status", "Check to make sure the Puppetmaster is alive and well.") do
		options[:action] = 'status'
	end
}

begin
	optparse.parse!

	restAPI = RestAPI.new(options[:debug])
	# if certname isn't specified, let's default to our certname, except for init
	if options[:action] != 'init'
		options[:certname] ||= restAPI.certname
	end

	case options[:action]
		when 'init'
			restAPI.init(options[:certname], options[:server])
		when 'install'
			restAPI.install
		when 'catalog'
			restAPI.catalog
		when 'status'
			restAPI.status
		when 'facts'
			restAPI.facts(options[:certname])
		when 'node'
			restAPI.node(options[:certname])
		when 'search'
			restAPI.search(options[:query])
		when 'insert'
			restAPI.insert(options[:certname], options[:filename])
		when 'delete'
			restAPI.delete(options[:certname])
		when 'file_metadata'
			restAPI.file_metadata(options[:argument])			
		when 'getfile'
			restAPI.getfile(options[:argument], options[:filename])
		when 'certificate'
			restAPI.certificate(options[:certname])
		when 'sign'
			restAPI.sign(options[:certname])
		when 'certificate_status'
			restAPI.certificate_status(options[:certname], options[:state])
		when 'certificate_revocation_list'
			restAPI.certificate_revocation_list
		when 'resource'
			restAPI.resource(options[:argument])
		when 'report'
			restAPI.report(options[:certname], options[:filename])
		else
			puts 'Use -h/--help for usage documentation.'
	end		
rescue Exception => e
	puts e
end
