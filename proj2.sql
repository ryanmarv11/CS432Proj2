CREATE OR REPLACE PACKAGE proj2 AS
	procedure insert_student(sid in students.sid%type, firstname in students.firstname%type, lastname in students.lastname%type, status in students.status%type, gpa in students.gpa%type,
email in students.email%type);
	procedure show_students;
	procedure show_courses;
	procedure show_prerequisites;
	procedure show_classes;
	procedure show_enrollments;
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
		procedure show_prerequisites AS
		BEGIN
			FOR c1 IN (SELECT * FROM prerequisites)
				LOOP	
					dbms_output.put_line(c1.dept_code || ',' || c1.course_no || ',' || c1.pre_dept_code|| ',' || c1.pre_course_no);
				END LOOP;
		END show_prerequisites;
		procedure show_classes AS
		BEGIN
			FOR c1 IN (SELECT * FROM classes)
				LOOP
					dbms_output.put_line(c1.classid || ',' || c1.dept_code || ',' || c1.course_no || ',' || c1.sect_no || ',' || c1.year || ',' ||  c1.semester || ',' || c1.limit ||','|| c1.class_size);
				END LOOP;	
		END show_classes;
		procedure show_enrollments AS
		BEGIN
			FOR c1 in (SELECT * FROM enrollments)
				LOOP
					dbms_output.put_line(c1.sid || ',' || c1.classid || ',' || c1.lgrade);
				END LOOP;
		END show_enrollments;
		procedure print_info(si in students.sid%type) AS
		BEGIN
			FOR c2 IN (SELECT * FROM students s INNER JOIN (enrollments e INNER JOIN classes c USING(classid)) USING(sid) WHERE sid = si)
				LOOP	
					dbms_output.put_line(c2.sid || ',' || c2.firstname || ',' || c2.lastname || ',' || c2.gpa || ',' || c2.classid || ',' || CONCAT(c2.dept_code, c2.course_no) 
					|| ',' || c2.semester || ',' || c2.year);
				END LOOP;
		END print_info;
	END proj2;
/
show errors
