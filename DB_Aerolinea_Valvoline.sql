create database valvoline;

use valvoline;

-- tabla: aeropuerto
create table aeropuerto (
    id_aeropuerto int auto_increment primary key,
    nombre varchar(100) not null,
    codigo_iata char(3) not null unique,
    ciudad varchar(100) not null,
    pais varchar(100) not null
);

-- tabla: avión
create table avion (
    id_avion int auto_increment primary key,
    modelo varchar(100) not null,
    capacidad int not null,
    matricula varchar(20) not null unique,
    estado enum('en servicio', 'mantenimiento', 'fuera de servicio') default 'en servicio'
);

-- tabla: pasajero
create table pasajero (
    id_pasajero int auto_increment primary key,
    nombre varchar(100) not null,
    documento varchar(20) not null unique,
    email varchar(100),
    telefono varchar(20)
);

-- tabla: vuelo
create table vuelo (
    id_vuelo int auto_increment primary key,
    codigo_vuelo varchar(20) not null unique,
    aeropuerto_salida int not null,
    aeropuerto_llegada int not null,
    fecha_salida datetime not null,
    fecha_llegada datetime not null,
    estado enum('programado', 'en vuelo', 'cancelado', 'completado') default 'programado',
    avion_id int not null,
    foreign key (aeropuerto_salida) references aeropuerto(id_aeropuerto) on delete cascade,
    foreign key (aeropuerto_llegada) references aeropuerto(id_aeropuerto) on delete cascade,
    foreign key (avion_id) references avion(id_avion) on delete cascade
);

-- tabla: ticket
create table ticket (
    id_ticket int auto_increment primary key,
    pasajero_id int not null,
    vuelo_id int not null,
    clase_asiento enum('economica', 'ejecutiva') default 'economica',
    numero_asiento varchar(10) not null,
    estado_ticket enum('activo', 'cancelado') default 'activo',
    precio decimal(10, 2) not null,
    check_in_realizado boolean default false,
    estado_embarque enum('pendiente', 'completado') default 'pendiente',
    foreign key (pasajero_id) references pasajero(id_pasajero) on delete cascade,
    foreign key (vuelo_id) references vuelo(id_vuelo) on delete cascade
);

-- tabla: tripulante
create table tripulante (
    id_tripulante int auto_increment primary key,
    nombre varchar(100) not null,
    rol enum('piloto', 'copiloto', 'azafata') not null,
    licencia varchar(50) not null unique,
    email varchar(100),
    telefono varchar(20),
    disponibilidad boolean default true
);

-- tabla: asignación de tripulación
create table asignacion_tripulacion (
    id_asignacion int auto_increment primary key,
    vuelo_id int not null,
    tripulante_id int not null,
    rol enum('piloto', 'copiloto', 'azafata') not null,
    foreign key (vuelo_id) references vuelo(id_vuelo) on delete cascade,
    foreign key (tripulante_id) references tripulante(id_tripulante) on delete cascade
);

-- tabla: mantenimiento
create table mantenimiento (
    id_mantenimiento int auto_increment primary key,
    avion_id int not null,
    fecha date not null,
    descripcion text,
    estado enum('pendiente', 'en proceso', 'completado') default 'pendiente',
    foreign key (avion_id) references avion(id_avion) on delete cascade
);

-- tabla: historial de pasajero
create table historial_pasajero (
    id_historial int auto_increment primary key,
    pasajero_id int not null,
    vuelo_id int not null,
    fecha_vuelo datetime not null,
    foreign key (pasajero_id) references pasajero(id_pasajero) on delete cascade,
    foreign key (vuelo_id) references vuelo(id_vuelo) on delete cascade
);

-- tabla: logs de actividad
create table log_actividad (
    id_log int auto_increment primary key,
    usuario varchar(100) not null,
    accion varchar(255) not null,
    tabla_afectada varchar(100),
    fecha_hora datetime default current_timestamp
);

-- índices adicionales para optimizar consultas comunes
create index idx_fecha_salida on vuelo(fecha_salida);
create index idx_aeropuerto_salida on vuelo(aeropuerto_salida);
create index idx_aeropuerto_llegada on vuelo(aeropuerto_llegada);

-- -------------------------------------------------------------------------------------------------

-- Registros para la tabla aeropuerto
insert into aeropuerto (nombre, codigo_iata, ciudad, pais) values
('Aeropuerto Internacional de Quito', 'UIO', 'Quito', 'Ecuador'),
('Aeropuerto Internacional de Guayaquil', 'GYE', 'Guayaquil', 'Ecuador'),
('Aeropuerto Internacional de Lima', 'LIM', 'Lima', 'Perú'),
('Aeropuerto Internacional de Bogotá', 'BOG', 'Bogotá', 'Colombia'),
('Aeropuerto Internacional de Santiago', 'SCL', 'Santiago', 'Chile'),
('Aeropuerto Internacional de Buenos Aires', 'EZE', 'Buenos Aires', 'Argentina'),
('Aeropuerto Internacional de Miami', 'MIA', 'Miami', 'Estados Unidos'),
('Aeropuerto Internacional de Madrid', 'MAD', 'Madrid', 'España'),
('Aeropuerto Internacional de México', 'MEX', 'Ciudad de México', 'México'),
('Aeropuerto Internacional de Sao Paulo', 'GRU', 'Sao Paulo', 'Brasil');

-- Registros para la tabla avion
insert into avion (modelo, capacidad, matricula, estado) values
('Airbus A320', 180, 'EC-1234', 'en servicio'),
('Boeing 737', 160, 'EC-5678', 'mantenimiento'),
('Embraer 190', 100, 'EC-9012', 'en servicio'),
('Airbus A330', 250, 'EC-3456', 'en servicio'),
('Boeing 787', 300, 'EC-7890', 'en servicio'),
('Airbus A380', 800, 'EC-2345', 'en servicio'),
('Boeing 747', 400, 'EC-6789', 'fuera de servicio'),
('Cessna 208', 12, 'EC-1011', 'en servicio'),
('Bombardier CRJ700', 75, 'EC-1213', 'mantenimiento'),
('Airbus A321', 200, 'EC-1415', 'en servicio');

-- Registros para la tabla pasajero
insert into pasajero (nombre, documento, email, telefono) values
('Adrian Ramos', '0102030405', 'adrian.ramos@gmail.com', '0987654321'),
('Josue Guerra', '0203040506', 'josue.guerra@gmail.com', '0987654322'),
('Carlos Rodríguez', '0304050607', 'carlos.rodriguez@example.com', '0987654323'),
('Ana Martínez', '0405060708', 'ana.martinez@example.com', '0987654324'),
('Luis Gómez', '0506070809', 'luis.gomez@example.com', '0987654325'),
('Sofía Torres', '0607080910', 'sofia.torres@example.com', '0987654326'),
('Diego Flores', '0708091011', 'diego.flores@example.com', '0987654327'),
('Valeria Morales', '0809101112', 'valeria.morales@example.com', '0987654328'),
('Daniela Castillo', '0910111213', 'daniela.castillo@example.com', '0987654329'),
('Pedro Vargas', '1011121314', 'pedro.vargas@example.com', '0987654330');

-- Registros para la tabla vuelo
insert into vuelo (codigo_vuelo, aeropuerto_salida, aeropuerto_llegada, fecha_salida, fecha_llegada, estado, avion_id) values
('UIO-GYE001', 1, 2, '2025-02-01 08:00:00', '2025-02-01 09:00:00', 'programado', 1),
('GYE-LIM002', 2, 3, '2025-02-01 10:00:00', '2025-02-01 13:00:00', 'programado', 2),
('LIM-BOG003', 3, 4, '2025-02-02 14:00:00', '2025-02-02 17:00:00', 'programado', 3),
('BOG-SCL004', 4, 5, '2025-02-03 08:00:00', '2025-02-03 12:00:00', 'programado', 4),
('SCL-EZE005', 5, 6, '2025-02-04 10:00:00', '2025-02-04 13:00:00', 'programado', 5),
('EZE-MIA006', 6, 7, '2025-02-05 09:00:00', '2025-02-05 16:00:00', 'programado', 6),
('MIA-MAD007', 7, 8, '2025-02-06 17:00:00', '2025-02-07 07:00:00', 'programado', 7),
('MAD-MEX008', 8, 9, '2025-02-07 10:00:00', '2025-02-07 15:00:00', 'programado', 8),
('MEX-GRU009', 9, 10, '2025-02-08 12:00:00', '2025-02-08 21:00:00', 'programado', 9),
('GRU-UIO010', 10, 1, '2025-02-09 06:00:00', '2025-02-09 13:00:00', 'programado', 10);

-- Registros para la tabla ticket
insert into ticket (pasajero_id, vuelo_id, clase_asiento, numero_asiento, estado_ticket, precio, check_in_realizado, estado_embarque) values
(1, 1, 'economica', '1A', 'activo', 100.00, false, 'pendiente'),
(2, 1, 'economica', '1B', 'activo', 100.00, false, 'pendiente'),
(3, 2, 'ejecutiva', '2A', 'activo', 300.00, false, 'pendiente'),
(4, 3, 'economica', '3A', 'activo', 150.00, false, 'pendiente'),
(5, 4, 'economica', '4A', 'activo', 200.00, false, 'pendiente'),
(6, 5, 'economica', '5A', 'activo', 250.00, false, 'pendiente'),
(7, 6, 'economica', '6A', 'activo', 400.00, false, 'pendiente'),
(8, 7, 'economica', '7A', 'activo', 500.00, false, 'pendiente'),
(9, 8, 'economica', '8A', 'activo', 350.00, false, 'pendiente'),
(10, 9, 'economica', '9A', 'activo', 450.00, false, 'pendiente');

-- Registros para la tabla tripulante
insert into tripulante (nombre, rol, licencia, email, telefono, disponibilidad) values
('Luis Ramos', 'piloto', 'LIC123', 'luis.ramos@gmail.com', '0987654301', true),
('Eduadr Guerra', 'copiloto', 'LIC124', 'eduard.guerra@gmail.com', '0987654302', true),
('José Torres', 'azafata', 'LIC125', 'jose.torres@example.com', '0987654303', true),
('Ana Castro', 'azafata', 'LIC126', 'ana.castro@example.com', '0987654304', true),
('Diego Fernández', 'piloto', 'LIC127', 'diego.fernandez@example.com', '0987654305', true),
('María Rojas', 'copiloto', 'LIC128', 'maria.rojas@example.com', '0987654306', true),
('Pedro Álvarez', 'azafata', 'LIC129', 'pedro.alvarez@example.com', '0987654307', true),
('Lucía Suárez', 'azafata', 'LIC130', 'lucia.suarez@example.com', '0987654308', true),
('Fernando Pérez', 'piloto', 'LIC131', 'fernando.perez@example.com', '0987654309', true),
('Daniela Gómez', 'copiloto', 'LIC132', 'daniela.gomez@example.com', '0987654310', true);

-- Registros para la tabla asignacion_tripulacion
insert into asignacion_tripulacion (vuelo_id, tripulante_id, rol) values
(1, 1, 'piloto'),
(1, 2, 'copiloto'),
(1, 3, 'azafata'),
(1, 4, 'azafata'),
(2, 5, 'piloto'),
(2, 6, 'copiloto'),
(2, 7, 'azafata'),
(3, 8, 'azafata'),
(3, 9, 'piloto'),
(3, 10, 'copiloto');

-- Registros para la tabla mantenimiento
insert into mantenimiento (avion_id, fecha, descripcion, estado) values
(2, '2025-01-20', 'Revisión de motores', 'pendiente'),
(9, '2025-01-22', 'Cambio de aceite', 'completado'),
(7, '2025-01-25', 'Inspección general', 'en proceso'),
(5, '2025-01-28', 'Reparación de fuselaje', 'pendiente'),
(4, '2025-01-30', 'Actualización de software', 'completado');

-- Registros para la tabla historial_pasajero
insert into historial_pasajero (pasajero_id, vuelo_id, fecha_vuelo) values
(1, 1, '2025-01-01 08:00:00'),
(2, 1, '2025-01-01 08:00:00'),
(3, 2, '2025-01-02 10:00:00'),
(4, 3, '2025-01-03 14:00:00'),
(5, 4, '2025-01-04 10:00:00'),
(6, 5, '2025-01-05 09:00:00'),
(7, 6, '2025-01-06 17:00:00'),
(8, 7, '2025-01-07 10:00:00'),
(9, 8, '2025-01-08 12:00:00'),
(10, 9, '2025-01-09 06:00:00');

-- Registros para la tabla log_actividad
insert into log_actividad (usuario, accion, tabla_afectada) values
('admin', 'creación', 'pasajero'),
('admin', 'creación', 'vuelo'),
('admin', 'modificación', 'avion'),
('admin', 'eliminación', 'ticket'),
('admin', 'creación', 'mantenimiento'),
('admin', 'modificación', 'tripulante'),
('admin', 'creación', 'historial_pasajero'),
('admin', 'modificación', 'aeropuerto'),
('admin', 'eliminación', 'asignacion_tripulacion'),
('admin', 'creación', 'log_actividad');

-- -----------------------------------------------------------------------------------------------

