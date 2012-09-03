use strict;
use warnings;
use Test::More tests => 33;
use WWW::Mechanize;

#BEGIN { use_ok 'Catalyst::Test', 'Registro' }

my $a = WWW::Mechanize->new();
isa_ok( $a, "WWW::Mechanize");

my $r = $a->get( 'http://localhost/' );
ok( $r->is_success, 'el home de la aplicación abre' );

ok( $a->follow("Registro de participantes"), 'puedo ir al registro' );

foreach my $link ( $a->links) {
	isa_ok( $link, "WWW::Mechanize::Link");
	ok( defined($link), "link " . $link->text() . " definido" );
	ok ( $a->follow( $link->text() ), "puedo ir a " . $link->text() );
	$a->get( 'http://localhost/' );
}

