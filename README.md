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
* nginx
* artifact

Recipes
=======

* default - the recipe you want in your run-list. Configures a system and installs a Nexus server.
* app - the core recipe used for installing the Nexus server.
* nginx - add this recipe to your run-list when you want nginx installed and configured to proxy the Nexus server.
* cli - installs packages at compilation time and uses `chef_gem` to instal the nexus_cli gem. Primarily used by the LWRPs of this cookbook.


Usage
=====

Simply add the `nexus::default` recipe to the node where you want Sonatype Nexus installed.

Due to a recent change on Sonatypes website, the downloads got a bit weird. Each time you download a tar.gz from Sonatype's site, it has two version
numbers. One that is an internal folder inside the tar (ex: 2.3.1-01) and one that they use on their website's downloads page (ex: 2.3, latest). I have
recently added a new attribute to reflect this change - `node.nexus.version` will be used to reflect the inner version, and `node.nexus.external_version`
will be used to reflect the version in the downloads URL.

Data Bags
=========

As of version 2.0.0, this cookbook now uses fewer, more standardized Encrypted Data Bags. Following the style used 
at Riot, Data bags are created per Chef Environment and default to a data bag item named "_wildcard" if there is no environmental
data bag item. 

For version 2.0.0, the data bag has been revised to only include the credentials, and license elements.

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
        },
      },
      "license": {
        "file": "base64d license file"
      }
    }

When you want to configure the Nexus to be served via SSL, you will need to set the nexus.app\_server\_proxy.ssl.enabled attribtue and configure an
encrypted data bag.

Your data bag items should look like the following:

    knife data bag create nexus_ssl_files _wildcard -c your/chef/config --secret-file your/encrypted_data_bag_key

    {
      "id": "_wildcard",
      "fully-qualified-domain-name": {
        "crt": "base64-encoded-ssl-certificate",
        "key": "base64-encoded-private-key"
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
policy           | Either "HOSTED" or "SNAPSHOT" repository policy for artifacts       | String                |
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

Most attributes under nexus are basic attributes needed for correctly installing the server. You can define things like the url to download the Nexus zip from, the install location, and other similar things here.

* nexus.version - sets the version inside the nexus package
* nexus.base_dir - sets the base directory under which to place the nexus user's home directory.
* nexus.user - sets the user to install nexus under
* nexus.group - sets the group to install nexus under
* nexus.external_version - the version used on the downloads page for nexus
* nexus.url - sets the URL where the nexus package is located
* nexus.checksum - The SHA256 checksum of the Nexus installation package
* nexus.port - the port to run nexus on
* nexus.host - the hostname to use for nexus
* nexus.context_path - the context path under which Nexus is running under. ie. "/nexus" #=> "http://localhost:8081/nexus"
* nexus.name - the name of the Nexus
* nexus.bundle_name - the name of the internal folder of the Nexus tar. Usually nexus-{professional or nothing}-{VERSION}
* nexus.home - the installation directory for the nexus application. Uses name.
* nexus.current_path - the above home/current/bundle_name. The artifact_deploy resource uses the `current` symlink to denote the currently installed version.
* nexus.pid_dir - the pid directory defined in the nexus.erb template. Saves a pid in the `pids` directory created by the artifact_deploy resource.
* nexus.conf_dir - the above home/conf
* nexus.bin_dir - the above home/bin
* nexus.work_dir - the above path/sonatype-work/nexus
* nexus.plugins - an Array of Nexus plugins that will be installed by the default recipe.
* nexus.logs.logs\_to\_keep - a fixnum value for the maximum number of logs the Nexus should keep.

Attributes under app\_server\_proxy help when you want to install an proxy in front of the running Nexus Jetty container. At the moment, the only supported alternative is nginx. Also, here is where you can configure SSL for either nginx or Jetty.

* nexus.app\_server\_proxy.nginx.server_name - the name to be configured in the nginx.conf server element.
* nexus.app\_server.jetty.loopback - true if you want to loop back on the default port (useful if you want to disable HTTP access).
* nexus.app\_server\_proxy.ssl.setup - set this attribute when you want SSL configured. Valid values are :none, :nginx, or :jetty.
* nexus.app\_server\_proxy.use_self_signed - defaults to false, set to true to use the pre-packaged, self signed certificate.
* nexus.app\_server\_proxy.ssl.port - the port to use for SSL connections.
* nexus.app\_server\_proxy.ssl.key - defines where to look in the credentials data bag for the SSL certificate and key information.
* nexus.app\_server\_proxy.nginx.server.options - used to generate options in the `server` section of the nginx conf file.
* nexus.app\_server\_proxy.nginx.proxy.options - used to generate proxy options in the `location` section of the nginx conf file.

Attributes under cli are used for configuring how the nexus_cli should behave. Most LWRPs in this cookboo use the nexus_cli gem for configuring a running Nexus server. Here you can configure how many attempts the gem should make before raising an exception about the Nexus server not being reachable (useful when you start or restart the server).

* nexus.cli.ssl.verify - true if we want to verify SSL connections. false if you have bad SSL certificates on your servers. If you are testing local nginx and SSL, you'll want this value to be false, because the certificate is self-signed.
* nexus.cli.repository - The repository that nexus_cli gem will use for push / pull operations. A requirement of nexus_cli, not used by this cookbook.
* nexus.cli.default\_admin\_credentials\_updated - this attribute is used for setting chosing what credentials the nexus_cli will use. This attribute will be set on the node after the nexus\_user resource changes the Nexus server's password.
* nexus.cli.retries - the number of attempts to make when connecting to a Nexus server. Most LWRPs in this cookbook require the Nexus server to be running.
* nexus.cli.retry\_delay - the time to wait in between attempts to connect to the Nexus server.

Local Development
=================

In order to run this cookbook locally in Vagrant, you need to configure data bags in `~/.chef/data_bags` and place your encrypted data bag secret key in `~/.chef/encrypted_data_bag_secret`.

License and Author
==================

Author:: Kyle Allan (<kallan@riotgames.com>)
Based on work by Joseph Holsten (<joseph@josephholsten.com>), Charles Scott (<connaryscott@gmail.com>),
Greg Schueler (<greg.schueler@gmail.com>), and Seth Chisamore (<schisamo@opscode.com>)

Copyright 2014, Riot Games

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
