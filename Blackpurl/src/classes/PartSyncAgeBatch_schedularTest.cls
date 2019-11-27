@isTest
public class PartSyncAgeBatch_schedularTest {
    static testMethod void testMethod1(){
    Account vendor = testUtil.createVendor(true,'testVendor');
    Category__c categoryRecord = testUtil.createCategory(true,'test category');	
    part__c part = testUtil.createPart(true,'P1234',vendor.id,'test Description',categoryRecord.id );
    Part_FIFO_Bucket__c partFifo = new Part_FIFO_Bucket__c();
    partFifo.Part__c = part.id;
    partFifo.Qty_In__c = 200;
    insert partFifo;
    Part_FIFO_Bucket_Activity_Line_Item__c partFifoBucketLineItem = new Part_FIFO_Bucket_Activity_Line_Item__c();
    partFifoBucketLineItem.Qty_Out__c = 10;
    partFifoBucketLineItem.Part_FIFO_Bucket__c = partFifo.id;
   	insert partFifoBucketLineItem;
   	Test.setCreatedDate(partFifo.Id, datetime.now()- 30);
    test.startTest(); 
    PartSyncAgeBatch_Schedular partSync = new PartSyncAgeBatch_Schedular();
    partSync.partListToUpdate = new list<Part__c>();
    DataBase.executeBatch(partSync);
    test.stopTest();
    Part_FIFO_Bucket__c partFifoObj = [select id,age__c from Part_FIFO_Bucket__c where id=:partFifo.id];
    system.assertEquals(30,partFifoObj.age__c);
    }
    
    
    
}