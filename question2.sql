SET SERVEROUTPUT ON
     BEGIN
	  INSERT INTO students
	  VALUES('B001', 'Anne', 'Broder', 'junior', 3.9, 'broder@bu.edu');
          -- A PL/SQL cursor
          FOR cursor1 IN (SELECT * FROM courses)
          LOOP
            DBMS_OUTPUT.PUT_LINE(cursor1.dept_code || ', ' || cursor1.course_no || ', ' || cursor1.title);
          END LOOP;
     END;
/
