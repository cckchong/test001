public without sharing class SurveyFormatDateController {
	public SurveyFormatDateController() {
		
	}

	public DateTime dateTimeValue { get; set; }
	public String emailType { get; set; }

	public String getFormattedDateTime() {
		if (dateTimeValue == null) { 
			return ''; 
		}
		return dateTimeValue.format();
	}

	public Boolean getShowDatetimeValue() {
		System.debug('(getShowDatetimeValue) email type: ' + emailType + ', dateTimeValue: ' + dateTimeValue);
		return String.isNotBlank(emailType) && emailType.equalsIgnoreCase('Reminder')
			&& dateTimeValue != null;
	}
}