/*
1. Escribir un disparador de base de datos que permita auditar las modificaciones (solo updates) en la tabla EMPLOYEES insertando en 
la tabla AUDITAREMPLE (creada en la tarea de aprendizaje) los siguientes datos concatenados: 

• Fecha y hora. 
• Employee_ID que se ha modificado. (OLD)
• La operación de actualización: 'MODIFICACIÓN'. (La cadena de caracteres tal cual)
• El valor anterior y el valor nuevo de la columna modificada. Utilizaremos la función CASE y solamente guardaremos una columna en caso de que en el update se actualicen más de una. 

Comprobación: UPDATE employees SET first_name= 'sss' WHERE employee_id=100; Deberá introducir en la en la tabla AUDITAREMPLE, 
en la columna COL1 de tipo Varchar2 (200), lo siguiente: 02/04/20*13:36*100* MODIFICACION *Steven*sss 
*/

CREATE OR REPLACE TRIGGER t_audit_update_employees
AFTER UPDATE ON EMPLOYEES
FOR EACH ROW
DECLARE 
    v_log VARCHAR2(200);    
    
BEGIN
    v_log:= TO_CHAR(SYSDATE, 'DD/MM/YY*HH24:MI') || '*' || :OLD.employee_id || '*MODIFICACION*' ||
    
    CASE
        WHEN :OLD.first_name <> :NEW.first_name THEN
            :OLD.first_name || '*' || :NEW.first_name
        WHEN :OLD.last_name <> :NEW.last_name THEN
            :OLD.last_name || '*' || :NEW.last_name
        WHEN :OLD.email <> :NEW.email THEN
            :OLD.email || '*' || :NEW.email
        WHEN :OLD.salary <> :NEW.salary THEN
            TO_CHAR(:OLD.salary) || '*' || TO_CHAR(:NEW.salary)
        ELSE
            NULL
    END;
    
    IF v_log IS NOT NULL THEN
        INSERT INTO AUDITAREMPLE (col1) VALUES (v_log);
    END IF;
END;

/* 
2. Crea un disparador BEFORE UPDATE que cuando un departamento se traslade a otro lugar (diferente location_id), 
cada empleado de ese departamento tenga automáticamente un incremento de salario del 2%

Comprobación: UPDATE departments SET location_id=1700 WHERE department_id=20; Todos los empleados del departamento 20 deben ver su sueldo aumentado en un 2%
*/

CREATE OR REPLACE TRIGGER t_more_money_when_moving
BEFORE UPDATE ON DEPARTMENTS
FOR EACH ROW

BEGIN
    IF :OLD.location_id <> :NEW.location_ID THEN
        UPDATE EMPLOYEES
        SET salary = salary * 1.02
        WHERE department_id = :OLD.department_id;
    END IF;
END;

--test para antes y despues del update
SELECT e.employee_id, e.salary, d.location_id
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.department_id = 20

/* 
3. Escribe un disparador de base de datos que haga fallar cualquier operación de modificación del nombre o apellido de un empleado, 
o que suponga una subida de sueldo superior al 10%.

Comprobación posible: UPDATE employees SET first_name= 'sss' WHERE employee_id=100; Se lanzará un error con raise_application error.
*/

CREATE OR REPLACE TRIGGER t_anti_fraud
BEFORE UPDATE ON EMPLOYEES
FOR EACH ROW

BEGIN
    IF :OLD.first_name <> :NEW.first_name THEN
        RAISE_APPLICATION_ERROR(-20020, 'No se permite modificar el nombre del empleado.');
    END IF;
    
    IF :OLD.last_name <> :NEW.last_name THEN
        RAISE_APPLICATION_ERROR(-20021, 'No se permite modificar el apellido del empleado.');
    END IF;
    
    IF :NEW.salary > :OLD.salary * 1.10 THEN
        RAISE_APPLICATION_ERROR(-20022, 'No se permite un aumento de salario superior al 10%.');
    END IF;
END;

/* 
4. Crea un disparador que asegure que no se realizará ningún cambio en la tabla EMPLOYEES antes de las 6:00 de la mañana y después de las 22:00 de la noche.

Comprobación posible: Cambiar los horarios para no tener que esperar a la noche y realizar cualquier operación DML sobre la tabla.  Se lanzará un error con raise_application error.
*/

CREATE OR REPLACE TRIGGER t_estamos_cerrado
BEFORE INSERT OR DELETE OR UPDATE ON EMPLOYEES

BEGIN
    IF TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) < 6 OR TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) >= 22 THEN
        RAISE_APPLICATION_ERROR(-20030, 'No se permite modificar la tabla EMPLOYEES fuera del horario laboral (06:00–22:00).');
    END IF;
END;

/* 
5. Crea un trigger para impedir que, al INSERTAR un empleado, la suma de los salarios de los empleados pertenecientes al departamento del empleado insertado supere los 22000 euros.  
El trigger lo realizaremos para comprobar que al insertar nuevos no se supere esa cantidad. En la BD hay departamentos con sumas de salario más altas pero esas las dejaremos como están.

Comprobación: INSERT INTO EMPLOYEES VALUES (301,'Pepe','Perez','p@p','3123121','10/10/05','SA_MAN','10000','','','20');  Se lanzará un error con raise_application error.
*/

CREATE OR REPLACE TRIGGER t_within_budget
BEFORE INSERT ON EMPLOYEES
FOR EACH ROW
DECLARE
    v_salary_sum NUMBER;

BEGIN
    IF :NEW.department_id IS NOT NULL THEN
        SELECT NVL(SUM(salary), 0)
        INTO v_salary_sum
        FROM EMPLOYEES
        WHERE department_id = :NEW.department_id;
        
        v_salary_sum := v_salary_sum + :NEW.salary;
        
        IF v_salary_sum > 22000 THEN
            RAISE_APPLICATION_ERROR(-20050, 'Máximo de 22000 euros en salarios por departamento.');
        END IF;
    END IF;
END;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Trabajo previo a la tarea de evaluacion


/* Construir un disparador de base de datos que permita auditar las operaciones de inserción o borrado de datos 
que se realicen en la tabla EMPLOYEES según las siguientes especificaciones: */


-- En primer lugar se creará desde SQL*Plus la tabla AUDITAREMPLE con una única columna col1 de tipo VARCHAR2(200).

CREATE TABLE AUDITAREMPLE (
	col1 VARCHAR2(200)
);

/*
• Cuando se produzca cualquier manipulación se insertará una fila en dicha tabla que contendrá concatenada la siguiente información:
• Fecha y hora.
• Employee_ID y Last_Name que se han borrado o insertado.
• La operación de actualización que ha tenido lugar: 'INSERCIÓN' o 'BORRADO'
*/

CREATE OR REPLACE TRIGGER t_audit_employees
AFTER INSERT OR DELETE ON EMPLOYEES
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO AUDITAREMPLE (col1)
		VALUES (TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI') || '*' || :NEW.employee_id || '*' || :NEW.last_name || '*INSERCIÓN');
	ELSIF DELETING THEN
		INSERT INTO AUDITAREMPLE (col1)
		VALUES (TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI') || '*' || :OLD.employee_id || '*' || :OLD.last_name || '*BORRADO');
	END IF;
END;

-- Crea un disparador BEFORE DELETE sobre la tabla EMPLOYEES que impida borrar un registro si su JOB_ID contiene la cadena 'CLERK'.

CREATE OR REPLACE TRIGGER t_preserve_clerks
BEFORE DELETE ON EMPLOYEES 
FOR EACH ROW 
BEGIN
	--IF UPPER(:OLD.job_id) LIKE '%CLERK%' THEN
	IF INSTR(:OLD.job_id, 'CLERK') > 0 THEN
		RAISE_APPLICATION_ERROR(-20001, 'No se pueden eliminar empleados cuyo JOB_ID contenga "CLERK".');
	END IF;
END;

--Crea un disparador para asegurar que el salario de los empleados no se disminuye.

CREATE OR REPLACE TRIGGER t_no_salary_reduction
BEFORE UPDATE ON EMPLOYEES
FOR EACH ROW
BEGIN
	IF :NEW.salary < :OLD.salary THEN
		RAISE_APPLICATION_ERROR(-20002, 'No se puede reducir el salario de los empleados.');
	END IF;
END;

--Crea un disparador sobre la tabla EMPLOYEES para que al insertar un empleado no se permita que un empleado sea jefe de más de cinco empleados.

CREATE OR REPLACE TRIGGER t_limit_employees_per_manager
BEFORE INSERT ON EMPLOYEES
FOR EACH ROW
DECLARE 
	counter NUMBER;
BEGIN
	IF :NEW.manager_id IS NOT NULL THEN
		SELECT COUNT(*) INTO counter
		FROM EMPLOYEES
		WHERE manager_id = :NEW.manager_id;
		
		IF counter >= 5 THEN
			RAISE_APPLICATION_ERROR(-20003, 'No se permite asignar más de cinco empleados a un solo jefe.');
		END IF;
	END IF;
END;

--Observa el disparador para actualizar la tabla JOB_HISTORY que está creado por defecto en el esquema HR y realiza una prueba para comprobar su correcto funcionamiento.

UPDATE EMPLOYEES 
SET JOB_ID = 'IT_PROG'
WHERE EMPLOYEE_ID = 101;

SELECT * FROM JOB_HISTORY WHERE EMPLOYEE_ID = 101;

--Posible estructura del trigger:
CREATE OR REPLACE TRIGGER trg_update_job_history
BEFORE UPDATE OF job_id ON EMPLOYEES
FOR EACH ROW
BEGIN
    INSERT INTO JOB_HISTORY (employee_id, start_date, end_date, job_id, department_id)
    VALUES (:OLD.employee_id, :OLD.hire_date, SYSDATE, :OLD.job_id, :OLD.department_id);
END;
/

