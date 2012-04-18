require 'yaml'
require "net/https"

class RestAPI
    attr_accessor :server, :certname

    def initialize(dbg = false, usecurl=false)
        @debug = dbg
        @curl = usecurl
        @configdir = File.expand_path('~/.restapi')

        begin
            config = YAML.load_file("#{@configdir}/config.yaml")
            @server   = config['server']
            @certname = config['certname']
        rescue Exception => e
            puts 'Initializing API...'
        end
    end

    def command( opts={} )
        if @curl
            curl(opts)
        else
            uri = "/production/#{opts[:action]}/#{opts[:argument]}"

            http = Net::HTTP.new(@server, 8140)
            http.use_ssl = true

            unless opts[:noauth]
                http.verify_mode = OpenSSL::SSL::VERIFY_PEER

                store = OpenSSL::X509::Store.new
                store.add_cert(OpenSSL::X509::Certificate.new(File.read("#{@configdir}/ca_crt.pem")))
                http.cert_store = store

                http.key = OpenSSL::PKey::RSA.new(File.read("#{@configdir}/#{@certname}.key"))
                http.cert = OpenSSL::X509::Certificate.new(File.read("#{@configdir}/#{@certname}.pem"))
            end

            case opts[:method]
                when 'PUT'
                    request = Net::HTTP::Put.new(uri)
                    request["Content-Type"] = "text/#{opts[:type]}"

                    if opts[:file]
                        # set the body to the binary contents of :file
                        file = File.open(opts[:file], 'rb')
                        request.body = file.read
                    else
                        # set the body to the string value of :data
                        request.body = opts[:data]
                    end

                when 'DELETE'
                    request = Net::HTTP::Delete.new(uri)
                when 'HEAD'
                    request = Net::HTTP::Head.new(uri)
                else
                    # default to a GET request
                    request = Net::HTTP::Get.new(uri)
            end

            request["Accept"] = opts[:type] || 'yaml'

            if @debug
                puts request.to_yaml
            else
                response = http.request(request)

                if opts[:output]
                    file = File.new(opts[:output], 'w')
                    file.syswrite(response.body)
                    file.close
                else
                    puts response.body
                end
            end
        end
    end

    #def command(action, argument='', method='GET', type='yaml', output=false, file=false, data=false)
    def curl( opts={} )
        opts[:method] ||= 'GET'
        opts[:type] ||= 'yaml'

        if opts[:noauth]
            auth = '-k '
        else
            auth = "--cert #{@configdir}/#{@certname}.pem --key #{@configdir}/#{@certname}.key --cacert #{@configdir}/ca_crt.pem"
        end

        output = opts[:output] ? "-o #{opts[:output]}" : ''
        header = "-H 'Accept: #{opts[:type]}'"
        
        case opts[:method]
            when 'GET'
                methodstr = ''
            when 'PUT'
                methodstr = '-X PUT'
                header = "-H 'Content-Type: text/#{opts[:type]}'"

                if opts[:file]
                    filestr   = "--data-binary @#{opts[:file]}"
                end

                if opts[:data]
                    datastr   = "--data '#{opts[:data]}'"
                end

            when 'DELETE'
                methodstr = '-X DELETE'
            when 'HEAD'
                methodstr = '-I'
        end

        uri = "https://#{@server}:8140/production/#{opts[:action]}/#{opts[:argument]}"
        cmd = "curl #{auth} #{methodstr} #{output} #{filestr} #{datastr} #{header} \"#{uri}\"" #quoted uri for fact ampersands
        if @debug
            puts cmd
        else
            if not system(cmd)
                raise StandardError, 'cURL execution failed.'
            end
            puts # newline after curl output
        end
    end

    def init(certname, server)
        if certname == nil || server == nil
            puts "Must set server and certname to initialize API"
            exit
        end

        @certname = certname
        @server = server

        if File::directory?( @configdir )
            require 'fileutils'
            FileUtils.rm_rf( @configdir )
        end

        Dir.mkdir( @configdir )
        configfile = File.new("#{@configdir}/config.yaml", 'w')
            configfile.syswrite("version: 0.1\n")
            configfile.syswrite("certname: #{@certname}\n")
            configfile.syswrite("server: #{@server}\n")
        configfile.close

        begin
            if not system("openssl genrsa -out #{@configdir}/#{@certname}.key 1024")
                raise StandardError, 'Certificate generation failed.'
            end

            if not system("openssl req -new -key #{@configdir}/#{@certname}.key -subj '/CN=#{@certname}' -out #{@configdir}/#{@certname}.csr")
                raise StandardError, 'CSR generation failed.'
            end

            self.command( { :action => 'certificate_request',
                            :argument => @certname,
                            :file => "#{@configdir}/#{@certname}.csr",
                            :type => 'plain',
                            :method => 'PUT',
                            :noauth => true } )

            puts "CSR submitted. Now go sign it on the server and rerun this with --install."
        rescue Exception => e
            puts "Failure: #{e.message}"
        end
    end

    def install
        begin
            self.command( { :action => 'certificate',
                            :argument => @certname,
                            :output => "#{@configdir}/#{@certname}.pem",
                            :type => 's',
                            :noauth => true } )

            self.command( { :action => 'certificate',
                            :argument => 'ca',
                            :output => "#{@configdir}/ca_crt.pem",
                            :type => 's',
                            :noauth => true } )

            puts "Certificate installed. API ready for use."
        rescue Exception => e
            puts "Failure: #{e.message}"
        end
    end

    def catalog
        self.command( { :action => 'catalog', 
                        :argument => @certname } )
    end

    def status
        self.command( { :action => 'status', 
                        :argument => 'no_key' } )
    end

    def facts(node)
        self.command( { :action => 'facts', 
                        :argument => node } )
    end

    def search(query)
        query.map!{ |item| "facts.#{item}"}
        self.command( { :action => 'facts_search', 
                        :argument => "search?#{query.join('&')}" } )
    end

    def node(node)
        self.command( { :action => 'node', 
                        :argument => node } )
    end

    def insert(node, path)
        self.command( { :action => 'facts', 
                        :argument => node, 
                        :method => 'PUT', 
                        :file => path } )
    end

    def file_metadata(path)
        self.command( { :action => 'file_content',
                        :argument => path,
                        :type => 'yaml' } )
    end

    def getfile(path, filename=nil)
        self.command( { :action => 'file_content',
                        :argument => path,
                        :type => 'raw',
                        :output => filename } )
    end

    def delete(node)
        self.certificate_status(node, 'revoked')
        self.command( { :action => 'certificate_status', 
                        :argument => node, 
                        :method => 'DELETE', 
                        :type => 'pson' } )
    end

    def certificate(node)
        self.command( { :action => 'certificate', 
                        :argument => node, 
                        :type => 's' } )
    end

    def sign(node)
        self.command( { :action => 'certificate_status', 
                        :argument => node, 
                        :method => 'PUT', 
                        :type => 'pson',
                        :noauth => true, 
                        :data => "{\"desired_state\":\"signed\"}" } )
    end

    def certificate_revocation_list
        self.command( { :action => 'certificate_revocation_list', 
                        :argument => 'ca', 
                        :type => 's' } )
    end

    def certificate_status(node, state=nil)
        if node == nil
            self.command( { :action => 'certificate_statuses', 
                            :action => 'no_key', 
                            :type => 'pson' } )
        elsif state == nil
            self.command( { :action => 'certificate_status', 
                            :argument => node, 
                            :type => 'pson' } )
        else
            self.command( { :action => 'certificate_status', 
                            :argument => node, 
                            :method => 'PUT', 
                            :type => 'pson', 
                            :data => "{\"desired_state\":\"#{state}\"}" } )
        end
    end

    def resource(resource)
        self.command( { :action => 'resource', 
                        :argument => resource } )
    end

    def report(node, file)
        self.command( { :action => 'report', 
                        :argument => node, 
                        :method => 'PUT', 
                        :file => file } )
    end

    def debug
        puts "@configdir: #{@configdir}"
        puts "   @server: #{@server}"
        puts " @certname: #{@certname}"
    end
end
