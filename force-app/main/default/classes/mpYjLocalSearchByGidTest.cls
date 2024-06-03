@isTest
public class mpYjLocalSearchByGidTest {
    /*
    private static Id mpCommCommOutSide = mpUtilString.getRecordTypeByDeveloperName(mpComm__c.sObjectType, 'CommOutSide');
	
	//データ準備
    static void TestRecordPrepares(){
        List<String> gids = new List<String>{'_0Erjrm0-bc','_0IpwymFWMg','_0jkFFs_Uy6','-0_FLZeBTeU','0_gF5Y0juQc','0-_gmXVKZo6','0_gq6dZSybw','0_guUhixtI2','0_hWG7Wh_5k','0_iPI2MkA5Q','0_j6Xkc4s0s','0_k1j0fUByA','0_kvNCP4eVM','0Eqe4ko74Nk','0EqoxcWVWVk','0EquV9giyMM','0ER6N1ht6xY','0ERgvAybZTU','0ErIayd08zU','0erywUXX2R-','0ESM4wMh6fw','0ESSoJV9SUA','0EtakDILPr-','0EtNGOD0NME','0EUaoO2jxRE','0Ev2_SSZlM6','0ew2bH7vaIc','0eW7jm4O_KM','0eWaMqewAjw','0eXclqvtD4w','0ExMASbMXTc','0ExuhmkEZYo','0EyGkV64-j2','0eYhbl_i03Q','0eYpwWFVdng','0EYtz7_S7uw','0eYVwL5D32k','0Eyx9BDeom2','0EzGrBoI6m6','0f_TBo936Ug','0F0K6K2l-jA','0f1U7F7WMz2','0f1U7MkJAdo','0f1U7OvM-Ms','0f1U7SbK-F2','0f229G3lFPY','0f29GlEnYcY','0F2fI1Bf_pg','0f2rid8FPLM','0F2YC-WIibc','0f2z-POST9o','0f2ZzdSGw4Q','0f3hA97j7B6','0f4dpbn2q4s','0F4HWjW1jZ2','0f4SJf2UCvI','0f-5akGCdcw','0f6oEQwB-As','0F7GPgDJHAc','0F7rVXnWZgg','0f8Sq5jE39g','0Fb-6I4Grbc','0fbhcCQXEhw','0FbmViLHnHY','0FBX_NSsprA','0fcK6ZRBDf-','0FD8Z08S6Ws','0FD8Z96bgTw','0fe5Q0HNFK2','0fe5QDLb0gE','0Ff1ypHTW7c','0ffFbAaLnlw','0FfpU8XTMN2','0fg8vEoDoR-','0fg8vEYxUxc','0fg8vFoWZ72','0fg8vH9l6JY','0fg8vHreHT6','0fg8vKOCAwE','0fg8vKy-NFU','0fg8vKysBrA','0fg8vLL0w6E','0fg8vLlRZtU','0fg8vLsgy2M','0fg8vMKdkfg','0fg8vN5OQo-','0fg8vNCV7VU','0fg8vNIb1AM','0fg8vO90uMw','0fg8vPQ02ls','0fg8vQ24uOQ','0fg8vQ3S4RE','0fg8vQIuZn2','0fg8vRLDmjk','0fg8vT1Ly0k','0fg8vTd79rQ','0FgcafJlNtc','0FgJAuB08wk','0FhkguB_A6o','0fI6uDP8v4k','0FkgLh2k7so','0f-KlYcP9_M','0FkOaIGSz_-','0FKTxojGnJY','0FldzlRazs2','0-fLj0fSE2A','0fLqieX6BXI','0fmWcrQUO8Y','0FMxiCM_8Zg','0fn8wQd-fSo','0fOBfWfehdo','0FoPojdkfqo','0Foyb5nrpa-','0fPgFotFgBU','0FpW60OxS7g','0Fr-beW6z5Y','0fr-JaaBqaw','0FsiPN17Gr6','0FSiWK76w9I','0FsJwWJ5l3k','-0FtBldEgtE','0f-TDTz5Rzk','0Ftw7p3JBaM','0FUdxiDKhE6','0funjRNRX_w','0FVZbG93nWw','0FWcj3sMr0U','0FWcjDAO7PM','0fWIXlFzlo2','0FWNSGpHmvU','0f-xqVQZ3NA','0FXS5dWZc96','0FY4OcrI7JA','0fzfMxLbLu2','0fzKwp3SFik','0fZTnpd4anQ','0G_tSTCFdtM','0g0HEttB5eg','0g1Xs6L0oa-','0g2iTLX9z_o','0G2swVaElOs','0G2tQp26NAQ','0G4LCc2b7ZU','0g5Ox4aolDQ','0g5XreXf14-','0g7Kay9XVfk','0G8F-L36JTI','0G9cwoLzl9k','0G9FBfLvja2','0gBwanasP0E','0gBy9r1VfDc','0GcpPVsnE2E','0gcVEhySzlA','0Gcw5sJhxSM','0gDGaeVjJ5t','0Gdj4X3lSHs','0gDkGUEcfnA','0gDlbVy2N_o','0ge0rUPFxAM'};
        gids.addAll(new List<String>{'0G9-SQN0N4o','0GAmxsjtb9g','0Gapa_RA9HI','0gap-xT2q7k','0gauo_381KI','0gAzdX6ckBM','0GbJLBpA7Xo','0GBRHsspLY2','0GBrQVrm6-Y','0gBs-i5dupo','0gBwanasP0E','0gBy9r1VfDc','0GcpPVsnE2E','0gcVEhySzlA','0Gcw5sJhxSM','0gDGaeVjJ5t','0Gdj4X3lSHs','0gDkGUEcfnA','0gDlbVy2N_o','0ge0rUPFxAM','0gO7sCOTQkU','0gOd-998iIE','0gOd-CH73t-','0gOKEDC9u_-','0gPAooB_A96','0gr7U_rbmnE','0grCMO48IXU','0grw-wZEe1o','0gsiiOfxK0Q','0GTqpEqTD96','0G-TrlNaGck','0gUpO29yE7Q','0gvfMoTXGcs','0gvfMszoLP-','0GwJB6EG1zY'});
		
        List<mpComm__c> mpComms = new List<mpComm__c>();
        for(String gid : gids){
            mpComms.add(new mpComm__c(W_YAML__c='PayPay加盟店リクエスト受付フォーム', RecordTypeId=mpUtilString.getRecordTypeByDeveloperName(mpComm__c.sObjectType, 'CommOutSide'), Gid__c=gid));
        }
        insert mpComms;
    }
    
    //スケジューラ　テスト
    static testMethod void scheduledLocalSearchByGidTest(){
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new LocalSearchApiMockImpl_ResultCountZero());
            String jobId = System.schedule('mpYjLocalSearchByGidScheduled Class Test', '0 0 * * * ?', new mpYjLocalSearchByGidScheduled());
        Test.stopTest();
	}
    
    //バッチ　テスト
    static testMethod void execBatchLocalSearchByGidTest(){
        TestRecordPrepares(); //データ準備
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new LocalSearchApiMockImpl_200());
            String query = 'SELECT Id, Gid__c, MID__c, StoreId__c, uid__c, NumOfGidSearch__c FROM mpComm__c WHERE RecordTypeId = \''+mpCommCommOutSide+'\' AND CreatedDate > 2018-10-31T00:00:00Z AND Gid__c != null AND MID__c = null AND StoreId__c = null ORDER BY NumOfGidSearch__c ASC NULLS First, Gid__c ASC';
            ID batchprocessid = Database.executeBatch(new mpYjLocalSearchByGidAndUpdateBatch(query),200);
        Test.stopTest();
    }
    
    static testMethod void localSearchByGidTest_200(){
        
            String query = 'SELECT Id, Gid__c, MID__c, StoreId__c, uid__c, NumOfGidSearch__c FROM mpComm__c WHERE RecordTypeId = \''+mpCommCommOutSide+'\' AND CreatedDate > 2018-10-31T00:00:00Z AND Gid__c != null AND MID__c = null AND StoreId__c = null ORDER BY NumOfGidSearch__c ASC NULLS First, Gid__c ASC';
            List<mpComm__c> scope = Database.query(query);
            if(scope.size() < 1) {
                TestRecordPrepares(); //データ準備
                scope = Database.query(query);
            }
        	Integer baseCount = scope.size();

            Map<String,Map<Id,mpComm__c>> gidMap = new Map<String,Map<Id,mpComm__c>>();
            Map<String, List<mpComm__c>> returnValue = new Map<String, List<mpComm__c>>();
            List<mpComm__c> updatePrepares = new List<mpComm__c>();
        
        Test.startTest();
	        Test.setMock(HttpCalloutMock.class, new LocalSearchApiMockImpl_200());
        
            for(mpComm__c mpComm : scope){
                mpComm.NumOfGidSearch__c = mpComm.NumOfGidSearch__c != null ? mpComm.NumOfGidSearch__c+1 : 1;
                
                if(gidMap.containsKey(mpComm.Gid__c)) gidMap.get(mpComm.Gid__c).put(mpComm.Id, mpComm);
                else gidMap.put(mpComm.Gid__c, new Map<Id,mpComm__c>{mpComm.Id => mpComm});
            
                if(gidMap.size() >= 150){
                    returnValue = mpYjLocalSearchByGid.localSearchByGid(gidMap);
                    if (!returnValue.isEmpty() && returnValue.containsKey('Success')){
                        updatePrepares.addAll(returnValue.get('Success'));
                    }
                    gidMap.clear();
                }
            }
            returnValue = mpYjLocalSearchByGid.localSearchByGid(gidMap);
            if (!returnValue.isEmpty() && returnValue.containsKey('Success')){
                updatePrepares.addAll(returnValue.get('Success'));
            }
            
            Map<Id, mpComm__c> baseList = new Map<Id, mpComm__c>(scope);
            Map<Id, mpComm__c> gidHitList = new Map<Id, mpComm__c>(updatePrepares);
            
            for(Id gidHitId : gidHitList.keySet()){
               baseList.remove(gidHitId);
            }
            
            baseList.putAll(gidHitList);        
            System.assertEquals(true, baseList.size() == baseCount);
        
        Test.stopTest();
    }
    
    static testMethod void localSearchByGidTest_500(){
        
            String query = 'SELECT Id, Gid__c, MID__c, StoreId__c, uid__c, NumOfGidSearch__c FROM mpComm__c WHERE RecordTypeId = \''+mpCommCommOutSide+'\' AND CreatedDate > 2018-10-31T00:00:00Z AND Gid__c != null AND MID__c = null AND StoreId__c = null ORDER BY NumOfGidSearch__c ASC NULLS First, Gid__c ASC Limit 10';
            List<mpComm__c> scope = Database.query(query);
            if(scope.size() < 1) {
                TestRecordPrepares(); //データ準備
                scope = Database.query(query);
            }
            Map<String,Map<Id,mpComm__c>> gidMap = new Map<String,Map<Id,mpComm__c>>();
        
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new LocalSearchApiMockImpl_500());
            
            for(mpComm__c mpComm : scope){
                if(gidMap.containsKey(mpComm.Gid__c)) gidMap.get(mpComm.Gid__c).put(mpComm.Id, mpComm);
                else gidMap.put(mpComm.Gid__c, new Map<Id,mpComm__c>{mpComm.Id => mpComm});
            }       
            mpYjLocalSearchByGid.localSearchByGid(gidMap);
        
        Test.stopTest();
    }
    
    static testMethod void localSearchByGidTest_ResultCountZero(){
        
            String query = 'SELECT Id, Gid__c, MID__c, StoreId__c, uid__c, NumOfGidSearch__c FROM mpComm__c WHERE RecordTypeId = \''+mpCommCommOutSide+'\' AND CreatedDate > 2018-10-31T00:00:00Z AND Gid__c != null AND MID__c = null AND StoreId__c = null ORDER BY NumOfGidSearch__c ASC NULLS First, Gid__c ASC Limit 10';
            List<mpComm__c> scope = Database.query(query);
            if(scope.size() < 1) {
                TestRecordPrepares(); //データ準備
                scope = Database.query(query);
            }
            Map<String,Map<Id,mpComm__c>> gidMap = new Map<String,Map<Id,mpComm__c>>();
        
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new LocalSearchApiMockImpl_ResultCountZero());
            
            for(mpComm__c mpComm : scope){
                if(gidMap.containsKey(mpComm.Gid__c)) gidMap.get(mpComm.Gid__c).put(mpComm.Id, mpComm);
                else gidMap.put(mpComm.Gid__c, new Map<Id,mpComm__c>{mpComm.Id => mpComm});
            }       
            mpYjLocalSearchByGid.localSearchByGid(gidMap);
        
        Test.stopTest();
    }
    
    static testMethod void localSearchByGidTest_Null_ResultInfo(){
        
            String query = 'SELECT Id, Gid__c, MID__c, StoreId__c, uid__c, NumOfGidSearch__c FROM mpComm__c WHERE RecordTypeId = \''+mpCommCommOutSide+'\' AND CreatedDate > 2018-10-31T00:00:00Z AND Gid__c != null AND MID__c = null AND StoreId__c = null ORDER BY NumOfGidSearch__c ASC NULLS First, Gid__c ASC Limit 10';
            List<mpComm__c> scope = Database.query(query);
            if(scope.size() < 1) {
                TestRecordPrepares(); //データ準備
                scope = Database.query(query);
            }
            Map<String,Map<Id,mpComm__c>> gidMap = new Map<String,Map<Id,mpComm__c>>();
        
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new LocalSearchApiMockImpl_Null_ResultInfo());
            
            for(mpComm__c mpComm : scope){
                if(gidMap.containsKey(mpComm.Gid__c)) gidMap.get(mpComm.Gid__c).put(mpComm.Id, mpComm);
                else gidMap.put(mpComm.Gid__c, new Map<Id,mpComm__c>{mpComm.Id => mpComm});
            }       
            mpYjLocalSearchByGid.localSearchByGid(gidMap);
        
        Test.stopTest();
    }
    
    static testMethod void localSearchByGidTest_Null_Property(){
        
            String query = 'SELECT Id, Gid__c, MID__c, StoreId__c, uid__c, NumOfGidSearch__c FROM mpComm__c WHERE RecordTypeId = \''+mpCommCommOutSide+'\' AND CreatedDate > 2018-10-31T00:00:00Z AND Gid__c != null AND MID__c = null AND StoreId__c = null ORDER BY NumOfGidSearch__c ASC NULLS First, Gid__c ASC Limit 10';
            List<mpComm__c> scope = Database.query(query);
            if(scope.size() < 1) {
                TestRecordPrepares(); //データ準備
                scope = Database.query(query);
            }
            Map<String,Map<Id,mpComm__c>> gidMap = new Map<String,Map<Id,mpComm__c>>();
        
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new LocalSearchApiMockImpl_Null_Property());
            
            for(mpComm__c mpComm : scope){
                if(gidMap.containsKey(mpComm.Gid__c)) gidMap.get(mpComm.Gid__c).put(mpComm.Id, mpComm);
                else gidMap.put(mpComm.Gid__c, new Map<Id,mpComm__c>{mpComm.Id => mpComm});
            }       
            mpYjLocalSearchByGid.localSearchByGid(gidMap);
        
        Test.stopTest();
    }
    
    public class LocalSearchApiMockImpl_200 implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
           
			List<String> resBodyList = new List<String>();
			List<String> gids = new List<String>{'_0Erjrm0-bc','_0IpwymFWMg','_0jkFFs_Uy6','-0_FLZeBTeU','0_gF5Y0juQc','0-_gmXVKZo6','0_gq6dZSybw','0_guUhixtI2','0_hWG7Wh_5k','0_iPI2MkA5Q','0_j6Xkc4s0s','0_k1j0fUByA','0_kvNCP4eVM','0Eqe4ko74Nk','0EqoxcWVWVk','0EquV9giyMM','0ER6N1ht6xY','0ERgvAybZTU','0ErIayd08zU','0erywUXX2R-','0ESM4wMh6fw','0ESSoJV9SUA','0EtakDILPr-','0EtNGOD0NME','0EUaoO2jxRE','0Ev2_SSZlM6','0ew2bH7vaIc','0eW7jm4O_KM','0eWaMqewAjw','0eXclqvtD4w','0ExMASbMXTc','0ExuhmkEZYo','0EyGkV64-j2','0eYhbl_i03Q','0eYpwWFVdng','0EYtz7_S7uw','0eYVwL5D32k','0Eyx9BDeom2','0EzGrBoI6m6','0f_TBo936Ug','0F0K6K2l-jA','0f1U7F7WMz2','0f1U7MkJAdo','0f1U7OvM-Ms','0f1U7SbK-F2','0f229G3lFPY','0f29GlEnYcY','0F2fI1Bf_pg','0f2rid8FPLM','0F2YC-WIibc','0f2z-POST9o','0f2ZzdSGw4Q','0f3hA97j7B6','0f4dpbn2q4s','0F4HWjW1jZ2','0f4SJf2UCvI','0f-5akGCdcw','0f6oEQwB-As','0F7GPgDJHAc','0F7rVXnWZgg','0f8Sq5jE39g','0Fb-6I4Grbc','0fbhcCQXEhw','0FbmViLHnHY','0FBX_NSsprA','0fcK6ZRBDf-','0FD8Z08S6Ws','0FD8Z96bgTw','0fe5Q0HNFK2','0fe5QDLb0gE','0Ff1ypHTW7c','0ffFbAaLnlw','0FfpU8XTMN2','0fg8vEoDoR-','0fg8vEYxUxc','0fg8vFoWZ72','0fg8vH9l6JY','0fg8vHreHT6','0fg8vKOCAwE','0fg8vKy-NFU','0fg8vKysBrA','0fg8vLL0w6E','0fg8vLlRZtU','0fg8vLsgy2M','0fg8vMKdkfg','0fg8vN5OQo-','0fg8vNCV7VU','0fg8vNIb1AM','0fg8vO90uMw','0fg8vPQ02ls','0fg8vQ24uOQ','0fg8vQ3S4RE','0fg8vQIuZn2','0fg8vRLDmjk','0fg8vT1Ly0k','0fg8vTd79rQ','0FgcafJlNtc','0FgJAuB08wk','0FhkguB_A6o','0fI6uDP8v4k','0FkgLh2k7so','0f-KlYcP9_M','0FkOaIGSz_-','0FKTxojGnJY','0FldzlRazs2','0-fLj0fSE2A','0fLqieX6BXI','0fmWcrQUO8Y','0FMxiCM_8Zg','0fn8wQd-fSo','0fOBfWfehdo','0FoPojdkfqo','0Foyb5nrpa-','0fPgFotFgBU','0FpW60OxS7g','0Fr-beW6z5Y','0fr-JaaBqaw','0FsiPN17Gr6','0FSiWK76w9I','0FsJwWJ5l3k','-0FtBldEgtE','0f-TDTz5Rzk','0Ftw7p3JBaM','0f-xqVQZ3NA','0FXS5dWZc96','0FY4OcrI7JA','0g2iTLX9z_o','0G2swVaElOs','0G2tQp26NAQ','0G4LCc2b7ZU','0g5Ox4aolDQ','0g5XreXf14-','0g7Kay9XVfk','0G8F-L36JTI','0G9cwoLzl9k','0G9FBfLvja2','0gBwanasP0E','0gBy9r1VfDc','0GcpPVsnE2E','0gcVEhySzlA','0Gcw5sJhxSM','0gDGaeVjJ5t','0Gdj4X3lSHs','0gDkGUEcfnA','0gDlbVy2N_o','0ge0rUPFxAM'};
			Integer index = 1;
            
            for(String gid: gids){
                String body = '{"Name":"'+String.valueOf(index).leftPad(3,'0')+'_'+gid+'",'
                    +'"Gid": "'+gid+'",'
                    +'"Property":{'
                           +'"Uid": "'+String.valueOf(index).leftPad(10,'0')+'_'+gid+'",'
                           +'"Detail":{'
                                +'"PayPayFlag":"true",'
                                +'"PayPayMid":"'+String.valueOf(index).leftPad(4,'0')+'",'
                                +'"PayPaySid":"'+String.valueOf(index).leftPad(3,'0')+'"'
                           +'}'
                        +'}'
                    +'}';
                
                
                resBodyList.add(body); 
                index+=1;
            }
            System.assertEquals('GET', req.getMethod());

            HttpResponse res = new HttpResponse();

            if (Pattern.matches('.*distinct=paypay.*', req.getEndpoint())) {
                // 正常系
                res.setStatusCode(200);
                res.setHeader('Content-Type', 'application/json;charset=UTF-8');
                res.setBody('{"ResultInfo":{"Count":500,"Total":4582,"Start":1,"Status":200,"Description":"","Copyright":"","Latency":0.034},"Feature":['+String.join(resBodyList, ',')+']}');
                // res.setBody('{"ResultInfo":{"Count":500,"Total":4582,"Start":1,"Status":200,"Description":"","Copyright":"","Latency":0.034},"Feature":['
                //             +'{"Name":"002_zuNubPhXxnE",'
                //             +'"Gid": "zuNubPhXxnE",'
                //             +'"Property":{'
                //                 +'"Uid": "0000000002_zuNubPhXxnE",'
                //                 +'"Detail":{'
                //                     +'"PayPayFlag":"true",'
                //                     +'"PayPayMid":"0002",'
                //                     +'"PayPaySid":"002"'
                //                     +'}'
                //                 +'}'
                //             +'},'
                //             +'{"Name":"003_ZuF2_HRt1Wg",'
                //             +'"Gid": "ZuF2_HRt1Wg",'
                //             +'"Property":{'
                //                 +'"Uid": "0000000003_ZuF2_HRt1Wg",'
                //                 +'"Detail":{'
                //                     +'"PayPayFlag":"true",'
                //                     +'"PayPayMid":"0003",'
                //                     +'"PayPaySid":"003"'
                //                     +'}'
                //                 +'}'
                //             +'}'
                // +']}');
            }
            else {
                res.setStatusCode(500);
            }

            return res;
        }
    }
    public class LocalSearchApiMockImpl_500 implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
           
            HttpResponse res = new HttpResponse();
			res.setStatusCode(500);
            
            return res;
        }
    }
    public class LocalSearchApiMockImpl_ResultCountZero implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
           
            System.assertEquals('GET', req.getMethod());

            HttpResponse res = new HttpResponse();

                // 正常系
                res.setStatusCode(200);
                res.setHeader('Content-Type', 'application/json;charset=UTF-8');
                res.setBody('{"ResultInfo":{"Count":0}}');

            return res;
        }
    }
    public class LocalSearchApiMockImpl_Null_ResultInfo implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
           
            System.assertEquals('GET', req.getMethod());

            HttpResponse res = new HttpResponse();

                // 正常系
                res.setStatusCode(200);
                res.setHeader('Content-Type', 'application/json;charset=UTF-8');
                res.setBody('{"Result":{"Count":0}}');

            return res;
        }
    }
    public class LocalSearchApiMockImpl_Null_Property implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
           
            System.assertEquals('GET', req.getMethod());

            HttpResponse res = new HttpResponse();

                // 正常系
                res.setStatusCode(200);
                res.setHeader('Content-Type', 'application/json;charset=UTF-8');
                 res.setBody('{"ResultInfo":{"Count":1,"Total":1,"Start":1,"Status":200,"Description":"","Copyright":"","Latency":0.034},"Feature":['
                             +'{"Name":"003_ZuF2_HRt1Wg",'
                             +'"Gid": "ZuF2_HRt1Wg",'
                             +'"Prop":{'
                                 +'"Uid": "0000000003_ZuF2_HRt1Wg",'
                                 +'"Detail":{'
                                     +'"PayPayFlag":"true",'
                                     +'"PayPayMid":"0003",'
                                     +'"PayPaySid":"003"'
                                     +'}'
                                 +'}'
                             +'}'
                 +']}');

            return res;
        }
    } 
*/
}