use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Registro' }
BEGIN { use_ok 'Registro::Controller::personas' }

ok( request('/personas')->is_success, 'Request should succeed' );


