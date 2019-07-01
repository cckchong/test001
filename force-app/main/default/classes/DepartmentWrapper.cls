/*****************************************************
Department Wrapper Class

Constructor
1. Construct Article Wrapper includes additional attribute
    a. deptName
    b. deptFullName
    c. deptPicURL
    
******************************************************/
public class DepartmentWrapper {
	public String deptName {get;set;}
	public String deptFullName {get;set;}
	public String deptPicURL {get;set;}
	public DepartmentWrapper(String name, String fullname, String url) {
		deptName = name;
		deptFullname = fullname;
		deptPicURL = url;
	}
}