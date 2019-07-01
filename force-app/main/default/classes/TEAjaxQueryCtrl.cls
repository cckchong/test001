public without sharing class TEAjaxQueryCtrl{

    public String result {set;get;} 
    
    private class LocationVO {
        
        public String id {get;set;}
        public String text {get;set;}
    }
    
    public String getLocations() {
        String type = '';
        String q = '';
        String data = '';
        this.result = '';
        List<LocationVO> locationVOList = new List<LocationVO>();
        try{
            type = apexpages.currentpage().getparameters().get('type');
            q = apexpages.currentpage().getparameters().get('q');        
            if (!String.isBlank(type) && !String.isBlank(q)){        
                q = '%' + q + '%';
                if ( type == 'location'){
                    for(Travel_Location__c tc : [select id , Name, city_code__c  
                                                 from Travel_Location__c 
                                                 where name like :q or city_code__c like :q 
                                                 order by name 
                                                ]) {
                        LocationVO lVo = new LocationVO();
                        lVo.id = tc.id;
                        lVo.text = tc.Name;                        
                        locationVOList.add(lVo);
                    }
                }
            }
        }
        catch (Exception ex){}        
        return JSON.serialize(locationVOList);
    }
    
    public TEAjaxQueryCtrl(){
        result = getLocations();
        return;
    }
    
}