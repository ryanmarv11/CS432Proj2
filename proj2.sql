	CREATE OR REPLACE PACKAGE proj2 AS
	
 	--query 1
	function new_log_id return number;

 	--query 2
	procedure show_logs;
	procedure show_students;
	procedure show_courses;
	procedure show_prerequisites;
	procedure show_classes;
	procedure show_enrollments; 

	--query 3
	procedure insert_student(sid in students.sid%type, firstname in students.firstname%type, lastname in students.lastname%type, status in students.status%type, gpa in students.gpa%type,email in students.email%type); 

	--query 4
	procedure print_student_info(si in students.sid%type);
	
	--query 5
	procedure print_pre(code in prerequisites.dept_code%type, no in prerequisites.course_no%type);

	--query 6
	procedure print_enr(cid in classes.classid%type);

	--query 7
	procedure enroll_student(sid_in in students.sid%type, cid_in classes.classid%type);

	--query 8
	procedure drop_student(si in students.sid%type, cid in classes.classid%type);

	--query 9
	procedure delete_student(si in students.sid%type);
end proj2;
/
show errors

CREATE OR REPLACE PACKAGE BODY proj2 AS

		function new_log_id
			RETURN number IS
			cnt number;
			counted number;
		BEGIN
			select count(*) into counted from logs; --assigns counted to number of items in logs
			IF counted = 0 then			--if no logs exist, return default value of first log, 1
				return 1;
			END IF;
			select logid into cnt from (select logid from logs order by logid desc) where rownum = 1; --assigns counted to logid of most recent log
			return (cnt+1);				--return next logid
		END new_log_id;

		--nothing to complex, constraint checking is done with insert statement so no checking of the parameters is necesary
		procedure insert_student(sid in students.sid%type, firstname in students.firstname%type, lastname in students.lastname%type, status in students.status%type, gpa in students.gpa%type,
		email in students.email%type) AS
		BEGIN
			INSERT INTO students("SID", "FIRSTNAME", "LASTNAME", "STATUS", "GPA", "EMAIL") VALUES(sid, firstname, lastname, status, gpa, email);
		END insert_student;

		--prints all rows in logs table, each value in each row is separated by a comma
		procedure show_logs AS
		BEGIN
			FOR cursor1 IN (SELECT * FROM logs)
				LOOP
					dbms_output.put_line(lpad(to_char(cursor1.logid),4,'0') || ',' || cursor1.who || ',' || cursor1.time || ',' || cursor1.table_name || ',' || cursor1.operation || ',' 
					|| cursor1.key_value);
				END LOOP;
		END show_logs;

		--prints all rows in students table, each value in each row is separated by a comma
		procedure show_students AS
		BEGIN
			FOR cursor1 IN (SELECT * FROM students)
				LOOP
					dbms_output.put_line(cursor1.sid || ',' || cursor1.firstname || ',' || cursor1.lastname || ',' || cursor1.status || ',' || cursor1.gpa || ',' || cursor1.email );
				END LOOP;

		END show_students;

		--prints all rows in courses table, each value in each row is separated by a comma
		procedure show_courses AS
		BEGIN
			FOR c1 IN (SELECT * FROM courses)
				LOOP
					dbms_output.put_line(c1.dept_code || ',' || c1.course_no || ',' || c1.title);
				END LOOP;
		END show_courses;

		--prints all rows in prerequisites table, each value in each row is separated by a comma
		procedure show_prerequisites AS
		BEGIN
			FOR c1 IN (SELECT * FROM prerequisites)
				LOOP	
					dbms_output.put_line(c1.dept_code || ',' || c1.course_no || ',' || c1.pre_dept_code|| ',' || c1.pre_course_no);
				END LOOP;
		END show_prerequisites;

		--prints all rows in classes table, each value in each row is separated by a comma
		procedure show_classes AS
		BEGIN
			FOR c1 IN (SELECT * FROM classes)
				LOOP
					dbms_output.put_line(c1.classid || ',' || c1.dept_code || ',' || c1.course_no || ',' || c1.sect_no || ',' || c1.year || ',' ||  c1.semester || ',' || c1.limit ||','|| c1.class_size);
				END LOOP;	
		END show_classes;

		--prints all rows in enrollments table, each value in each row is separated by a comma
		procedure show_enrollments AS
		BEGIN
			FOR c1 in (SELECT * FROM enrollments)
				LOOP
					dbms_output.put_line(c1.sid || ',' || c1.classid || ',' || c1.lgrade);
				END LOOP;
		END show_enrollments;

		--prints all of a students info along with all info on the classes he or she both is taking and has taken
		procedure print_student_info(si in students.sid%type) AS
			cursor c1 is select * from students where sid = si;
			c1_rec c1%rowtype;
			cursor c3 is select * from students inner join enrollments on students.sid = enrollments.sid where enrollments.sid = si;
			c3_rec c3%rowtype;
		BEGIN
			OPEN c1;
			FETCH c1 INTO c1_rec;
			OPEN c3;
			FETCH c3 INTO c3_rec;
			IF c1%notfound = true THEN						--verifies that the student exists in the students table
				dbms_output.put_line('The sid is invalid');
			ELSIF c3%notfound = true THEN
				dbms_output.put_line('The student hasnt taken any course.');	--verifies that the student is/was enrolled in at least one course
			ELSE
			--print info of student in students table along with all info of classes currently being taken or previously taken
			FOR c2 IN (SELECT * FROM students s INNER JOIN (enrollments e INNER JOIN classes c USING(classid)) USING(sid) WHERE sid = si)
				LOOP	
					dbms_output.put_line(c2.sid || ',' || c2.firstname || ',' || c2.lastname || ',' || c2.gpa || ',' || c2.classid || ',' || CONCAT(c2.dept_code, c2.course_no) 
					|| ',' || c2.semester || ',' || c2.year);
				END LOOP;
			END IF;
		END print_student_info;

		--prints all direct and indirect prerequisites of a certain class
		procedure print_pre(code in prerequisites.dept_code % type, no in prerequisites.course_no%type) AS
			cursor c1 is SELECT DISTINCT * FROM prerequisites p CONNECT BY PRIOR course_no = pre_course_no and dept_code = pre_dept_code;	--recursively gets all direct and indirect prerequisites for a course given dept_code and course_no		
			c1_rec c1%rowtype;
		BEGIN
			OPEN c1;
			FETCH c1 INTO c1_rec; --get first prerequisite in "list" of prerequisites (list is in quotes because it isn't a list data structure but list in the colloquial sense)
			WHILE c1%found = true --loop for each prerequisite in cursor
			 	LOOP
					dbms_output.put_line(CONCAT(c1_rec.pre_dept_code , c1_rec.pre_course_no));
					FETCH c1 INTO c1_rec; --gets next prerequisite 
				END LOOP;
			CLOSE c1;
		END print_pre;

		procedure print_enr(cid in classes.classid%type) AS
			cursor c1 is SELECT * from
			(enrollments inner join students using(sid))
			inner join 
			(courses inner join classes using(dept_code, course_no)) using (classid) --(gets all enrollments of students inner joined on sid) that is then inner joined with (courses and classes inner joined on same dept_code and course_no) on classid. Results in all student, enrollment, class, and course info based on given classid
			where classid = cid;
			c1_rec c1%rowtype;
			cursor c2 is SELECT * from classes where classes.classid = cid;
			c2_rec c2%rowtype;
			cursor c3 is SELECT * FROM enrollments e where e.classid = cid; 
			c3_rec c3%rowtype;
		BEGIN
			OPEN c1;
			FETCH c1 into c1_rec;
			OPEN c2;
			FETCH c2 into c2_rec;
			OPEN c3;
			FETCH c3 into c3_rec;
			IF c2%notfound = true THEN						--verifies that the classid parameter matches a class in the classes table
				dbms_output.put_line('The cid is invalid.');
			ELSIF c3%notfound = true THEN
				dbms_output.put_line('No student is enrolled in the class.');	--verifies that at least one student is enrolled in the class with the given classid
			ELSE									
				WHILE c1%found = true
					LOOP	--prints out all student info and class info given the classid (some columns are ambiguous but inner join removes the ambiguity
						dbms_output.put_line(c1_rec.sid || c1_rec.firstname || c1_rec.lastname || c1_rec.email 
						|| c1_rec.classid || c1_rec.semester || c1_rec.year);
						FETCH c1 INTO c1_rec;
				END LOOP;
			END IF;
		END print_enr;

		--adds an enrollment to the enrollments table given a proper sid and classid
		procedure enroll_student(sid_in in students.sid%type, cid_in in classes.classid%type) AS
                        cursor c1 is SELECT s.sid from students s where s.sid = sid_in;
                        c1_rec c1%rowtype;
                        cursor c2 is SELECT c.classid from classes c where c.classid = cid_in;
                        c2_rec c2%rowtype;
                        cursor c3 is SELECT c.limit, c.class_size from classes c where c.classid = cid_in;
                        c3_rec c3%rowtype;
                        cursor c4 is SELECT * FROM (SELECT e.classid from enrollments e where e.sid = sid_in) t1 WHERE t1.classid = cid_in;
                        c4_rec c4%rowtype;
                        cnt number;
                        cursor c5 is		--find prerequisite courses that have either not been completed or been completed with insufficient grade
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
                        IF c1%notfound = true THEN				--verifies that student of given sid exists in students table
                                dbms_output.put_line('sid not found');
                        ELSIF c2%notfound = true THEN				--verifies that class of given classid exists in classes table
                                dbms_output.put_line('invalid classid');
                        ELSIF c3_rec.limit = c3_rec.class_size THEN		--verifies that there is at least one spot open in the given class
                                dbms_output.put_line('class full');
                        -- SELECT e.classid into already from enrollments e where e.sid = sid_in;
                        ELSIF c4%found = true THEN				--verifies that the student is not currently or was previously enrolled in the given class
                                dbms_output.put_line('already in this class');
                        	SELECT count(e.classid) into cnt from enrollments e where e.sid = sid_in;
                        -- dbms_output.put_line(cnt);
                        ELSIF cnt > 3 THEN					--verifies that the student is taking or was taking 3 or less other courses, taking more than 4 courses is overloading
                                dbms_output.put_line('overloaded');
                        ELSIF c5%notfound = true THEN				--verifies that no prerequisite courses have either not been completed nor been completed with an insufficient grade(worse than C)
                                -- dbms_output.put_line(c5_rec.classid);
                                dbms_output.put_line('Prerequisite courses havent been completed.');
                        ELSE
                        	insert into enrollments values(sid_in, cid_in, 'I'); --if all condition are met, create the enrollment
			END IF;
                END enroll_student;

		--deletes a row in enrollments table based on sid and classid
		procedure drop_student(si in students.sid%type, cid in classes.classid%type) AS
			cursor c1 is select * from students where si = students.sid;
			c1_rec c1%rowtype;
			cursor c2 is select * from classes where cid = classes.classid;
			c2_rec c2%rowtype;
			cursor c3 is select * from students inner join enrollments using (sid) where sid = si and classid = cid;
			c3_rec c3%rowtype;
			cursor c4 is select * from --gets courses that given course is a prerequisite for, joins them with student's current/past enrollments
			(students inner join enrollments using(sid)) 
			inner join
			(classes inner join prerequisites on classes.dept_code = prerequisites.pre_dept_code and classes.course_no = prerequisites.course_no)
			using(classid) 				
			where sid = si and classid = cid;
			c4_rec c4%rowtype;
			class_count number; 
			student_count number;
		BEGIN
			OPEN c1;
			FETCH c1 into c1_rec;
			OPEN c2;
			FETCH c2 into c2_rec;
			OPEN c3;
			FETCH c3 into c3_rec;
			OPEN c4;
			FETCH c4 into c4_rec;
			IF c1%notfound = true THEN				--verifies that student of given sid exists in students table
				dbms_output.put_line('sid not found');
			ELSIF c2%notfound = true THEN				--verifies that class of given classid exists in classes table
				dbms_output.put_line('classid not found');
			ELSIF c3%notfound = true THEN				--verifies that student is/was enrolled in given class
				dbms_output.put_line('student not enrolled in this class');
			ELSIF c4%found = true THEN				--verifies that class would not break any rules regarding prerequisites for other enrolled classes
				dbms_output.put_line('drop request rejected due to prerequisite requiremenets');
			ELSE
				select count(*) into class_count from enrollments where sid = si;	--gets count of classes student is enrolled in
				select class_size into student_count from classes where classid = cid;	--gets class_size of class that student is dropping from
				if class_count = 1 then							
					dbms_output.put_line('student enrolled in no class');
				elsif student_count = 1 then
					dbms_output.put_line('no student in this class');
				END IF;
				delete from enrollments where sid = si and classid = cid;
			END IF;
		END drop_student;
		
		--deletes an entry from the students table given a proper sid
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
	END proj2;
/
show errors

