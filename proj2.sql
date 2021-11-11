	CREATE OR REPLACE PACKAGE proj2 AS
	function new_log_id return number;
	procedure insert_student(sid in students.sid%type, firstname in students.firstname%type, lastname in students.lastname%type, status in students.status%type, gpa in students.gpa%type,
email in students.email%type);
	procedure show_logs;
	procedure show_students;
	procedure show_courses;
	procedure show_prerequisites;
	procedure show_classes;
	procedure show_enrollments;
	procedure print_info(si in students.sid%type);
	procedure print_pre(code in prerequisites.dept_code%type, no in prerequisites.course_no%type);
	procedure print_enr(cid in classes.classid%type);
end proj2;
/
show errors

CREATE OR REPLACE PACKAGE BODY proj2 AS
		function new_log_id
			RETURN number IS
			cnt number;
			strap varchar2(20) := '22';
		BEGIN
			select logid into cnt from (select logid from logs order by logid desc) where rownum = 1;
			return (cnt+1);
		END new_log_id;
		procedure insert_student(sid in students.sid%type, firstname in students.firstname%type, lastname in students.lastname%type, status in students.status%type, gpa in students.gpa%type,
		email in students.email%type) AS
		BEGIN
			INSERT INTO students("SID", "FIRSTNAME", "LASTNAME", "STATUS", "GPA", "EMAIL") VALUES(sid, firstname, lastname, status, gpa, email);
		END insert_student;
		procedure show_logs AS
		BEGIN
			FOR cursor1 IN (SELECT * FROM logs)
				LOOP
					dbms_output.put_line(lpad(to_char(cursor1.logid),4,'0') || ',' || cursor1.who || ',' || cursor1.time || ',' || cursor1.table_name || ',' || cursor1.operation || ',' 
					|| cursor1.key_value);
				END LOOP;
		END show_logs;
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
			cursor c1 is select * from students where sid = si;
			c1_rec c1%rowtype;
			cursor c3 is select * from students inner join enrollments on students.sid = enrollments.sid where enrollments.sid = si;
			c3_rec c3%rowtype;
		BEGIN
			OPEN c1;
			FETCH c1 INTO c1_rec;
			OPEN c3;
			FETCH c3 INTO c3_rec;
			IF c1%notfound = true THEN
				dbms_output.put_line('The sid is invalid');
			ELSIF c3%notfound = true THEN
				dbms_output.put_line('The student has not taken any course.');
			END IF;
			FOR c2 IN (SELECT * FROM students s INNER JOIN (enrollments e INNER JOIN classes c USING(classid)) USING(sid) WHERE sid = si)
				LOOP	
					dbms_output.put_line(c2.sid || ',' || c2.firstname || ',' || c2.lastname || ',' || c2.gpa || ',' || c2.classid || ',' || CONCAT(c2.dept_code, c2.course_no) 
					|| ',' || c2.semester || ',' || c2.year);
				END LOOP;
		END print_info;
		procedure print_pre(code in prerequisites.dept_code % type, no in prerequisites.course_no%type) AS
			cursor c1 is SELECT DISTINCT * FROM prerequisites p WHERE p.dept_code = code AND p.course_no = no;			
			c1_rec c1%rowtype;
		BEGIN
			OPEN c1;
			FETCH c1 INTO c1_rec;
			WHILE c1%found = true
			 	LOOP
					dbms_output.put_line(CONCAT(c1_rec.pre_dept_code , c1_rec.pre_course_no));
					FETCH c1 INTO c1_rec;
				END LOOP;
			CLOSE c1;
		END print_pre;
		procedure print_enr(cid in classes.classid%type) AS
			cursor c1 is SELECT s.sid as studentsid, e.sid as esid, c.classid as cclassid, c.semester, c.year, s.firstname, s.lastname, s.email FROM classes c INNER JOIN 
				(students s INNER JOIN enrollments e on s.sid = e.sid) ON c.classid = e.classid where cid = c.classid;
			c1_rec c1%rowtype;
			cursor c2 is SELECT * from classes where classes.classid = cid;
			c2_rec c2%rowtype;
			cursor c3 is SELECT * FROM enrollments e where e.classid = cid; 
			c3_rec c3%rowtype;
		BEGIN
			OPEN c2;
			FETCH c2 into c2_rec;
			IF c2%notfound = true THEN
				dbms_output.put_line('The cid is invalid.');
			END IF;
			OPEN c3;
			FETCH c3 into c3_rec;
			IF c3%notfound = true THEN
				dbms_output.put_line('No student is enrolled in the class.');
			END IF;
			OPEN c1;
			FETCH c1 into c1_rec;
		
			WHILE c1%found = true
				LOOP
					dbms_output.put_line(c1_rec.studentsid || c1_rec.firstname || c1_rec.lastname || c1_rec.email || c1_rec.cclassid 
					|| c1_rec.semester || c1_rec.year);
					FETCH c1 INTO c1_rec;
				END LOOP;
		END print_enr;
	END proj2;
/
show errors
