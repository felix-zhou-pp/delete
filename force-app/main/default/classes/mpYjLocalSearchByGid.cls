//Test Class : mpYjLocalSearchByGidTest
public class mpYjLocalSearchByGid {
    // Yahoo!ローカルサーチAPI
    private class YjLocalSearchException extends Exception {}
    
    public static Map<String, List<mpComm__c>> localSearchByGid(Map<String,Map<Id,mpComm__c>> gidMap){
        Map<String, List<mpComm__c>> result  = new Map<String, List<mpComm__c>>();
        List<mpComm__c> updatePrepares = new List<mpComm__c>();
        
        result.put('Error', new List<mpComm__c>());
        if(gidMap.size() < 1) return result;
        try{
            Long startTime = DateTime.now().getTime();
            Long finishTime = DateTime.now().getTime();
            //0.4second Sleep
            if (!Test.isRunningTest()) { while ((finishTime - startTime) < 400) {finishTime = DateTime.now().getTime();}}
                
            HttpRequest req = new HttpRequest();
            String appid = 'dj00aiZpPVdYMFM0MkVpME9LNiZzPWNvbnN1bWVyc2VjcmV0Jng9N2U-';
            String cid = '65cb0f23a8ac78347db3c3a9114edf67';
            String gids = String.join(new List<String>(gidMap.keySet()), ',');
            //String gids = 'H8xmJoKRltI,9MOddMLRuJY,F6M0SjokXOY,MASvYxedAbw,nn5goeIaUWk,vi4CUtE5UHE,aK5tV-nadbU,D-73C9Rfv-Y,roLcNrqrQ0g,t2nHlgX8GiM,qzpzk14LN3w,f1xDRU8p09Y,5N7nL9VUafY,UUbCTBREp-2,M52ZarnsAig,9z1N3FF8AAM,QcKSQHX8v1A,Kw5_1Wha6tg,BDaaPUBgme-,__YwltbMOVM,hyRdWHkjVA2,VgqkW5zRArE,WYqwRptgjYU,bi-fPi5juFw,FpyOyyDTvrA,72fPVavHpco,WLRAjFC-4bw,-UwmAovb3v-,HAigS5BJ-Ds,TCegENez9RY,uOihU4DcdTE,fqDA93_leAw,usUCBy7dzWc,TO0mswufWBk,9lVYzBPXNM-,u0czO78capg,9UdWrvrsI0I,XEYGDacagrA,ymp-9fUs6M-,qi3MLWW1ii-,BhwR-D3S0iw,sq4NrDIVdFQ,hOJ8jK73h7o,YUVDQZmf1A-,AC4x-dSZ0r-,zGqLI8mG_-A,2i6NJv3fnVI,VLBlwfOzlWw,9sov4aj1hyQ,xxudhAVtR0M,QEMIHyfObKA,tCLI0wS64nM,9vxeRhJYG9Y,U0-gnIrQI_w,38ZM_cgDsVc,8vYKs8J7782,3lFgiVJd1zw,TFcJ4q1iud6,FhS-9pgysOo,GmE7BbR8b1I,b_MIYC1FOtw,lZ6zWWmwhio,bAqk5BwhoDM,uPJHbuGV0Lg,PYDf9xBd3f-,A0WqEIhsMB-,ejDHsdpUDTc,cBiMg82EWTo,uafzLrFQfpE,qfEPcCDToik,FDzRqQeiENY,QV9pFTl1jZw,ZjcitWUsJhw,vdkOFBX4PlM,_fBt-EMxOSk,g7nTvPAdjQ6,ZFC6weq3BLI,Yjvwc-3yq-Y,AeCqsioZ0Ro,w6Lnb4faWr2,vHaKbKamJq6,Nexy_FKwHko,_ACV0wK3K4-,XRONCLQeAZ-,_WwIgxCIRuo,l87H1b-dNvA,7tKHbI3q8_-,s5S3Qu5Pk36,xn-dH55nnKU,pKxLZgGQXEk,vHeobDtlCRk,8tPoruxb2mY,F9UpDITAm5-,qvFG3KIT9eY,Qurgl7XQQf-,8ab2IU9Q4NE,O7A-tdC0YB2,O7A-tdC0YB2,GsLWPjhapPA,h_WOBFcX9bQ,lZObeozqdeY,pvPhuet4wxY,AxRkqlBTi2M,KvhLAiJ5A8-,s-qoeAl-cvs,niPpiNC0YB2,TooaWj4mG2-,L1vn67TZr4A,H4cPZv3bqAY,B-4YEHINJQU,7ndYAGdB-Os,tII0R-V9w-Y,kZJVuR5Lybk,4rgpV659C0s,DDmPvI5X0rw,WYDG2byUt76,mes2PxomfRE,u2xMVfTZ6MI,y7LNyEZesvU,mRj8a9enizI,FX0CUILgmrQ,199t0aQkM9-,KFwZlHsCdjc,bj1ZDhFje8A,AdJTqrGjIx2,rTqxZ9t3U9o,G7QQJlRS4iQ,oc2LppZirdA,i8zF3ZaRodQ,LJ0v9Rsfzjc,DUDUOIbYT2-,7MB3sH5u2j-,1gS_V95_xf2,lNbUjexXREM,Y33Nt_6BHko,8pLWi51DN1c,6pFcLZFTewI,RD7goMqB3rc,2IfYQUvK6Jk,s5n04P0ZxgI,8m2NKuCzc3s,NiVJkYHmkaM,2HhBgZ_tMYs,Live7IY4VxA,nSvyqB_O2fo,742r3Q-7ORs,MXu0xDoTFWs,H0jfI4HtjJ-,g11WoGVibTE,ffFoCd7t50w';

            req.setEndpoint('https://map.yahooapis.jp/search/local/V1/localSearch?detail=full&results=100&output=json&distinct=paypay&group=gid&cid='+cid+'&appid='+appid+'&gid='+gids);
            req.setMethod('GET');

            Http h = new Http();
            HttpResponse res = h.send(req);

            //system.debug(res);
            //system.debug(res.getBody());

            //Response Sample 
                /*
                {
                    "ResultInfo": {
                        "Count": 2,
                    },
                    "Feature": [
                        {
                            "Name": "JOTARO SAITO GINZA SIX店",
                            "Category": [
                                "カフェ、スイーツ"
                            ],
                            "Property": {
                                "Address": "東京都中央区銀座6丁目10-1 GINZA SIX 4F",
                                "Tel1": "03-6263-9961"
                                    （略）
                                "LandmarkCode": "80901000006",
                                "Detail": {
                                    （略）
                                    "PayPayFlag": "true",
                                    "PayPayMid": "70000077000000000",
                                    "PayPaySid": "70000077000000001",
                                    （略）
                                }
                            }
                        }, 
                        {
                            （略）
                        }
                    ]
                }
                */

            // レスポンス解析
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Map<String, Object> resultInfo = (Map<String, Object>) response.get('ResultInfo');
            //system.debug(resultInfo);
            if (resultInfo == null) {
                // 認証失敗など
                throw new YjLocalSearchException('YOLPからレスポンスが返されなかった');
            }
        
            Integer count = (Integer) resultInfo.get('Count');

            if (count == 0 || count == null) {
                // 該当結果なし
                system.debug('該当結果なし');
            } else {
                //system.debug(DateTime.now());
                //system.debug(count);

                List<Object> featureList = (List<Object>) response.get('Feature');

                String name;
                Map<String, Object> property;
                Map<String, Object> detail;

                for (Object  featureObject : (List<Object>) featureList) {
                    Map<String, Object> feature = (Map<String, Object>)  featureObject;

                    name = '';
                    property = null;
                    detail = null;

                    name = (String) feature.get('Name');
                    property = (Map<String, Object>) feature.get('Property');
                    if (property != null) {
                        detail = (Map<String, Object>) property.get('Detail');
                    }

                    if (name != null 
                        && property != null // プロパティ情報がないやつは除外
                        && (
                            // PayPay登録済みのみ
                            detail != null
                            && detail.get('PayPayFlag') != null
                            && (String) detail.get('PayPayFlag') == 'true'
                            // ID登録済み
                            && detail.get('PayPayMid') != null && (String) detail.get('PayPayMid') != ''
                            && detail.get('PayPaySid') != null && (String) detail.get('PayPaySid') != ''
                        )
                        ) {
                        
                        //system.debug('name : '+name);
                        //system.debug('res gid : '+(String)feature.get('Gid'));
                        //system.debug('mid : '+(String)(detail.get('PayPayMid')));
                        //system.debug('sid : '+(String)(detail.get('PayPaySid')));
                        //system.debug('uid : '+(String)(property.get('Uid'));

                        if(gidMap.containsKey((String)feature.get('Gid'))){
                            for(mpComm__c mpCommRow: gidMap.get((String)feature.get('Gid')).values() ){
                                mpCommRow.MID__c=(String)(detail.get('PayPayMid'));
                                mpCommRow.StoreId__c=(String)(detail.get('PayPaySid'));
                                mpCommRow.uid__c=(String)(property.get('Uid'));
                                updatePrepares.add(mpCommRow);  
                            }
                        }
                    } else {
                        count--;
                    }
                }
            }
            if(updatePrepares.size() > 0) result.put('Success', updatePrepares);
            
        } catch (Exception e) {
                system.debug(e.getMessage());
                system.debug(e.getCause());

                // エラー返す
                result.put('Error', new List<mpComm__c>());
        }
        return result;
    }
}