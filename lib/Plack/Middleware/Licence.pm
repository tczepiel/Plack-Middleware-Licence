package Plack::Middleware::Licence;

use strict;
use warnings;

use parent 'Plack::Middleware';

use Plack::Util::Accessor qw(licence content_mapping use_defaults);
use Plack::Util;

our $VERSION = '0.1';

#ABSTRACT attach licence content to your files

=head1 NAME

Plack::Middleware::Licence

=head1 DESCRIPTION

add append licence text to your html,css,js ( etc. ) files...

=head1 SYNOPSIS

    use Plack::Builder;
    my $app = sub { ... };
    builder {
        enable 'Licence',
            licence => 'the following software is incensed under GPLv3...';
        $app;
    };

    # define the content types you want to handle
    builder {
        enable 'Licence', 
            licene => 'by accepting this brick, you accept it as is.. without any warranty explicit or implied..',
            use_defaults => 1|0,
            content_type => {
                'text/html' => {
                    start => q{<!--},
                    end   => q{-->}
                },
            };
    };

=cut

our %__content_mapping = (
    'text/html' => {
        start => q{<!--},
        end   => q{-->},
     },
    'text/javascript' => {
        start => q{/*},
        end   => q{*/},
    },
    'text/css' => {
        start => q{/*},
        end   => q{*/},
    },
);

sub call {
    my $self = shift;
    my $env  = shift;

    my $response = $self->app->($env);
    my $headers  = Plack::Util::headers($response->[1]);
    my $content_type = $headers->get('Content-Type') || return $response;

    $self->_merge_configs();

    if ( my $mapping = $self->content_mapping->{ $content_type } ) {
        unshift @{ $response->[2] },
            $self->_get_licence($mapping);
    }

    $response;
}

sub _get_licence {
    my $self    = shift;
    my $mapping = shift;
    my $licence = $self->licence;

    my ( $start, $end ) = @{ $mapping }{ qw/start end/ };
    $start ||= '';
    $end   ||= '';

    if ( $start && ! $end ) {
        $licence =~ s{ "\n" }{ "\n$start" }g;
    }
    else {
        $licence = join '', $start, $licence, $end;
    }

    return $licence;
}

sub _merge_configs {
    my $self = shift;

    %__content_mapping = () 
        if ( defined $self->use_defaults && ! $self->use_defaults );
    
    my $content_mapping ||= {
        %__content_mapping,
        %{ $self->content_mapping || {} },
    };

    $self->content_mapping($content_mapping);
}

1;

# ABSTRACT: attach licence content to your files


