/**
 * Test for LibraryNumberWrapper 
 */
@isTest
public class TestLibraryNumberWrapper {
    
    static testMethod void myUnitTest() {
        
        LibraryNumberWrapper lnw = new LibraryNumberWrapper();
        lnw.min = 1.5;
        lnw.max = 2.5;
        System.assertEquals(lnw.min, 1.5);
        System.assertEquals(lnw.max, 2.5);
        
        lnw = new LibraryNumberWrapper(Double.valueOf(2.55555), Double.valueOf(2.55555));
        System.assertEquals(lnw.min, lnw.max);
        
    }
}