use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Registro' }
BEGIN { use_ok 'Registro::Controller::Logout' }

ok( request('/logout')->is_success, 'Request should succeed' );


