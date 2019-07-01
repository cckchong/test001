@isTest
private class TestSurveyFormatDateController {
	
	@isTest static void testGetFormattedDateTime() {
		SurveyFormatDateController controller = new SurveyFormatDateController();
		controller.emailType = 'Reminder';
		DateTime dt =  Datetime.newInstance(2008, 12, 1, 12, 30, 2);
		controller.dateTimeValue =  dt;
		System.assert(controller.getFormattedDateTime().equals(dt.format())); 			
	}
	
	@isTest static void testGetShowDatetimeValue() {
		SurveyFormatDateController controller = new SurveyFormatDateController();
		controller.emailType = 'Reminder';
		DateTime dt =  Datetime.newInstance(2008, 12, 1, 12, 30, 2);
		controller.dateTimeValue = dt;
		System.assertEquals(true, controller.getShowDatetimeValue()); 		

		controller.dateTimeValue = null;
		System.assertEquals(false, controller.getShowDatetimeValue()); 		
	}
	
}