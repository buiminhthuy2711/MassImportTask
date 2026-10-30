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
        Integer recordLimitPerImport;
        List<String> errorMessages = new List<String>();
        
        ContentVersion cv = [
            SELECT Id, Title, VersionData, ContentDocumentId
            FROM ContentVersion 
            WHERE Id = :contentVersionId 
            LIMIT 1
        ];
        
        // Get the record limit from the custom label and validate it
        try {
            recordLimitPerImport = Integer.valueOf(
                System.Label.Project_Task_Import_Record_Limit.trim()
            );
        } catch (Exception e) {
            errorCount += 1;
            errorMessages.add('Invalid record limit configuration: ' + e.getMessage());
            sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
            deleteImportedCSV(cv);
            return;
        }
        if (recordLimitPerImport <= 0) {
            errorCount += 1;
            errorMessages.add('Record limit configuration must be greater than zero.');
            sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
            deleteImportedCSV(cv);
            return;
        }

        // Parse the CSV file and create ProjectTask records
        if (cv != null && cv.VersionData != null) {
            String versionDataString = cv.VersionData.toString();
            List<String> csvRows = versionDataString.split('\n');

            // Check if the number of records exceeds the limit
            if (csvRows.size() - 1 > recordLimitPerImport) {
                errorCount += 1;
                errorMessages.add('CSV file exceeds the maximum allowed number of records: ' + recordLimitPerImport);
                sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
                deleteImportedCSV(cv);
                return;
            }

            System.debug('csvRows' + csvRows.size());
            if (csvRows.size() <= 1) {
                errorCount += 1;
                errorMessages.add('CSV file contains headers only.');
                sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
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
                errorMessages.add('CSV header is missing or invalid. Expected: ' + String.join(header, ', '));
                sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
                deleteImportedCSV(cv);
                return;
            }

            List<JIP_ProjectTask__c> tasksToInsert = new List<JIP_ProjectTask__c>();
            Set<String> workerCodes = new Set<String>();
            Map<String, Id> workersByCode = new Map<String, Id>();

            // Collect all unique worker codes from the CSV
            for(Integer i = 1; i < csvRows.size(); i++) {
                List<String> csvColumns = csvRows[i].split(',');
                if (csvColumns.size() != header.size()) {
                    errorCount++;
                    Integer csvRow = i + 1; // +1 to account for header row
                    errorMessages.add('Invalid number of columns at Row ' + csvRow);
                    continue;
                }

                if(errorCount == 0 && csvColumns[2] != null && csvColumns[2] != '') {
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
                if (csvColumns.size() != header.size()) {
                    errorCount++;
                    Integer csvRow = i + 1; // +1 to account for header row
                    errorMessages.add('Invalid number of columns at Row ' + csvRow);
                    continue;
                }
                else {
                    csvTask.Project__c = projectId;
                    csvTask.TaskType__c = picklistValueOrDefault(JIP_ProjectTask__c.TaskType__c, csvColumns[0]);
                    csvTask.Subject__c = csvColumns[1];
                    csvTask.Assignee__c = workersByCode.get(csvColumns[2]);
                    csvTask.Status__c = picklistValueOrDefault(JIP_ProjectTask__c.Status__c, csvColumns[3]);
                    csvTask.Category__c = picklistValueOrDefault(JIP_ProjectTask__c.Category__c, csvColumns[4]);
                    csvTask.Priority__c = picklistValueOrDefault(JIP_ProjectTask__c.Priority__c, csvColumns[5]);
                    csvTask.Milestone__c = csvColumns[6];
                    csvTask.DueDate__c = Date.valueOf(csvColumns[7]);
                    csvTask.Description__c = csvColumns[8];
                    System.debug('CSV Task: ' + csvTask);
                    tasksToInsert.add(csvTask);
                }
            }

            // Count total tasks
            totalCount = tasksToInsert.size();
            
            // Insert tasks and handle errors
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

            // Send email to user after import
            try {
                sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Email template not found or email sending failed: ' + e.getMessage());
            }
            
            deleteImportedCSV(cv);
        }
    }

    // Send email to user
    private void sendImportResultEmail(
        Integer totalCount,
        Integer successCount,
        Integer errorCount,
        List<String> errorMessages
    ){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        String projectUrl = baseUrl + '/lightning/r/JIP_Project__c/' + projectId + '/view';
        String tasksUrl = baseUrl + '/lightning/n/JIP_TicketManagement?projectId=' + projectId;

        Boolean hasErrors = errorCount > 0;
        String templateName = hasErrors ? 'Mass_Import_Error' : 'Mass_Import_Completion';
        List<EmailTemplate> templates = [
            SELECT Subject, HtmlValue
            FROM EmailTemplate
            WHERE DeveloperName = :templateName
            LIMIT 1
        ];
        if (templates.isEmpty()) {
            System.debug(LoggingLevel.ERROR, 'Email template not found.');
            return;
        }
        EmailTemplate template = templates[0];
        String emailBody = template.HtmlValue;
        String errorDetails = String.join(errorMessages, '<br><br>');
        errorDetails = errorDetails.replace('\n', '<br>');

        Map<String, String> placeholders = new Map<String, String>{
            '{{fileName}}' => fileName,
            '{{totalTasks}}'=> String.valueOf(totalCount),
            '{{successfulImports}}' => String.valueOf(successCount),
            '{{failedImports}}' => String.valueOf(errorCount),
            '{{errorMessages}}' => errorDetails,
            '{{projectUrl}}' => projectUrl,
            '{{tasksUrl}}' => tasksUrl
        };
        for (String key : placeholders.keySet()) {
            String value = placeholders.get(key);
            String safeValue = value == null ? '' : value;
            emailBody = emailBody.replace(key, safeValue);
        }

        email.setHtmlBody(
            emailBody
        );

        email.setToAddresses(
            new List<String> { userEmail }
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

    // Get picklist value or default value
    private static String picklistValueOrDefault(Schema.SObjectField fieldTask, String csvValue) {
        if (String.isNotBlank(csvValue)) {
            return csvValue.trim();
        }

        for (Schema.PicklistEntry entry : fieldTask.getDescribe().getPicklistValues()) {
            if (entry.isActive() && entry.isDefaultValue()) {
                return entry.getValue();
            }
        }
        
        return null;
    }
}
