global class deleteAWSFileSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        deleteAWSFileBatch.run(100);
    }
}