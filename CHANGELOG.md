## v.3.3.0

* [#64](https://github.com/RiotGames/nexus-cookbook/issues/64) Add a feature to allow for the usage of Chef Vault

## v.3.2.0

* [#69](https://github.com/RiotGames/nexus-cookbook/pull/69) Create pid and work dirs.
* [#70](https://github.com/RiotGames/nexus-cookbook/pull/70) Default to using Nexus 2.7.2.
* [#71](https://github.com/RiotGames/nexus-cookbook/pull/71) Nginx should redirect to https when hit on http/80.
* [#68](https://github.com/RiotGames/nexus-cookbook/pull/68) Be more lax on dependencies and shoot for newer ones in java, nginx, and artifact.
* [#73](https://github.com/RiotGames/nexus-cookbook/pull/73) Add new 'policy' attribute to hosted_repository and proxy_repository.
* [#72](https://github.com/RiotGames/nexus-cookbook/pull/72) Replace localhost with 127.0.0.1 in nginx config.

## v.3.1.0

* [#67](https://github.com/RiotGames/nexus-cookbook/pull/67) Get a bit more up-to-date on nginx for COOK-3030

## v3.0.1

* [#59](https://github.com/RiotGames/nexus-cookbook/pull/59) Bump Nexus 2.7 dependency, because a bad version was released.
* [#56](https://github.com/RiotGames/nexus-cookbook/pull/56) Fixed a security bug with the file mode on SSL certs.
* [#60](https://github.com/RiotGames/nexus-cookbook/pull/60) Bump java and artifact cookbook dependencies.

## v3.0.0

Backwards incompatible release supporting Nexus 2.7.

* [#57](https://github.com/RiotGames/nexus-cookbook/pull/57) Support for Nexus 2.7
* Data bags are no longer required for the basic default recipe workflow.

## v2.4.0

* [#52](https://github.com/RiotGames/nexus-cookbook/pull/52) Fixed a compilation bug for credentials data bag.
* [#50](https://github.com/RiotGames/nexus-cookbook/pull/50) Fixed a bug where we couldn't communicate with Nexus servers using a modified context path.
* Some less vulnerable SSL options have been added to the nginx config
* Removed chef-solo specific portions of code

## v2.3.0

* Default to Nexus 2.6
  * Deprecates Java 6 in favor of Java 7
* Cookbook dependency updated to java 1.12.0

## v2.2.0

* Functionality for the nginx Upstream module

## v2.1.0

* Change nginx config attributes to an Array of Strings instead of a Hash. See #33.

## v2.0.0

* Remove many of the recipes and attempt to follow the "Application Cookbook Pattern" a bit more.
* Removed the usage of many of the LWRPs. Those calls belong in a wrapper cookbook.
* Remove the ability to configure Jetty with SSL.

## v1.2.1

* The proxy recipe should no longer causes failures on chef-solo runs.
* Use the latest 1.5.0 version of artifact cookbook.

## v1.2.0

* Add a template resource for logback-nexus.xml and a configurable option for keeping logs.

## v1.1.0

* Uses a newer version of the nexus_cli gem, which no longer requires libxml or libxslt packages.
* Use an attribute to set the home of the nexus user this cookbook creates.

## v1.0.0

This release features a number of improvements and changes to this cookbook. In particular, things to watch out for include a new
data bag format, the ability to use Jetty instead of nginx for SSL, a modified Library API, and the removal of the `nexus::pro` recipe.

It is recommended that you configure your own cookbook to override some of the attributes defined in this cookbook and use the provided
LWRPs to customize your installation to your liking.

Major Improvements
* [#22] New nexus::nginx recipe and a new nexus::jetty that helps Jetty use SSL.
* [#18] Data bag usage has been completely reworked
* [#19] The artifact-cookbook is now being used more effectively.
* [#21] The Nexus file wrapper.log will no longer cause redeploys of Nexus.
* [#17] A library method has been added to help ensure the Nexus service is available before LWRPs use it.

Bug Fixes
* [#15] Now depends on build-essential