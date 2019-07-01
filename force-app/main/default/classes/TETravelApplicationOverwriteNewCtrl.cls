/**
 * TETravelApplicationOverwriteNewCtrl
 * @description override new button of Travel Application
 */
public without sharing class TETravelApplicationOverwriteNewCtrl 
{
    public TETravelApplicationOverwriteNewCtrl (ApexPages.StandardController controller) {}
      
    public PageReference redirectNewTETravelAppplication() {
        String url = '/apex/TETravelApplication'; 
        PageReference pr = new PageReference(url);
        return pr;
    }
    
}