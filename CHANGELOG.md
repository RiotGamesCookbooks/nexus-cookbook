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