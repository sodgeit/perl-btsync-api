#!/usr/bin/env perl

use strict;
use warnings;
use 5.10.1;
use lib 'lib/';
use Time::HiRes qw/sleep/;

use BTSync::API;

use Data::Dumper;

use Mojo::Util qw(b64_encode);

say b64_encode "admin:mypassword2013";

my $api = BTSync::API->new({ host => "localhost", port => 8888, username => "admin", password => "mypassword2013" });

$| = 1;

say Dumper $api->get_folders("AAHUTMNTZHJFHT2TNPJDQNSZFZZRGAO6R");

exit;

while(1) {
	my $speed = $api->get_speed();
	print "\r " . localtime() . ": Up: $speed->{upload} - Down: $speed->{download}                                        ";
	sleep(0.2);
}

exit;
my $res = $api->get_folders();

say Dumper $res;

my $secret = $api->add_folder("/tmp/test/");

say Dumper $api->get_folders();

#say Dumper $api->remove_folder($secret);
