package BTSync::API;

use strict;
use warnings;
use Mojo::Base -base;
use Mojo::URL;
use Mojo::UserAgent;

our $VERSION = '0.06';

has 'ua' => sub { return Mojo::UserAgent->new(); };
has 'host' => 'localhost';
has 'port' => 8888;
has 'username' => undef;
has 'password' => undef;


sub get_files {
	my $self = shift;
	my $secret = shift || die "You need to provide a secret to retrieve a file listing!";
	my $path = shift || undef;

	$self->request('get_files', { secret => $secret, path => $path });
}

sub get_folders {
	my $self = shift;
	my $secret = shift || undef;
	$self->request('get_folders',{ secret => $secret });
}

sub add_folder {
	my $self = shift;
	my $folder = shift;
	my $secret = shift || undef;
	my $selective = shift || undef;

	my $res = $self->request('add_folder', { dir => $folder, secret => $secret, selective => $selective });
	
	my $new_secret = undef;

	if(exists($res->{result}) && $res->{result} == 0) {
		foreach my $f (@{$self->get_folders()}) {
			my $dir = $f->{dir};
			if($dir !~ m!/$!) {
				$dir .= "/";
			}
			
			# Clean up the escaped path-string...
			$dir =~ s/\\//g;
			if($dir eq $folder) {
				$new_secret = $f->{secret};
				last;
			}
		}
	}

	$res->{new_secret} = $new_secret;

	return $res;
}

sub remove_folder {
	my $self = shift;
	my $secret = shift;

	$self->request("remove_folder", { secret => $secret });
}

sub get_speed {
	my $self = shift;

	$self->request("get_speed");
}

sub get_prefs {
	my $self = shift;

	$self->request("get_prefs");;
}


sub get_folder_hosts {
	my $self = shift;
	my $secret = shift || die "You need to provide a folder secret!";

	$self->request('get_folder_hosts', { secret => $secret });
}

sub get_folder_prefs {
	my $self = shift;
	my $secret = shift || die "You need to provide a folder secret!";

	$self->request('get_folder_prefs', { secret => $secret });
}

sub get_os {
	shift->request('get_os');
}

sub get_version {
	shift->request('get_version');
}


sub set_prefs {
	my $self = shift;
	my $prefs = shift || {};

	$self->request("set_prefs", $prefs);
}

sub set_folder_prefs {
	my $self = shift;
	my $secret = shift || die "You need to provide a folder secret";
	my %prefs = %{shift()}; # get a real copy of the preferences

	$prefs{secret} = $secret;

	$self->request('set_folder_prefs', \%prefs);
}

sub set_folder_hosts {
	my $self = shift;
	my $secret = shift || die "You need t provide a folder secret!";
	my $host = shift;

	if(ref $host eq "ARRAY") {
		$host = join(",", @$host);
	}

	$self->request('set_folder_hosts', { secret => $secret, hosts => $host });
}

sub shutdown {
	my $self = shift;
	$self->request('shutdown');
}



sub request {
	my $self = shift;
	my $method = shift || die "No request without a method!";
	my $params = shift || {};
	my $url = $self->mk_url;

	# Remove empty parameters
	while(my ($k, $v) = each(%$params)) {
		if(!defined $v) {
			delete $params->{$k};
		}
	}

	# Set the method here, so nobody can inject a method via params hash
	$params->{method} = $method;
	
	my $tx = $self->ua->get($url, form => $params);

	if(!$tx->success) {
		my ($msg, $code) = $tx->error;
		return { error => ($code||500), message => "Communication Error: " . $msg };
	}
	else {
		return $tx->res->json;
	}
}

sub mk_url {
	my $self = shift;
	my $url = Mojo::URL->new();
	$url->scheme("http");
	$url->host($self->host);
	$url->port($self->port);
	$url->path("/api");
	if($self->username && $self->password) {
		$url->userinfo($self->username . ':' . $self->password);
	}

	return $url;
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

BTSync::API - Perl extension for BitTorrent Sync API

=head1 SYNOPSIS

 use BTSync::API;
 my $api = BTSync::API->new({ username => "admin", password => "********" });
 my $api = BTSync::API->new({ host => '192.168.1.2', port => 4711, username => 'admin', password => '*******' });
 
 my $res = $api->add_folder("/home/user/syncdir/");
 
 foreach my $folder (@{$api->get_folders}) {
    say 'Syncing folder: ' . $folder->{dir};
 }
 
 $api->remove_folder($secret);

=head1 DESCRIPTION

B<This module is work in progress. Not all API-Methods are implemented!>

This module makes accessing the BTSync API via perl easy and straight forward.

In order to get API access to your BTSync client, you need to obtain an
API key first and configure BTSync to allow API access.
If you get wiered "400 ERROR" repsonses, you most likely forgot to activate the API.

See L<http://www.bittorrent.com/sync/developers>

=head1 ATTRIBUTES

=head2 username

The username for the API-Access

May be I<undef> if no authentication is needed.

=head2 password

The password for the API-Access.

May be I<undef> if no authentication is needed.

=head2 host

The host to connect to. Defaults to I<localhost>.

=head2 port

The port to connect to. Defaults to I<8888>.

=head2 ua

Internal L<Mojo::UserAgent> object


=head1 METHODS

=head2 add_folder

 $res = $api->add_folder("/path/to/folder");
 $res = $api->add_folder("/path/to/folder/", $secret);
 $res = $api->add_folder("/path/to/folder/", $secret, $selective);
 my $new_secret = $res->{new_secret};

=head2 get_files

 @files = @{$api->get_files($secret)};

=head2 get_folders

 @folders = @{$api->get_folders()};
 $folder = $api->get_folders($secret);

=head2 get_folder_hosts

 $res = $api->get_folder_hosts($secret);
 @hosts = @{$res->{hosts}};

=head2 get_prefs

=head2 get_os

 $operatingsystem = $api->get_os();

=head2 get_speed

=head2 get_version

 $version = $api->get_version();

=head2 remove_folder

=head2 set_folder_hosts

 $api->set_folder_hosts($secret, $host);
 $api->set_folder_hosts($secret, ['host:port', 'host2:port2', 'host3:port3' ]);

=head2 set_prefs

=head2 shutdown

Shutdown the Bittorrenc Sync client.

=head1 SEE ALSO

This module ist based on the BitTorrent Sync API.

Documentation avaiable at L<http://www.bittorrent.com/sync/developers/api>

=head1 AUTHOR

Sven Eppler, sodgeIT GmbH, cpan@sveneppler.de

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by sodgeIT GmbH

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
