// usage:  1. compile: javac mydemo1.java
//         2. execute: java mydemo1
import java.sql.*;
import oracle.jdbc.*;
import java.math.*;
import java.io.*;
import java.awt.*;
import oracle.jdbc.pool.OracleDataSource;

public class proj2 {

	public static void main (String args []) throws SQLException {

        try {
        	//Connection to Oracle server
	        OracleDataSource ds = new oracle.jdbc.pool.OracleDataSource();
	        ds.setURL("jdbc:oracle:thin:@castor.cc.binghamton.edu:1521:ACAD111");
	        Connection conn = ds.getConnection("rmarvin1","Archery7;");

        	// Input sid from keyboard
	        BufferedReader  readKeyBoard; 
	        String          sid;
	        readKeyBoard = new BufferedReader(new InputStreamReader(System.in)); 
	        System.out.println("1 for displaying a table\n" + 
	        	"2 for enrolling a student into a class\n" +
	        	"2 for show_logs\n" +
	        	"3 for show_students\n" +
	        	"4 for show_courses\n" +
	        	"5 for show_prerequisites\n"+
	        	"6 for show_enrollments\n"+
	        	"7 for print_info\n"+
	        	"8 for print_pre\n"+
	        	"9 for print_enr\n"+
	        	"10 for q7_enroll\n"+
	        	"11 for drop_student\n"+
	        	"12 for delete_student\n"+
	        	"13 for subp");
	        sid = readKeyBoard.readLine();

	        switch (Integer.parseInt(sid)) {
            	case 1:
                    break;
            	default:
            		System.out.println("Invalid input");
                    break;
            }

        }

        catch (SQLException ex) { System.out.println ("\n*** SQLException caught ***\n" + ex.getMessage());}
   		catch (Exception e) {System.out.println ("\n*** other Exception caught ***\n");}

	}
}
