#!/usr/bin/perl -w
# $Id: scancd.pl,v 1.4 2004-06-06 21:01:59 mitch Exp $
#
# 2004 (c) by Christian Garbs <mitch@cgarbs.de>
# Licensed under GNU GPL
#
use strict;
use Audio::CD;

# globals
my ($keep_year, $keep_artist, $keep_title, $keep_version) = ( 1, 1, 0, 0 );
my $file = '/tmp/cdinfo';


my $args = join '', @ARGV;
$args =~ tr/A-Z/a-z/;

while ( $args =~ /(.)/g ) {
    if ($1 eq "y") {
	$keep_year = 1 - $keep_year;
    } elsif ($1 eq "a") {
	$keep_artist = 1 - $keep_artist;
    } elsif ($1 eq "t") {
	$keep_title = 1 - $keep_title;
    } elsif ($1 eq "v") {
	$keep_version = 1 - $keep_version;
    } else {
	print "a  artist  (keep = $keep_artist)\n";
	print "t  title   (keep = $keep_title)\n";
	print "v  version (keep = $keep_version)\n";
	print "y  year    (keep = $keep_year)\n";
	exit;
    }
}

my $cd = Audio::CD->init;
die "could not initialize Audio::CD\n" unless defined $cd;

my $stat = $cd->close;
$stat = $cd->stat;
die "no cd detected\n" unless $stat->present;

my $cddb = $cd->cddb;
my $discid = $cddb->discid;

print "discid=[$discid], track_count=[".$stat->total_tracks."]\n";

open CDINFO, '>', $file or die "can't open `$file': $!\n";

print CDINFO "DISCID=$discid\n";

use Term::ReadLine;
my ($artist, $album, $path, $title, $version, $year);
my $term = new Term::ReadLine 'scancd $Id: scancd.pl,v 1.4 2004-06-06 21:01:59 mitch Exp $';
$|++;

$artist = $term->readline("Artist  : ");
$album  = $term->readline("Album   : ");
print CDINFO "ALBUM=$album\n";
# read path
$path   =  $artist;
$path   =~ tr,/,_,;
$album  =~ tr,/,_,;
$path  .=  '/' . $album;
print CDINFO "PATH=$path\n";

# {
foreach my $track (1 .. $stat->total_tracks) {
    print CDINFO "\nTRACK=$track\n";
    print "\nTRACK $track/".$stat->total_tracks."\n";
    $artist  = $term->readline("Artist  : ");
    $title   = $term->readline("Title   : ");
    $version = $term->readline("Version : ");
    $year    = $term->readline("Year    : ");
    print CDINFO "ARTIST=$artist\nTITLE=$title\nVERSION=$version\nYEAR=$year\n";
}

close CDINFO or die "can't close `$file': $!\n";
