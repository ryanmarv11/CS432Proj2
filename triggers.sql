	create or replace trigger add_to_students
after insert on students
begin
	dbms_output.put_line('A new students has been added');
end add_to_students;
/
create or replace trigger delete_to_enrollments
before delete on enrollments
for each row
begin
	begin
		update classes set class_size = class_size - 1
		where classid = :OLD.classid;
	end;
end delete_to_enrollments;
/
create or replace trigger delete_to_students
before delete on students
for each row
begin
	delete from enrollments where sid = :OLD.sid;
end delete_to_students;
/
create or replace trigger add_to_enrollments
before insert on enrollments
for each row
begin
	begin
		update classes set class_size = class_size + 1 
		where classid = :NEW.classid;
	end;
	
end add_to_enrollments;	
/
create or replace trigger insert_student_logs
after insert on students
for each row
declare
si varchar2(100);
begin
	begin
		select user into si from dual;
		insert into logs(logid, who, time, table_name, operation, key_value)
		values (proj2.new_log_id, si, SYSDATE, 'students', 'insert', :new.sid);
	end;	
end insert_student_logs;
/
create or replace trigger delete_student_logs
before delete on students
for each row
declare
si varchar2(100);
begin
	begin
		select user into si from dual;
		insert into logs(logid, who, time, table_name, operation, key_value)
		values(proj2.new_log_id, si, SYSDATE, 'students', 'delete', :old.sid);
	end;
end delete_student_logs;
/
create or replace trigger insert_enrollment_logs
before insert on enrollments
for each row
declare
si varchar2(100);
begin
     	begin
             	select user into si from dual;
                insert into logs(logid, who, time, table_name, operation, key_value)
                values(proj2.new_log_id, si, SYSDATE, 'enrollments', 'insert', CONCAT(:new.sid, :new.classid));
        end;
end insert_enrollment_logs;
/
create or replace trigger delete_enrollment_logs
before delete on enrollments
for each row
declare
si varchar2(100);
begin
     	begin
             	select user into si from dual;
                insert into logs(logid, who, time, table_name, operation, key_value)
                values(proj2.new_log_id, si, SYSDATE, 'enrollments', 'delete', CONCAT(:old.sid, :old.classid));
        end;
end delete_enrollment_logs;
/
show errors;
