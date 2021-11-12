create or replace trigger add_to_students
after insert on students
begin
	dbms_output.put_line('A new students has been added');
end;
/
show errors;
