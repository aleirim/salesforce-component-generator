global class BatchClassExample implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    //Set of IDs of the records inserted
    private Set<Id> lytId;
    
    //start by querying what we need
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Name FROM Account WHERE Id IN :lytId]);
    }
	
	//let's do something with those records    
    global void execute(Database.BatchableContext bc, List<Account> scope) {}
    
    //the finish section can be used to cleanup tasks, notifcations, etc.
    global void finish(Database.BatchableContext bc){}

}