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

## nexus\_repository

Resource provider for creating and deleting Neuxs repositories.

### Actions
Action  | Description              | Default
------- |-------------             |---------
create  | Creates a new repository | Yes
delete  | Deletes a repository     |
update  | Updates a repository     | 

### Attributes
Attribute  | Description                   			               | Type                  | Default
---------  |-------------                  			               |-----                  |--------
name       | Name of the repository to create/delete               | String                | name
type       | The type of repository - either "hosted" or "proxy".  | String                |
url        | The url used for a proxy repository.                  | String                |
publisher  | Whether this repository is a publisher of artifacts.  | TrueClass, FalseClass |
subscriber | Whether this repository is a subscriber to artifacts. | TrueClass, FalseClass |

## nexus\_settings

Resource provider for modifying the global Nexus settings.

### Actions
Action  | Description              						 | Default
------- |-------------             						 |---------
update  | Updates a global Nexus setting to a new value. | Yes

### Attributes
Attribute  | Description                   			 				  | Type                          | Default
---------  |-------------                  			 				  |-----                          |--------
path       | The element of the settings that is going to be changed. | String                        | name
value      | The new value to update the path to.                     | String, TrueClass, FalseClass |

## nexus\_user

Resource provider for creating, deleting, and modifying Nexus user accounts.

### Actions
Action  		| Description              						 | Default
------- 		|-------------             						 |---------
create  		| Creates a new Nexus user.                      | Yes
delete          | Deletes a Nexus user.                          | 
update          | Updates a Nexus user with updated information  |
change_password | Changes a Nexus user's password                |

### Attributes
Attribute    | Description                   			 				| Type                  | Default
---------    |-------------                  			 				|-----                  |--------
username     | The element of the settings that is going to be changed. | String                | name
first_name   | The first name of the user.                              | String                |
last_name    | The last name of the user.                               | String                |
email        | The email address of the user.                           | String                |
enabled      | Whether or not this user is enabled or disabled.         | TrueClass, FalseClass |
password     | The current (or new) password of the user.               | String                |
old_password | The old password of the user, used in change_password.   | String                |
roles        | A list of roles (permissions) to apply to the user.      | Array                 |

## nexus\_license

Resource provider for installing a license file into Nexus. This LWRP uses an encrypted data bag namespaced
under nexus license.

	knife data bag create nexus license -c <your chef config> --secret-file<your secret file>

Your data bag should look like the following:

	{
	  "id": "license"
	  "file": "<base64 encoded string of your .lic file>"
	}

It is *very important* that you base64 encode your Nexus license before storage inside the data bag.
	
	openssl base64 -in /path/to/your/license.lic

### Actions
Action   | Description              						 | Default
-------  |-------------             						 |---------
install  | Installs a license file into the server.          | Yes

### Attributes
Attribute  | Description                   			 				           | Type                          | Default
---------  |-------------                  			 				           |-----                          |--------
name       | Some useful information about the license. Similar to ruby_block. | String                        | name

## nexus\_proxy

Resource provider for manipulating the Nexus' settings for Smart Proxy.

### Actions
Action  		        | Description              						 | Default
------- 		        |-------------             						 |---------
enable  		        | Enables the Smart Proxy functionality.         | Yes
disable  		        | Disables the Smart Proxy functionality.        | 
add_trusted_key  		| Adds a trusted key to the server.              | 
delete_trusted_key  	| Removes a trusted key from the server.         | 


### Attributes
Attribute    | Description                   			 				                      | Type                  | Default
---------    |-------------                  			 				                      |-----                  |--------
name         | Some useful information about the proxy. Similar to ruby_block.                | String                | name
id           | Used for delete_trusted_key. The id of the key to delete.                      | String                |
host         | The host to use for Smart Proxy. Used for enable.                              | String                |
port         | The port to use for Smart Proxy. Used for enable.                              | Fixnum                |
certificate  | The certificate of another Nexus to add. Used for add_trusted_key.             | String                |
description  | The description of the other Nexus. Used for add_trusted_key.                  | String                |


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
* name - the name of the Nexus
* home - the installation directory for nexus. Uses name.
* conf_dir - the above home/conf
* bin_dir - the above home/bin
* work_dir - the above path/sonatype-work/nexus
* plugins - an Array of Nexus plugins that will be installed by the default recipe.
* create_repositories - an Array of repositories that will be created by the default recipe.

The following attributes are set under `nexus::nginx` namespace:

* listen\_port - the port to listen on for nginx
* server\_name - the name of the nginx server
* options - used to generate options in the nginx conf file

The following attributes are set under the `nexus::cli` namespace:

* url - The url that the nexus_cli gem will connect to. The default recipe uses this to configure itself, so localhost.
* repository - The repository that nexus_cli gem will use for push / pull operations. A requirement of nexus_cli, not used by this cookbook.
* packages - required packages to install for using the `chef_gem "nexus_cli"`

The following attributes are set under the `nexus::repository` namespace:

* create_hosted - An Array of repository names that will be used to create Hosted Repositories.
* create_proxy - A Hash of repository names to urls that will be used to create Proxy Repositories.
* publishers - An Array of repository names that will be set to publish artifacts (Smart Proxy).
* subscribers - An Array of repository names that will be set to subscribe to artifacts (Smart Proxy).

The following attributes are set under the `nexus::smart_proxy` namespace:

* enable - true if we want to enable Smart Proxy, false if not.
* host - The host to use for Smart Proxy configuration.
* port - The port to use for Smart Proxy configuration.

SSL
===

The files directory contains a self-signed certificate and key that are installed to `nginx::dir/shared/certificates/nexus-proxy.crt` 
and `nginx::dir/shared/certificates/nexus-proxy.key`.

By default, the cookbook will look for a ssl_certificate encrypted data bag:

	knife data bag create nexus ssl_certificate -c <your chef config> --secret-file=<your secret file>

Your data bag should look like the following:

	{
      "id": "ssl_certificate",
      "fully-qualified-domain-name": {
        "crt": "base64-encoded-ssl-certificate",
        "key": "base64-encoded-private-key"
      },
      ...
    }

The cookbook will look for an entry for your node[:fqdn] in the data bag, and if found, will get the certificate and key,
base64 decode them, and write them using the `file` resource. If there is no entry in the data bag, the default action will
use the `cookbook_file` resource to copy the self-signed certificate and key and install them.

Nexus Usage
===========

Many of the LWRPs utilize the Nexus CLI gem to interact with the Nexus server. In order to use them, you must first
create an [encrypted data bag](http://wiki.opscode.com/display/chef/Encrypted+Data+Bags) that contains the credentials
for your Nexus server.

	knife data bag create nexus credentials -c <your chef config> --secret-file=<your secret file>

Your data bag should look like the following:

	{
	  "id": "credentials",
	  "default_admin": {
	    "username": "admin",
	    "password": "admin123"
	  },
	  "updated_admin": {
	    "username": "admin",
	    "password": "customize_me"
	  }
	}

Out-of-the-box, Nexus comes configured with a specific administrative username/password combo. The default recipe
change the password for that account to the password configured in the `updated_admin` element.

Smart Proxy Usage
=================

When Smart Proxy is enabled (`nexus::pro` recipe), repositories need to be set to become publishers or subscribers. In
addition, we need to store the certificates of other Nexus servers on the server that Smart Proxy is being enabled on.

	knife data bag create nexus certificates -c <your chef config> --secret-file=<your secret file>

Your data bag will store a certificate and description based on the IP address of other Nexus servers and should look like the following:

	{
	  "id": "certificates",
	  "192.168.0.1": {
	    "certificate": "-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----\n",
	    "description": "192.168.0.1 Trusted Key"
	  },
      "192.168.0.2": {
        "certificate": "-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----\n",
        "description": "192.168.0.2 Trusted Key"
      }
	}

Override the `nexus::repository` attributes to set these appropriately for your Nexus.

Usage
=====

Simply add the "nexus::default" recipe to the node where you want Sonatype Nexus installed.

To install Nexus Pro and perform some extra steps, use the "nexus::pro" recipe. Most likely, all you'll need is
to override the following attributes like so:

    :nexus => {
      :version => '2.1.2',
      :checksum => 'new checksum',
      :url => 'some/url/to/nexus-professional-2.1.2-bundle.tar.gz',
    }

License and Author
==================

Author:: Kyle Allan (<kallan@riotgames.com>)
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

