#!perl

use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/lib";
use Catalyst::Test 'TestApp';
use Spreadsheet::ParseExcel ();

use Test::More tests => 10;
use Test::Deep;

ok((my $file  = get '/rest/a_o_a?content-type=application%2Fvnd.ms-excel'),
    'received file');
ok((my $excel = Spreadsheet::ParseExcel::Workbook->Parse(\$file)),
    'parsed file');
my $sheet = $excel->{Worksheet}[0];

cmp_deeply(
    read_sheet($sheet),
    [[1,2,3],[4,5,6]],
    'array_of_array -> sheet'
);

ok((my $resp = request '/rest/fancy?content-type=application%2Fvnd.ms-excel'),
    'received response');

is($resp->header('Content-Type'), 'application/octet-stream', 'Content-Type');

is($resp->header('Content-Disposition'), 'attachment; filename=mtfnpy.xls', 'Content-Disposition');

ok(($file = $resp->content), 'received file');

ok(($excel = Spreadsheet::ParseExcel::Workbook->Parse(\$file)), 'parsed file');

$sheet = $excel->{Worksheet}[0];

cmp_deeply(
# internal representation of column widths is as floats
# and for some reason there's a width set on the column beyond the last
    [ map int, @{ $sheet->{ColWidth} }[0..1] ],
    [ 10, 20 ],
    'column_widths'
);

cmp_deeply(
    read_sheet($sheet),
    [ [qw/Foo Bar/], [1,2], [3,4] ],
    'with options -> sheet'
);

sub read_sheet {
    my $sheet = shift;
    my $res;
    $sheet->{MaxRow} ||= $sheet->{MinRow};
    foreach my $row ($sheet->{MinRow} .. $sheet->{MaxRow}) {
        $sheet->{MaxCol} ||= $sheet->{MinCol};
        foreach my $col ($sheet->{MinCol} ..  $sheet->{MaxCol}) {
            my $cell = $sheet->{Cells}[$row][$col];
            if ($cell) {
                $res->[$row][$col] = $cell->{Val};
            }
        }
    }
    $res
}
