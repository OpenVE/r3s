package Registro::Controller::Registro;

use strict;
use warnings;

use base 'Catalyst::Controller::FormBuilder';	# C::C::FormBuilder!

use locale;                             # la paranoia de locales
use POSIX qw( locale_h );               # de bureado

use MIME::Lite::TT::HTML;		# para el correo

use Encode;				# yay utf8

=head1 NOMBRE

Registro::Controller::Registro - Controlador de las operaciones de registro

=head1 DESCRIPCION

Este controlador maneja las solicitudes de registro, proviendo la
accion "registro" para mostrar un formulario y agregar un participante.

=head1 METODOS

=cut

=head2 default

El método principal de registro carga un formulario diseñado con CGI::FormBuilder en un archivo YAML. Este método maneja la confirmación de datos

=cut

sub default : Local Form {
	my ( $self, $c ) = @_;

	my $form = $self->formbuilder;

        # More locale paranoia
        setlocale( LC_CTYPE, "es_VE.UTF-8" );

	# Si estamos volviendo al formulario por alguna razón,
	# no hacemos nada.
	if ( $form->submitted eq 'Volver' ) {
		return;
	}

	# Si el formulario está siendo enviado, procesamos
	if ( $form->submitted ) {
		my %datos;

		# Verificación de existencia del usuario
		if ( Registro::Model::CDBI::Usuarios->retrieve( correo => $c->req->param( 'correo' ) ) ) {
			$c->stash->{mensaje} = "El participante ya est&aacute; inscrito en el registro.";
			return 1;	
		}

		# Llenamos el stash y el formulario "fantasma"
		foreach my $field ( $form->field ) {
			$form->field( name => $field, type => 'hidden' );
			if ( defined( $c->req->param( $field ) ) ) {
				$form->field( name => "$field", value => $c->req->param( ${field} ), type => 'hidden' );
			}
			$datos{$field} = $c->req->param( $field );
		}

		# Ofrecemos dos botones, enviamos los datos al stash y
		# direccionamos los botones a /registro/confirmar
		$form->submit( 'Confirmar' );
		$c->stash->{datos} = \%datos;
		$form->action( "/registro/confirmar" );
	}

}

sub confirmar : Local Form {
	my ( $self, $c ) = @_;

	my $form = $self->formbuilder;
	my %datos;

	if ( $form->submitted eq 'Confirmar' ) {

		# Obtenemos un código para este registro y lo
		# pasamos al stash.
	    	my $codigo = generaCodigo();
		$c->stash->{codigo} = $codigo;

		# Nos traemos los campos llenados en el formulario
		# Esos campos los metemos en nuestro hash %vars
		# y los pasamos al stash de vuelta.
		my %vars;
	    	my @fields = $form->fields;
	    	foreach (@fields) {
	    		$vars{$_} = $c->request->param($_);
	    		$c->stash->{$_} = $vars{$_};
	    	}
		$vars{codigo} = $codigo;

		# Verificamos que el participante no esté en la
		# base de datos
		if ( agregaParticipante( $c, $codigo, \%vars, $form ) ) {
			$c->res->redirect("/registro");
		}

		# Template por defecto
	    	$c->stash->{template} = "registro/registro-final.tt";

	} else {
		$c->forward('/registro/default');
	}
}

=head2 agregaParticipante

Agrega al participante a la base de datos de participantes y
a la base de datos de asistentes (para su posterior verificacion)
Este metodo utiliza el modelo CDBI con la base de datos SQLite creada
por sqlite3 registro-db.db < registro.sql en el directorio raiz.

=cut

sub agregaParticipante {
	my ( $c, $codigo, $hashref, $form ) = @_;

	# Recupero el hashref
	my %vars = %$hashref;

	# Verifico si el participante ya estaba inscrito
	if ( Registro::Model::CDBI::Usuarios->retrieve( correo => $vars{'correo'} ) ) {
		$c->stash->{mensaje} = "El participante ya est&aacute; inscrito en el registro.";
		return 1;	
	}

	# Construyo un hash (%participante) solo con los datos necesarios
	# como los reporta Class::DBI, método ->columns.
	my %participante;
	my @columns = Registro::Model::CDBI::Usuarios->columns;
	foreach( @columns ) {
		$participante{$_} = encode_utf8( $vars{$_} ) if defined( $vars{$_} );
	}

	# Intento introducir el participante a la BD de participantes, conservando
	# al objeto "usuario" en $usuario para su uso posterior en relaciones has_many
	my $usuario;
	$usuario = Registro::Model::CDBI::Usuarios->find_or_create( \%participante );
	unless ( $usuario ) {
		$c->stash->{mensaje} = "Hubo un problema al agregarlo a la base de datos."; return 1;
	}

	# Para el campo multiple "sede", tomo todos los valores seleccionados por la persona
	# y luego agrego elementos a la tabla usuario_sede usando la relación has_many
	my @sedes = $form->field('sede');
	foreach ( @sedes ) {
		unless ( $usuario->add_to_sedes( {
			id_sede => $_
		} ) ) {
			$c->stash->{mensaje} = "Hubo un problema al agregarlo a la base de datos.";
			return 1;
		}

	}

	# Si hay información sobre pagos, intento introducir los
	# datos a la BD de pagos.
	if ( $vars{'cert'} ) {

		# Por sencillez, capturo en las variables.
		my $cedula = $vars{'cedula'};
		my $deposito = $vars{'deposito'};
		my $fecha = $vars{'fecha'};
		my $monto = $vars{'monto'};

		# Verifico que el usuario haya introducido los datos
		# requeridos.
		unless ( defined( $cedula ) && $cedula ne '' ) {
			$c->stash->{mensaje} = "Debe introducir su c&eacute;dula de identidad.";
			return 1;
		}
		unless ( defined( $deposito ) && $deposito ne '' ) {
			$c->stash->{mensaje} = "Debe introducir el n&uacute;mero del dep&oacute;sito";
			return 1;
		}
		unless ( defined( $fecha ) && $fecha ne '' ) {
			$c->stash->{mensaje} = "Debe introducir la fecha del dep&oacute;sito.";
			return 1;
		}

		# Introduzco los datos
		unless ( $usuario->add_to_pagos({
			cedula => $cedula,
			fecha => $fecha,
			deposito => $deposito,
			monto => $monto
		}) ) {
			$c->stash->{mensaje} = "Hubo un problema al inscribirlo en el sistema de pagos."; return 1;
		}

	}

	# Paso la fecha y hora local al stash
	$vars{epoch} = localtime();

	# Preparo y envío el correo de confirmación
	my $msg = MIME::Lite::TT::HTML->new(
		From	=>	'GUDICITE <info@gudicite.info.ve>',
		To	=>	"$vars{nombre} $vars{apellido} <$vars{correo}>",
		Bcc	=>	'deivinsontejeda@gmail.com',
		Subject	=>	'Registro: I Encuentro Unefista con el SL',
		TimeZone	=>	'America/Caracas',
		Encoding	=>	'quoted-printable',
		Template	=>	{
			html	=>	'/srv/www/registro.gudicite.info.ve/registro/Registro/root/mail.tt2'
		},
		Charset	=>	'utf8',
		TmplOptions	=>	{ ABSOLUTE => 1 },
		TmplParams	=>	\%vars
	);

	$msg->send();

	return 0;
}

=head2 generaCodigo

Genera un codigo aleatorio de nueve numeros. Probablemente sea mejor usar cualquier generador criptográficamente seguro, a-la-Crypt::Random o String::Random, pero agregaríamos otra dependencia no solo en un módulo sino en quizás la existencia de /dev/random y /dev/urandom, difíciles de implementar en sistemas no-Unix.

=cut

sub generaCodigo {
	my $codigo = ( time + int(rand(100000)) ) * int(rand(100));
	chop $codigo while (length($codigo) > 9);
	return $codigo;
}

=head1 AUTHOR

José Miguel Parrella Romero,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
