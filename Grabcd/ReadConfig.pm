#!/usr/bin/perl -w
#
# 2005 (c) by Christian Garbs <mitch@cgarbs.de>
# utility function to read a simple config file
# if not all keywords are found, an error is raised
# $filename is searched for as "~/.$filename" and "/etc/$filename.conf"
# file format is:
# # comment
# KEY=value

use strict;

package Grabcd::ReadConfig;

sub read_config($@)
# $_[0]    = Configuration file name
# $_[1..n] = must-have configuration keys
# result is an hash of the configuration
{
    my $filename = shift;
    my @keys = @_;

    my $result = {};

    my $file = "$ENV{HOME}/.$filename";

    if (! -r $file) {
	$file = "/etc/$filename.conf";
    }

    die "ERROR: configuration file <$file> does not exist.\n" unless -e $file;
    die "ERROR: configuration file <$file> is not readable.\n" unless -r _;

    open CONF, '<', $file or die "can't open <$file>: $!\n";
    while (my $line = <CONF>) {
	chomp $line;
	next if $line =~ /^\s*#/;
	next if $line =~ /^\s*$/;
	if ($line =~ /^\s*([A-Z_+-]+)=(.+)\s*$/) {
	    $result->{uc $1} = $2;
	} else {
	    warn "unparseable line $. in configuration file\n";
	}
    }
    close CONF or die "can't close <$file>: $!\n";

    foreach my $key (@keys) {
	$key = uc $key;
	die "ERROR: configuration option $key is not set.\n" unless exists $result->{$key};
    }

    return $result;
}

1;
