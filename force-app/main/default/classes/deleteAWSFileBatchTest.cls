@isTest
public class deleteAWSFileBatchTest {
    
    @TestSetup
    static void setUp(){
        
        mpComm__c comm = TestDataFactory.createMpComm(false);
        comm.AWSDeleteDate__c = system.today();
        comm.toB_EMailSubject__c = 'Test';
        comm.recordTypeId = [Select Id From RecordType where Name = 'toBサポート(メール受信)'].Id;
        insert comm;
        
        List<mpComm__c> childCommList = new List<mpComm__c>();
        for(integer i = 0; i< 2; i++) {
            mpComm__c commChild = TestDataFactory.createMpComm(false);  
            commChild.toB_EmailIncoming__c = comm.Id;
            commChild.toB_EMailSubject__c = 'Test';
            commChild.KYC_AWS_imageID__c = 'imageId'+i;
            childCommList.add(commChild);
        }
        insert childCommList;

        List<mpMaster__c> masterList = new List<mpMaster__c>();
        masterList.add(TestDataFactory.createOuterAPIMaster('AWS_KYC_Read', 'https://test.paypay.jp/testApi/v1/Read', 'Api-Key'
                                                              , 'test', 5000, 1, false));
        masterList.add(TestDataFactory.createOuterAPIMaster('AWS_KYC_Update', 'https://test.paypay.jp/testApi/v1/Update', 'Api-Key'
                                                              , 'test', 5000, 1, false));
        masterList.add(TestDataFactory.createOuterAPIMaster('AWS_KYC_Upload', 'https://test.paypay.jp/testApi/v1/Upload', 'Api-Key'
                                                              , 'test', 5000, 1, false));
        insert masterList;
           
    }
    public class UpdateAWSMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            res.setBody('{"statusCode":"00"}');
            return res;
        }
    }
    public class UpdateAWSMockErrorRes implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            res.setBody('{"errorCode": "01", "errorMessage": "errorMsg"}');
            return res;
        }
    }

    @isTest
    static void deletetest_CalloutSuccess_Success() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UpdateAWSMock());
        deleteAWSFileBatch.run(10);
        Test.stopTest();
        
        List<mpComm__c> commList = [Select id, toB_EmailSubject__c from mpComm__c where toB_EmailIncoming__c <> null];
        //件名更新される、Delete成功
        for(mpComm__c comm: commList) {
            system.assert(comm.toB_EMailSubject__c.contains('delete_'));
        }
    }
    
    @isTest
    static void deletetest_CalloutFail_Fail() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UpdateAWSMockErrorRes());
        deleteAWSFileBatch.run(10);
        Test.stopTest();
        
        List<mpComm__c> commList = [Select id, toB_EmailSubject__c from mpComm__c where toB_EmailIncoming__c <> null];
        //件名更新されないこと、Delete失敗
        for(mpComm__c comm: commList) {
            system.assert(!comm.toB_EMailSubject__c.contains('delete_'));
        }
    }
}