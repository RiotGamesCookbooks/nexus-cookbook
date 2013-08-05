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