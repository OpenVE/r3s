package Registro;

use strict;
use warnings;

use Catalyst::Runtime '5.70';
use Catalyst qw/ConfigLoader
		Static::Simple
		Authentication
		Authentication::Store::DBIC
		Authentication::Credential::Password
		Session
		Session::Store::FastMmap
		Session::State::Cookie
		Unicode
		Unicode::Encoding
		/;

our $VERSION = '0.6';

# Start the application
__PACKAGE__->setup;


=head1 NOMBRE

Registro - Aplicación de Registro para Eventos

=head1 USO

    script/registro_server.pl

=head1 DESCRIPCION

Esta aplicación maneja las operaciones básicas de registro de participantes y control de asistencia para eventos como Congresos y Conferencias. Está diseñada utilizando el framework MVC Catalyst, escrita en Perl y puede trabajar con casi cualquier RDBMS. El objetivo es abstraer el modelo del controlador y poder tener una aplicación reusable para cualquier evento. Esta aplicación hace un uso extensivo de Template Toolkit, Class::DBI y CGI::FormBuilder, proviendo templates por omisión diseñados para el III Congreso Nacional de Software Libre de Venezuela que son XHTML1.1/CSS compliant con el W3C.

En el desarrollo se han involucrado Alejandro Garrido Mota, Christian Sánchez y José Miguel Parrella Romero, además de muchos miembros del grupo de usuarios de Linux UNPLUG a través del canal de IRC #unplug de irc.unplug.org.ve.

=head1 VER TAMBIEN

L<Registro::Controller::Root>, L<Catalyst>

=head1 AUTORES

José Miguel Parrella Romero,,,

=head1 LICENCIA

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
