/*
    LibraryFlsFabricModelUtil Class
    
    @Author: AN, WG, NW
    @Object: Library_Item__c
    @Description: Used to map fabric fields with web services
*/
public without sharing class LibraryFlsFabricModelUtil {//DEPLOYME
    
    //mapping the FLS results without commit
    public static List<Library_Item__c> mapFlsResultsToItemsNoCommit(LibraryFlsFabricSearchWs.fabricSearchResult[] results) {
        List<Location__c> defaultLocation = [SELECT Id FROM Location__c WHERE Name = :Label.Tech_Default_Fabric_Location];
        
        List<Library_Item__c> liList = new List<Library_Item__c>();
        
        if(results != null) {
            for(LibraryFlsFabricSearchWs.fabricSearchResult fbr : results) {
                if(fbr.fabric.fabricName != null && fbr.fabric.fabricName != '') {
                    liList.add(LibraryFlsfabricModelUtil.mapFlsFabricModel(fbr));
                }
            }
        }
        return liList;
    }
    
    
    //mapping the FLS results and upsert into system
    public static List<Library_Item__c> mapFlsResultsToItems(LibraryFlsFabricSearchWs.fabricSearchResult[] results) {
        List<Location__c> defaultLocation = [SELECT Id FROM Location__c WHERE Name = :Label.Tech_Default_Fabric_Location];
        
        List<Library_Item__c> liList = new List<Library_Item__c>();
        
        if(results != null) {
            for(LibraryFlsFabricSearchWs.fabricSearchResult fbr : results) {
                if(fbr.fabric.fabricName != null && fbr.fabric.fabricName != '') {
                    liList.add(LibraryFlsfabricModelUtil.mapFlsFabricModel(fbr));
                }
            }
            try{
                upsert liList Fabric_External_Id__c;
            }catch(Exception ex){
            }
            
            // AN (22/01/2015): Re-query the list for the formula fields
            // we need to take into account the Fabric Field Set
            List<String> selectCriteria = new List<String>();
            List<String> inScopeIds = new List<String>();
            if(Schema.SObjectType.Library_Item__c.fieldSets.getMap().get('FabricResultFieldSet') != null) {
                List<Schema.FieldSetMember> fieldSet = Schema.SObjectType.Library_Item__c.fieldSets.getMap().get('FabricResultFieldSet').getFields();
                for(Schema.FieldSetMember fsm : fieldSet) {
                    selectCriteria.add(fsm.getFieldPath());
                }
                
                for(Library_Item__c li : liList) {
                    inScopeIds.add(li.Id);
                }
            }
            if(!selectCriteria.isEmpty() && !inScopeIds.isEmpty()) {
 
                String query = String.format('SELECT {0} , Id, Name, Tech_Selected__c FROM Library_Item__c WHERE Id IN {1} ',
                                         new List<String>{ String.join(selectCriteria, ','),  '(\'' + String.join(inScopeIds, '\',\'') + '\')' });
                
                List<Library_Item__c> itemResultSet = (List<Library_Item__c>)Database.query(query);
                
                if(itemResultSet != null && !itemResultSet.isEmpty()) {

                    liList = itemResultSet;
                }
            }
        }
        return liList;
    }
    
    //mapping each fields of FLS result to Library_Item__c
    public static Library_Item__c mapFlsFabricModel(LibraryFlsFabricSearchWs.fabricSearchResult result) {
        
        Library_Item__c li = new Library_Item__c(); 
        li.OwnerId = Label.Library_Default_Fabric_Owner;
        LibraryFlsFabricSearchWs.fabric fabric = result.fabric;
        System.debug('>>>>> Fabric Inventory = ' + JSON.serialize(result.inventory));
        
        if(result.inventory != null && !result.inventory.isEmpty()) {
            List<LibraryFlsFabricSearchWs.fabricInventory> fabricInventoryList = result.inventory;
            li.Fabric_Inventory_Json__c = JSON.serialize(fabricInventoryList);
            
            li.Fabric_Inventory__c = '';
            for(LibraryFlsFabricSearchWs.fabricInventory fi : fabricInventoryList) {
                if(fi.facility != null && fi.availableQty != null && fi.reservedQty != null && fi.unit != null) {
                    li.Fabric_Inventory__c += 'Factory: ' + fi.facility + '\n';
                    li.Fabric_Inventory__c += 'Available Qty: ' + fi.availableQty.setScale(2) + '\n';
                    li.Fabric_Inventory__c += 'Reserved Qty: ' + fi.reservedQty.setScale(2) + '\n';
                    li.Fabric_Inventory__c += 'Unit: ' + fi.unit + '\n\n';
                }
            }
        }
        
        List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SObjectType =: Label.Library_Item_ObjectName AND DeveloperName =: Label.Library_RecordType_Fabric];
        
        if(!ErrorUtils.isEmpty(rtList)) {
            li.RecordTypeId = rtList[0].Id;
        }
        if(result.color != null) {
            li.Color_ID_1__c = result.color.colorNo;
            
            li.Fls_Color__c = result.color.fabricColor;
            li.Fls_Pattern__c = result.color.fabricPattern;
            
            li.Fabric_External_Id__c = fabric.fabricName + '-' + result.color.colorNo;
        } else {
            li.Fabric_External_Id__c = fabric.fabricName;
        }
        
        /*
            Added by nick wu 10 Feb 2015
            Season, season year mapping
        */
        if(fabric.fabricSeason!=null &&fabric.fabricSeason!=''){
            li.Season__c =fabric.fabricSeason;
        }
        if(fabric.fabricYear!=null){
            li.Season_Year__c = String.valueOf(fabric.fabricYear);
        } 
        
        /*
            Added by nickwu 20141223
            mapping the createdate to Library_Item__c
        */
        li.Created_Date__c = Date.valueOf(fabric.createDateStr);
        
        li.Width_Actual__c = fabric.actualWidth;
        li.Width_Actual_UOM__c = fabric.actualWidthUom;
        //li.Can_Be_Borrowed__c = true;
        
        /*
            Added by nickwu 16 Apr 2015
            1. for storing all test report urls into a string list
            2. mapping the test report print out for report fields
        */
        List<String> reportValueList = new List<String>();
        
        //test report attachment values
        List<LibraryFlsFabricSearchWs.fabricConstructAttachment> attachments = fabric.attachments;
        
        //test report print out values
        List<LibraryFlsFabricSearchWs.testReportPrintout> testReportPrintOut = result.testReportPrintouts;
        
        //clean up the report links
        li.Test_Report_Attachments__c = '';
        li.Test_Report_1__c = '';
        li.Test_Report_2__c = '';
        li.Test_Report_3__c = '';

        //assign attachment urls to the list 
        if(attachments != null) {
            for(Integer i = 0; i < attachments.size() ; i++) {
                if(attachments[i]!=null){
                    li.Test_Report_Attachments__c += Label.Library_FLS_Url + Label.Library_TestReport_path + fabric.fabricName + '/' + attachments[i].attachmentId + '\r\n';
                }
            }
        }

        //assign print out urls to the list
        if(testReportPrintOut !=null){
            for(Integer i=0;i<testReportPrintOut.size();i++){
                if(testReportPrintOut[i]!=null && testReportPrintOut[i].reportType == 'C'){
                    li.Test_Report_1__c = Label.Library_FLS_Url + 'printouts/testReport/' + fabric.fabricName + '/' + testReportPrintOut[i].reportType+'/' + result.color.colorNo;
                }else if(testReportPrintOut[i]!=null && testReportPrintOut[i].reportType == 'M'){
                   li.Test_Report_2__c = Label.Library_FLS_Url + 'printouts/testReport/' + fabric.fabricName + '/' + testReportPrintOut[i].reportType+'/' + result.color.colorNo;
                }else if(testReportPrintOut[i]!=null && testReportPrintOut[i].reportType == 'I'){
                   li.Test_Report_3__c = Label.Library_FLS_Url + 'printouts/testReport/' + fabric.fabricName + '/' + testReportPrintOut[i].reportType+'/' + result.color.colorNo;
                }
            }
        }

        li.Fls_Brand_Customer__c = fabric.brandCustomer;
        li.Fls_Country__c = fabric.countryOfOrigins;
        li.Currency__c = fabric.currency_x;
        li.Width_Cuttable__c = fabric.cuttableWidth;
        li.Width_Cuttable_UOM__c = fabric.cuttableWidthUom;
        li.D_Wash__c = fabric.DWashTest;

        li.Fls_Product_Type__c = fabric.fabricEndUse;
        li.Fabric_ID__c = fabric.fabricName;
                
        li.Item_Name__c = fabric.fabricName;
        li.Item_Description__c = fabric.fiberContentStr;
        li.Content_Description__c = fabric.fiberContentStr;
        
        try {
            if(fabric.fiberContentStr != null && fabric.fiberContentStr != '') {
                String[] contentPercentPairList = fabric.fiberContentStr.split(', ');
                
                for(Integer i = 0 ; i < contentPercentPairList.size() ; i++ ) {
                    String s = contentPercentPairList[i];
                    if(s != null) {
                        String[] contentAndPercentPair = s.split(' ');
                        if(contentAndPercentPair[0] != null && i == 0) {
                            li.Content_Percent__c = Decimal.valueOf(contentAndPercentPair[0].replace('%', ''));
                            li.Fls_Content__c = contentAndPercentPair[1];
                        } else if(contentAndPercentPair[0] != null && i == 1) {
                            li.Content_Percent_2__c = Decimal.valueOf(contentAndPercentPair[0].replace('%', ''));
                            li.Fls_Content_2__c = contentAndPercentPair[1];
                        } else if(contentAndPercentPair[0] != null && i == 2) {
                            li.Content_Percent_3__c = Decimal.valueOf(contentAndPercentPair[0].replace('%', ''));
                            li.Fls_Content_3__c = contentAndPercentPair[1];
                        } else if(contentAndPercentPair[0] != null && i == 3){
                            li.Content_Percent_4__c = Decimal.valueOf(contentAndPercentPair[0].replace('%', ''));
                            li.Fls_Content_4__c = contentAndPercentPair[1];
                        }
                    }
                }
            }
        } catch (Exception e) {}
        
        if(fabric.garmentFinishings != null && !fabric.garmentFinishings.isEmpty()) {
            li.Fls_Garment_Finish__c = String.join(fabric.garmentFinishings, ';');
        }
        
        li.Gauge__c = fabric.gauge;
        
        li.Completeness__c = (fabric.isCompleted ? Label.Library_isCompleted_T : Label.Library_isCompleted_F); 
        li.Dipping__c = (fabric.isDipping ? Label.Library_dipping_T : Label.Library_dipping_F);
        
        
        /*
            added by nickwu 02 Mar 2015
        */
        
        System.debug('hello friends: ' + fabric.requestByRnD);
        if(fabric.requestByRnD!=null){
            li.RequestByRnD__c = fabric.requestByRnD;
        }
        
        li.Fabric_Status__c = fabric.status;
        
        
        try{
            li.TestReportCount__c = fabric.access.releasedTestReportCount;               
        }catch(Exception ex){
        
        }
        
        if(fabric.requireRndTest=='YES'){
            li.requireRndTest__c =  true;
        }else if(fabric.requireRndTest=='NO'){
            li.requireRndTest__c =  false;
        }
            
       
        if(fabric.isKnitFabric) {
            li.Fabric_Type__c = Label.Library_FabricType_210;
            li.Yarn_Size__c = fabric.yarnSizeStr;
        } else if(fabric.isWovenFabric) {
            li.Fabric_Type__c = Label.Library_FabricType_211;
            
            /*
                Added by Nick Wu
                format the warp yarn size and type & weft yarn size and type
                eg. <weftYarnSizeStr>50 Compact, 60/2 Combed</weftYarnSizeStr>
            */
            li.Warp_Yarn_Size__c = '';
            li.Yarn_Type_Warp__c = '';
            li.Weft_Yarn_Size__c = '';
            li.Yarn_Type_Weft__c = '';
            if(fabric.warpYarnSizeStr!=null &&fabric.warpYarnSizeStr!=''){
                String[] warpList =  fabric.warpYarnSizeStr.split(', ');
                for(String temp : warpList){
                    String[] warps = temp.split(' ');
                    if(warps.size()>0){
                        if(warps[0]!=null){
                            li.Warp_Yarn_Size__c += warps[0] + ' ';
                        }
                        if(warps.size()>1 && warps[1]!=null){
                            li.Yarn_Type_Warp__c += warps[1] + ' ';
                        }
                    }
                }
            }
            
            if(fabric.weftYarnSizeStr!=null &&fabric.weftYarnSizeStr!=''){
                String[] weftList =  fabric.weftYarnSizeStr.split(', ');
                for(String temp : weftList){
                    String[] wefts = temp.split(' ');
                    if(wefts.size()>0){
                        if(wefts[0]!=null){
                            li.Weft_Yarn_Size__c += wefts[0] + ' ';
                        }
                        if(wefts.size()>1 && wefts[1]!=null){
                            li.Yarn_Type_Weft__c += wefts[1] + ' ';
                        }
                    }
                }
            }
        }

        li.Fls_Material_Type__c = fabric.materialType;
        li.Pilot_Fabric__c = fabric.pilotFabric;
        li.Quoted_Price__c = Decimal.valueOf(fabric.quotedPrice);
        li.Quoted_Price_UOM__c = fabric.quotedPriceUom;
                
        li.Fls_Supplier__c = fabric.supplierName;        
        
        li.Fls_Woven_Type__c = fabric.weaveType;//uncomment by Vic for test
        
        if(ErrorUtils.isValidDecimal(fabric.warpDensity)) {
            li.Density_Warp__c = Decimal.valueOf(fabric.warpDensity);               
        }
        
        if(ErrorUtils.isValidDecimal(fabric.weftDensity)) {
            li.Density_Weft__c = Decimal.valueOf(fabric.weftDensity);    
        }

        li.Weight_Before_Dip_Description__c = fabric.weightBeforeDipStr;
        li.Weight_Description__c = fabric.weightStr;
        
        li.Fls_Dyeing_Method__c = fabric.yarnDyeMethod;
        
        if(fabric.materialFinishings != null) {
            String strFabricFinishing = '';
            for(String str: fabric.materialFinishings) {
                strFabricFinishing += str + ';';
            }
            
            li.Fls_Fabric_Finish__c = strFabricFinishing;
        }
        
        try{
            li.Price_Validity__c = Date.valueOf(fabric.validDate);
        }catch(Exception ex){}

        return li;
    }
    

}