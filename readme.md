# actividad del ramo base de datos
- se basa en el cliente intentando migrar sus datos de un excel a una base de datos basada en posgresql

## enunciado
- Un cine de barrio lo tiene todo en hojas de Excel: en una planilla anotan qué película pasa en qué sala y a qué hora, y en otra van apuntando las entradas vendidas con su butaca. Funcionó por un tiempo, pero ya aparecieron los problemas de siempre: dos películas quedaron agendadas en la misma sala a la misma hora, se vendió dos veces la butaca C12, se registró un RUT que no existe, y al cierre nadie sabe cuánto recaudó cada función, cuáles son los horarios peak ni qué tan llenas quedan las salas.

- Te contratan para llevar ese caos a una base de datos PostgreSQL seria. Pero hay una condición central: todo tu trabajo vive en migraciones. El dueño del cine no quiere "una base que tú armaste a mano"; quiere poder tomar tus archivos, aplicarlos en orden sobre una base vacía y quedar con exactamente la misma base de datos que tú: mismas tablas, mismas reglas, mismas vistas y los mismos datos de prueba. Si algo no está en una migración, no existe

## requsitos
- [X] modelo
- [X] verificacion de correo, rut y reglas de negocio tal que limitador de asientos por sala, prevencion de solapamiento de funciones y limitador de ventas por funcion/sala
- [X] vistas para uso de aplicacion
- [X] generacion de pruebas
- [ ] consultas (parte-consultas.md y consultas.sql)