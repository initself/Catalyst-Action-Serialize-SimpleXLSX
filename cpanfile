requires 'Catalyst::Controller::REST';
requires 'Spreadsheet::WriteExcel';
requires 'Excel::Writer::XLSX';
requires 'Catalyst::Exception';;
requires 'parent';
requires 'namespace::clean';

on 'test' => sub {
  requires 'Test::More';
  requires 'Spreadsheet::ParseExcel';
  requires 'Test::Deep';
};


