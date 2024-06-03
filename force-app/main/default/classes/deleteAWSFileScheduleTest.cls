@isTest
public class deleteAWSFileScheduleTest {
    @isTest
    static void deleteAWSFileScheduleTest(){
        Test.startTest();
        // Apexをスケジュールに登録
        String jobId = System.schedule('deleteAWSFileScheduleTest', '0 0 * * * ?', new deleteAWSFileSchedule());
        // テスト終了（登録したスケジュールが実施される）
        Test.stopTest();
        System.assert(String.isNotBlank(jobId));
    }

}