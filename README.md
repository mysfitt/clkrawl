WWW::Search::CraigsList
=======

Craigslist Search Module for Perl with accompanying search script


Search the Craigslist website for stuff. Note that this is done via
a scraper and prone to breakage if CL feels like changing things.

There is no official API unfortunately :(

Check in the bin/ directory for script called clkrawl.pl that you can
copy to any bin directory in your path after installing the module.

Configure the email settings with the following Environment Variables:
`Host    $ENV{'EMAIL_HOST'}`
`Port    $ENV{EMAIL_PORT}`
`User    $ENV{'EMAIL_USER'}`
`Pass    $ENV{'EMAIL_PASS'}`
TLS support for email servers is available and enabled by default.

Call clkrawl without options for a nice help message, including the categories
and cities that are built in. It's a simple matter of adding to the hashes to
add more.

Features
--------
* Locations
* Categories
* Email Support [-e email@address.tld]
* Stdout output [-o]
* Search only for results with pictures [-p]
* min/max [-m -x]

Credit for the Original version of this Module goes to Martin Thurn <mthurn@cpan.org>
