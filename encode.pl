#!/usr/bin/perl -w
# $Id: encode.pl,v 1.2 2004-06-07 19:54:25 mitch Exp $
#
# 2004 (c) by Christian Garbs <mitch@cgarbs.de>
# Licensed under GNU GPL
#
use strict;
use File::Path;
use POSIX qw(nice);

# globals
my $pfad = '/tmp';
my $file = "$pfad/cdinfo";

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
nice 20;

open CDINFO, '<', $file or die "can't open `$file': $!\n";

my $album = readTag('ALBUM');
my $path  = readTag('PATH');
my $first = lc(substr($path, 0, 1));
if ($first =~ /[a-z]/) {
    $path = "/$first/$path";
} else {
    $path = "/1/$path";
}
$path = '/mnt/mp3/mp1' . $path;

my $track_want = shift;
die "no track given!" unless defined $track_want;

# cycle tracks
while ((my $track = readTag('TRACK')) ne '') {
    if ($track == $track_want) {
	mkpath($path);
	my ($artist, $title, $version, $year) = 
	    (
	     readTag('ARTIST'),
	     readTag('TITLE'),
	     readTag('VERSION'),
	     readTag('YEAR')
	     );
	my $filename = sprintf '%02d.%s.%s.%s.ogg', $track, $artist, $title, $version;
	system('oggenc',
	       '-q', '6',
	       '-N', $track,
	       '-l', $album,
	       '-t', $title,
	       '-d', $year,
	       '-a', $artist,
	       '-c', "COMMENT=$version",
	       '-o', "$path/$filename",
	       '-'
	       );
    }
}

close CDINFO or die "can't close `$file': $!\n";
