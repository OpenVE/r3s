package Registro::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

__PACKAGE__->config->{namespace} = '';

=head1 NAME

Registro::Controller::Root - Controlador principal de Registro

=head1 DESCRIPTION

Este controlador maneja las acciones en el namespace raiz
de la aplicacion de Registro, incluyendo default (la pagina principal)
y end (el metodo canonico para renderizar vistas, en este caso, TTSite).

=head1 METHODS

=cut

=head2 acerca

Muestra la pagina informativa "Acerca de", en el template "acerca.tt2"

=cut

sub acerca : Global {
    my ( $self, $c ) = @_;
}

=head2 default

Renderiza la pagina principal. Toma valores del archivo de configuracion
registro.yml y los pasa a las plantillas de TTSite.

=cut

sub default : Private {
    my ( $self, $c ) = @_;
}

=head2 end

Renderiza las vistas, si no ha sido hecho por otros metodos.

=cut 

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Jose Miguel Parrella Romero,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
