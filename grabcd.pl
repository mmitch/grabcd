#!/usr/bin/perl -w
# $Id: grabcd.pl,v 1.2 2004-06-07 18:58:55 mitch Exp $
#
# 2004 (c) by Christian Garbs <mitch@cgarbs.de>
# Licensed under GNU GPL
#
use strict;
use Audio::CD;

sub readTag($)
{
    my $tag = shift;
    while (my $line = <CDINFO>) {
	chomp $line;
	if ($line =~ /^\s*$tag\s*=(.*)$/i) {
	    return $1;
	}
    }
    return '';
}

# globals
my $pfad = '/tmp';
my $file = "$pfad/cdinfo";

my $cd = Audio::CD->init;
die "could not initialize Audio::CD\n" unless defined $cd;

my $stat = $cd->close;
$stat = $cd->stat;
die "no cd detected\n" unless $stat->present;

open CDINFO, '<', $file or die "can't open `$file': $!\n";

# check discid
my $cddb = $cd->cddb;
my $discid_want = $cddb->discid;
my $discid_have = readTag('DISCID');
die "discid does not match (want=$discid_want, have=$discid_have)\n" unless $discid_want eq $discid_have;

# display album
print 'Album : '.readTag('Album' )."\n";

# cycle tracks
while ((my $track = readTag('TRACK')) ne '') {
    print "grabbing track $track\n";
    system('cdparanoia -e -B -w $track >/dev/null 2>/dev/null');
}

close CDINFO or die "can't close `$file': $!\n";
