/*
 * MultiselectController synchronizes the values of the hidden elements to the
 * SelectOption lists.
 */
public class MultiselectController {
    // SelectOption lists for public consumption
    //BEGIN
    public SelectOption[] listLeftOptions { get; set{
        SelectOption[] tmp=value;
        if(tmp==null){tmp=new SelectOption[]{};}
        this.listLeftOptions=tmp;
    }}
    public SelectOption[] listRightOptions { get; set{
        SelectOption[] tmp=value;
        if(tmp==null){tmp=new SelectOption[]{};}
        this.listRightOptions=tmp;
    }}
    public MultiselectController(){
        listLeftOptions=new SelectOption[]{};
        listRightOptions=new SelectOption[]{};
    }
    //ENd init()
    
    // Parse &-separated values and labels from value and 
    // put them in option
    private void setOptions(SelectOption[] options, String value) {
        options.clear();
        String[] parts = value.split('&');
        for (Integer i=0; i<parts.size()/2; i++) {
            options.add(new SelectOption(EncodingUtil.urlDecode(parts[i*2], 'UTF-8'), 
              EncodingUtil.urlDecode(parts[(i*2)+1], 'UTF-8')));
        }
    }
    
    // Backing for hidden text field containing the options from the
    // left list
    public String leftOptionsHidden { get; set {
           leftOptionsHidden = value;
           setOptions(listLeftOptions, value);
        }
    }
    
    // Backing for hidden text field containing the options from the
    // right list
    public String rightOptionsHidden { get; set {
           rightOptionsHidden = value;
           setOptions(listRightOptions, value);
        }
    }
}