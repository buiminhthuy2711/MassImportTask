public class JIP_ProjectTaskImportQueueable implements Queueable{
    private Id contentVersionId;
    private Id projectId;
    private String userEmail;
    private String fileName;

    public JIP_ProjectTaskImportQueueable(
         Id contentVersionId,
         Id projectId,
         String userEmail,
         String fileName
    )
    {
        this.contentVersionId = contentVersionId;
        this.projectId = projectId;
        this.userEmail = userEmail;
        this.fileName = fileName;
    }
    public void execute(QueueableContext context) {
        Integer totalCount = 0;
        Integer successCount = 0;
        Integer errorCount = 0;
        
        ContentVersion cv = [
            SELECT Id, Title, VersionData 
            FROM ContentVersion 
            WHERE Id = :contentVersionId 
            LIMIT 1
        ];

        // Parse the CSV file and create ProjectTask records
        if (cv != null && cv.VersionData != null) {
            String versionDataString = cv.VersionData.toString();
            List<String> csvRows = versionDataString.split('\n');
            System.debug('CSV Rows: ' + csvRows);
            List<JIP_ProjectTask__c> tasksToInsert = new List<JIP_ProjectTask__c>();
            Set<String> workerCodes = new Set<String>();
            Map<String, Id> workersByCode = new Map<String, Id>();

            // Collect all unique worker codes from the CSV
            for(Integer i = 1; i < csvRows.size(); i++) {
                List<String> csvColumns = csvRows[i].split(',');
                if(csvColumns[2] != null && csvColumns[2] != '') {
                    workerCodes.add(csvColumns[2]);
                }
            }

            // Query the workers by their codes
            if (!workerCodes.isEmpty()) {
                List<JIP_Worker__c> workers = [
                    SELECT Id, Worker_Code__c 
                    FROM JIP_Worker__c 
                    WHERE Worker_Code__c IN :workerCodes
                ];
                for (JIP_Worker__c worker : workers) {
                    workersByCode.put(worker.Worker_Code__c, worker.Id);
                }
            }

            // Create ProjectTask records from the CSV data
            for (Integer i = 1; i < csvRows.size(); i++) {
                List<String> csvColumns = csvRows[i].split(',');
                System.debug('CSV Columns: ' + csvColumns);
                JIP_ProjectTask__c csvTask = new JIP_ProjectTask__c();
                csvTask.Project__c = projectId;
                csvTask.TaskType__c = csvColumns[0];
                csvTask.Subject__c = csvColumns[1];
                csvTask.Assignee__c = workersByCode.get(csvColumns[2]);
                csvTask.Status__c = csvColumns[3];
                csvTask.Category__c = csvColumns[4];
                csvTask.Priority__c = csvColumns[5];
                csvTask.Milestone__c = csvColumns[6];
                csvTask.DueDate__c = Date.valueOf(csvColumns[7]);
                csvTask.Description__c = csvColumns[8];
                System.debug('CSV Task: ' + csvTask);
                tasksToInsert.add(csvTask);
            }

            // Insert the tasks and count successes and errors
            Database.SaveResult[] results = Database.insert(tasksToInsert, false);
            for (Database.SaveResult result : results) {
                totalCount++;
                System.debug('Insert Result: ' + result);
                if (result.isSuccess()) {
                    successCount++;
                    System.debug('Success: ' + successCount);
                    System.debug('Task inserted successfully: ' + result.getId());
                } else {
                    errorCount++;
                    System.debug('Error: ' + errorCount);
                    for (Database.Error error : result.getErrors()) {
                        System.debug('Error inserting task: ' + error.getMessage());
                    }
                }
            }
        }
    }
}
