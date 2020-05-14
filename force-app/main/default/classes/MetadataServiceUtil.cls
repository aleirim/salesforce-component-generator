public class MetadataServiceUtil {
    
	public static MetadataService.MetadataPort createService(){
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }

    public static void handleSaveResults(MetadataService.SaveResult[] saveResult)
        {
             for(MetadataService.SaveResult result:saveResult){
        // Nothing to see?
        if(result==null || result.success)
            return;
        // Construct error message and throw an exception
        if(result.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (result.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + result.fullName + '.');
            for(MetadataService.Error error : result.errors){
                messages.add(error.message + ' (' + error.statusCode + ').' + ( error.fields!=null && error.fields.size()>0 ? ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            
            	if(messages.size()>0)
                	System.debug(messages);
        	}
        	if(!result.success)
                System.debug(messages);
            //throw new Exception ('Something went wrong while processing: '+messages);
        }
    }
        }
    
    //script to create custom object in the org
    public static void createListviewCustomObject (String objName){
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomObject customObject = new MetadataService.CustomObject();
        customObject.fullName = objName + '__c'; //CustomListView__c
        customObject.label = 'Custom List View';
        customObject.pluralLabel = 'Custom List Views';
        customObject.nameField = new MetadataService.CustomField();
        customObject.nameField.type_x = 'Text';
        customObject.nameField.label = 'Test Record';
        customObject.deploymentStatus = 'Deployed';
        customObject.sharingModel = 'ReadWrite';
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { customObject });
        handleSaveResults(results);
       
        if(results[0].errors == null){
            System.debug('no errors while creating the object');
            List<String> fieldsList = new List <String> {'lvobject', 'lvName', 'lvLabel', 'lvFilterScope'};
            createObjectFields(objName, fieldsList);
        }
        else
            System.debug('Something went wrong while creating the custo object');

    }
    
    //let's modify this method to accept a list of fields, maybe a map or return metadata and created all at once
    public static void createObjectFields(String objName, List<String> fieldNames){
         List<MetadataService.CustomField> mdList = new List<MetadataService.CustomField>();
        //fields
        MetadataService.MetadataPort service = createService();
        for(String fn: fieldNames){
            MetadataService.CustomField customField = new MetadataService.CustomField();
            System.debug('Creating ' + fn);
            customField.fullName = objName + '__c.' + fn + '__c';
            system.debug('creating full name ' + customfield.fullname);
            customField.label = fn;
            customField.type_x = 'Text';
            customField.length = 42;
            mdList.add(customField);
            system.debug(mdList);
        }
        
        List<MetadataService.SaveResult> results = service.createMetadata(mdList);
        system.debug('list of results: ' + results);
        handleSaveResults(results);
    }
}