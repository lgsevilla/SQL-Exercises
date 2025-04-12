SET SERVEROUTPUT ON
/*
BEGIN
   DBMS_OUTPUT.PUT_LINE('HOLA MUNDO!');
END;

DECLARE
x number:=&x;
y number:=&y;
z number;
BEGIN
    z := x + y;
    DBMS_OUTPUT.PUT_LINE(z);
END;



DECLARE 
X NUMBER:=&X;
BEGIN
    IF 
        X > 0
    THEN 
        DBMS_OUTPUT.PUT_LINE('Number is positive!');
    ELSIF 
        X < 0
    THEN 
        DBMS_OUTPUT.PUT_LINE('Number is negative!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Number is zero!');
    END IF;
END;

DECLARE 
X NUMBER:=&X;
BEGIN
    CASE 
        WHEN X > 0 THEN DBMS_OUTPUT.PUT_LINE('Number is positive!');
        WHEN X < 0 THEN DBMS_OUTPUT.PUT_LINE('Number is negative!');
        ELSE DBMS_OUTPUT.PUT_LINE('Number is zero!');
    END CASE;    
END;

*/

/* 
Crea un bloque anónimo que introduciendo una nota numérica por teclado del 0-10 muestre en pantalla su equivalente nominal. 
Por ejemplo si la nota es 8 deberá mostrar "Tu nota es: notable". 
Si la nota es no válida lo deberá mostrar en un mensaje. Utiliza la función CASE.
*/
/*
DECLARE 
GRADE NUMBER:=&GRADE;
BEGIN
    CASE 
        WHEN GRADE > 8 and GRADE < 11 THEN DBMS_OUTPUT.PUT_LINE('Tu nota de '|| GRADE ||' es un sobresaliente!');
        WHEN GRADE > 6 and GRADE < 9 THEN DBMS_OUTPUT.PUT_LINE('Tu nota de '|| GRADE ||' es un notable!');
        WHEN GRADE > 4 and GRADE < 7 THEN DBMS_OUTPUT.PUT_LINE('Tu nota de '|| GRADE ||' es un aprobado!');
        WHEN GRADE > 10  or GRADE < 0 THEN DBMS_OUTPUT.PUT_LINE('Nota no valida, introduce un numero entre 0 y 10!');
        ELSE DBMS_OUTPUT.PUT_LINE('Has suspendido, lo siento!');
    END CASE;    
END;
*/

/*
Escribe un bloque anónimo en PL/SQL que chequee si un determinado carácter introducido por teclado es una letra o un dígito.
*/

/*
DECLARE
    v_char CHAR(1);
    v_ascii NUMBER;
BEGIN
    v_char := '&ingrese_un_caracter';
    v_ascii := ASCII(v_char); //converts input into ASCII which is then checked below in CASE
    CASE
        WHEN (v_ascii BETWEEN ASCII('A') AND ASCII('Z')) OR (v_ascii BETWEEN ASCII('a') AND ASCII('z')) THEN //or WHEN (v_ascii BETWEEN 65 AND 90) OR (v_ascii BETWEEN 97 AND 122) THEN 
            DBMS_OUTPUT.PUT_LINE(v_char || ' es una letra.');
        WHEN (v_ascii BETWEEN ASCII('0') AND ASCII('9')) THEN //or WHEN (v_ascii BETWEEN 48 AND 57) THEN
            DBMS_OUTPUT.PUT_LINE(v_char || ' es un dígito.');
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_char || ' no es ni una letra ni un dígito.');
    END CASE;
END;
/
*/


/* Escribe un bloque anónimo en PL/SQL que imprima los primeros n numeros. Del 1 hasta el n introducido por teclado. */
/*
NORMAL LOOP
DECLARE
    countme NUMBER;
    x number := 1;
BEGIN
    countme := &countme;
    LOOP
        DBMS_OUTPUT.PUT_LINE(x);
        x:=x+1;
        EXIT WHEN x = countme;
    END LOOP;
END; 

FOR LOOP
DECLARE
    countme NUMBER;
BEGIN
    countme := &countme;
FOR I IN 1..countme 
    LOOP DBMS_OUTPUT.PUT_LINE(I);
    END LOOP;
END;

*/

/* Escribe un bloque anónimo en PL/SQL que saca la tabla de multiplicar hasta 10 de un número introducido por teclado. */
/*
DECLARE
    countme NUMBER;
BEGIN
    countme := &countme;
FOR I IN 1..10 
    LOOP DBMS_OUTPUT.PUT_LINE(I * countme);
    END LOOP;
END;

*/

/*Escribe un bloque anónimo en PL/SQL para imprimir los numeros primos desde el 1 hasta el 50. 
Un número primo es un número natural mayor que 1 que tiene únicamente dos divisores distintos: él mismo y el 1*/

/*
DECLARE
    x NUMBER;
    y NUMBER;
    is_prime BOOLEAN;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Numeros primos del 1 al 50:');
    FOR x IN 1..50 LOOP
        is_prime := TRUE;
        
        IF x = 1 THEN
            is_prime := FALSE;
        ELSE
            FOR y IN 2..SQRT(x) LOOP
                IF x MOD y = 0 THEN
                    is_prime := FALSE;
                    EXIT;
                END IF;
            END LOOP;
        END IF;
        IF is_prime THEN
            DBMS_OUTPUT.PUT_LINE(x);
        END IF;
    END LOOP;
END;
*/

/*Escribe un bloque anónimo en PL/SQL que devuelva el reverso de un número introducido por teclado. Si introduzco 2345 me devolverá 5432*/
/*
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
    DBMS_OUTPUT.PUT_LINE(reverse_y);
END;
*/

/* Escribe un bloque anónimo en PL/SQL que devuelva la serie fibonacci hasta la posición que indiquemos en el número introducido por teclado. 
La serie comienza con los números 0 y 1,​ y a partir de estos, cada término es la suma de los dos anteriores. 
La secuencia es la siguiente: 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377...*/

/*
DECLARE
    x NUMBER := 0;
    y NUMBER := 1;
    end_fibo NUMBER := &end_of_sequence;
    shifted NUMBER := 1;
BEGIN
    DBMS_OUTPUT.PUT_LINE(x);
    IF end_fibo > 0 THEN
        DBMS_OUTPUT.PUT_LINE(y);
    END IF;
    
    WHILE shifted <= end_fibo LOOP
        DBMS_OUTPUT.PUT_LINE(shifted);
        x := y;
        y := shifted;
        shifted := x + y;
    END LOOP;

END;

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
    DBMS_OUTPUT.PUT_LINE('Tu dices ' || x || ', yo digo ' || reverse_x || '!');
END;