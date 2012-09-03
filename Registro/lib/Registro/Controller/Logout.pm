package Registro::Controller::Logout;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Registro::Controller::Logout - Controlador para terminar sesión

=head1 DESCRIPTION

Este controlador permite terminar una sesion de usuario del sistema de registro

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
        my ($self, $c) = @_;
    
        # se cierra la sesion
        $c->logout;
    
        # Se redirecciona a la pagina inicial del sistema
        $c->response->redirect($c->uri_for('/'));
    }



=head1 AUTHOR

Christian Sánchez,�,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
