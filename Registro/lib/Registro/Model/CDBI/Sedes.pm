package Registro::Model::CDBI::Sedes;

use strict;

=head1 NAME

Registro::Model::CDBI::Sedes - CDBI Table Class

=head1 SYNOPSIS

See L<Registro>

=head1 DESCRIPTION

CDBI Table Class.

=cut

Registro::Model::CDBI::Sedes->has_many(usuarios => 'Registro::Model::CDBI::UsuarioSede');

=head1 AUTHOR

Jose Parrella,,,

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
