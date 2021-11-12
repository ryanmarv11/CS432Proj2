--this query is not part of the project's requirements but was my first test of a PL/SQL TRIGGER to determine the syntax
CREATE OR REPLACE TRIGGER add_to_students
	AFTER INSERT ON students
	BEGIN
		dbms_output.put_line('A new students has been added');
	END add_to_students;
/

--ENROLLMENTS TABLE TRIGGERS
--when a ROW in enrollments is going to be deleted, decrement the class size of the class with the corresponding classid
CREATE OR REPLACE TRIGGER delete_to_enrollments
	BEFORE delete ON enrollments
	FOR EACH ROW
	BEGIN
		UPDATE classes SET class_size = class_size - 1
		WHERE classid = :OLD.classid;
	END delete_to_enrollments;
/

--when a ROW in elements is going to be inserted, increment the class size of the class with the corresponding classid. 
CREATE OR REPLACE TRIGGER insert_to_enrollments
	BEFORE INSERT ON enrollments
	FOR EACH ROW
	BEGIN
		UPDATE classes SET class_size = class_size + 1 
		WHERE classid = :NEW.classid;
	END insert_to_enrollments;	
/

--STUDENTS TABLE TRIGGERS
--when a ROW in students is going to be deleted, delete all rows in the enrollments table with the corresponding sid
CREATE OR REPLACE TRIGGER delete_to_students
	BEFORE delete ON students
	FOR EACH ROW
	BEGIN
		DELETE FROM enrollments WHERE sid = :OLD.sid;
	END delete_to_students;
/

--LOGS TABLE TRIGGERS
--when a ROW in enrollments is going to be inserted, INSERT an entry INTO the logs table with the corresponding VALUES, the table being modified is the enrollments table, this is an INSERT operation, the primary key of enrollments is classid and the foreign key of enrollments is sid 
CREATE OR REPLACE TRIGGER insert_enrollment_logs
	BEFORE INSERT ON enrollments
	FOR EACH ROW
	DECLARE
		si varchar2(100);
	BEGIN
		SELECT user INTO si FROM dual; --assigns si to current username
		INSERT INTO logs(logid, who, time, table_name, operation, key_value)
		VALUES(proj2.new_log_id, si, SYSDATE, 'enrollments', 'INSERT', CONCAT(:new.sid, :new.classid));
	END insert_enrollment_logs;
/

--when a ROW in enrollments is going to be deleted, INSERT an entry INTO the logs table with the corresponding VALUES, the table being modified is the enrollments table, this is a delete operation, the primary key of enrollments is classid and the foreign key of enrollments is sid 
CREATE OR REPLACE TRIGGER delete_enrollment_logs
	BEFORE delete ON enrollments
	FOR EACH ROW
	DECLARE
		si varchar2(100);
	BEGIN
	     	SELECT user INTO si FROM dual; --assigns si to current username
		INSERT INTO logs(logid, who, time, table_name, operation, key_value)
		VALUES(proj2.new_log_id, si, SYSDATE, 'enrollments', 'delete', CONCAT(:old.sid, :old.classid));
	END delete_enrollment_logs;
/

--when a ROW in students is going to be added, INSERT an entry INTO the logs table with the corresponding VALUES, the table being modified is the students table, this is an INSERT operation, the primary key of students is sid
CREATE OR REPLACE TRIGGER insert_student_logs
	AFTER INSERT ON students
	FOR EACH ROW
	DECLARE
		si varchar2(100);
	BEGIN
		SELECT user INTO si FROM dual;	--assigns si to current username
		INSERT INTO logs(logid, who, time, table_name, operation, key_value)
		VALUES (proj2.new_log_id, si, SYSDATE, 'students', 'INSERT', :new.sid);
	END insert_student_logs;
/

--when a ROW in students is going to be deleted, INSERT an entry INTO the logs table with the corresponding VALUES, the table being modified is the students table, this is a delete operation, the primary key of students is sid
CREATE OR REPLACE TRIGGER delete_student_logs
	BEFORE delete ON students
	FOR EACH ROW
	DECLARE
		si varchar2(100);
	BEGIN
		SELECT user INTO si FROM dual;	--assigns si to current username
		INSERT INTO logs(logid, who, time, table_name, operation, key_value)
		VALUES(proj2.new_log_id, si, SYSDATE, 'students', 'delete', :old.sid);
	END delete_student_logs;
/

show errors;
