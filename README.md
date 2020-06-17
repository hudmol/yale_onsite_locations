Yale Onsite Location
-----------------------------------

This is an ArchivesSpace plugin that introduces Onsite and Offsite locations
 via new flag on the Location model and exposes this as new filter and
 container details in the PUI.

This plugin was developed by Hudson Molonglo for Yale University.


# Getting Started

Download the latest release from the Releases tab in Github:

> https://github.com/hudmol/yale_onsite_locations/releases

Unzip the release and move it to:

    /path/to/archivesspace/plugins

Unzip it:

    $ cd /path/to/archivesspace/plugins
    $ unzip yale_onsite_locations-vX.X.zip

Enable the plugin by editing the file in `config/config.rb`:

    AppConfig[:plugins] = ['some_plugin', 'yale_onsite_locations']

(Make sure you uncomment this line (i.e., remove the leading '#' if present))

Run the database migrations:

    $ cd /path/to/archivesspace
    $ ./scripts/setup_database.sh

See also:

> https://archivesspace.github.io/archivesspace/user/archivesspace-plug-ins/

# How it works

A new "Onsite" checkbox is presented on the Location record form and batch
creation form.  The boolean value defaults to `true`.  Any records linked to
that location (top containers, accessions, resources, archival objects) then
calculate a readonly field `onsite_status` based on whether the linked
locations (via the instance or directly) are `onsite`, `offsite` or `mixed`
when the record is linked to both `onsite` and `offsite` locations.

This `onsite_status` is then indexed against those records allowing the PUI
to filter by this value.  It is also exposed in the PUI in the "Physical
Storage Information" suffixed to the container identifiers.
