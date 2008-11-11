package TestApp::Controller::REST;

use strict;
use warnings;
use parent 'Catalyst::Controller::REST';

__PACKAGE__->config->{map}{'application/vnd.ms-excel'} = 'SimpleExcel';

sub a_o_a : Local ActionClass('REST') {}

sub a_o_a_GET {
    my ($self, $c) = @_;

    $self->status_ok(
        $c,
        entity => [
            [1,2,3],
            [4,5,6]
        ]
    );
}

sub fancy : Local ActionClass('REST') {}

sub fancy_GET {
    my ($self, $c) = @_;

    $self->status_ok(
        $c,
        entity => {
            header => [qw/Foo Bar/],
            column_widths => [10, 20],
            rows => [
                [1,2],
                [3,4]
            ],
            filename => 'mtfnpy'
        }
    );
}

1;
