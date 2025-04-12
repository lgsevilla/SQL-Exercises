SET SERVEROUTPUT ON

/*
1. Crea un bloque anónimo PL/SQL que introduciendo un número por teclado diga si es par o impar. (Utiliza la función MOD)
*/

DECLARE 
    x NUMBER:= &x;
BEGIN
    IF x MOD 2 = 0 THEN
        DBMS_OUTPUT.PUT_LINE(x || ' es un numero par!');
    ELSE
        DBMS_OUTPUT.PUT_LINE(x || ' es un numero impar!');
    END IF;    
END;


/*
2. Crea un bloque anónimo en PL/SQL que pida un nombre por teclado. 
Deberemos pintar tantos asteriscos como letras tenga el nombre y utilizaremos un bucle FOR para ello. Por ejemplo Alberto --> *******
*/
DECLARE
    nombre_censurar VARCHAR2(100) := '&nombre_a_censurar';
    censurado VARCHAR2(100) := '';
    cuantas_letras NUMBER;
BEGIN
    cuantas_letras := LENGTH(nombre_censurar);
    FOR I in 1..cuantas_letras 
        LOOP
            censurado := censurado || '*';
        END LOOP;
    DBMS_OUTPUT.PUT_LINE(censurado);    
END;


/*
3. Crea un bloque anónimo en PL/SQL que analice si un número es palíndromo. 
Esto es, si se leen igual en los dos sentidos. Por ejemplo 12321 es palíndromo y 123 no lo es.
*/
DECLARE
    x NUMBER:=&x;
    y VARCHAR2(100);
    reverse_y VARCHAR2(100):='';
    position NUMBER;
BEGIN
    y := TO_CHAR(x);
    position := LENGTH(y);
    
    FOR I in REVERSE 1..position
        LOOP
            reverse_y := reverse_y || SUBSTR(y, I, 1);
        END LOOP;    
    DBMS_OUTPUT.PUT_LINE('Has introducido ' || x);
    IF 
        x = reverse_y
    THEN 
        DBMS_OUTPUT.PUT_LINE('y claro que es un palindromo!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('y obviamente no es un palindromo...');
    END IF;
END;


/*
4. Crea un bloque anónimo en PL/SQL que devuelva una cadena de caracteres introducida por teclado, al revés. (Utiliza la función SUBSTR).
*/
DECLARE
    x VARCHAR2(100) := '&x';
    reverse_x VARCHAR2(100):='';
    position NUMBER;
BEGIN
    position := LENGTH(x);
    
    FOR I in REVERSE 1..position
        LOOP
            reverse_x := reverse_x || SUBSTR(x, I, 1);
        END LOOP;    
    DBMS_OUTPUT.PUT_LINE('Has dicho ' || x || ' y yo digo ' || reverse_x || '!');
END;


/*
5. Crea un bloque anónimo en PL/SQL que introduciendo 
un número de empleado (employee_id) por teclado, devuelva su nombre(first_name), apellido(last name) y ciudad (city) en la que trabaja. 
En caso de que no exista un empleado con la id introducida lanzar una excepción 
predefinida NO_DATA_FOUND con un mensaje 'No existe ningún empleado con ese ID '.
*/
DECLARE
numero_empleado EMPLOYEES.EMPLOYEE_ID%TYPE := &numero_empleado;
nombre EMPLOYEES.FIRST_NAME%TYPE;
apellido EMPLOYEES.LAST_NAME%TYPE;
ciudad LOCATIONS.CITY%TYPE;
BEGIN  
    SELECT e.first_name, e.last_name, l.city INTO nombre, apellido, ciudad
    FROM EMPLOYEES e
    JOIN DEPARTMENTS d ON e.department_id = d.department_id
    JOIN LOCATIONS l ON d.location_id = l.location_id
    WHERE e.employee_id = numero_empleado;
    DBMS_OUTPUT.PUT_LINE('Empleado: ' || nombre || ' ' || apellido || ', Ciudad: ' || ciudad);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No existe ningún empleado con ese ID.');
END;


/*
6. Crea un bloque anónimo en PL/SQL que inserte un nuevo departamento en la tabla DEPARTMENTS. 
Para saber el DEPARTMENT_ID que debemos asignar al nuevo departamento, 
primero deberemos averiguar el valor máximo que existe en la tabla DEPARTMENTS y sumarle uno para la nueva clave. 

- Location_id debe ser 1000, manager_id debe ser 100 y Department_name debe ser “INFORMATICA”
- NOTA: en PL/SQL debemos usar COMMIT y ROLLBACK de la misma forma que lo hacemos en SQL. 
Por tanto, para validar definitivamente un cambio debemos usar COMMIT dentro del bloque PL/SQL. 
- Por si acaso, controlaremos mediante la excepción predefinida DUP_VAL_ON_INDEX 
que el registro que se introduce no tiene la clave primaria duplicada en la tabla y mostraremos el siguiente mensaje 
en caso de que se lance la excepción. 'No es posible duplicar la clave primaria'
*/
DECLARE
    nuevo_department_id NUMBER;
BEGIN
    SELECT NVL(MAX(department_id), 0) + 1 INTO nuevo_department_id FROM DEPARTMENTS;

    INSERT INTO DEPARTMENTS (department_id, department_name, manager_id, location_id)
    VALUES (nuevo_department_id, 'INFORMATICA', 100, 1000);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Nuevo departamento creado con ID: ' || nuevo_department_id);

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('No es posible duplicar la clave primaria.');
		ROLLBACK;
END;

/*
6.2 Crear otro bloque PL/SQL que modifique la LOCATION_ID del nuevo departamento a 1700.
*/
DECLARE
    nuevo_department_id NUMBER;
BEGIN
    SELECT department_id INTO nuevo_department_id 
    FROM DEPARTMENTS 
    WHERE department_name = 'INFORMATICA';

    UPDATE DEPARTMENTS 
    SET location_id = 1700 
    WHERE department_id = nuevo_department_id;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Se ha actualizado la LOCATION_ID a 1700 para el departamento ID: ' || nuevo_department_id);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('El departamento INFORMATICA no existe.');
        ROLLBACK;
END;

/*
6.3 Por último crea otro bloque PL/SQL que elimine ese departamento nuevo.
*/
DECLARE
    nuevo_department_id NUMBER;
BEGIN
    SELECT department_id INTO nuevo_department_id 
    FROM DEPARTMENTS 
    WHERE department_name = 'INFORMATICA';

    DELETE FROM DEPARTMENTS WHERE department_id = nuevo_department_id;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Se ha eliminado el departamento INFORMATICA con ID: ' || nuevo_department_id);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('El departamento INFORMATICA no existe, no se puede eliminar.');
        ROLLBACK;
END;

/*
7. Crea un bloque anónimo en PL/SQL que incremente el salario del empleado 115 en base a las siguientes condiciones: 
Si la experiencia es mayor que 20 años, incrementa el salario en un 20%. 
Si la experiencia es mayor que 10 años, incrementa el salario en un 10%. 
Si no incrementa el salario en un 5%. (Utiliza la función CASE)
*/

DECLARE
    experiencia NUMBER;
    salario_nuevo NUMBER;
    salario_antiguo NUMBER;
BEGIN
    SELECT FLOOR(MONTHS_BETWEEN(SYSDATE, hire_date) / 12), salary 
-- SELECT FLOOR((SYSDATE - hire_date) / 365) ya que FLOOR(MONTHS_BETWEEN(SYSDATE, hire_date) / 12) Puede dar resultados inexactos si el mes de contratación es diferente al mes actual."
    INTO experiencia, salario_antiguo
    FROM EMPLOYEES
    WHERE employee_id = 115;

    salario_nuevo := salario_antiguo * 
        CASE 
            WHEN experiencia > 20 THEN 1.2
            WHEN experiencia > 10 THEN 1.1
            ELSE 1.05
        END;

    UPDATE EMPLOYEES 
    SET salary = salario_nuevo
    WHERE employee_id = 115;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Empleado 115: Experiencia: ' || experiencia || ' años.');
    DBMS_OUTPUT.PUT_LINE('Salario actualizado de ' || salario_antiguo || ' a ' || salario_nuevo);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No existe un empleado con ID 115.');
        ROLLBACK;
END;
