#!/usr/bin/perl -w
#
# 2004-2005,2008 (c) by Christian Garbs <mitch@cgarbs.de>
# Licensed under GNU GPL
#
use strict;
use File::Path;
use POSIX qw(nice);
use Grabcd::ReadConfig;

# globals
my $VERSION = '@@git@@';

my $config = Grabcd::ReadConfig::read_config('grabcd', qw(CDINFO_TEMP ENCODE_NICE ENCODE_PATH));
my $file = $config->{CDINFO_TEMP};

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
nice $config->{ENCODE_NICE};

open CDINFO, '<', $file or die "can't open `$file': $!\n";

my $catalog = readTag('CATALOG');
my $album   = readTag('ALBUM');
my $path    = readTag('PATH');
my $first   = lc(substr($path, 0, 1));
if ($first =~ /[a-z]/) {
    $path = "/$first/$path";
} else {
    $path = "/1/$path";
}
$path = $config->{ENCODE_PATH} . $path;

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
	$filename =~ tr,/, ,;
	my @args = ('oggenc',
		    '-Q',
		    '-q', '6',
		    '-N', $track,
		    '-l', $album,
		    '-t', $title,
		    '-d', $year,
		    '-a', $artist,
		    '-o', "$path/$filename");
	if ($version ne '') {
	    push @args, ('-c', "comment=($version)");
	}
	if ($catalog ne '') {
	    push @args, ('-c', "catalog=$catalog");
	}
	push @args, '-';

	system( @args );
    }
}

close CDINFO or die "can't close `$file': $!\n";
