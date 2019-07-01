/*
	LibraryNumberWrapper Class
	Used to wrap the integer type of field for library item
*/
public class LibraryNumberWrapper {
        public Double min {get;set;}
        public Double max {get;set;}
        
        //Constructor, set min & max = null
        public LibraryNumberWrapper() {min = null;max = null;}
        
        //Constructor, assign min & max by input values
        public LibraryNumberWrapper(Double min, Double max) {this.min = min;this.max = max;}
    }