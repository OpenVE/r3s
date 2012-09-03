use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Registro' }
BEGIN { use_ok 'Registro::Controller::Login' }

ok( request('/login')->is_success, 'Request should succeed' );


