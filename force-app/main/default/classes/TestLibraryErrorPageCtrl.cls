/*
* Test Class of LibraryErrorPageCtrl
*/
@isTest
public class TestLibraryErrorPageCtrl{
    
      @isTest
    public static void doTestLibraryErrorPageCtrl() {
        LibraryErrorPageCtrl le = new LibraryErrorPageCtrl();
        System.assertEquals(le.message, null);
    
    }
}