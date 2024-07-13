------------------------------------------------------------------------------------------------
-- SELECT con subcolsultas y JOINS
------------------------------------------------------------------------------------------------
/*1
Listar de la tabla facilities el id y nombre, 
además de la tabla floors el id, nombre y facilityid
*/
select 
    facilities.name,
    facilities.id, 
    floors.facilityid,
    floors.id,
    floors.name
from facilities
    join floors on facilities.id = floors.facilityid;

/*2
Lista de id de espacios que no están en la tabla de componentes (spaceid)
pero sí están en la tabla de espacios.
*/ 
select id 
from spaces 
where id not in (select spaceid from components);

/*3
Lista de id de tipos de componentes que no están en la tabla de componentes (typeid)
pero sí están en la tabla de component_types
*/
select id 
from component_types
where id not in (select typeid from components);

/*4
Mostrar de la tabla floors los campos: name, id;
y de la tabla spaces los campos: floorid, id, name
de los espacios 109, 100, 111
*/
select
    floors.name,
    floors.id,
    spaces.floorid,
    spaces.id,
    spaces.name
from floors
    join spaces on floors.id = spaces.floorid
where
    spaces.id in (109,110,111);

/*5
Mostrar de component_types los campos: material, id;
y de la tabla components los campos: typeid, id, assetidentifier
de los componentes con id 10000, 20000, 300000
*/
select 
    component_types.material,
    component_types.id,
    components.typeid,
    components.id,
    components.assetidentifier
from
    components
    join component_types on components.typeid = component_types.id
where
    components.id in (10000,20000,30000);

/*6
¿Cuál es el nombre de los espacios que tienen cinco componentes?
*/
select spaces.name
from spaces
    join components on spaces.id = components.spaceid
group by spaces.name
having count(*) = 5;

/*7
¿Cuál es el id y assetidentifier de los componentes
que están en el espacio llamado CAJERO?
*/
select 
    components.id,
    components.assetidentifier
from spaces
    join components on spaces.id = components.spaceid
where 
    spaces.name ='CAJERO';

/*8
¿Cuántos componentes
hay en el espacio llamado CAJERO?
*/
select 
    count(*)
from spaces
    join components on spaces.id = components.spaceid
where 
    spaces.name ='CAJERO';

/*9
Mostrar de la tabla spaces: name, id;
y de la tabla components: spaceid, id, assetidentifier
de los componentes con id 10000, 20000, 30000
aunque no tengan datos de espacio.
*/
select 
    spaces.name,
    spaces.id,
    components.spaceid,
    components.id,
    components.assetidentifier
from spaces
    full join components on spaces.id = components.spaceid
where 
    components.id in (10000,30000,20000)
order by 2 desc nulls first;

/*
10
Listar el nombre de los espacios y su área del facility 1
*/
select spaces.name, grossarea
from spaces 
    join floors on spaces.floorid = floors.id
where facilityid = 1;

/*11
¿Cuál es el número de componentes por facility?
Mostrar nombre del facility y el número de componentes.
*/
select facilities.name, count(*)
from facilities
    join components on facilities.id = components.facilityid
group by facilities.name;

/*12
¿Cuál es la suma de áreas de los espacios por cada facility?
Mostrar nombre del facility y la suma de las áreas 
*/
select facilities.name, sum(netarea)
from facilities
    join floors on facilities.id = floors.facilityid
    join spaces on floors.id = spaces.floorid
group by facilities.name;

/*13
¿Cuántas sillas hay de cada tipo?
Mostrar el nombre del facility, el nombre del tipo
y el número de componentes de cada tipo
ordernado por facility.
*/
select
    facilities.name,
    component_types.name, 
    count(*)
from component_types
    join components on component_types.id = components.typeid
    join facilities on facilities.id = components.facilityid
where
    lower(component_types.name) like '%silla%'
group by facilities.name,component_types.name
order by 1 asc;

--Ejemplo
--Alegra	Silla-Apilable_Silla-Apilable	319
--Alegra	Silla-Brazo escritorio_Silla-Brazo escritorio	24
--Alegra	Silla (3)_Silla (3)	24
--Alegra	Silla-Corbu_Silla-Corbu	20
--Alegra	Silla-Oficina (brazos)_Silla-Oficina (brazos)	17
--COSTCO	Silla-Apilable_Silla-Apilable	169
--COSTCO	Silla_Silla	40
--COSTCO	Silla-Corbu_Silla-Corbu	14
--COSTCO	Silla-Oficina (brazos)_Silla-Oficina (brazos)	188

/*
14
Listar nombre, código de asset, número de serie, el año de instalación, nombre del espacio,
de todos los componentes
del facility 1
que estén en un aula y no sean tuberias, muros, techos, suelos.
*/
select components.name, components.assetidentifier, serialnumber, installatedon, spaces.name
from components
    left join spaces on components.spaceid = spaces.id
where facilityid = 1
    and lower(spaces.name) like '%aula%'
    and lower(components.name) not like '%tube%'
    and lower(components.name) not like '%muro%'
    and lower(components.name) not like '%techo%'
    and lower(components.name) not like '%suelo%'
order by 1 desc;

/*
15
Nombre, área bruta y volumen de los espacios con mayor área que la media de áreas del facility 1.
*/
select spaces.name, grossarea, volume
from spaces 
    join floors on spaces.floorid = floors.id
where facilityid = 1 
    and grossarea > (
        select avg(grossarea) 
        from spaces 
            join floors on spaces.floorid = floors.id
        where facilityid = 1);

/*
16
Nombre y fecha de instalación (yyyy-mm-dd) de los componentes del espacio con mayor área del facility 1
*/
select name, to_char(installatedon,'yyyy-mm-dd') installatedon
from components
where facilityid = 1 
and spaceid in (
    select spaces.id
    from spaces join floors on spaces.floorid = floors.id 
    where facilityid=1 and grossarea = 
        (select max(grossarea) 
        from spaces join floors on spaces.floorid = floors.id
        where facilityid = 1)
        );

/*
17
Nombre y código de activo  de los componentes cuyo tipo de componente contenga la palabra 'mesa'
del facility 1
*/
select name, assetidentifier
from components
where facilityid = 1 
and typeid in (
    select id
    from component_types 
    where facilityid=1 and lower(name) like '%mesa%'
        );

/*
18
Nombre del componente, espacio y planta de los componentes
de los espacios que sean Aula del facility 1
*/
select components.name, spaces.name, floors.name
from components
    join spaces on components.spaceid = spaces.id
    join floors on spaces.floorid = floors.id
where components.facilityid = 1 
and lower(spaces.name) like '%aula%';

/*
19
Número de componentes y número de espacios por planta (nombre) del facility 1. 
Todas las plantas.
*/
select count(components.id), count(distinct spaces.id), floors.name
from components
    right join spaces on components.spaceid = spaces.id
    right join floors on spaces.floorid = floors.id
where components.facilityid = 1 
group by floors.name;

/*
20
Número de componentes por tipo de componente en cada espacio
de los componentes que sean mesas del facility 1
ordenados de forma ascendente por el espacio y descentente por el número de componentes.
Ejmplo:
Componentes    Tipo   Espacio
--------------------------------
12  Mesa-cristal-redonda    Aula 2
23  Mesa-4x-reclinable      Aula 3
1   Mesa-profesor           Aula 3
21  Mesa-cristal-redonda    Aula 12
*/
select count(components.id), component_types.name, spaces.name
from components
    join spaces on components.spaceid = spaces.id
    join component_types on components.typeid = component_types.id
where components.facilityid = 1
group by spaces.name,component_types.name
order by spaces.name asc, 1 desc;

/*
21
Mostrar el nombre de las Aulas y una etiqueda «Sillas» que indique
'BAJO' si el número de sillas es menor a 6
'ALTO' si el número de sillas es mayor a 15
'MEDIO' si está entre 6 y 15 inclusive
del facility 1
ordenado ascendentemente por el espacio
Ejemplo:
Espacio Sillas
--------------
Aula 1  BAJO
Aula 2  BAJO
Aula 3  MEDIO
*/
select spaces.name,
    case 
    when count(components.id) < 6 then 'BAJO'
    when count(components.id) > 15 then 'ALTO'
    else 'MEDIO'
    end Sillas
from components
    join spaces on components.spaceid = spaces.id
where components.facilityid = 1
    and lower(components.name) like '%silla%'
group by spaces.name
order by spaces.name asc;


/*
22
Tomando en cuenta los cuatro primeros caracteres del nombre de los espacios
del facility 1
listar los que se repiten e indicar el número.
En orden descendente por el número de ocurrencias.
Ejemplo:
Espacio Ocurrencias
Aula    18
Aseo    4
Hall    2
*/
select substr(spaces.name,1,4) Espacio, count(*) Ocurrencias
from
spaces join floors on spaces.floorid = floors.id
where facilityid = 1
group by substr(spaces.name,1,4)
having count(*) > 1
order by 2 desc;

/*
23
Nombre y área del espacio que mayor área bruta tiene del facility 1.
*/
select spaces.name, grossarea
from spaces 
    join floors on spaces.floorid = floors.id
where facilityid = 1 
    and grossarea = (
        select max(grossarea) 
        from spaces 
            join floors on spaces.floorid = floors.id
        where facilityid = 1);

/*
24
Número de componentes instalados entre el 1 de mayo de 2010 y 31 de agosto de 2010
y que sean grifos, lavabos del facility 1
*/
select count(*)
from components
    left join spaces on components.spaceid = spaces.id
where facilityid = 1
    and to_char(components.installatedon,'yyyy-mm-dd') between '2010-05-01' and '2020-08-31'
    and (lower(components.name)  like '%grifo%'
        or lower(components.name)  like '%lavabo%')
order by 1 desc;

/*
25
Un listado en el que se indique en líneas separadas
una etiqueta que describa el valor, y el valor:
el número de componentes en Aula 03 del facility 1, 
el número de sillas en Aula 03 del facility 1
el número de mesas o escritorios en Aula 03 del facility 1
Ejemplo:
Componentes 70
Sillas 16
Mesas 3
*/
select 'c',count(components.name)
from components
    left join spaces on components.spaceid = spaces.id
where facilityid = 1
    and spaces.name = 'Aula 03'
union all
select 'Sillas', count(*)
from components
    left join spaces on components.spaceid = spaces.id
where facilityid = 1
    and spaces.name = 'Aula 03'
    and lower(components.name) like '%silla%'
union all
Select 'Mesas', count(*)
from components
    left join spaces on components.spaceid = spaces.id
where facilityid = 1
    and spaces.name = 'Aula 03'
    and (lower(components.name) like '%mesa%' 
        or lower(components.name) like '%escritorio%')
;

/*
26
Nombre del espacio, y número de grifos del espacio con más grifos del facility 1.
*/
select spaces.name, count(components.name)
from components
left join spaces on components.spaceid = spaces.id
where facilityid = 1
    and lower(components.name) like '%grifo%'
group by spaces.name
having count(*) = (
    select max(count(*))
    from components
        left join spaces on components.spaceid = spaces.id
    where facilityid = 1
        and lower(components.name) like '%grifo%'
    group by spaces.name);

/*
27
Cuál es el mes en el que más componentes se instalaron del facility 1.
*/
select to_char(installatedon,'Month')
from components
where facilityid = 1
group by to_char(installatedon,'Month')
having count(*) = (
    select max(count(*))
    from components
    where facilityid = 1
    group by to_char(installatedon,'Month')
    );

/* 28
Nombre del día en el que más componentes se instalaron del facility 1.
Ejemplo: Jueves
*/
select to_char(installatedon,'Day')
from components
where facilityid = 1
having count(*) = (
    select max(count(*))
    from components
    where facilityid = 1
    group by to_char(installatedon,'Day'))
group by to_char(installatedon,'Day');

/*29
Listar los nombres de componentes que están fuera de garantía del facility 1.
*/
select  components.name
from components 
    join component_types on components.typeid = component_types.id
where components.facilityid = 1
    and (warrantystarton + component_types.warrantydurationparts * 365) < sysdate;


/*
30
Listar el nombre de los tres espacios con mayor área del facility 1
*/
select name, grossarea
from
(select rownum fila,spaces.name, grossarea
from spaces 
    join floors on spaces.floorid = floors.id
where facilityid = 1
order by grossarea desc) tmp
where rownum < 4;
------------------------------------------------------------------------------------------------
