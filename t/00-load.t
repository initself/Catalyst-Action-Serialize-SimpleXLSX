#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Catalyst::Action::Serialize::SimpleExcel2007' );
}

diag( "Testing Catalyst::Action::Serialize::SimpleExcel2007 $Catalyst::Action::Serialize::SimpleExcel2007::VERSION, Perl $], $^X" );
