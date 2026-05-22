/**
 * Test class for DemoStatusUpdateBatch
 */
@isTest
private class DemoStatusUpdateBatchTest {
    
    @TestSetup
    static void setupTestData() {
        List<Demo__c> testRecords = new List<Demo__c>();
        
        // Records that SHOULD be updated (Tag = 'Archive', Status != 'Archive')
        testRecords.add(new Demo__c(Tag__c = 'Archive', Status__c = 'Available'));
        testRecords.add(new Demo__c(Tag__c = 'Archive', Status__c = 'Available'));
        testRecords.add(new Demo__c(Tag__c = 'Archive', Status__c = 'Available'));
        
        // Records that should NOT be updated (Tag = 'Archive', Status = 'Archive')
        testRecords.add(new Demo__c(Tag__c = 'Archive', Status__c = 'Archive'));
        testRecords.add(new Demo__c(Tag__c = 'Archive', Status__c = 'Archive'));
        
        // Records that should NOT be updated (Tag != 'Archive')
        testRecords.add(new Demo__c(Tag__c = 'Other', Status__c = 'Available'));
        testRecords.add(new Demo__c(Tag__c = 'Test', Status__c = 'Available'));
        testRecords.add(new Demo__c(Tag__c = null, Status__c = 'Available'));
        
        insert testRecords;
    }
    
    @isTest
    static void shouldUpdateStatus_WhenTagIsArchiveAndStatusIsNotArchive() {
        Test.startTest();
        DemoStatusUpdateBatch batch = new DemoStatusUpdateBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        List<Demo__c> updatedRecords = [
            SELECT Id, Tag__c, Status__c 
            FROM Demo__c 
            WHERE Tag__c = 'Archive' AND Status__c = 'Archive'
        ];
        
        Assert.areEqual(5, updatedRecords.size(), 
            'Should have 5 Demo records with Archive status');
        
        List<Demo__c> nonArchivedRecords = [
            SELECT Id, Tag__c, Status__c 
            FROM Demo__c 
            WHERE Tag__c != 'Archive' OR Tag__c = null
        ];
        
        for (Demo__c record : nonArchivedRecords) {
            Assert.areEqual('Available', record.Status__c, 
                'Records without Archive tag should remain Available');
        }
    }
    
    @isTest
    static void shouldHandleNoRecords_WhenNoMatchingCriteria() {
        delete [SELECT Id FROM Demo__c];
        
        Test.startTest();
        DemoStatusUpdateBatch batch = new DemoStatusUpdateBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        List<Demo__c> allRecords = [SELECT Id FROM Demo__c];
        Assert.areEqual(0, allRecords.size(), 
            'Should have no records after deletion');
    }
    
    @isTest
    static void shouldHandleBulkRecords_WhenProcessingLargeDataset() {
        delete [SELECT Id FROM Demo__c];
        
        List<Demo__c> bulkRecords = new List<Demo__c>();
        for (Integer i = 0; i < 251; i++) {
            bulkRecords.add(new Demo__c(
                Tag__c = 'Archive', 
                Status__c = 'Available'
            ));
        }
        insert bulkRecords;
        
        Test.startTest();
        DemoStatusUpdateBatch batch = new DemoStatusUpdateBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        List<Demo__c> updatedRecords = [
            SELECT Id, Status__c 
            FROM Demo__c 
            WHERE Status__c = 'Archive'
        ];
        
        Assert.areEqual(251, updatedRecords.size(), 
            'All 251 records should be updated to Archive status');
    }
}
