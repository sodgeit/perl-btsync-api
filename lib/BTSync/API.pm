package BTSync::API;

use strict;
use warnings;
use Mojo::Base -base;
use Mojo::URL;
use Mojo::UserAgent;
#use Mojo::JSON;

#require Exporter;
#use AutoLoader qw(AUTOLOAD);

#our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BTSync::API ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
#our %EXPORT_TAGS = ( 'all' => [ qw(
	
#) ] );
#
#our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
#
#our @EXPORT = qw(
#	
#);
#
#our $VERSION = '0.01';

has 'ua' => sub { return Mojo::UserAgent->new(); };
has 'host' => 'localhost';
has 'port' => 8888;
has 'username' => undef;
has 'password' => undef;


# Preloaded methods go here.

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

	if($res->{result} == 0) {
		foreach my $f (@{$self->get_folders()}) {
			my $dir = $f->{dir};
			if($dir !~ m!/$!) {
				$dir .= "/";
			}
			
			# Clean up the escaped path-string...
			$dir =~ s/\\//g;
			say "===> Testing $dir against $folder";
			if($dir eq $folder) {
				$new_secret = $f->{secret};
				last;
			}
		}
	}

	return $new_secret;
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


sub set_prefs {
	my $self = shift;
	my $prefs = shift || {};

	$self->request("set_prefs", $prefs);
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
		die "HTTP-Error: $code $msg";
	}

	return $tx->res->json;
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
  my $secret = $api->add_folder("/home/user/syncdir/");

  foreach my $folder (@{$api->get_folders}) {
     say 'Syncing folder: ' . $folder->{dir};
  }
  
  $api->remove_folder($secret);

=head1 DESCRIPTION

This module makes accessing the BTSync API via perl easy and straight forward.

In order to get API access to your BTSync client, you need to obtain an
API key first.

See http://www.bittorrent.com/sync/developers

=head2 EXPORT

None by default.

=head1 METHODS

=head2 add_folder

=head2 get_folders

=head2 get_prefs

=head2 get_speed

=head2 remove_folder

=head2 set_prefs

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Sven Eppler, sodgeIT GmbH

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by sodgeIT GmbH

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
