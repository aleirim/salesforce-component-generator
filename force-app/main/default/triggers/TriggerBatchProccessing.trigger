trigger TriggerBatchProccessing on Account (before insert) {
	//lets's say that we are checking something in the accounts and based on that condition we'll do something else (like updating a field):
	//this only makes sense if we are massive importing or updating accounts, maybe thru the Data Loader
	try{
		//in this case BatchListviewGenerator is the class with the logic to process the items
        BatchListviewGenerator batch_lv = new BatchListviewGenerator(Trigger.newMap.keySet());
        Database.executeBatch(batch_lv, 100); //we are here speciyfing the batch size: 100
    }catch(Exception e) {
        System.debug('Something went wrong: ' + e.getMessage());
    }
}