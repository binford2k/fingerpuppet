Introduction
============

`fingerpuppet` is a simple library and commandline tool to interact with Puppet's REST API
without needing to have Puppet itself installed. This may be integrated, for example,
into a provisioning tool to allow your provisioning process to remotely sign certificates
of newly built systems. Alternatively, you could use it to request known facts about
a node from your Puppet Master, or even to request a catalog for a node to, for example,
perform acceptance testing against a new version of Puppet before upgrading your
production master.

Limitations
============

This is still in early development. Features may not work completely as advertised, and will
certainly be less polished than an established product. Pull requests are welcome!


Usage
============

`fingerpuppet [commandstring]`

Steps for using the API with fingerpuppet:

1. `fingerpuppet --init --certname my.cert.name --server my.server.name`
    * Builds the config file
    * Generates the certificate and CSR
    * Submits the CSR to the Puppetmaster
2. On puppetmaster: `puppet cert sign my.cert.name`
3. `fingerpuppet --install`
    * Downloads the signed certificate and installs it
4. ...
5. Profit!

Your Puppetmaster must be configured to allow requests other than certificate requests.
See [http://docs.puppetlabs.com/guides/rest_auth_conf.html](http://docs.puppetlabs.com/guides/rest_auth_conf.html) for more information.

An example `auth.conf` might look something like:

    path ~ ^/catalog/([^/]+)$
    method find
    auth yes
    allow $1, provisioner.example.com
    
    path ~ ^/node/([^/]+)$
    method find
    auth yes
    allow $1, provisioner.example.com
    
    path  /certificate_revocation_list/ca
    method find
    auth yes
    allow *
    
    path  /report
    method save
    auth yes
    allow *
    
    path  /file
    auth yes
    allow *

    path  /resource
    method find
    auth any
    allow provisioner.example.com
    
    path  /status
    method find
    auth any
    allow provisioner.example.com
    
    path  /certificate/ca
    method find
    auth any
    allow *
    
    path  /certificate/
    method find
    auth any
    allow *
    
    path  /certificate_request
    method find, save
    auth any
    allow *
    
    path  /certificate_status
    method find, search, save, destroy
    auth yes
    allow pe-internal-dashboard, provisioner.example.com
    
    path  /facts
    method find, search
    auth any
    allow *
    
    path  /facts
    method save
    auth yes
    allow master.puppetlabs.vm, provisioner.example.com
    
    path  /
    auth any

The certname can be specified with `--certname` or with optional `CERTNAME` argument to many options.

You may want to use the `-dcn` options to print the cURL equivalent command.

    -d, --debug                      runs in debug mode
    -h, --help                       Displays this help
    -c, --curl                       Use commandline curl rather than Net::HTTP.
    -n, --nop                        No-Op mode. Don't perform action, just output debugging data. Implies --debug.

        --server SERVER              The server address of your Puppetmaster.
        --certname CERTNAME          The certname you wish to use when connecting to your Puppetmaster
        --file FILENAME              The file to send to the Puppetmaster.
        --output FILENAME            The file to save any output to.
        --state STATE                The desired state you want to set.

        --init                       Initialize application. Generate config file, certificate and submit CSR. Requires --certname and --server.
        --install                    Download and install signed certificate.

        --catalog                    Download the catalog compiled for your app's certname. Quite often just the default Node.
        --delete [CERTNAME]          Remove certificate and facts about a node from Puppetmaster.
        --facts [CERTNAME]           Retrieve the facts known about a given certname.
        --insert [CERTNAME]          Send facts for a given certname to the Puppetmaster. Requires --file.
        --node [CERTNAME]            Retrieve the node information (including facts) known about a given certname.
        --search QUERY               Retrieve the nodes matching a comma separated query string (e.g. kernel=Linux,virtual=vmware)

        --certificate [CERTNAME]     Retrieve the certificate for a given certname or 'ca'.
        --cert_status [CERTNAME]     Retrieve the certificate status for a given certname. Set the status by using --state.
        --cert_revocation_list       Retrieve and display the certifiacte revocation list from the master.
        --sign [CERTNAME]            Instruct the Puppetmaster to sign a certificate. Requires significant privileges in auth.conf.

        --file_metadata PATH         Retrieve the metadata for a file.
        --getfile PATH               Download a file from the Puppetmaster. Save to --file or output on stdout.

        --resource RESOURCE          Returns a list of resources (e.g. user) or information about a resource (e.g. 'user/elvis')
        --report [CERTNAME]          Sends a YAML report to the Puppetmaster. Requires --file or --state.
        --status                     Check to make sure the Puppetmaster is alive and well.

Contact
=======

* Author: Ben Ford
* Email: ben.ford@puppetlabs.com
* Twitter: @binford2k
* IRC (Freenode): binford2k

License
=======

Copyright (c) 2012 Puppet Labs, info@puppetlabs.com

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.