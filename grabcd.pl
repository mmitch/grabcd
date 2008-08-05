#!/usr/bin/perl -w
#
# 2004-2005,2008 (c) by Christian Garbs <mitch@cgarbs.de>
# Licensed under GNU GPL
#
use strict;
use Audio::CD;
use Grabcd::ReadConfig;

# globals
my $config = Grabcd::ReadConfig::read_config('grabcd', qw(CDINFO_TEMP ENCODE_HOST ENCODE_BINARY));
my $file   = $config->{CDINFO_TEMP};
my $host   = $config->{ENCODE_HOST};
my $encode = $config->{ENCODE_BINARY};

# subs
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

# main
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
print 'Album : '.readTag('ALBUM' )."\n";

# copy cdinfo
if ($host ne 'localhost' and $host ne '') {
    system("scp $file $host:$file");
}

# cycle tracks
while ((my $track = readTag('TRACK')) ne '') {
    print "grabbing track $track\n";
    if ($host ne 'localhost' and $host ne '') {
	system("icedax -O wav -t $track -paranoia - | ssh $host $encode $track");
    } else {
	system("icedax -O wav -t $track -paranoia - | $encode $track");
    }
}

close CDINFO or die "can't close `$file': $!\n";
