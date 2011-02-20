#!/usr/bin/perl
############################################################################
#
# readme.pl
# This program is a simple demonstration of the usage of Simple Reddit API
# It searches reddit for all posts that point to imgur.com, and that contain
# the title 'alaska'.
#
############################################################################
use strict;
use warnings;

use WWW::Simple::Reddit;

my $reddit=Reddit->new;

print "This is version : ",$reddit->version(),"\n";

my @links=$reddit->get_links_from_xml(($reddit->search({site=>"imgur.com",over18=>"no",query=>"alaska"})));

foreach(@links){
	print $_->{title},"\n";
}

print "End of demo\n";
