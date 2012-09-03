package Registro::Model::CDBI::Usuarios;

=head1 NOMBRE

Registro::Model::CDBI::Usuarios - Clase de la tabla CDBI correspondiente a usuarios

=head1 SINOPSIS

Ver L<Registro>

=head1 DESCRIPCION

Esta es una clase de la tabla "usuarios", que aprovecha las características del mapeador objeto-relacional Class::DBI de Perl.

=cut

Registro::Model::CDBI::Usuarios->has_many(sedes => 'Registro::Model::CDBI::UsuarioSede', 'id_usuario');
Registro::Model::CDBI::Usuarios->has_many(pagos => 'Registro::Model::CDBI::Pagos');

=head1 AUTOR

José Miguel Parrella Romero,,,

=head1 LICENCIA

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
