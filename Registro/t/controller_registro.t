use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Registro' }
BEGIN { use_ok 'Registro::Controller::registro' }

ok( request('/registro')->is_success, 'Request should succeed' );


