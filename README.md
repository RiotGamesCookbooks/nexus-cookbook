Description
===========

Installs and configures Sonatype Nexus and Nginx. Nginx is installed from source with the http\_ssl\_module.
Nginx is configured to run as a proxy for Nexus using HTTPS/SSL.

Requirements
============

Platform: 

* Ubuntu
* CentOS

The following cookbooks are dependencies:

* java
* ark
* nginx

Resources/Providers
===================

## nexus\_plugin

Installs a Nexus plugin by creating a symlink of a named plugin from the Nexus' `optional-plugins` directory into the
Nexus' `plugin-repositroy` directory.

### Actions
Action  | Description         | Default
------- |-------------        |---------
install | Installs the plugin | Yes

### Attributes
Attribute  | Description                   | Type    | Default
---------  |-------------                  |-----    |--------
name       | Name of the plugin to install | String  | name

Attributes
==========

The following attributes are set under the `nexus` namespace:

* version - sets the version to install
* user - sets the user to install nexus under
* group - sets the group to install nexus under
* url - sets the URL where the nexus package is located
* port - the port to run nexus on
* host - the hostname to use for nexus
* path - the `user` home directory
* home - the installation directory for nexus

The following attributes are set under `nexus::nginx` namespace:

* listen\_port - the port to listen on for nginx
* server\_name - the name of the nginx server
* options - used to generate options in the nginx conf file

SSL
===

The files directory contains a self-signed certificate that is installed to `nginx::dir/shared/certificates/nexus-proxy.pem`
Replace this file with your own certificates for a production environment.

Usage
=====

Simply add the "nexus::default" recipe to the node where you want Sonatype Nexus installed.

License and Author
==================

Author:: Charles Scott (<connaryscott@gmail.com>)
Author:: Greg Schueler (<greg.schueler@gmail.com>)
Author:: Seth Chisamore (<schisamo@opscode.com>)

Copyright 2011, DTO, Inc.
Copyright 2010, Opscode, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

