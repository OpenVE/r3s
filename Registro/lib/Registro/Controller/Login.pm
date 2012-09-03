package Registro::Controller::Login;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NOMBRE

Registro::Controller::Login - Controlador para la autentificacion

=head1 DESCRIPCION

Este controlador maneja el acceso de los usuarios a diversas áreas administrativas y semi-públicas mediante los campos de control en la BD de participantes.

=head1 METODOS

=cut


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    # obtenemos los datos para la autentificación desde el formulario
    my $correo = $c->request->params->{correo} || "";
    my $codigo = $c->request->params->{codigo} || "";

    #se hace la autentificacion
    if ($correo && $codigo) {
    	if ($c->login($correo, $codigo))  {
                #si se logra hacer la autentificacion, verificamos el nivel
                #de acceso del usuario
                #my $nivel = $c->user->nivel if $c->user_exists;
                if ($c->user->nivel ==  1) {
                #se redirecciona a la lista de personas
			$c->response->redirect( '/personas/buscar' );
                	return;
                }
                else {
                	#se envia el mensaje de error
               		$c->stash->{error_msg} = "No tienes los niveles de acceso para ingresar a este modulo.";
		   	#se elimina la sesion, por que si se deja la sesion
		   	#abierta el usuario puede acceder a estas secciones
		   	#quizas se pueda utilizar roles, pero para algo tan 
		   	#sencillo no hace falta
		   	$c->logout;
                }
            } else {
                # se envia el mensaje de error
                $c->stash->{error_msg} = "El correo o el password están
equivocados. Por favor verifique estos datos. O quiz&aacute;s no tienes los
niveles de acceso correctos.";
		
            }
    }

    #si no se autentifica, se envia a la pagina de login
    #$c->stash->{template} = 'login.tt2';
    
}

=head1 AUTOR

Christian Sánchez,�,

=head1 LICENCIA

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
