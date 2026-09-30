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
            System.debug('csvRows' + csvRows.size());
            if (csvRows.size() <= 1) {
                errorCount += 1;
                errorMessages.add('CSV file contains headers only.');
                sendImportErrorEmail(totalCount, errorCount, errorMessages);
                deleteImportedCSV(cv);
                return;
            }

            List<String> header = new List<String> {
                'Type', 'Subject', 'Assignee', 'Status', 'Category', 'Priority', 'Version/Milestone', 'Due Date', 'Description'
            };
            List<String> csvHeader = csvRows[0].split(',');
            Boolean isValidHeader = csvHeader.size() == header.size();
            if (isValidHeader) {
                for (Integer i = 0; i <header.size(); i++) {
                    if (csvHeader[i].trim() != header[i]) {
                        isValidHeader = false;
                        break;
                    }
                }
            }
            if (!isValidHeader) {
                errorCount += 1;
                errorMessages.add('CSV header is missing or invalid.');
                sendImportErrorEmail(totalCount, errorCount, errorMessages);
                deleteImportedCSV(cv);
                return;
            }

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
        Messaging.SingleEmailMessage email =
            new Messaging.SingleEmailMessage();

        String baseUrl =
            URL.getOrgDomainUrl().toExternalForm();

        // Link tới Project
        String projectUrl =
            baseUrl
            + '/lightning/r/JIP_Project__c/'
            + projectId
            + '/view';

        // Link tới Task Management
        String tasksUrl =
             baseUrl + '/lightning/n/JIP_TicketManagement'
             +'?projectId='
             + projectId;

        // Create the email message
        EmailTemplate template = [
            SELECT Id, Subject, HtmlValue, Body
            FROM EmailTemplate
            WHERE DeveloperName = 'Mass_Import_Completion'
            LIMIT 1
        ];
        string emailBody = template.HtmlValue;
        emailBody = emailBody.replace('{{fileName}}', fileName);
        emailBody = emailBody.replace('{{totalTasks}}', String.valueOf(totalCount));
        emailBody = emailBody.replace('{{successfulImports}}', String.valueOf(successCount));
        emailBody = emailBody.replace('{{projectUrl}}', projectUrl);
        emailBody = emailBody.replace('{{tasksUrl}}', tasksUrl);
        email.setHtmlBody(
            emailBody
        );
        email.setToAddresses(
            new String[] { userEmail }
        );
        email.setSubject(
            template.Subject
        );
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(
            new Messaging.SingleEmailMessage[] { email }
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
        String tasksUrl =
             baseUrl + '/lightning/n/JIP_TicketManagement'
             +'?projectId='
             + projectId;

        Messaging.SingleEmailMessage email =
            new Messaging.SingleEmailMessage();

        email.setToAddresses(
            new String[] { userEmail }
        );

       // Create the email message
        EmailTemplate template = [
            SELECT Id, Subject, HtmlValue, Body
            FROM EmailTemplate
            WHERE DeveloperName = 'Mass_Import_Error'
            LIMIT 1
        ];

        String emailBody = template.HtmlValue;
        String errorDetails = String.join(errorMessages, '<br><br>');
        errorDetails = errorDetails.replace('\n', '<br>');
        emailBody = emailBody.replace('{{fileName}}', fileName);
        emailBody = emailBody.replace('{{totalTasks}}', String.valueOf(totalCount));
        emailBody = emailBody.replace('{{failedImports}}', String.valueOf(errorCount));
        emailBody = emailBody.replace('{{errorMessages}}', errorDetails);
        emailBody = emailBody.replace('{{projectUrl}}', projectUrl);
        emailBody = emailBody.replace('{{tasksUrl}}', tasksUrl);
        
        email.setHtmlBody(
            emailBody
        );
        email.setToAddresses(
            new String[] { userEmail }
        );
        email.setSubject(
            template.Subject
        );

        Messaging.SendEmailResult[] results = Messaging.sendEmail(
            new Messaging.SingleEmailMessage[] { email }
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
