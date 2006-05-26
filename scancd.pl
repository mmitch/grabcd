#!/usr/bin/perl -w
# $Id: scancd.pl,v 1.34 2006-05-26 14:05:51 mitch Exp $
#
# 2004-2006 (c) by Christian Garbs <mitch@cgarbs.de>
# Licensed under GNU GPL
#
use strict;
use Audio::CD;
use Grabcd::ReadConfig;

# globals
my ($keep_year, $keep_artist, $keep_title, $keep_version) = ( 1, 1, 0, 0 );

my $config = Grabcd::ReadConfig::read_config('grabcd', qw( CDINFO_TEMP CDINFO_REMOTE ));
my $file   = $config->{CDINFO_TEMP};
my $remote = $config->{CDINFO_REMOTE};

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
my @tracks = @{$stat->tracks};

print "discid=[$discid], track_count=[".$stat->total_tracks."]\n";

use Term::ReadLine;
my ($artist, $album, $path, $title, $version, $year, $catalog);
my $term = new Term::ReadLine 'scancd $Id: scancd.pl,v 1.34 2006-05-26 14:05:51 mitch Exp $';
$|++;

$catalog = $term->readline("Catalog :");
$catalog =~ s/^\s+//;
$catalog =~ s/\s+$//;
$artist  = $term->readline("Artist  :");
$artist  =~ s/^\s+//;
$artist  =~ s/\s+$//;
$album   = $term->readline("Album   :");
$album   =~ s/^\s+//;
$album   =~ s/\s+$//;

open CDINFO, '>', $file or die "can't open `$file': $!\n";
print CDINFO "DISCID=$discid\n";
print CDINFO "CATALOG=$catalog\n";
print CDINFO "ALBUM=$album\n";
# read path
if ($artist eq '') {
    $path = $album;
} else {
    $path   =  $artist;
    $path   =~ tr,/,_,;
    $album  =~ tr,/,_,;
    $path  .=  '/' . $album;
}
$path   = $term->readline("Path    :", $path);
$path   =~ s/^\s+//;
$path   =~ s/\s+$//;
print CDINFO "PATH=$path\n";

# {
foreach my $track (1 .. $stat->total_tracks) {
    unless ($tracks[$track-1]->is_audio) {
	print "\nskipping $track, no audio...\n";
	next;
    }
    print CDINFO "\nTRACK=$track\n";
    my ($minutes, $seconds) = $tracks[$track-1]->length;
    printf "\n == Track %02d/%02d  %02d:%02d  ==\n", $track, $stat->total_tracks, $minutes, $seconds;
    if ($keep_artist) {
	$artist  = $term->readline("Artist  :", $artist);
    } else {
	$artist  = $term->readline("Artist  :");
    }
    if ($keep_title) {
	$title   = $term->readline("Title   :", $title);
    } else {
	$title   = $term->readline("Title   :");
    }
    if ($keep_version) {
	$version = $term->readline("Version :", $version);
    } else {
	$version = $term->readline("Version :");
    }
    if ($keep_year) {
	$year    = $term->readline("Year    :", $year);
    } else {
	$year    = $term->readline("Year    :");
    }
    $artist =~ s/^\s+//;
    $artist =~ s/\s+$//;
    $title  =~ s/^\s+//;
    $title  =~ s/\s+$//;
    $version=~ s/^\s+//;
    $version=~ s/\s+$//;
    $year   =~ s/^\s+//;
    $year   =~ s/\s+$//;
    print CDINFO "ARTIST=$artist\nTITLE=$title\nVERSION=$version\nYEAR=$year\n";
}

close CDINFO or die "can't close `$file': $!\n";

system($ENV{EDITOR}, $file);

$path =~ s,/,___,g;
$path =~ s/([;\' &<>()])/\\$1/g;
system('scp', $file, "$remote/$path");
