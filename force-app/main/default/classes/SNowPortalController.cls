public class SNowPortalController {
    public String url;
    
    public SNowPortalController() {
        String urlParameter = ApexPages.currentPage().getParameters().get('URL');
        
        if (urlParameter == null) {
            url = Label.ServiceNow_ESS_URL;
        } else {
            url = urlParameter;
        }
    }
    
    public String getUrl() {
        return this.url;
    }
    
    public void setUrl(String url) {
        this.url = url;
    }
}