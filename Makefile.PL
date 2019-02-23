#!/usr/bin/env perl
use warnings;
use strict;
use ExtUtils::MakeMaker 6.64;

my $preop = 'perldoc -uT $(VERSION_FROM) | tee README.pod';

WriteMakefile(
  NAME          => 'Catalyst::Action::Serialize::SimpleXLSX',
  AUTHOR        => 'Mike Baas <mbaas@cpan.org>',
  VERSION_FROM  => 'lib/Catalyst/Action/Serialize/SimpleXLSX.pm',
  ABSTRACT_FROM => 'lib/Catalyst/Action/Serialize/SimpleXLSX.pm',
  ($ExtUtils::MakeMaker::VERSION >= 6.3002 ? ('LICENSE'=> 'perl') : ()),
  PL_FILES => {},
  CONFIGURE_REQUIRES => {
    'ExtUtils::MakeMaker' => 6.64,
  },
  BUILD_REQUIRES => {
    'Template' => 0,
  },
  PREREQ_PM => {
    'Exporter' => 0,
    'strict'   => 0,
    'warnings' => 0,
    'vars'     => 0,
    'Catalyst::Controller::REST' => 0,
    'Catalyst::Exception' => 0,
    'Excel::Writer::XLSX' => 0,
    'parent' => 0,
    'namespace::clean' => 0,
  },
  TEST_REQUIRES => {
    'Test::More' => 0.88,
    'Test::Deep' => 0,
    'Spreadsheet::ParseExcel' => 0,
  },
  dist => {
    COMPRESS => 'gzip -9f',
    SUFFIX => 'gz',
    PREOP => $preop,
  },
  clean => { FILES => 'Catalyst-Action-Serialize-SimpleXLSX-*' },
);


