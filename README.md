Description
===========

Installs and configures Sonatype Nexus. Can optionally configure and install an nginx installation or provide
SSL access to the Jetty server that runs Nexus.

Requirements
============

Platform: 

* Ubuntu
* CentOS

The following cookbooks are dependencies:

* java
* ark
* nginx
* artifact
* build-essential

Recipes
=======

* default - installs and configures a Nexus installation
* nginx - installs and configures an nginx server that will proxy the Nexus server with SSL
* cli - installs packages at compilation time and uses `chef_gem` to instal the nexus_cli gem. Primarily used by the LWRPs of this cookbook.
* group, hosted, proxy - recipe abstractions that get the appropriate entry from the data bag item and create repositories on the Nexus server.

Usage
=====

Simply add the `nexus::default` recipe to the node where you want Sonatype Nexus installed.

Data Bags
=========

As of version 1.0.0, this cookbook now uses fewer, more standardized Encrypted Data Bags. Following the style used 
at Riot, Data bags are created per Chef Environment and default to a data bag item named "_wildcard" if there is no environmental
data bag item. 

The biggest changes to v1.0.0 are the combination of the Nexus credentials, license, and *_repositories data bags into one.

Below is how you should create your data bags for using this cookbook:
    
    knife data bag create nexus _wildcard -c your/chef/config --secret-file your/encrypted_data_bag_key

    {
      "id": "_wildcard",
      "credentials": {
        "default_admin": {
          "username": "admin",
          "password": "admin123"
        },
        "updated_admin": {
          "username": "admin",
          "password": "new_password"
        }
      },
      "license": {
        "file": "base64d license file"
      },
      "group_repositories": {
        "repositories": [
          {
            "name": "My Group",
            "add": [
              "Releases",
              "Snapshots"
            ]
          }
        ]
      },
      "hosted_repositories": {
        "repositories": [
          {
            "name": "Hosted Files"
          },
          {
            "name": "More Hosted Files",
            "publisher": true
          }
        ]
      },
      "proxy_repositories": {
        "repositories": [
          {
            "name": "Proxy Repo",
            "url": "http://some-remote-repository"
          },
          {
            "name": "Another Proxy Repo",
            "url": "http://some-other-remote-repository",
            "subscriber": true,
            "publisher": true
          }
        ]
      }
    }

The `nexus_ssl_certificates` data bag replaces the old `ssl_certificate` data bag item. The cookbook is also set up to look for
Chef environment named items inside this data bag.

Once the data bag item is loaded for the environment, the attribute [:nexus][:ssl_certificate][:key] is used to find an entry. The
default value for the cookbook is the node's fqdn. Using this format, you can have a Chef environment with multiple Nexus servers that
may need to use different SSL certificates.

Your data bag items should look like the following:

    knife data bag create nexus_ssl_certificates _wildcard -c your/chef/config --secret-file your/encrypted_data_bag_key

    {
      "id": "_wildcard",
      "fully-qualified-domain-name": {
        "crt": "base64-encoded-ssl-certificate",
        "key": "base64-encoded-private-key"
      }
    }

The `nexus_trusted_certificates` data bag replaces the old `certificates` data bag item. Each Chef environment maintains a data
bag item for this data bag, and each entry inside the item should be keyed to a node's fully qualified domain name.

    knife data bag create nexus_trusted_certificates _wildcard -c your/chef/config --secret-file your/encrypted_data_bag_key

    {
      "id": "_wildcard",
      "fully-qualified-domain-name": {
        "description": "Trusted key for full-qualified-domain-name",
        "certificate": "base64d Certificate from the Nexus Smart Proxy panel"
      }
    }


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
Attribute        | Description                                                         | Type                  | Default
---------        |-------------                                                        |-----                  |--------
name             | Name of the repository to create/delete                             | String                | name
type             | The type of repository - either "hosted" or "proxy".                | String                |
url              | The url used for a proxy repository.                                | String                |
publisher        | Whether this repository is a publisher of artifacts.                | TrueClass, FalseClass |
subscriber       | Whether this repository is a subscriber to artifacts.               | TrueClass, FalseClass |
preemptive_fetch | Whether this (proxy) repository should preemptively fetch artifacts | TrueClass, FalseClass |

## nexus\_settings

Resource provider for modifying the global Nexus settings.

### Actions
Action  | Description                          | Default
------- |-------------                         |---------
update  | Updates a global Nexus setting to a new value. | Yes

### Attributes
Attribute  | Description                                  | Type                          | Default
---------  |-------------                                 |-----                          |--------
path       | The element of the settings that is going to be changed. | String                        | name
value      | The new value to update the path to.                     | String, TrueClass, FalseClass |

## nexus\_user

Resource provider for creating, deleting, and modifying Nexus user accounts.

### Actions
Action          | Description                                    | Default
-------         |-------------                                   |---------
create          | Creates a new Nexus user.                      | Yes
delete          | Deletes a Nexus user.                          | 
update          | Updates a Nexus user with updated information  |
change_password | Changes a Nexus user's password                |

### Attributes
Attribute    | Description                                              | Type                  | Default
---------    |-------------                                             |-----                  |--------
username     | The element of the settings that is going to be changed. | String                | name
first_name   | The first name of the user.                              | String                |
last_name    | The last name of the user.                               | String                |
email        | The email address of the user.                           | String                |
enabled      | Whether or not this user is enabled or disabled.         | TrueClass, FalseClass |
password     | The current (or new) password of the user.               | String                |
old_password | The old password of the user, used in change_password.   | String                |
roles        | A list of roles (permissions) to apply to the user.      | Array                 |

## nexus\_license

Resource provider for installing a license file into Nexus. 

### Actions
Action   | Description                                       | Default
-------  |-------------                                      |---------
install  | Installs a license file into the server.          | Yes

### Attributes
Attribute  | Description                                                       | Type                          | Default
---------  |-------------                                                      |-----                          |--------
name       | Some useful information about the license. Similar to ruby_block. | String                        | name

## nexus\_proxy

Resource provider for manipulating the Nexus' settings for Smart Proxy.

### Actions
Action              | Description                                    | Default
-------             |-------------                                   |---------
enable              | Enables the Smart Proxy functionality.         | Yes
disable             | Disables the Smart Proxy functionality.        | 
add_trusted_key     | Adds a trusted key to the server.              | 
delete_trusted_key  | Removes a trusted key from the server.         | 


### Attributes
Attribute    | Description                                                                    | Type                  | Default
---------    |-------------                                                                   |-----                  |--------
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
* checksum - The SHA256 checksum of the Nexus installation package
* port - the port to run nexus on
* host - the hostname to use for nexus
* context_path - the context path under which Nexus is running under. ie. "/nexus" #=> "http://localhost:8081/nexus"
* name - the name of the Nexus
* bundle_name - the name of the internal folder of the Nexus tar. Usually nexus-{professional or nothing}-{VERSION}
* home - the installation directory for nexus. Uses name.
* current_path - the above home/current/bundle_name. The artifact_deploy resource uses the `current` symlink to denote the currently installed version.
* pid_dir - the pid directory defined in the nexus.erb template. Saves a pid in the `pids` directory created by the artifact_deploy resource.
* conf_dir - the above home/conf
* bin_dir - the above home/bin
* work_dir - the above path/sonatype-work/nexus
* plugins - an Array of Nexus plugins that will be installed by the default recipe.

The following attribute is set under the `nexus::jetty` namespace:

* loopback - if true, the jetty.xml.erb will be written to disable access to anything but localhost. Useful for enabling access to Nexus via Jetty's HTTP connection.

The following attributes are set under the `nexus::ssl` namespace and are related to the SSL settings of Nexus:

* jetty - if true, the default recipe will configure Nexus to use Jetty's SSL connection.
* nginx - if true, the default recipe will include the `nexus::nginx` recipe, installing and configuring an nginx SSL proxy server.
* jetty_keystore_path - used for configuring where on the machine the keystore file will be that Jetty will use for its SSL configuration.
* verify - if true, the calls in the chef_nexus.rb library will verify SSL connections. This is useful to disable when working with a self-signed certificate.
* port - the default port for either Jetty or nginx SSL connections.

* ssl\_certificate::key - the key to look for in the `nexus::ssl_certificate` encrypted data bag.

The following attributes are set under `nexus::nginx` namespace:

* server\_name - the name of the nginx server.
* server::options - used to generate options in the `server` section of the nginx conf file.
* proxy::options - used to generate proxy options in the `location` section of the nginx conf file.

The following attributes are set under the `nexus::cli` namespace:

* url - The url that the nexus_cli gem will connect to. The default recipe uses this to configure itself, so localhost.
* repository - The repository that nexus_cli gem will use for push / pull operations. A requirement of nexus_cli, not used by this cookbook.
* packages - required packages to install for using the `chef_gem "nexus_cli"`

The following attributes are not fully supported but are under the `nexus::mount` namespace:

* nfs::enable - enables an NFS mount.
* nfs::mount\_point - the local path to mount an NFS drive to.
* nfs::device\_path - the remote server where the NFS drive is located.

License and Author
==================

Author:: Kyle Allan (<kallan@riotgames.com>)
Based on work by Joseph Holsten (<joseph@josephholsten.com>), Charles Scott (<connaryscott@gmail.com>),
Greg Schueler (<greg.schueler@gmail.com>), and Seth Chisamore (<schisamo@opscode.com>)

Copyright 2013, Riot Games

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.