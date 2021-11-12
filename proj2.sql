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
	procedure q7_enroll(sid_in in students.sid%type, cid_in classes.classid%type);
	procedure drop_student(si in students.sid%type, cid in classes.classid%type);
	procedure delete_student(si in students.sid%type);
	procedure subp(si in enrollments.sid%type); 
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
				dbms_output.put_line('The student hasnt taken any course.');
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
			cursor c1 is SELECT * from
			(enrollments inner join students using(sid))
			inner join 
			(courses inner join classes using(dept_code, course_no)) using (classid)
			where classid = cid;
			c1_rec c1%rowtype;
			cursor c2 is SELECT * from classes where classes.classid = cid;
			c2_rec c2%rowtype;
			cursor c3 is SELECT * FROM enrollments e where e.classid = cid; 
			c3_rec c3%rowtype;
		BEGIN
			OPEN c2;
			FETCH c2 into c2_rec;
			OPEN c3;
			FETCH c3 into c3_rec;
			OPEN c1;
			FETCH c1 into c1_rec;
			IF c2%notfound = true THEN
				dbms_output.put_line('The cid is invalid.');
			ELSIF c3%notfound = true THEN
				dbms_output.put_line('No student is enrolled in the class.');
			ELSE
				WHILE c1%found = true
					LOOP
						dbms_output.put_line(c1_rec.sid || c1_rec.firstname || c1_rec.lastname || c1_rec.email 
						|| c1_rec.classid || c1_rec.semester || c1_rec.year);
						FETCH c1 INTO c1_rec;
				END LOOP;
			END IF;
		END print_enr;
procedure q7_enroll(sid_in in students.sid%type, cid_in in classes.classid%type) AS
                        cursor c1 is SELECT s.sid from students s where s.sid = sid_in;
                        c1_rec c1%rowtype;
                        cursor c2 is SELECT c.classid from classes c where c.classid = cid_in;
                        c2_rec c2%rowtype;
                        cursor c3 is SELECT c.limit, c.class_size from classes c where c.classid = cid_in;
                        c3_rec c3%rowtype;
                        cursor c4 is SELECT * FROM (SELECT e.classid from enrollments e where e.sid = sid_in) t1 WHERE t1.classid = cid_in;
                        c4_rec c4%rowtype;
                        -- alreadyInClass char(5);
                        cnt number;
                        cursor c5 is
                        SELECT t5.sid FROM
                        (SELECT e.sid FROM enrollments e,
                        (SELECT classid FROM classes,
                        (SELECT pre.pre_dept_code, pre.pre_course_no FROM prerequisites pre,
                        (SELECT c.dept_code, c.course_no FROM classes c WHERE c.classid = cid_in) t2
                        WHERE pre.dept_code=t2.dept_code AND pre.course_no=t2.course_no) t3
                        WHERE classes.dept_code=t3.pre_dept_code AND classes.course_no=t3.pre_course_no) t4
                        WHERE e.classid=t4.classid AND (e.lgrade='A' OR e.lgrade='B' OR e.lgrade='C')) t5
                        WHERE sid_in=t5.sid;
                     	c5_rec c5%rowtype;
 		BEGIN
                     	OPEN c1;
                        FETCH c1 into c1_rec;
                        OPEN c2;
                        FETCH c2 into c2_rec;
                        OPEN c3;
                        FETCH c3 into c3_rec;                        
                        OPEN c4;
                        FETCH c4 into c4_rec;                        
                        OPEN c5;
                        FETCH c5 into c5_rec;                        
                        IF c1%notfound = true THEN
                                dbms_output.put_line('sid not found');
                        ELSIF c2%notfound = true THEN
                                dbms_output.put_line('invalid classid');
                        ELSIF c3_rec.limit = c3_rec.class_size THEN
                                dbms_output.put_line('class full');
                        -- SELECT e.classid into already from enrollments e where e.sid = sid_in;
                        ELSIF c4%found = true THEN
                                dbms_output.put_line('already in this class');
                        	SELECT count(e.classid) into cnt from enrollments e where e.sid = sid_in;
                        -- dbms_output.put_line(cnt);
                        ELSIF cnt > 3 THEN
                                dbms_output.put_line('overloaded');
                        ELSIF c5%notfound = true THEN
                                -- dbms_output.put_line(c5_rec.classid);
                                dbms_output.put_line('Prerequisite courses havent been completed.');
                        ELSE
                        	insert into enrollments values(sid_in, cid_in, 'I');
                END q7_enroll;

		procedure drop_student(si in students.sid%type, cid in classes.classid%type) AS
			cursor c1 is select * from students where si = students.sid;
			c1_rec c1%rowtype;
			cursor c2 is select * from classes where cid = classes.classid;
			c2_rec c2%rowtype;
			cursor c3 is select * from students inner join enrollments using (sid) where sid = si and classid = cid;
			c3_rec c3%rowtype;
			cursor c4 is select * from 
			(students inner join enrollments using(sid)) 
			inner join
			(classes inner join prerequisites on classes.dept_code = prerequisites.pre_dept_code and classes.course_no = prerequisites.course_no)
			using(classid) 
			where sid = si and classid = cid;
			c4_rec c4%rowtype; 
		BEGIN
			OPEN c1;
			FETCH c1 into c1_rec;
			OPEN c2;
			FETCH c2 into c2_rec;
			OPEN c3;
			FETCH c3 into c3_rec;
			OPEN c4;
			FETCH c4 into c4_rec;
			IF c1%notfound = true THEN
				dbms_output.put_line('sid not found');
			ELSIF c2%notfound = true THEN
				dbms_output.put_line('classid not found');
			ELSIF c3%notfound = true THEN
				dbms_output.put_line('student not enrolled in this class');
			ELSIF c4%notfound = true THEN
				dbms_output.put_line('drop request rejected due to prerequisite requiremenets');
			ELSE
				delete from enrollments where sid = si and classid = cid;
			END IF;
		END drop_student;
		procedure delete_student(si in students.sid%type) AS
			cursor c1 is select * from students where si = sid;
			c1_rec c1%rowtype;
		BEGIN
			OPEN c1;
			FETCH c1 into c1_rec;
			IF c1%notfound = true THEN
				dbms_output.put_line('sid not found');
			ELSE
				delete from students where sid = si;
			END IF;
		END delete_student;
		procedure subp(si in enrollments.sid%type) AS
			cnt number;
		BEGIN
			select count(sid) into cnt from enrollments where enrollments.sid = si;
			dbms_output.put_line(cnt);
		END subp;
	END proj2;
/
show errors
