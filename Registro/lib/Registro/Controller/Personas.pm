package Registro::Controller::Personas;

use strict;
use warnings;
use Encode;
use base 'Catalyst::Controller::FormBuilder';	# C::C::FormBuilder!

=head1 NAME

Registro::Controller::Personas - Controlador de las operaciones de participantes

=head1 DESCRIPTION

Este controlador maneja las operaciones con personas (asistentes) en el Registro,
esto incluye la lista de participantes, la verificacion de asistencia y el
certificado de participación.

=head1 METHODS

=cut

=head2 autentificacion
Realiza el proceso de autentificacion para este controlador, solo los usuarios
con nivel de acceso "1" pueden ingresar a estos metodos
=cut

sub auto : Private {
	my ( $self, $c ) = @_;

	# Se permite que los usuarios entren sin login a personas/certificado
	if ( $c->action eq $c->controller('Personas')->action_for('certificado') ) {
                return 1;
        }

	# Sanidad en la información: si hay alguna irregularidad con el usuario
	# lo mandamos a /login
	unless ( $c->user_exists ) {
            # si no se ha iniciado sesion, se redirecciona a la pagina de login
            $c->response->redirect($c->uri_for('/login'));
            # se retorna 0 para detener la ejecucion de este controlador
            return 0;
        }
       
        # El usuario esta autentificado y con nivel de acceso correcto,
        # se prosigue con la ejecución del controlador
        return 1;
}


=head2 lista

Muestra una lista de los participantes.

=cut

sub lista : Local {
	my ( $self, $c, $sede, $number ) = @_;

	# Obtengo los nombres, valores y fechas de las sedes y las
	# mando al stash. Fuera.
	my @sedes = Registro::Model::CDBI::Sedes->retrieve_all;
	$c->stash->{sedes} = \@sedes;

	my %partNum;
	my %partConf;

	foreach ( @sedes ) {
		$partNum{$_->nombre} = Registro::Model::CDBI::UsuarioSede->search( id_sede => $_->id )->count;
		$partConf{$_->nombre} = Registro::Model::CDBI::UsuarioSede->search( id_sede => $_->id , asistio => 1 )->count;
	}

	$c->stash->{partNum} = \%partNum;
	$c->stash->{partConf} = \%partConf;
	
	# Si en el path no me viene un pager, asumo 0. Fuera.
	$number = 0 unless defined ( $number );

	my $iterator;

	# Intento obtener un objeto para la sede con el nombre especificado,
	# si no existe, devuelvo al usuario a la página informativa, con un
	# mensaje de error. Luego obtengo el ID de la sede.
	if ( defined ($sede) ) {
		unless ( Registro::Model::CDBI::Sedes->retrieve( id => $sede ) ) {
			$c->stash->{mensaje} = "Esa sede no está en la base de datos";
			return;
		}

		# Fabricamos un iterador sobre los elementos de la tabla
		# "UsuarioSede" -- el costo de esta operación es bajo porque
		# no estamos almacenando de hecho los datos de toda la tabla.
		# Esto es un feature de Class::DBI
		$iterator = Registro::Model::CDBI::UsuarioSede->search( id_sede => $sede );

		# Verifico que hayan participantes en la BD; de lo contrario,
		# salgo a la página informativa con un mensaje de error.
		unless ( $iterator ) {
			$c->stash->{mensaje} = "No hay participantes registrados en esta sede";
			return;
		}

		# Guardo en @elements solo diez elementos
		my @elements = $iterator->slice($number,$number+9);

		# Ahora de los diez elementos "llamo" al objeto de la tabla usuarios
		# gracias a la relación has_a de la tabla.
		my @current;	
		foreach ( @elements ) {
			push ( @current, $_->id_usuario );
		}
		
		my %asistencia;

		foreach ( @current ) {
			my $element;
			$element = Registro::Model::CDBI::UsuarioSede->retrieve( id_sede => $sede, id_usuario => $_->id );
			$asistencia{"$_->id"} = 1 if $element->asistio();
		}

		$c->stash->{asistencia} = %asistencia;

		# Envío un arrayref (\@) a la variable "current" del stash. Esto lo
		# puedo utilizar en TT para iterar sobre los elementos.
		$c->stash->{current} = \@current;

		# La variable "count" me permite mostrar cuantos elementos están
		# disponibles en el iterador. Lo paso al stash para que el template
		# lo use al estilo de "n elementos de [% count %] en la BD"
		$c->stash->{count} = $iterator->count;

		# Obtengo el valor del campo "id" para el último elemento del arreglo
		# de diez que estoy obteniendo y lo paso al stash.
		if ( $c->stash->{count} - $current[$#current]->id > 0 ) {
			$c->stash->{last} = $number + 10;
		}

		foreach my $elem ( @sedes ) {
			if ( $elem->id == $sede ) {
				$c->stash->{sede} = $elem;
			}
		}
	}
}

=head2 buscar

Busca participantes.

=cut

sub buscar : Local {
	my ( $self, $c ) = @_;

	foreach ( qw/correo codigo apellido/ ) {
		next unless ( defined( $c->req->param($_) ) && $c->req->param($_) ne '' );

		my @elements = Registro::Model::CDBI::Usuarios->search_like( $_ => $c->req->param($_) . '%' );

		unless ( @elements ) {
			$c->stash->{mensaje} = "No hay participantes que cumplan con los criterios buscados.";
			return;
		}

		# Envío un arrayref (\@) a la variable "current" del stash. Esto lo
		# puedo utilizar en TT para iterar sobre los elementos.
		$c->stash->{current} = \@elements;

		return;
	}

}

=head2 confirmar

Confirma la participación de un asistente.

=cut

sub confirmar : Local {
	my ( $self, $c, $correo, $sede ) = @_;

	# Revisión de parámetros

	unless ( defined ( $correo ) ) { 
		$c->stash->{mensaje} = "Debe especificar un correo electrónico para confirmar la asistencia del participante.";
		return;
	}

	unless ( defined ( $sede ) ) { 
		$c->stash->{mensaje} = "Debe especificar una sede para confirmar la asistencia del participante.";
		return;
	}

	# Trato de obtener un objeto del participante desde la BD
	my $usuario = Registro::Model::CDBI::Usuarios->retrieve( correo => $correo );

	# Si el participante no está registrado, devuelvo con error.
	unless ( $usuario ) {
		$c->stash->{mensaje} = "Este usuario no está registrado en el evento.";
		return;
	}

	my @sedes = $usuario->sedes( id_sede => $sede );

	foreach my $elem ( @sedes ) {
		if ( $elem->id_sede->id == $sede ) {
			if ( $elem->asistio() ) {
				$c->stash->{mensaje} = "El participante ya está confirmado.";
				return;
			} else {
				$elem->asistio(1);
				$elem->update;
				$c->stash->{mensaje} = "Participante confirmado.";
				return;
			}
		}
	}

	$c->stash->{mensaje} = "Este usuario no está registrado para participar en esa sede.";
	
}

=head2 borrar

Borra un participante de la BD.

=cut

sub borrar : Local {
	my ( $self, $c, $correo ) = @_;

	# Revisión de parámetros

	unless ( defined ( $correo ) ) { 
		$c->stash->{mensaje} = "Debe especificar un correo electrónico para borrar un participante.";
		return;
	}

	# Trato de obtener un objeto del participante desde la BD
	my $usuario = Registro::Model::CDBI::Usuarios->retrieve( correo => $correo );

	# Si el participante no está registrado, devuelvo con error.
	unless ( $usuario ) {
		$c->stash->{mensaje} = "Este usuario no está registrado en el evento.";
		return;
	}

	$usuario->delete;

	$c->stash->{mensaje} = "Participante eliminado.";
}

=head2 ver

Visualiza la información de un participante registrado.

=cut

sub ver : Local Form {
	my ( $self, $c, $correo ) = @_;

	my $form = $self->formbuilder;

	# Reviso que se pase el parámetro adecuado al método, de no
	# ser así lo devuelvo con error.
	unless ( defined ( $correo ) ) { 
		$c->stash->{mensaje} = "Debe especificar un correo electrónico en la dirección para ver información sobre el participante.";
		return;
	}

	# Trato de obtener un objeto del participante desde la BD
	my $participante = Registro::Model::CDBI::Usuarios->retrieve( correo => $correo );

	# Si el participante no está registrado, devuelvo con error.
	unless ( $participante ) {
		$c->stash->{mensaje} = "Este usuario no está registrado en el evento.";
		return;
	}

	my @candidates = Registro::Model::CDBI::UsuarioSede->search( id_usuario => $participante->id() );
	my %sedes;
	foreach ( @candidates ) {
		my $sede = Registro::Model::CDBI::Sedes->retrieve( id => $_->id_sede );
		$sedes{$_->id_sede} = $sede->nombre unless $_->asistio();
	}
	$c->stash->{sedes} = \%sedes;

	$c->stash->{correo} = $participante->correo();

	if ( $form->submitted ) {

		$participante->nombre( encode_utf8( $c->req->param('nombre') ) );
		$participante->apellido( encode_utf8( $c->req->param('apellido') ) );
		$participante->update;

		$c->response->redirect("/personas/lista");

	} else {

		# Lleno el formulario con los datos de la BD
		foreach ( $form->field ) {
			$form->field( name => $_ , value => $participante->$_ );
		}
	}
}

=head1 AUTOR

José Miguel Parrella Romero,,,

=head1 LICENCIA

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
