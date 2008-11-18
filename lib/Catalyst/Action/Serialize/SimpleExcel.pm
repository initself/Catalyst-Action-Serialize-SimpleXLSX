package Catalyst::Action::Serialize::SimpleExcel;

use strict;
use warnings;
no warnings 'uninitialized';
use parent 'Catalyst::Action';
use Spreadsheet::WriteExcel;
use Scalar::Util 'reftype';
use namespace::clean;

=head1 NAME

Catalyst::Action::Serialize::SimpleExcel - Serialize tables to Excel files

=head1 VERSION

Version 0.012

=cut

our $VERSION = '0.012';

=head1 SYNOPSIS

Serializes tabular data to an Excel file. Not terribly configurable, but should
suffice for simple purposes.

In your REST Controller:

    package MyApp::Controller::REST;

    use parent 'Catalyst::Controller::REST';
    use DBIx::Class::ResultClass::HashRefInflator ();
    use POSIX 'strftime';

    __PACKAGE__->config->{map}{'application/vnd.ms-excel'} = 'SimpleExcel';

    sub books : Local ActionClass('REST') {}

    sub books_GET {
        my ($self, $c) = @_;

        my $rs = $c->model('MyDB::Book')->search({}, {
            order_by => 'author,title'
        });

        $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');

        my @t = map {
            [ @{$_}{qw/author title/} ]
        } $rs->all;

        my $entity = {
            header => ['Author', 'Title'], # will be bold
            rows => \@t,
    # the part before .xls, which is automatically appended
            filename => 'myapp-books-'.strftime('%m-%d-%Y', localtime)
        };

        $self->status_ok(
            $c,
            entity => $entity
        );
    }

In your javascript, to initiate a file download:

    // this uses jQuery
    function export_to_excel() {
        $('<iframe '
         +'src="/rest/books?content-type=application%2Fvnd.ms-excel">')
        .hide().appendTo('body');
    }

Note, the content-type query param is required if you're just linking to the
action. It tells L<Catalyst::Controller::REST> what you're serializing the data
as.

=head1 DESCRIPTION

Your entity should be either an array of arrays, or the more embellished format
described below and in the L</SYNOPSIS>.

If entity is a hashref, keys should be:

=head2 rows

Required. The array of arrays of rows.

=head2 header

Optional, an array for the first line of the sheet, which will be in bold.

=head2 column_widths

Optional, the widths in characters of the columns. Otherwise the widths are
calculated automatically from the data and header.

=head2 filename

The name of the file before .xls. Defaults to "data".

=cut

sub execute {
    my $self = shift;
    my ($controller, $c) = @_;

    my $stash_key = (
            $controller->config->{'serialize'} ?
                $controller->config->{'serialize'}->{'stash_key'} :
                $controller->config->{'stash_key'}
        ) || 'rest';

    my $data = $c->stash->{$stash_key};

    $data = { rows => $data } if reftype $data eq 'ARRAY';

    open my $fh, '>', \my $buf;
    my $workbook = Spreadsheet::WriteExcel->new($fh);
    my $worksheet = $workbook->add_worksheet;

    my ($row, $col) = (0,0);

    my @auto_widths;

# Write Header
    if (exists $data->{header}) {
        my $header_format = $workbook->add_format;
        $header_format->set_bold;
        for my $header (@{ $data->{header} }) {
            $auto_widths[$col] = length $header
                if $auto_widths[$col] < length $header;

            $worksheet->write($row, $col++, $header, $header_format);
        }
        $row++;
        $col = 0;
    }

# Write data
    for my $the_row (@{ $data->{rows} }) {
        for my $the_col (@$the_row) {
            $auto_widths[$col] = length $the_col
                if $auto_widths[$col] < length $the_col;

            $worksheet->write($row, $col++, $the_col);
        }
        $row++;
        $col = 0;
    }

# Set column widths
    $data->{column_widths} = \@auto_widths
        unless exists $data->{column_widths};

    for my $width (@{ $data->{column_widths} }) {
        $worksheet->set_column($col, $col++, $width);
    }
# Have to set the width of column 0 again, otherwise Excel loses it!
# I don't know why...
    $worksheet->set_column(0, 0, $data->{column_widths}[0]);
    $col = 0;

# Write the file
    my $filename = $data->{filename} || 'data';

    $workbook->close;
    $c->res->content_type('application/vnd.ms-excel');
    $c->res->header('Content-Disposition' =>
     "attachment; filename=${filename}.xls");
    $c->res->output($buf);

    1;
}

=head1 AUTHOR

Rafael Kitover, C<< <rkitover at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-catalyst-action-serialize-simpleexcel at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Catalyst-Action-Serialize-SimpleExcel>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SEE ALSO

L<Catalyst>, L<Catalyst::Controller::REST>, L<Catalyst::Action::REST>,
L<Catalyst::View::Excel::Template::Plus>, L<Spreadsheet::WriteExcel>,
L<Spreadsheet::ParseExcel>

=head1 TODO

=over 4

=item * Split into mutliple overridable methods.

=item * Multiple sheet support.

=back

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Catalyst::Action::Serialize::SimpleExcel

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Catalyst-Action-Serialize-SimpleExcel>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Catalyst-Action-Serialize-SimpleExcel>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Catalyst-Action-Serialize-SimpleExcel>

=item * Search CPAN

L<http://search.cpan.org/dist/Catalyst-Action-Serialize-SimpleExcel/>

=back

=head1 COPYRIGHT & LICENSE

Copyright (c) 2008 Rafael Kitover

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Catalyst::Action::Serialize::SimpleExcel
