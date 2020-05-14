global class BatchListviewGenerator implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
	
    private Set<Id> lvId;
    
    public BatchListviewGenerator(Set<Id> lvId){
        this.lvId=lvId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT lvobject__c, lvName__c, lvLabel__c, lvFilterScope__c FROM CustomListView__c WHERE Id IN :lvId]);
    }
    
    global void execute(Database.BatchableContext bc, List<CustomListView__c> scope) {
        try{
            MetadataService.MetadataPort service = MetadataServiceUtil.createService();        
            List<MetadataService.Metadata> mdList = new List<MetadataService.Metadata>();
            
            //creating list views specified in the list: object, full name, label
            for(CustomListView__c lv: scope){
                MetadataService.ListView listView = new MetadataService.ListView();
                listView.fullName = lv.lvobject__c + '.' + lv.lvName__c;
                listView.label = lv.lvLabel__c;
                listView.filterScope = lv.lvFilterScope__c;
                //listView.columns = new List<String> {'Name'};
                mdList.add(ListView);        
            }
            List<MetadataService.SaveResult> results = service.createMetadata( mdList );
        	MetadataServiceUtil.handleSaveResults(results);
        } catch (Exception e){
            System.debug('Something went wrong: ' + e.getMessage());
        }       
    }
    
    global void finish(Database.BatchableContext bc){
        //send email with batch results
        AsyncApexJob jb = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, ExtendedStatus, CreatedBy.Email
          				   FROM AsyncApexJob WHERE Id = :bc.getJobId()];
         String htmlBody='';
        try{     
           // Send an email to the Apex job's submitter notifying the job completion.
           String body='The job is finished. A total of ' + jb.TotalJobItems + ' batches were processed with '+ jb.NumberOfErrors + ' failures.';
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           mail.setTargetObjectId(UserInfo.getUserId());
           mail.setSaveAsActivity(false);
           mail.setSubject('Batch job ' + jb.Status.toLowerCase());
           mail.setPlainTextBody(body);
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception e){
            System.debug(e.getMessage());
            throw e;
        }
    }  
}