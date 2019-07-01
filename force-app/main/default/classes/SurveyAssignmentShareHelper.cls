public without sharing class SurveyAssignmentShareHelper {
    
    public static Set<String> createAssignmentShareSet(List<String> listSurveyAssignmentId, List<String> reasons) {

        List<Survey_Assignment__Share> ll = [Select Id, UserOrGroupId 
                                             From Survey_Assignment__Share 
                                             Where ParentId in :listSurveyAssignmentId And RowCause in :reasons];
        Set<String> setUserId = new Set<String>();
        for (Survey_Assignment__Share sas : ll) {
            System.debug('(createAssignmentShareSet) survey assignment id: ' + sas.id + ', sas.UserOrGroupId: ' + sas.UserOrGroupId);
            setUserId.add(sas.UserOrGroupId);
        }
        return setUserId;
    }

    public static Set<String> retrieveSurveyShareSet(String surveyId, List<String> reasons, String debugPrefix) {

        String prefix = debugPrefix;
        Set<String> setUserId = new Set<String>();
        if (reasons != null) {
            List<Survey__Share> ll = [Select Id, UserOrGroupId 
                                      From Survey__Share 
                                      Where ParentId = :surveyId AND RowCause in :reasons];
            for (Survey__Share sa : ll) {
                setUserId.add(sa.UserOrGroupId);

                /*Comment by DTT Support Team   For save CPU running time*/
                // for (String id : setUserId) {
                //     System.debug(prefix + ' UserOrGroupId: ' + id);  
                // }
            }
        } 
        return setUserId;
    }

    public static Set<String> createAssignmentShareSetByReason(List<Survey_Assignment__c> newSurveyAssignmentList, 
        List<String> reasons) {

        List<String> newSurveyAssignmentId = new List<String>();
        for (Survey_Assignment__c sa : newSurveyAssignmentList) {
            newSurveyAssignmentId.add(sa.Id);
        }

        for (String  saId: newSurveyAssignmentId) {
            System.debug('(createAssignmentShareSetByReason) new survey assignment Id: ' + saId);
        }

        for (String reason: reasons) {
            System.debug('(createAssignmentShareSetByReason) Reason: ' + reason);
        }

        Set<String> setAssignmentAdmin = createAssignmentShareSet(newSurveyAssignmentId, reasons);
        return setAssignmentAdmin;
    }

    public static List<Survey_Assignment__Share> createSurveyAssignmentShareList(
              List<Survey_Assignment__c> allAdmins , Set<String> setAssignmentAdmin
            , List<Survey_Assignment__c> newSurveyAssignmentList) {

        List<Survey_Assignment__Share> listAssignmentShareInsert = new List<Survey_Assignment__Share>();
        for (Survey_Assignment__c admin : allAdmins) {
            // check if survey assignment administrator already created for survey assignment custom object 
            if (!setAssignmentAdmin.contains(admin.User__c)) {
                // grant read/write access of survey assignment record to shared manager 
                for (Survey_Assignment__c  newSurveyAssignment: newSurveyAssignmentList) {
                    Survey_Assignment__Share sa_share = new Survey_Assignment__Share();
                    sa_share.UserOrGroupId = admin.User__c;
                    sa_share.AccessLevel = 'Edit';
                    sa_share.RowCause = Survey_Assignment__Share.RowCause.Survey_Administrator__c;
                    sa_share.ParentId = newSurveyAssignment.Id;
                    //System.debug('(createSurveyAssignmentShareList) sa_share - parentId: ' + sa_share.ParentId 
                    //        + ', UserOrGroupId: ' + sa_share.UserOrGroupId 
                    //        + ', sa_share.AccessLevel: ' + sa_share.AccessLevel 
                    //        + ', sa_share.RowCause: ' + sa_share.RowCause);//Comment by DTT
                    listAssignmentShareInsert.add(sa_share);
                }
            }
        }
        System.debug('listAssignmentShareInsert '+listAssignmentShareInsert.size());//by DTT
        return listAssignmentShareInsert;
    }

    public static List<Survey__Share> createSurveyShareList(List<Survey_Assignment__c> listAssignmentGroup, 
            Set<String> setExistSurveyShare, String rowCause, String surveyId, String prefix) {
        
        List<Survey__Share> listSurveyShareInsert = new List<Survey__Share>();
        for (Survey_Assignment__c sa : listAssignmentGroup) {
            String userOrGroupId = '';
            if (String.isNotBlank(sa.User__c)) {
                userOrGroupId = sa.User__c;
            } else if (String.IsNotBlank(sa.GroupId__c)) {
                userOrGroupId = sa.GroupId__c;
            }
            if (String.isNotBlank(userOrGroupId)) {
                if (!setExistSurveyShare.contains(userOrGroupId)) {
                    Survey__Share survey_share = new Survey__Share();
                    survey_share.UserOrGroupId = userOrGroupId;
                    survey_share.AccessLevel = 'Edit';
                    survey_share.RowCause = rowCause;
                    survey_share.ParentId = surveyId;
                    //System.debug('(createSurveyShareList) ' + prefix + ' survey_share - parentId: ' + survey_share.ParentId 
                    //        + ', survey_share.UserOrGroupId: ' + survey_share.UserOrGroupId 
                    //        + ', survey_share.AccessLevel: ' + survey_share.AccessLevel 
                    //        + ', survey_share.RowCause: ' + survey_share.RowCause);Comment by DTT
                    listSurveyShareInsert.add(survey_share);
                }
            }
        }
        System.debug('listSurveyShareInsert '+listSurveyShareInsert.size());//by DTT
        return listSurveyShareInsert;
    }

    public static void persistSurveyAssignmentShareRecord(List<Survey_Assignment__Share> listAssignmentShareInsert, 
            Map<Id, Survey_Assignment__c> allSurveyAssignmentMap) {

        Integer i = 0;
        system.debug('listAssignmentShareInsert:'+listAssignmentShareInsert.size());
        List<Database.SaveResult> results;
        if (listAssignmentShareInsert.size() > 0) {

            // results = Database.insert(listAssignmentShareInsert, false);

            /*Add by DTT support TEam*/
            // List<Survey_Assignment__Share> subListAssignmentShareInsert1=new List<Survey_Assignment__Share>();
            // List<Survey_Assignment__Share> subListAssignmentShareInsert2=new List<Survey_Assignment__Share>();
            // List<Survey_Assignment__Share> subListAssignmentShareInsert3=new List<Survey_Assignment__Share>();


            // List<Database.SaveResult> results=new  List<Database.SaveResult>();
            if(Test.isRunningTest())
              {
                   results = Database.insert(listAssignmentShareInsert, false);

                   for (Database.SaveResult sr : results) {
                    if(!sr.isSuccess()) {
                        // Get the first save result error
                        Database.Error err = sr.getErrors()[0];
                        // Check if the error is related to a trivial access level
                        // Access levels equal or more permissive than the object's default
                        // access level are not allowed.
                        // These sharing records are not required and thus an insert exception is
                        // acceptable.
                        if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION 
                                                       &&  err.getMessage().contains('AccessLevel'))) {
                            // Throw an error when the error is not related to trivial access level.
                            allSurveyAssignmentMap.get(listAssignmentShareInsert.get(i).ParentId).
                              addError('Unable to grant sharing access due to following exception: '
                               + err.getMessage());
                        }
                    }
                   i++;
                     }
                 }
             
            else
              {
                  SurveyShareBatch theBatch = new SurveyShareBatch(listAssignmentShareInsert);
                  // for(Survey_Assignment__Share reader: listAssignmentShareInsert)
                  // {
                  //   if(reader!=null)
                  //   {
                  //       theBatch.insertList.add(reader);
                  //   }
                  // }
                  //theBatch.insertList.addAll(listAssignmentShareInsert);                
                  system.debug('listAssignmentShareInsert.size()='+listAssignmentShareInsert.size());
                  ID batchProcessId = Database.executeBatch(theBatch,9500);
              }
            // else
            // {   
            //     if(listAssignmentShareInsert.size()<24900)
            //     {
            //         Integer counter=0;
            //         for(Survey_Assignment__Share reader:listAssignmentShareInsert)
            //         {
            //             if(counter<7000)
            //             {
            //                 subListAssignmentShareInsert1.add(reader);
            //             }else if(counter<14000)
            //             {
            //                 subListAssignmentShareInsert2.add(reader);
            //             }
            //             else
            //             {
            //                 subListAssignmentShareInsert3.add(reader);
            //             }   
            //             counter++;
            //         }
                    
            //     }
            //     system.debug('THe size1:'+subListAssignmentShareInsert1.size());
            //     system.debug('THe size2:'+subListAssignmentShareInsert2.size());
            //     system.debug('THe size3:'+subListAssignmentShareInsert3.size());
            //     results = Database.insert(subListAssignmentShareInsert1, false);
            //     results.addAll(Database.insert(subListAssignmentShareInsert2, false));
            //     results.addAll(Database.insert(subListAssignmentShareInsert3, false));

            
            // List<List<Survey_Assignment__Share>> allItems=new List<List<Survey_Assignment__Share>>();
            // Integer sizes=listAssignmentShareInsert.size()/10000;
            // if(sizes>1){
            //  for(Integer x=0;x+1<=sizes;x++){
            //      List<Survey_Assignment__Share> aPart=new List<Survey_Assignment__Share>();  
            //       if(x+1<sizes){ 
            //        for(Integer y=x*10000;y<(x+1)*10000;y++){
            //             Survey_Assignment__Share aRecord=listAssignmentShareInsert.get(y);
            //             if(aRecord==null)
            //             {
            //                 break;
            //             }
            //             aPart.add(aRecord);
            //        } 
            //             allItems.add(aPart);
            // }
            //     //   else{
            //     //     for(Integer y=x*10000;y<listAssignmentShareInsert.size();y++){
            //     //         Survey_Assignment__Share aRecord=List<Survey_Assignment__Share> listAssignmentShareInsert.get(y);
            //     //         aPart.add(aRecord);
            //     //     }
   
            //     // allItems.add(aPart);

            //     //   }
            //  }
            // }

              /*Add by DTT Support Team End*/


            
        }
            
    }

    public static void persistSurveyShareRecord(List<Survey__Share> listSurveyShareInsert,
        List<Survey_Assignment__c> newSurveyAssignmentList, Map<Id, 
        Survey_Assignment__c> allSurveyAssignmentMap) {
        
        Integer i = 0;
        if (listSurveyShareInsert.size() > 0) {
            List<Database.SaveResult> results = Database.insert(listSurveyShareInsert, false);
            for (Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    allSurveyAssignmentMap.get(newSurveyAssignmentList.get(0).id).
                          addError('Unable to grant sharing access to survey due to following exception: '
                           + err.getMessage());
                }
                i++;
            }
        }
    }
}