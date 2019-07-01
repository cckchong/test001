/*
	MultiSelectWrapper Class
	Used to wrap the multi select fields from Library Item to display to page
*/
public class MultiSelectWrapper {
        public List<String> selectedValues {get;set;}
        public List<SelectOption> selectOptions {get;set;}
        
        //constructor
        public MultiSelectWrapper() {
            this.selectedValues = new List<String>();
            this.selectOptions = new List<SelectOption>();
        }
        //constructor with input list of select opitons
        public MultiSelectWrapper(List<SelectOption> selectOptions) {
            this.selectedValues = new List<String>();
            this.selectOptions = new List<SelectOption>();
            
            if(selectOptions != null) {
            	this.selectOptions = selectOptions;
            }
        }
        //constructor with input list of string
        public MultiSelectWrapper(List<String> optionValues) {
            this.selectedValues = new List<String>();
            this.selectOptions = new List<SelectOption>();
            
            if(optionValues != null) {
	            for(String s : optionValues) {
	                this.selectOptions.add(new SelectOption(s, s));
	            }
            }
        }
        //constructor with input list of picklist values
        public MultiSelectWrapper(List<Schema.PicklistEntry> picklistValues) {
            this.selectedValues = new List<String>();
            this.selectOptions = new List<SelectOption>();
            
            for(Schema.PicklistEntry pe : picklistValues) {
                this.selectOptions.add(new SelectOption(pe.getValue(), pe.getLabel()));
            }
        }
    }