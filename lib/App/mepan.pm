package App::mepan;
use 5.008_001;
use strict;
use warnings;

our $VERSION = '0.01';

use Getopt::Long ();
use Furl         ();
use JSON         qw(decode_json);
use URI::Escape  qw(uri_escape);

my $API = 'http://api.metacpan.org';

sub getopt_spec {
    return(
        'category|c=s',
        'search|s',

        'verbose|v',
        'version',
        'help',
    );
}

sub getopt_parser {
    return Getopt::Long::Parser->new(
        config => [qw(
            no_ignore_case
            bundling
            no_auto_abbrev
        )],
    );
}

sub appname {
    my($self) = @_;
    require File::Basename;
    return File::Basename::basename($0);
}

sub new {
    my $class = shift;
    local @ARGV = @_;

    my %opts;
    my $success = $class->getopt_parser->getoptions(
        \%opts,
        $class->getopt_spec());

    if(!$success) {
        $opts{help}++;
        $opts{getopt_failed}++;
    }

    $opts{argv} = \@ARGV;

    return bless \%opts, $class;
}

sub run {
    my $self = shift;

    if($self->{help}) {
        $self->do_help();
    }
    elsif($self->{version}) {
        $self->do_version();
    }
    else {
        $self->dispatch(@ARGV);
    }

    return;
}

sub dispatch {
    my($self, @args) = @_;

    my $agent = sprintf '%s/%s', $self->appname, $VERSION;
    my $ua = Furl->new( agent => $agent );

    my $category = $self->{category} || 'module';
    my $query;
    if($self->{search}) {
        $query = '_search?';
        my @q = (
            [ q => join ':', @args ],
        );
        $query .= join ';',
            map { join '=', uri_escape($_->[0]), uri_escape($_->[1]) } @q;
    }
    else {
        $query = uri_escape(join '', @args);
    }


    my $url = "$API/$category/$query";
    print "Request: $url\n" if $self->{verbose};
    my $res = $ua->get($url);

    if($res->is_success) {
        my $data = decode_json( $res->content );
        print Dump( $data );
    }
    else {
        print Dump( $res );
    }
    return;
}

sub Dump {
    my($data, $name) = @_;
    require Data::Dumper;
    my $dd = Data::Dumper->new([$data], [$name || 'app']);
    $dd->Indent(1);
    $dd->Maxdepth(3);
    $dd->Quotekeys(0);
    $dd->Sortkeys(1);
    return $dd->Dump();
}

sub do_help {
    my($self) = @_;
    if($self->{getopt_failed}) {
        die $self->help_message();
    }
    else {
        print $self->help_message();
    }
}

sub do_version {
    my($self) = @_;
    print $self->version_message();
}

sub help_message {
    my($self) = @_;
    require Pod::Usage;

    open my $fh, '>', \my $buffer;
    Pod::Usage::pod2usage(
        -message => $self->version_message(),
        -exitval => 'noexit',
        -output  => $fh,
        -input   => __FILE__,
    );
    close $fh;
    return $buffer;
}

sub version_message {
    my($self) = @_;

    require Config;
    return sprintf "%s\n" . "\t%s/%s\n" . "\tperl/%vd on %s\n",
        $self->appname(), ref($self), $VERSION,
        $^V, $Config::Config{archname};
}

1;
__END__

=head1 NAME

App::mepan - Perl extention to do something

=head1 VERSION

This document describes App::mepan version 0.01.

=head1 SYNOPSIS

    $ mepan --help

=head1 DESCRIPTION

# TODO

=head1 INTERFACE

=head2 Functions

=head3 C<< hello() >>

# TODO

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

Fuji Goro E<lt>fuji.goro@dena.jpE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011, Fuji Goro. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
