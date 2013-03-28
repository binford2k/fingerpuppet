Usage : fingerpuppet <commandstring>

        Steps for using the API:
            1:) fingerpuppet --init --certname my.cert.name --server my.server.name
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

        You may want to use the '-dcn' options to print the cURL equivalent command.

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
        --sign [CERTNAME]            Instruct the Puppetmaster to sign a certificate. Requires significate privileges in auth.conf.

        --file_metadata PATH         Retrieve the metadata for a file.
        --getfile PATH               Download a file from the Puppetmaster. Save to --file or output on stdout.

        --resource RESOURCE          Returns a list of resources (e.g. user) or information about a resource (e.g. 'user/elvis')
        --report [CERTNAME]          Sends a YAML report to the Puppetmaster. Requires --file or --state.
        --status                     Check to make sure the Puppetmaster is alive and well.
