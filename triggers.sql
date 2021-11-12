create or replace trigger add_to_students
after insert on students
begin
	dbms_output.put_line('A new students has been added');
end add_to_students;
/
create or replace trigger delete_to_enrollments
after delete on enrollments
begin
	dbms_output.put_line('A deletion in enrollments has occurred');
end delete_to_enrollments;
/
create or replace trigger delete_to_students
before delete on students
for each row
begin
	delete from enrollments where sid = :old.sid;
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
show errors;
