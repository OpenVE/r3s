package Registro::Model::CDBI::UsuarioSede;

use strict;

=head1 NAME

Registro::Model::CDBI::UsuarioSede - CDBI Table Class

=head1 SYNOPSIS

See L<Registro>

=head1 DESCRIPTION

CDBI Table Class.

=cut

Registro::Model::CDBI::UsuarioSede->has_a(id_usuario => 'Registro::Model::CDBI::Usuarios');
Registro::Model::CDBI::UsuarioSede->has_a(id_sede => 'Registro::Model::CDBI::Sedes');

=head1 AUTHOR

Jose Parrella,,,

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
