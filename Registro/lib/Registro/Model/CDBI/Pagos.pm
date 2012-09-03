package Registro::Model::CDBI::Pagos;

use strict;

=head1 NAME

Registro::Model::CDBI::Pagos - CDBI Table Class

=head1 SYNOPSIS

See L<Registro>

=head1 DESCRIPTION

CDBI Table Class.

=cut

Registro::Model::CDBI::Pagos->has_a(id_usuario => 'Registro::Model::CDBI::Usuarios');

=head1 AUTHOR

Jose Parrella,,,

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
