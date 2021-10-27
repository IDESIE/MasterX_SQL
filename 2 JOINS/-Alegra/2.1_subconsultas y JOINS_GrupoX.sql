------------------------------------------------------------------------------------------------
-- SELECT con subcolsultas y JOINS
------------------------------------------------------------------------------------------------
/*
1
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
2
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
3
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
4
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
5
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
6
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
7
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
8
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
9
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

/*
10
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
11
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
12
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
13
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
14
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
15
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

/* 16
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

/*17
Listar los nombres de componentes que están fuera de garantía del facility 1.
*/
select  components.name
from components 
    join component_types on components.typeid = component_types.id
where components.facilityid = 1
    and (warrantystarton + component_types.warrantydurationparts * 365) < sysdate;

------------------------------------------------------------------------------------------------
