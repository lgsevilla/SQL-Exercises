/*
1. En un bloque anónimo, crea un array asociativo que tenga los siguientes valores y visualizalos mediante un bucle FOR.

Clave      Valor
1            INFORMATICA
2            MATEMATICAS
3            BIOLOGIA
4            LITERATURA
*/

DECLARE
    TYPE subject_array IS TABLE OF VARCHAR2(50) INDEX BY PLS_INTEGER;
    subjects subject_array;
BEGIN
    subjects(1) := 'INFORMATICA';
    subjects(2) := 'MATEMATICAS';
    subjects(3) := 'BIOLOGIA';
    subjects(4) := 'LITERATURA';
    
    FOR i IN 1..4 LOOP
        DBMS_OUTPUT.PUT_LINE('Clave: ' || i || ' - Valor: ' || subjects(i));
    END LOOP;
END;

/*
2. Crea un procedimiento llamado prueba_array1 donde cargaremos en un array asociativo los datos de los empleados de la tabla employees que pertenezcan a un determinado departamento.
         El departamento lo pasamos como argumento del procedimiento.
         La clave será un número desde el 1 hasta el total de empleados cargados.
         Por último visualizamos el nombre y apellidos de los empleados.
*/

CREATE OR REPLACE PROCEDURE prueba_array1(p_dept_id IN employees.department_id%TYPE) IS
    TYPE emp_rec IS RECORD (
        first_name employees.first_name%TYPE,
        last_name employees.last_name%TYPE
    );
    
    TYPE emp_array IS TABLE OF emp_rec INDEX BY PLS_INTEGER;
    employees_array emp_array;
    
    v_counter PLS_INTEGER := 0;
BEGIN
    FOR emp IN (
        SELECT first_name, last_name
        FROM employees
        WHERE department_id = p_dept_id
    ) LOOP
        v_counter := v_counter + 1;
        employees_array(v_counter).first_name := emp.first_name;
        employees_array(v_counter).last_name := emp.last_name;
    END LOOP;
    
    FOR i IN 1..v_counter LOOP
        DBMS_OUTPUT.PUT_LINE('Employee ' || i || ': ' ||
                            employees_array(i).first_name || ' ' ||
                            employees_array(i).last_name);
    END LOOP;
END;

BEGIN
    prueba_array1(60);
END;

/*
3. Repite el ejercicio anterior pero esta vez utilizando los atributos del cursor (%rowcount) y los métodos de los arrays (fisrt, last)
*/

CREATE OR REPLACE PROCEDURE prueba_array2(p_dept_id IN employees.department_id%TYPE) IS
    TYPE emp_rec IS RECORD (
        first_name  employees.first_name%TYPE,
        last_name   employees.last_name%TYPE
    );
    
    TYPE emp_array IS TABLE OF emp_rec INDEX BY PLS_INTEGER;
    employees_array emp_array;
    
    CURSOR emp_cur IS
        SELECT first_name, last_name
        FROM employees
        WHERE department_id = p_dept_id;
        
    idx PLS_INTEGER := 0;
BEGIN
    OPEN emp_cur;
    LOOP
        FETCH emp_cur INTO  employees_array(emp_cur%ROWCOUNT).first_name,
                            employees_array(emp_cur%ROWCOUNT).last_name;
        EXIT WHEN emp_cur%NOTFOUND;
    END LOOP;
    CLOSE emp_cur;
    
    FOR i IN employees_array.FIRST .. employees_array.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('Empleado ' || i || ': ' ||
                            employees_array(i).first_name || ' ' ||
                            employees_array(i).last_name);
    END LOOP;
END;

BEGIN
  prueba_array2(60); 
END;

/*
4. Crea una copia del procedimiento anterior llamada prueba_array2, pero en este caso:
         Hacemos un BULK COLLECT a la hora de cargar los datos
         Visualizamos también el nombre y apellido de cada empleado para comprobar que está OK. 
		 En esta ocasión deberemos usar la función COUNT para saber el tamaño del array.
*/

CREATE OR REPLACE PROCEDURE prueba_array3(p_dept_id IN employees.department_id%TYPE) IS
    TYPE emp_rec IS RECORD (
        first_name  employees.first_name%TYPE,
        last_name   employees.last_name%TYPE
    );
    
    TYPE emp_array IS TABLE OF emp_rec INDEX BY PLS_INTEGER;
    employees_array emp_array;
    
BEGIN
    SELECT first_name, last_name
    BULK COLLECT INTO employees_array
    FROM employees
    WHERE department_id = p_dept_id;
    
    FOR i IN 1 .. employees_array.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Empleado ' || i || ': ' ||
                            employees_array(i).first_name || ' ' ||
                            employees_array(i).last_name);
    END LOOP;
END;

BEGIN
  prueba_array3(60);  -- Usa cualquier department_id válido
END;

/*
5. Modifica el procedimiento anterior para que visualice
         El nombre y salario del primer empleado
         El nombre y salario del ultimo empleado
         Comprueba si temenos un empleado en el índice 200. Si no es así devuelve un mensaje del tipo “Empleado 200 inexistente”
         Elimina del ARRAY los empleados que ganen más de 5000 dolares. Visualiza el número de empleados antes y después del proceso.
         Por ultimo,visualiza el array con los empleados que han quedado. Antes de visualizar cada fila comprueba que no haya sido eliminada por el delete.
*/

CREATE OR REPLACE PROCEDURE prueba_array3(p_dept_id IN employees.department_id%TYPE) IS
    TYPE emp_rec IS RECORD (
        first_name  employees.first_name%TYPE,
        salary   employees.salary%TYPE
    );
    
    TYPE emp_array IS TABLE OF emp_rec INDEX BY PLS_INTEGER;
    employees_array emp_array;
    
    total_antes     PLS_INTEGER;
    total_despues   PLS_INTEGER;

BEGIN
    SELECT first_name, salary
    BULK COLLECT INTO employees_array
    FROM employees
    WHERE department_id = p_dept_id;
    
    total_antes := employees_array.COUNT;
    DBMS_OUTPUT.PUT_LINE('Total de empleados antes del borrado: ' || total_antes);
    
    IF employees_array.COUNT > 0 THEN
        DBMS_OUTPUT.PUT_LINE('PRIMERO -> Nombre: ' || employees_array(employees_array.FIRST).first_name ||
                            ' | Salario: ' || employees_array(employees_array.FIRST).salary);
        
        DBMS_OUTPUT.PUT_LINE('ULTIMO -> Nombre: ' || employees_array(employees_array.LAST).first_name ||
                            ' | Salario: ' || employees_array(employees_array.LAST).salary);
    END IF;
    
    IF employees_array.EXISTS(200) THEN
        DBMS_OUTPUT.PUT_LINE('Empleado en indice 200 -> Nombre: ' ||
                            employees_array(200).first_name ||
                            ' | Salario: ' || employees_array(200).salary);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Empleado 200 inexistente.');
    END IF;
    
    FOR i IN employees_array.FIRST .. employees_array.LAST LOOP
        IF employees_array.EXISTS(i) AND employees_array(i).salary > 5000 THEN
            employees_array.DELETE(i);
        END IF;
    END LOOP;
    
    total_despues := employees_array.COUNT;
    DBMS_OUTPUT.PUT_LINE('Total de empleados despues del borrado: ' || total_despues);
    
    DBMS_OUTPUT.PUT_LINE('Empleados restantes:');
    FOR i IN employees_array.FIRST .. employees_array.LAST LOOP
        IF employees_array.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE('Indice ' || i || ' -> Nombre: ' ||
                                employees_array(i).first_name ||
                                ' | Salario: ' || employees_array(i).salary);
        END IF;
    END LOOP;
END;

BEGIN
  prueba_array3(60); 
END;
