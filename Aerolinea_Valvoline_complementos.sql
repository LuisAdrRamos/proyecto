use valvoline;
-- --------------- 1. definir roles y permisos en la base de datos ---------------
-- crear un rol de usuario
create role 'admin_role';

-- asignar permisos al rol de admin
grant select, insert, update, delete on aeropuerto to 'admin_role';
grant select, insert, update, delete on avion to 'admin_role';
grant select, insert, update, delete on vuelo to 'admin_role';
grant select, insert, update, delete on ticket to 'admin_role';
grant select, insert, update, delete on tripulante to 'admin_role';
grant select, insert, update, delete on asignacion_tripulacion to 'admin_role';
grant select, insert, update, delete on mantenimiento to 'admin_role';
grant select, insert, update, delete on historial_pasajero to 'admin_role';
grant select, insert, update, delete on log_actividad to 'admin_role';

-- crear un rol para usuario de solo lectura
create role 'read_user_role';

-- asignar permisos de solo lectura
grant select on aeropuerto to 'read_user_role';
grant select on avion to 'read_user_role';
grant select on vuelo to 'read_user_role';
grant select on ticket to 'read_user_role';
grant select on tripulante to 'read_user_role';
grant select on asignacion_tripulacion to 'read_user_role';
grant select on mantenimiento to 'read_user_role';
grant select on historial_pasajero to 'read_user_role';
grant select on log_actividad to 'read_user_role';

-- --------------- 2. cifrar datos sensibles ---------------
-- para insertar un nuevo pasajero con una contraseña cifrada
insert into pasajero (nombre, documento, email, telefono)
values 
('josué guerra', '1752370344', 'josue@email.com', '0964030442'),
('adrian ramos', '1714587245', 'adrian@email.com', '0964587614'),
('henry tonato ', '1768452793', 'henry@email.com', '0965487215');

-- cifrar la contraseña utilizando aes
set @password = 'contraseña123';
set @key = 'clave_secreta15'; 
alter table pasajero
add column contrasena varchar(255) not null;
alter table pasajero modify contrasena varbinary(255);

update pasajero
set contrasena = aes_encrypt(@password, @key);
set sql_safe_updates = 0;

select * from pasajero;
-- actualizar todas las contraseñas en la tabla 'pasajero'
update pasajero
set contrasena = aes_encrypt(@password, @key);

set sql_safe_updates = 1;
-- para consultar la contraseña desencriptada (para validación de login, por ejemplo)
select aes_decrypt(contrasena, @key) as contrasena
from pasajero
where documento = '1752370344';

select cast(aes_decrypt(contrasena, @key) as char) as contrasena
from pasajero
where documento = '1752370344';

-- --------------- 3. crear procedimientos almacenados y triggers ---------------
-- ------------ procedimientos ------------
-- primer procedimiento 
delimiter $$
create procedure agregar_vuelo(
    in p_codigo_vuelo varchar(20),
    in p_aeropuerto_salida int,
    in p_aeropuerto_llegada int,
    in p_fecha_salida datetime,
    in p_fecha_llegada datetime,
    in p_avion_id int
)
begin
    insert into vuelo (codigo_vuelo, aeropuerto_salida, aeropuerto_llegada, fecha_salida, fecha_llegada, avion_id)
    values (p_codigo_vuelo, p_aeropuerto_salida, p_aeropuerto_llegada, p_fecha_salida, p_fecha_llegada, p_avion_id);
end $$

delimiter ;
-- segundo procedimiento
delimiter $$

create procedure obtener_historial_vuelos(in p_documento varchar(20))
begin
    select p.nombre, v.codigo_vuelo, v.fecha_salida, v.fecha_llegada
    from pasajero p
    join historial_pasajero hp on p.id_pasajero = hp.pasajero_id
    join vuelo v on hp.vuelo_id = v.id_vuelo
    where p.documento = p_documento;
end $$

delimiter ;

-- tercer procedimiento 
delimiter $$

create procedure actualizar_estado_vuelo(in p_id_vuelo int, in p_estado varchar(20))
begin
    update vuelo
    set estado = p_estado
    where id_vuelo = p_id_vuelo;
end $$

delimiter ;


-- ------------ triggers ------------
-- primer trigger
delimiter $$

create trigger log_insert after insert on vuelo
for each row
begin
    insert into log_actividad (usuario, accion, tabla_afectada, fecha_hora)
    values ('admin', concat('inserción de vuelo con código ', new.codigo_vuelo), 'vuelo', now());
end $$

delimiter ;

-- segundo trigger
delimiter $$
create trigger after_mantenimiento_insert
after insert on mantenimiento
for each row
begin
    update avion
    set estado = 'mantenimiento'
    where id_avion = new.avion_id;
end $$
delimiter ;

-- ------------ vista de los procedimientos ------------
show procedure status where db = 'valvoline';
show create procedure agregar_vuelo;
show create procedure obtener_historial_vuelos;
show create procedure actualizar_estado_vuelo;

select routine_name 
from information_schema.routines 
where routine_type = 'procedure' and routine_schema = 'valvoline';


-- ------------ vista de los triggers ------------
show triggers like 'valvoline';
show create trigger log_insert;
show create trigger after_mantenimiento_insert;

select trigger_name
from information_schema.triggers
where trigger_schema = 'valvoline';

-- --------------- 4. implementar respaldos completos y en caliente ---------------
-- respaldo completo de la base de datos
-- se realiza mediante la interfaz del mysql workbench

-- --------------- 5. optimizar consultas con índices y explain ---------------
explain select * from vuelo where aeropuerto_salida = 1 and fecha_salida > '2025-01-01';

-- crea un índice en la columna 'documento' de la tabla 'pasajero'
create index idx_documento on pasajero(documento);
explain select * from pasajero where documento = '1752370344';

-- crear un índice en la columna 'email' de la tabla 'pasajero'
create index idx_email on pasajero(email);
explain select * from pasajero where email = 'josue@email.com';

-- crear un índice en la columna 'fecha_salida' de la tabla 'vuelo'
create index idx_fecha_salida on vuelo(fecha_salida);
explain select * from vuelo where fecha_salida = '2025-01-10';

-- crear un índice en la columna 'aeropuerto_salida' de la tabla 'vuelo'
create index idx_aeropuerto_salida on vuelo(aeropuerto_salida);
explain select * from vuelo where aeropuerto_salida = 1;

-- crear un índice en la columna 'aeropuerto_llegada' de la tabla 'vuelo'
create index idx_aeropuerto_llegada on vuelo(aeropuerto_llegada);
explain select * from vuelo where aeropuerto_llegada = 2;

-- consulta optimizada usando los índices sobre 'fecha_salida' y 'aeropuerto_salida'
explain select * from vuelo
where fecha_salida between '2025-01-01' and '2025-12-31'
and aeropuerto_salida = 1;

-- crear un índice en la columna 'vuelo_id' de la tabla 'ticket'
create index idx_vuelo_id on ticket(vuelo_id);
explain select t.id_ticket, v.codigo_vuelo 
from ticket t
join vuelo v on t.vuelo_id = v.id_vuelo
where v.estado = 'completado';

-- crear un índice en la columna 'rol_tripulante' de la tabla 'tripulante'
create index idx_rol_tripulante on tripulante(rol);
explain select * from tripulante
where rol = 'piloto';

-- crear un índice en la columna 'estado' de la tabla 'vuelo'
create index idx_estado_vuelo on vuelo(estado);
explain select * from vuelo
where estado = 'programado';

-- crear un índice en la columna 'pais_aeropuerto' de la tabla 'aeropuerto'
create index idx_pais_aeropuerto on aeropuerto(pais);
select * from aeropuerto where ciudad = 'quito';
