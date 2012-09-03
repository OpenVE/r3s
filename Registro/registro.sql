/*	usuarios

	En esta tabla se almacenan los participantes del
	evento y sus datos personales.

	Los campos correo y codigo son unívocos. No se deben
	remover. Los participantes se identifican a través de
	estos campos.
	
	El campo nivel determina el nivel de acceso del usuario,
	por defecto va en "0", si vale "1" el usuario tiene acceso
	a partes administrativas.
*/

CREATE TABLE usuarios (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  nombre varchar(255) NOT NULL,
  apellido varchar(255) NOT NULL,
  correo varchar(255) UNIQUE NOT NULL,
  grupo varchar(255) default NULL,
  conocimiento varchar(255) default NULL,
  grado varchar(255) NOT NULL,
  profesion varchar(255) NOT NULL,
  codigo int(10) UNIQUE NOT NULL,
  nivel int(1) default 0
);

/*	sedes

	Las sedes del evento. Esta tabla es "estática", y el
	identificador principal es "id". Los nombres de las sedes
	van capitalizados.

	id: identificador de la sede
	nombre: nombre capitalizado de la sede
	fecha: fecha del evento (opcional)
*/

CREATE TABLE sedes (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  nombre varchar(255) UNIQUE NOT NULL,
  fecha varchar(255)
);

INSERT INTO sedes VALUES (3, "Caracas", "22/3");

/*	usuario_sede

	Participación de los usuarios por cada
	una de las sedes del evento.

	id_usuario: id del usuario en la tabla usuarios
	id_sede: id de la sede en la tabla sedes
	asistio: campo binario para verificar asistencia

	Relaciones:
	usuarios has many sedes
*/

CREATE TABLE usuario_sede (
  id_usuario int REFERENCES usuarios(id),
  id_sede int REFERENCES sedes(id) DEFAULT 3,
  asistio int(1) DEFAULT 0,
  PRIMARY KEY(id_usuario, id_sede)
);

/*	pagos

	En esta tabla se registran los pagos de los
	participantes.

	id_usuario: id del usuario en la tabla usuarios
	cedula: Cédula de Identidad del depositante
	deposito: Número del depósito
	monto: Monto nominal del depósito
	fecha: Fecha del depósito

	Relaciones:
	usuarios has many pagos
*/

CREATE TABLE pagos (
  id_usuario int REFERENCES usuarios,
  cedula varchar(255) NOT NULL,
  deposito varchar(255) NOT NULL,
  monto varchar(255) NOT NULL,
  fecha date NOT NULL,
  PRIMARY KEY(id_usuario)
);
