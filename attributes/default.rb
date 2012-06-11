default['nexus']['port'] = '8080'
default['nexus']['version'] = '2.0.5'
default['nexus']['user'] = 'nexus'
default['nexus']['group'] = 'nexus'
default['nexus']['url'] = "http://www.sonatype.org/downloads/nexus-#{nexus['version']}-bundle.tar.gz"
default['nexus']['binaries'] = ['bin/nexus']
