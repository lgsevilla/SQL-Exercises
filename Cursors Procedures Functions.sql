SET SERVEROUTPUT ON

/*
1. Crea un bloque anónimo con un cursor que visualice el nombre, apellido y salario de los empleados cuyo salario sea superior 
a 5000 ordenado por el nombre. Por cada cinco empleados visualizados, añade estos guiones a la derecha del quinto empleado. 
Utiliza un bucle LOOP para recorrer el cursor.
*/

DECLARE
	CURSOR C_MONEY IS
		SELECT FIRST_NAME, LAST_NAME, SALARY
		FROM EMPLOYEES
		WHERE SALARY > 5000
		ORDER BY FIRST_NAME;
		
	V_FIRST_NAME EMPLOYEES.FIRST_NAME%TYPE;
	V_LAST_NAME EMPLOYEES.LAST_NAME%TYPE;
	V_SALARY EMPLOYEES.LAST_NAME%TYPE;
	COUNTER NUMBER := 0;

BEGIN

	OPEN C_MONEY;
		LOOP
			FETCH C_MONEY INTO V_FIRST_NAME, V_LAST_NAME, V_SALARY;
			EXIT WHEN C_MONEY%NOTFOUND;
			
			COUNTER := COUNTER + 1;
			DBMS_OUTPUT.PUT_LINE(COUNTER || '. '|| V_FIRST_NAME || ' ' || V_LAST_NAME || ', Salario: ' || V_SALARY ||
				CASE WHEN MOD(COUNTER, 5) = 0 
					THEN '--------------------------------'
					ELSE ''
				END);
		END LOOP;
	CLOSE C_MONEY;
END;


/*
2. Realiza el mismo ejercicio utilizando un bucle FOR para recorrer el cursor.
*/

DECLARE
	CURSOR C_MONEY IS
		SELECT FIRST_NAME, LAST_NAME, SALARY
		FROM EMPLOYEES
		WHERE SALARY > 5000
		ORDER BY FIRST_NAME;

/* Ya no es necesario en FOR LOOPS		
	V_FIRST_NAME EMPLOYEES.FIRST_NAME%TYPE;
	V_LAST_NAME EMPLOYEES.LAST_NAME%TYPE;
	V_SALARY EMPLOYEES.LAST_NAME%TYPE;
	
*/
	COUNTER NUMBER := 0;
	
BEGIN
--	OPEN C_MONEY;	ya tampoco necesario
	FOR EMPSAL IN C_MONEY LOOP
		COUNTER := COUNTER + 1;
		DBMS_OUTPUT.PUT_LINE(COUNTER || '. '|| EMPSAL.FIRST_NAME || ' ' || EMPSAL.LAST_NAME || ', Salario: ' || EMPSAL.SALARY ||
			CASE WHEN MOD(COUNTER, 5) = 0 
				THEN '--------------------------------'
				ELSE ''
			END);
	END LOOP;
--	CLOSE C_MONEY; ya tampoco necesario
END;

/* 
3. Escribe un procedimiento que tome como parámetro un número entero y visualice el last_name y el salary de todos los empleados 
cuyo salario sea igual o superior al número especificado ordenado por el salario. Al finalizar, muestra el número de empleados 
que cumplen con el criterio utilizando los atributos del cursor.
*/

--Procedure guardado en esquema
SET SERVEROUTPUT ON

--Crear el procedure
CREATE OR REPLACE PROCEDURE SHOW_EMPLOYEE_ABOVE_SALARY(P_SALARY IN NUMBER) IS
    CURSOR C_EMP IS
        SELECT LAST_NAME, SALARY
        FROM EMPLOYEES
        WHERE SALARY >= P_SALARY
        ORDER BY SALARY;

    V_LAST_NAME EMPLOYEES.LAST_NAME%TYPE;
    V_SALARY EMPLOYEES.SALARY%TYPE;
BEGIN
    OPEN C_EMP;
    LOOP
        FETCH C_EMP INTO V_LAST_NAME, V_SALARY;
        EXIT WHEN C_EMP%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Empleado: ' || V_LAST_NAME || ', Salario: ' || V_SALARY);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Total empleados: ' || C_EMP%ROWCOUNT);
    CLOSE C_EMP;
END;

--Llamar al procedure
EXECUTE SHOW_EMPLOYEE_ABOVE_SALARY(10000);


/*
4. Escribe el procedimiento realizado en el ejercicio anterior pero usando un cursor FOR… LOOP. Observa las diferencias con la estructura anterior. 
Debemos tener en cuenta que el cursor estará cerrado al salir del bucle y no estarán disponibles sus atributos (en concreto %ROWCOUNT).
*/

--Se cierra el cursor despues de cada loop en el for..loop, por eso no se puede llamar dentro el %ROWCOUNT y tenemos que recurrir a un contador

CREATE OR REPLACE PROCEDURE SHOW_EMPLOYEE_ABOVE_SALARY_WITH_FOR(P_SALARY IN NUMBER) IS
    CURSOR C_EMP IS
        SELECT LAST_NAME, SALARY
        FROM EMPLOYEES
        WHERE SALARY >= P_SALARY
        ORDER BY SALARY;
    
	COUNTER NUMBER := 0;
BEGIN
    FOR EMP_ABV_SAL IN C_EMP LOOP
        COUNTER := COUNTER + 1;
        DBMS_OUTPUT.PUT_LINE('Empleado: ' || EMP_ABV_SAL.LAST_NAME || ', Salario: ' || EMP_ABV_SAL.SALARY);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Total empleados: ' || COUNTER);
END;

--probar
EXECUTE SHOW_EMPLOYEE_ABOVE_SALARY_WITH_FOR(10000)

/*
5. Crea una función almacenada llamada contarletras que tenga como argumentos una frase y un carácter, 
y devuelva el número de veces que aparece ese carácter en la frase.
*/

CREATE OR REPLACE FUNCTION CONTARLETRAS(P_FRASE IN VARCHAR2, P_CARACTER IN VARCHAR2) 
	RETURN NUMBER IS
	
	COUNTER NUMBER := 0;
BEGIN
	FOR I IN 1 .. LENGTH(P_FRASE) LOOP
		IF LOWER(SUBSTR(P_FRASE, I, 1)) = LOWER(P_CARACTER) THEN
			COUNTER := COUNTER + 1;
		END IF;
	END LOOP;
	RETURN COUNTER;
END;

--probar (no se hace execute ya que a diferencia de PROCEDURE, FUNCTION devuelve un valor)
SELECT CONTARLETRAS('Aventura Educativa', 'a') 
AS NUMERO_DE_LETRAS 
FROM DUAL;

--probar en un bloque anonimo:
DECLARE
    RESULTADO NUMBER;
BEGIN
    RESULTADO := CONTARLETRAS('Juan es una buena persona', 'a');
    DBMS_OUTPUT.PUT_LINE('Número de letras en la frase: ' || RESULTADO);
END;

/*
6. Realiza un programa que, utilizando un cursor y la función contarletras, cuente, para cada uno de los empleados que son 'Sales Manager', 
el número de Aes, Es, Íes, Oes y Úes que tiene su nombre completo. Cuentan mayúsculas y minúsculas.
*/

--como nuestra funcion ya tiene LOWER(), ya no tenemos que incluirlo ni aqui ni en el numero 7
DECLARE
	CURSOR C_SALES_MANAGER IS
		SELECT FIRST_NAME || ' ' || LAST_NAME AS FULL_NAME
		FROM EMPLOYEES
		WHERE JOB_ID = 'SA_MAN';
	
	V_NAME VARCHAR2(100);

BEGIN
	FOR PERSON IN C_SALES_MANAGER LOOP
		V_NAME := PERSON.FULL_NAME;
		
		DBMS_OUTPUT.PUT_LINE('Nombre de empleado: ' || V_NAME);
		DBMS_OUTPUT.PUT_LINE('A: ' || CONTARLETRAS(V_NAME, 'a'));
		DBMS_OUTPUT.PUT_LINE('E: ' || CONTARLETRAS(V_NAME, 'e'));
		DBMS_OUTPUT.PUT_LINE('I: ' || CONTARLETRAS(V_NAME, 'i'));
		DBMS_OUTPUT.PUT_LINE('O: ' || CONTARLETRAS(V_NAME, 'o'));
		DBMS_OUTPUT.PUT_LINE('U: ' || CONTARLETRAS(V_NAME, 'u'));
        DBMS_OUTPUT.PUT_LINE('------------------------------');
	END LOOP;
END;

/*
7. Realiza un programa que, utilizando un cursor y la función contarletras, escriba en pantalla 
los nombres de los empleados de 'Seattle' o 'London' en cuyos nombres completos hay justo dos 'A's. Cuentan mayúsculas y minúsculas.
*/

DECLARE
	CURSOR C_EMPLOYEE_CITY IS
		SELECT E.FIRST_NAME || ' ' || E.LAST_NAME AS FULL_NAME
		FROM EMPLOYEES E
		JOIN DEPARTMENTS D ON E.DEPARTMENT_ID = D.department_id
		JOIN LOCATIONS L ON D.LOCATION_ID = L.LOCATION_ID
		WHERE L.CITY IN ('Seattle', 'London');
		
	V_NAME VARCHAR2(100);
BEGIN
	FOR PERSON IN C_EMPLOYEE_CITY LOOP
		V_NAME := PERSON.FULL_NAME;
		IF CONTARLETRAS(V_NAME, 'a') = 2 THEN
			DBMS_OUTPUT.PUT_LINE('Empleado con 2 A''s: ' || V_NAME);
		END IF;
	END LOOP;
END;

