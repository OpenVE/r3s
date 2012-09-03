package Registro::Model::CDBI;

use strict;
use base 'Catalyst::Model::CDBI';

__PACKAGE__->config(
    dsn           => 'dbi:mysql:RegGudicite',
    user          => 'UsuarioGUDICITE',
    password      => '4d15cr3c10n',
    options       => {},
    relationships => 1
);

=head1 NOMBRE

Registro::Model::CDBI - Componente del modelo CDBI

=head1 SINOPSIS

Ver L<Registro>

=head1 DESCRIPTION

Este es el componente del modelo Class::DBI de la aplicación. Aquí podemos cambiar el método DBI de acceso a la base de datos y efectivamente cambiar entre las bases de datos soportadas por DBI (MySQL, PostgreSQL, SQLite y muchísimas otras) sin alterar nuestra aplicación.

=head1 AUTOR

José Miguel Parrella Romero,,,

=head1 LICENCIA

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
