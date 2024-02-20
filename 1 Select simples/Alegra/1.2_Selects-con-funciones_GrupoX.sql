------------------------------------------------------------------------------------------------
-- SELECT CON FUNCIONES
------------------------------------------------------------------------------------------------
/* 1
Mostrar la fecha actual de la siguiente forma:
Fecha actual
------------------------------
Sábado, 11 de febrero de 2027. 16:06:06

El día en palabras con la primera letra en mayúsculas, seguida de una coma, el día en números,
la palabra "de", el mes en minúscula en palabras, la palabra "de", el año en cuatro dígitos
finalizando con un punto. Luego la hora en formato 24h con minutos y segundos.
Y de etiqueta del campo "Fecha actual".
*/
select 
    rtrim(to_char(sysdate,'Day'))||', '||
    to_char(sysdate,'dd')||' de '||
    rtrim(to_char(sysdate,'month'))|| ' de '||
    to_char(sysdate,'yyyy')||'. '||to_char(sysdate,'hh24:mi:ss')  "Fecha actual"
from dual;

/* 2
Día en palabras de cuando se instalaron los componentes
del facility 1
*/
select to_char(installatedon,'Day')
from components
where facilityid = 1

/* 3
De los espacios, obtener la suma de áreas, cuál es el mínimo, el máximo y la media de áreas
del floorid 1. Redondeado a dos dígitos.
*/
select sum(grossarea), min(grossarea), max(grossarea), round(avg(grossarea),2)
from spaces
where floorid = 1;

/* 4
¿Cuántos componentes tienen espacio? ¿Cuántos componentes hay?
En el facility 1. Ej.
ConEspacio  Componentes
----------------------------
3500  4000
*/
select count(spaceid), count(*)
from components
where facilityid = 1;

/* 5
Mostrar tres medias que llamaremos:
-Media a la media del área bruta
-MediaBaja la media entre el área media y el área mínima
-MediaAlta la media entre el área media y el área máxima
de los espacios del floorid 1
Solo la parte entera, sin decimales ni redondeo.
*/
select 
    trunc(avg(grossarea)) Media,
    trunc((avg(grossarea)+min(grossarea))/2) MediaBaja,
    trunc((avg(grossarea)+max(grossarea))/2) MediaAlta
from spaces
where floorid = 1

/* 6
Cuántos componentes hay, cuántos tienen fecha inicio de garantia, cuántos tienen espacio, y en cuántos espacios hay componentes
en el facility 1.
*/
select count(*), count(warrantystarton), count(spaceid), count(distinct spaceid)
from components
where facilityid = 1;

/* 7
Mostrar cuántos espacios tienen el texto 'Aula' en el nombre
del facility 1.
*/
select count(spaceid)
from components
where facilityId = 1 and lower(name) like '%aula%';

/* 8
Mostrar el porcentaje de componentes que tienen fecha de inicio de garantía
del facility 1.
*/
select round(count(warrantystarton)*100 /count(*),2)
from components
where facilityid = 1;

/* 9
Listar las cuatro primeras letras del nombre de los espacios sin repetir
de la planta 1. 
En orden ascendente.
Ejemplo:
Aula
Area
Aseo
Pasi
Pati
Serv
*/
select distinct substr(name,1,4)
from spaces
where floorid = 1
order by 1 asc

/* 10
Número de componentes por fecha de instalación del facility 1
ordenados descendentemente por la fecha de instalación
Ejemplo:
Fecha   Componentes
-------------------
2021-03-23 34
2021-03-03 232
*/
select to_char(installatedon,'yyyy-mm-dd') Fecha,count(*) Componentes
from components
where facilityid = 1
group by to_char(installatedon,'yyyy-mm-dd')
order by 1 desc;

/* 11
Un listado por año del número de componentes instalados del facility 1
ordenados descendentemente por año.
Ejemplo
Año Componentes
---------------
2021 344
2020 2938
*/
select to_char(installatedon,'yyyy'),count(*)
from components
where facilityid = 1
group by to_char(installatedon,'yyyy')
order by 1 desc;

/* 12
Nombre del día de instalación y número de componentes del facility 1.
ordenado de lunes a domingo
Ejemplo:
Día         Componentes
-----------------------
Lunes    	503
Martes   	471
Miércoles	478
Jueves   	478
Viernes  	468
Sábado   	404
Domingo  	431
*/
select to_char(installatedon,'Day'), count(*)
from components
where facilityid = 1
group by to_char(installatedon,'Day'),to_char(installatedon,'d')
order by to_char(installatedon,'d');

/*13
Mostrar en base a los cuatro primeros caracteres del nombre cuántos espacios hay
del floorid 1 ordenados ascendentemente por el nombre.
Ejemplo.
Aula 23
Aseo 12
Pasi 4
*/
select  substr(name,1,4), count(*)
from spaces
where floorid = 1
group by substr(name,1,4)
order by 1 asc

/*14
Cuántos componentes de instalaron un Jueves
en el facilityid 1
*/
select count(*)
from components
where facilityid = 1 
and replace(to_char(installatedon,'Day'),' ','') = 'Jueves';

/*15
Listar el id de planta concatenado con un guión
seguido del id de espacio concatenado con un guión
y seguido del nombre del espacio.
el id del espacio debe tener una longitud de 3 caracteres
Ej. 3-004-Nombre
*/
select concat(concat(concat(concat(floorid,'-'),lpad(id,3,'0')),'-'),name)
from spaces;
 
------------------------------------------------------------------------------------------------
