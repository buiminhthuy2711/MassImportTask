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
        List<String> errorMessages = new List<String>();
        
        ContentVersion cv = [
            SELECT Id, Title, VersionData, ContentDocumentId
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

            // Count total tasks
            totalCount = tasksToInsert.size();

            try {
                Database.SaveResult[] results = Database.insert(tasksToInsert, true);
                for (Database.SaveResult result : results) {
                    successCount++;
                }
            }
            // Catch CSV Row, Task Name, and Error Message for each failed record
            catch (DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++){
                    Integer errorIndex = e.getDmlIndex(i);
                    JIP_ProjectTask__c failedTask = tasksToInsert[errorIndex];
                    String taskName = failedTask.Subject__c != null ? failedTask.Subject__c : 'Empty';
                    String errorMessage = e.getDmlMessage(i);
                    Integer csvRow = errorIndex + 2; // +2 to account for header row and 0-based index
                    errorMessages.add('Row ' + csvRow + '\nTask Name: ' + taskName + '\nError: ' + errorMessage);
                    errorCount++;
                }
            }

            // SEND EMAIL AFTER IMPORT
            if (errorCount > 0) {
                sendImportErrorEmail(totalCount, errorCount, errorMessages);
            } else {
                sendImportSuccessEmail(totalCount, successCount);
            }
            deleteImportedCSV(cv);
        }
    }

    // SEND IMPORT SUCCESS EMAIL
    private void sendImportSuccessEmail(
        Integer totalCount,
        Integer successCount
    ) {

        String baseUrl =
            URL.getOrgDomainUrl().toExternalForm();

        // Link tới Project
        String projectUrl =
            baseUrl
            + '/lightning/r/JIP_Project__c/'
            + projectId
            + '/view';

        // Link tới Task Management
        String taskUrl =
             baseUrl + '/lightning/n/JIP_TicketManagement';

        Messaging.SingleEmailMessage email =
            new Messaging.SingleEmailMessage();

        email.setToAddresses(
            new String[] { userEmail }
        );

        email.setSubject(
            'CSV Import Completed Successfully'
        );

        email.setPlainTextBody(

            'CSV IMPORT SUCCESS\n\n'
            +'Your CSV file has been imported successfully.\n\n'

            + 'File Name: '
            + fileName
            + '\n\n'

            + 'Total Tasks: '
            + totalCount
            + '\n'

            + 'Successfully Imported: '
            + successCount
            + '\n\n'

            + 'Project Link:\n'
            + projectUrl
            + '\n'

            + 'View Tasks:\n'
            + taskUrl
        );
        Messaging.sendEmail(
            new Messaging.SingleEmailMessage[] {
                email
            }
        );
    } 

    // SEND IMPORT ERROR EMAIL
    private void sendImportErrorEmail(
        Integer totalCount,
        Integer errorCount,
        List<String> errorMessages
    ){
        String baseUrl =
            URL.getOrgDomainUrl().toExternalForm();

        // Link tới Project
        String projectUrl =
            baseUrl
            + '/lightning/r/JIP_Project__c/'
            + projectId
            + '/view';

        // Link tới Task Management
        String taskUrl =
             baseUrl + '/lightning/n/JIP_TicketManagement';

        Messaging.SingleEmailMessage email =
            new Messaging.SingleEmailMessage();

        email.setToAddresses(
            new String[] { userEmail }
        );

        email.setSubject(
            'CSV Import Completed with Errors'
        );

        email.setPlainTextBody(

            'CSV IMPORT FAILED\n\n'
            +'The CSV file could not be imported. No tasks were imported.\n\n'

            + 'File Name: '
            + fileName
            + '\n\n'

            + 'Total Tasks: '
            + totalCount
            + '\n'

            + 'Failed Tasks: '
            + errorCount
            + '\n\n'

            + 'Error Details:\n'
            + String.join(errorMessages, '\n\n')
            + '\n\n'

            + 'Project Link:\n'
            + projectUrl
            + '\n'

            + 'View Tasks:\n'
            + taskUrl
        );
        Messaging.sendEmail(
            new Messaging.SingleEmailMessage[] {
                email
            }
        );
    }

    // Delete CSV after import
    private void deleteImportedCSV(ContentVersion cv) {
        if (cv != null && cv.ContentDocumentId != null) {
            delete new ContentDocument (
                Id = cv.ContentDocumentId
            );
        }
    }

}
