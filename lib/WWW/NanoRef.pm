# Creation date: 2005-11-06 22:03:29
# Authors: don

=pod

=head1 NAME

 WWW::NanoRef - Shorten URLs via nanoref.com

=head1 SYNOPSIS

 use WWW::NanoRef;

 my $ref = WWW::NanoRef->new({ url => $destination_url });
 my $short_url = $ref->get_short_url;

=head1 DESCRIPTION

 This module uses the API published by nanoref.com to produce
 shortened URLs.  So a destination URL like

    http://maps.yahoo.com/dd_result?newaddr=865+W+El+C
    amino+Real&taddr=2495+S+Delaware+St&csz=Sunnyvale%
    2C+CA+94086&country=us&tcsz=San+Mateo%2C+CA+94403-
    1902&tcountry=us

 becomes a shorter URL like

    http://nanoref.com/yahoo/_QhGlg


=cut

use strict;
use warnings;

package WWW::NanoRef;

our $VERSION = '0.01';

use LWP;
use XML::Parser::Wrapper;

=pod

=head1 METHODS

=head2 new(\%params)

 Creates a new object.  The only key/value pair required is url,
 which is the destination URL you want the shortened URL to
 redirect to.

=head3 Parameters:

=over 4

=item url

 The destination URL you want the shortened URL to redirect to.

=item passwd

 The password you want to associated with the nanoref.com URL for
 viewing stats (see http://nanoref.com/ for details) when they
 are implemented.

=item test

 If set to a true value, a nanoref.com URL will be generated, but
 will not be stored (and will not work).  It is used for testing
 this module.

=back

=cut

sub new {
    my $proto = shift;
    my $url = shift;
    my $passwd = '';
    my $test = '';
    if (ref($url) eq 'HASH') {
        my $hash = $url;
        $url = $hash->{url};
        $passwd = $hash->{passwd};
        $passwd = '' unless defined $passwd;
        $test = $hash->{test} || '';
    }
    my $self = bless { _dest_url => $url, _passwd => $passwd, _test => $test },
        ref($proto) || $proto;
    return $self;
}

=pod

=head2 get_short_url()

 Returns a shortened URL that will redirect to the destination
 URL passed to new() when creating the object.  On error, undef
 is returned.

=cut
sub get_short_url {
    my $self = shift;
    if ($self->{_error}) {
        return;
    }
    elsif (exists($self->{_gen_url})) {
        return $self->{_gen_url};
    }
    else {
        if ($self->_fetch_api) {
            return $self->{_gen_url};
        }
        else {
            return;
        }
    }
}

=pod

=head2 get_error()

 Returns the error message, if any, from the server.

=cut
sub get_error {
    my $self = shift;
    return $self->{_error};
}

sub _fetch_api {
    my $self = shift;
    my $enc_url = $self->url_encode($self->{_dest_url});
    my $enc_passwd = $self->url_encode($self->{_passwd});
    my $fetch_url = "http://nanoref.com/?api=1;url=$enc_url;passwd=$enc_passwd";
    if ($self->{_test}) {
        $fetch_url .= ";test=1";
    }

    my $request = HTTP::Request->new(GET => $fetch_url);
    my $ua = LWP::UserAgent->new;
    my $response = $ua->request($request);

    if ($response->is_success) {
        my $content = $response->content;
        my $parser = XML::Parser::Wrapper->new($content);
        return unless $parser->name eq 'response';
        my $response_tag = $parser;
        if ($response_tag) {
            my $error_tag = $response_tag->kid('error');
            my $gen_url_tag = $response_tag->kid('gen_url');
            if ($error_tag and $error_tag->text !~ /^\s*$/) {
                $self->{_error} = $error_tag->text;
                return;
            }
            else {
                $self->{_gen_url} = $gen_url_tag->text if $gen_url_tag;
                return 1;
            }
        }
    }
    else {
        $self->{_error} = $response->message || 'problem fetching data';
        return;
    }
}

sub url_encode {
    my ($self, $str) = @_;
    $str =~ s{([^A-Za-z0-9_-])}{sprintf("%%%02x", ord($1))}eg;
    return $str;
}


=pod

=head1 DEPENDENCIES

 XML::Parser::Wrapper (which in turn depends on XML::Parser)
 LWP

=head1 AUTHOR

Don Owens <don@owensnet.com>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2005 Don Owens <don@owensnet.com>.  All rights reserved.

This is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.  See perlartistic.

This program is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.

=head1 SEE ALSO

 http://nanoref.com/

=head1 VERSION

 0.01

=cut

1;

# Local Variables: #
# mode: perl #
# tab-width: 4 #
# indent-tabs-mode: nil #
# cperl-indent-level: 4 #
# perl-indent-level: 4 #
# End: #
# vim:set ai si et sta ts=4 sw=4 sts=4:
