trigger CustomListViewTrigger on CustomListView__c (after insert) {
    try{
        BatchListviewGenerator batch_lv = new BatchListviewGenerator(Trigger.newMap.keySet());
        Database.executeBatch(batch_lv, 100);
    }catch(Exception e) {
        System.debug('Something went wrong: ' + e.getMessage());
    }
}