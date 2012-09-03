package Registro::Controller::Certificado;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NOMBRE

Registro::Controller::Certificado - Controlador de operaciones de generación del certificado

=head1 DESCRIPCION

Este controlador maneja las operaciones referentes al certificado de participación. Actualmente, simplemente genera un certificado para la sede si la persona asistió.

=head1 METODOS

=cut


=head2 index 

=cut

sub index : Private {
	my ( $self, $c ) = @_;

	if ( $c->form->submitted && $c->form->validate ) {

		# Verificación de existencia
		unless ( Registro::Model::CDBI::Participantes->retrieve( correo => $c->request->param('correo') ) ) {
			$c->stash->{mensaje} = "Este usuario no est&aacute; registrado.";
			$c->stash->{template} = "personas-certificado-inicio.tt2";
			return;
		}

		# Verificación de datos introducidos
		unless ( verificaCodigo( $c->request->param('correo'), $c->request->param('codigo') ) ) {
			$c->stash->{mensaje} = "Los datos de autenticaci&oacute;n NO coinciden.";
			$c->stash->{template} = "personas-certificado-inicio.tt2";
			return;
		}

		# Verificamos que el participante haya asistido al evento
		# revisando el campo "asistio" en la tabla de Asistencia. Para ello
		# obtenemos al usuario llamándolo por su código secreto y verificamos
		# el campo asistió.
		my $elemento = Registro::Model::CDBI::Asistencia->retrieve( codigo => $c->request->param('codigo') );
		unless ( $elemento->asistio ) {
			$c->stash->{mensaje} = "Usted no est&aacute; registrado como asistente al evento.";
			$c->stash->{template} = "personas-certificado-inicio.tt2";
			return;
		}

		# Obtenemos el usuario de la tabla "participantes" llamándolo por su
		# correo electrónico.
		my $usuario = Registro::Model::CDBI::Participantes->retrieve( correo => $c->request->param('correo') );	

		# Fabricamos un mensaje que firmamos con GPG si se ha especificado
		# en registro.yml
                my $string = "El Comit&eacute; Organizador del " . $c->config->{evento} . " hace constar que <strong>" . $usuario->apellido . ', ' . $usuario->nombre . "</strong> particip&oacute; en este evento, realizado en " . $c->config->{sitio} . ", " . $c->config->{fecha} . " registr&aacute;ndose v&iacute;a Internet y asistiendo a los eventos realizados.";
		my $signed = 0;

		if ( $c->config->{gpg} ) {
	                my $gpg = new Crypt::GPG or $c->log->debug("Problemas creando el objeto de GPG::Crypt");
			$gpg->gpgopts( '--homedir ' . $c->config->{gpgdir} );
			$gpg->secretkey( $c->config->{gpgkeyid} );
			$gpg->passphrase( $c->config->{gpgpass} );
			$signed = $gpg->sign( $string );
			$signed =~ s#\n#<br />#g;
		}

		# Enviamos el mensaje a la variable "certificado" del stash
		$c->stash->{certificado} = $string . '<br /><br />' . $signed || $string;

		# Plantilla por defecto
		$c->stash->{template} = "personas-certificado-ver.tt2";

	} else {

		# Plantilla por defecto cuando el formulario no ha sido enviado
		# Si no especificamos nada, se usará root/personas/certificado.tt2
		$c->stash->{template} = "personas-certificado-inicio.tt2";

	}
}


=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
