@isTest
public class TestELeaveSwitchCtrl {

    @isTest
    public static void TestELeaveSwitchCtrl() {
        Test.StartTest();
            EleaveSwitchCtrl sc = new EleaveSwitchCtrl();
            sc.enableAction();
            sc.disableAction();
        Test.StopTest();
    }
}