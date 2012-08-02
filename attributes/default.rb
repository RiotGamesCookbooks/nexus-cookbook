default[:nexus][:version]                                      = '2.0.5'
default[:nexus][:user]                                         = 'nexus'
default[:nexus][:group]                                        = 'nexus'
default[:nexus][:url]                                          = "http://www.sonatype.org/downloads/nexus-#{nexus['version']}-bundle.tar.gz"

default[:nexus][:port]                                         = '8081'
default[:nexus][:host]                                         = '0.0.0.0'
default[:nexus][:path]                                         = '/nexus'

default[:nexus][:name]                                         = 'nexus'
default[:nexus][:home]                                         = "/usr/local/#{default['nexus']['name']}"

default[:nexus][:nginx_proxy][:listen_port]                    = 8443
default[:nexus][:nginx_proxy][:server_name]                    = 'localhost'

default[:nexus][:plugins]                                      = ['nexus-custom-metadata-plugin']

default[:nginx][:configure_flags]                              = 'with-http_ssl_module'

default[:nexus][:nginx][:options][:client_max_body_size]       = '200M'
default[:nexus][:nginx][:options][:client_body_buffer_size]    = '512k'