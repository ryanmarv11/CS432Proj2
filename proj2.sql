CREATE OR REPLACE PACKAGE proj2 AS
	procedure insert_student(sid in students.sid%type, firstname in students.firstname%type, lastname in students.lastname%type, status in students.status%type, gpa in students.gpa%type,
email in students.email%type);
	procedure show_students;
	procedure show_courses;
	procedure print_info(si in students.sid%type);
end proj2;
/
show errors

CREATE OR REPLACE PACKAGE BODY proj2 AS
		procedure insert_student(sid in students.sid%type, firstname in students.firstname%type, lastname in students.lastname%type, status in students.status%type, gpa in students.gpa%type,
		email in students.email%type) AS
		BEGIN
			INSERT INTO students("SID", "FIRSTNAME", "LASTNAME", "STATUS", "GPA", "EMAIL") VALUES(sid, firstname, lastname, status, gpa, email);
		END insert_student;

		procedure show_students AS
		BEGIN
			FOR cursor1 IN (SELECT * FROM students)
				LOOP
					dbms_output.put_line(cursor1.sid || ',' || cursor1.firstname || ',' || cursor1.lastname || ',' || cursor1.status || ',' || cursor1.gpa || ',' || cursor1.email );
				END LOOP;
		END show_students;
		procedure show_courses AS
		BEGIN
			FOR c1 IN (SELECT * FROM courses)
				LOOP
					dbms_output.put_line(c1.dept_code || ',' || c1.course_no || ',' || c1.title);
				END LOOP;
		END show_courses;
		procedure print_info(si in students.sid%type) AS
		BEGIN
			FOR c1 IN (SELECT * FROM students s INNER JOIN enrollments e USING (sid) WHERE sid = si)
				LOOP
					dbms_output.put_line( c1.firstname || ',' || c1.classid);
				END LOOP;
			FOR c2 IN (SELECT * FROM students s INNER JOIN (enrollments e INNER JOIN classes c USING(classid)) USING(sid) WHERE sid = si)
				LOOP	
					dbms_output.put_line(c2.firstname || ',' || c2.classid || ',' || c2.sid);
				END LOOP;
		END print_info;
	END proj2;
/
show errors
