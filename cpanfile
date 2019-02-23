requires 'Catalyst::Controller::REST';
requires 'Excel::Writer::XLSX';
requires 'Catalyst::Exception';
requires 'parent';
requires 'namespace::clean';

on 'test' => sub {
  requires 'Test::More';
  requires 'Spreadsheet::XLSX';
  requires 'Test::Deep';
};


