public class JIP_ProjectTaskImportQueueable implements Queueable{
    private Id contentVersionId;
    private Id projectId;
    private String userEmail;
    private String fileName;

    // Define the required headers for the CSV file
    private static final List<String> REQUIRED_HEADERS = new List<String>{
        'Type',
        'Subject',
        'Assignee',
        'Status',
        'Category',
        'Priority',
        'Version/Milestone',
        'Due Date',
        'Description'
    };

    // Define the column indices for the CSV file
    private static final Integer COL_TYPE = 0;
    private static final Integer COL_SUBJECT = 1;
    private static final Integer COL_ASSIGNEE = 2;
    private static final Integer COL_STATUS = 3;
    private static final Integer COL_CATEGORY = 4;
    private static final Integer COL_PRIORITY = 5;
    private static final Integer COL_MILESTONE = 6;
    private static final Integer COL_DUE_DATE = 7;
    private static final Integer COL_DESCRIPTION = 8;

    // Define the status values for email sending
    private static final String STATUS_SENT = 'Sent';
    private static final String STATUS_FAILED = 'Failed';
    private static final String STATUS_TEMPLATE_NOT_FOUND = 'Template Not Found';

    // Define the email template names for success and error notifications
    private static final String TEMPLATE_COMPLETION = 'Mass_Import_Success';
    private static final String TEMPLATE_ERROR = 'Mass_Import_Error';

    // Define the error message for missing email template
    private static final String MSG_TEMPLATE_NOT_FOUND = 'Email template not found.';

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

        // 1. Check if ContentVersion exists and has data
        if (cv == null || cv.VersionData == null) {
            failImport(cv, 'ContentVersion not found or has no data.');
            return;
        }
        
        // 2. Get record limit configuration
        try {
            recordLimitPerImport = Integer.valueOf(
                System.Label.Project_Task_Import_Record_Limit.trim()
            );
        } catch (Exception e) {
            failImport(cv, 'Invalid record limit configuration: ' + e.getMessage());
            return;
        }
        if (recordLimitPerImport <= 0) {
            failImport(cv, 'Record limit configuration must be greater than zero.');
            return;
        }

        // 3. Parse CSV content into structured rows (BOM, CRLF, quoted commas/newlines handled)
        List<CsvRow> parsedRows;
        try {
            parsedRows = parseCsv(cv.VersionData.toString());
        }
        catch (Exception e) {
            failImport(cv, 'Error parsing CSV: ' + e.getMessage());
            return;
        }

        // Filter out empty rows
        List<CsvRow> nonEmptyRows = new List<CsvRow>();
        for (CsvRow row : parsedRows) {
            if (!isEmptyRow(row.columns)) {
                nonEmptyRows.add(row);
            }
        }

        // 4. Validate CSV header
        if (nonEmptyRows.isEmpty()) {
            failImport(cv, 'CSV is empty. Header row is missing.');
            return;
        }
        CsvRow csvHeader = nonEmptyRows[0];
        Boolean isValidHeader = REQUIRED_HEADERS.size() == csvHeader.columns.size();
        if (isValidHeader) {
            for (Integer i = 0; i < REQUIRED_HEADERS.size(); i++) {
                if (REQUIRED_HEADERS[i].trim() != csvHeader.columns[i].trim()) {
                    isValidHeader = false;
                    break;
                }
            }
        }
        if (!isValidHeader) {
            failImport(cv, 'CSV header is missing or invalid. Expected: ' + String.join(REQUIRED_HEADERS, ', '));
            return;
        }

        List<CsvRow> dataRows = new List<CsvRow>();
        for (Integer i = 1; i < nonEmptyRows.size(); i++) {
            dataRows.add(nonEmptyRows[i]);
        }
        // Check if there are any data rows after the header
        if(dataRows.isEmpty()) {
            failImport(cv, 'CSV file contains headers only. No data rows found.');
            return;
        }

        // 5. Check record limit
        if (dataRows.size() > recordLimitPerImport) {
            failImport(cv, 'CSV file exceeds the maximum allowed records of ' + recordLimitPerImport + '. Found: ' + dataRows.size());
            return;
        }

        
        // 6. Collect all unique worker codes from the CSV
        Set<String> workerCodes = new Set<String>();
        for(CsvRow row : dataRows) {
            List<String> csvColumns = row.columns;
            if (csvColumns.size() != REQUIRED_HEADERS.size()) {
                failImport(cv, 'Invalid number of columns at Row ' + row.lineNumber + '. Expected: ' + REQUIRED_HEADERS.size() + ', Found: ' + csvColumns.size());
                continue;
            }
            // Trim and add the worker code in the Assignee column to the set if it's not blank
            if(String.isNotBlank(csvColumns[COL_ASSIGNEE])) {
                workerCodes.add(csvColumns[COL_ASSIGNEE].trim());
            }
        }
        
        // Query the workers by their codes
        Map<String, Id> workersByCode = new Map<String, Id>();
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

        // 7. Create ProjectTask records from the CSV data
        
        // Get picklist values for validation
        List<Schema.PicklistEntry> typeEntries = JIP_ProjectTask__c.TaskType__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> statusEntries = JIP_ProjectTask__c.Status__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> categoryEntries = JIP_ProjectTask__c.Category__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> priorityEntries = JIP_ProjectTask__c.Priority__c.getDescribe().getPicklistValues();
        
        // Iterate through each data row and create a ProjectTask record
        List<JIP_ProjectTask__c> tasksToInsert = new List<JIP_ProjectTask__c>();
        List<Integer> taskLineNumbers = new List<Integer>();
        for (CsvRow row : dataRows) {
            List<String> csvColumns = row.columns;
            System.debug('CSV Columns: ' + csvColumns);
            JIP_ProjectTask__c csvTask = new JIP_ProjectTask__c();
            if (csvColumns.size() != REQUIRED_HEADERS.size()) {
                failImport(cv, 'Invalid number of columns at Row ' + row.lineNumber + '. Expected: ' + REQUIRED_HEADERS.size() + ', Found: ' + csvColumns.size());
                continue;
            } 
            
            List <String> rowErrors = new List<String>();

            //  Required: Subject column B
            String subject = csvColumns[COL_SUBJECT] == null ? '' : csvColumns[COL_SUBJECT].trim();
            if (String.isBlank(subject)) {
                rowErrors.add('Subject is required');
            }

            //  Required + validate format: Due Date H
            Date dueDate = null;
            String dueDateRaw = csvColumns[COL_DUE_DATE] == null ? '' : csvColumns[COL_DUE_DATE].trim();
            if (String.isBlank(dueDateRaw)) {
                rowErrors.add('Due Date is required');
            } else {
                dueDate = parseDueDate(dueDateRaw, rowErrors);
            }

            // Assignee: if provided, validate that the worker code exists in the system
            Id assigneeId = null;
            String assigneeCode = csvColumns[COL_ASSIGNEE] == null ? '' : csvColumns[COL_ASSIGNEE].trim();
            if (String.isNotBlank(assigneeCode)) {
                assigneeId = workersByCode.get(assigneeCode);
                if (assigneeId == null) {
                    rowErrors.add('Assignee with code "' + assigneeCode + '" does not exist');
                }
            }

            // Picklist fields: Task Type, Status, Category, Priority
            String taskType = resolvePicklistValue(typeEntries, csvColumns[COL_TYPE], 'Task Type', rowErrors);
            String status = resolvePicklistValue(statusEntries, csvColumns[COL_STATUS], 'Status', rowErrors);
            String category = resolvePicklistValue(categoryEntries, csvColumns[COL_CATEGORY], 'Category', rowErrors);
            String priority = resolvePicklistValue(priorityEntries, csvColumns[COL_PRIORITY], 'Priority', rowErrors);

            // If there are any errors for this row, log them and skip to the next row
            if (!rowErrors.isEmpty()) {
                errorCount++;
                for (String error : rowErrors) {
                    errorMessages.add('Row ' + row.lineNumber + ': ' + error);
                }
                continue; // Skip this row due to errors
            }

            // If no errors, map the CSV columns to the ProjectTask fields and add to the list for insertion
            if (rowErrors.isEmpty()) {
                csvTask.Project__c = projectId;
                csvTask.TaskType__c = taskType;
                csvTask.Subject__c = subject;
                csvTask.Assignee__c = assigneeId;
                csvTask.Status__c = status;
                csvTask.Category__c = category;
                csvTask.Priority__c = priority;
                csvTask.Milestone__c = csvColumns[COL_MILESTONE];
                csvTask.DueDate__c = dueDate;
                csvTask.Description__c = csvColumns[COL_DESCRIPTION];
                tasksToInsert.add(csvTask);
                taskLineNumbers.add(row.lineNumber);
                System.debug('CSV Task: ' + csvTask);
            }
        }

        totalCount = tasksToInsert.size() + errorCount;
        // 8. Insert the valid ProjectTask records and handle any DML exceptions
        try {
            Database.SaveResult[] results = Database.insert(tasksToInsert, true);
            successCount = results.size();
        }
        catch (DmlException e) {
            errorCount += e.getNumDml();
            for (Integer i = 0; i < e.getNumDml(); i++) {
                Integer errorIndex = e.getDmlIndex(i);
                Integer lineNumber = taskLineNumbers[errorIndex];
                String taskName = tasksToInsert[errorIndex].Subject__c;
                String errorMessage = 'Row ' + lineNumber + ' (Task: ' + taskName + '): ' + e.getDmlMessage(i);
                errorMessages.add(errorMessage);
            }
        }

        try {
            sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
        } finally {
            deleteImportedCSV(cv);
        }
    }

    // Helper class to represent a CSV row with its columns and line number
    private class CsvRow {
        List<String> columns;
        Integer lineNumber;
        CsvRow(List<String> columns, Integer lineNumber) {
            this.columns = columns;
            this.lineNumber = lineNumber;
        }
    }

    // Parse CSV content into structured rows, handling BOM, CRLF, quoted commas/newlines
    private static List<CsvRow> parseCsv(String content) {
        List<CsvRow> rows = new List<CsvRow>();

        // Return empty list if content is null or blank
        if (String.isBlank(content)){
            return rows;
        }

        // Delete UTF-8 BOM
        if (content.startsWith('\uFEFF')) {
            content = content.substring(1); 
        }

        List<String> currentRow = new List<String>();
        String currentField = '';
        Boolean inQuotes = false;
        Integer lineNumber = 1;
        Integer rowStartLine = 1;
        Integer i = 0;
        Integer len = content.length();

        while (i < len) {
            String c = content.substring(i, i + 1);

            if (inQuotes) {
                if (c == '"') {
                    // Escaped quote: ""
                    if (i + 1 < len && content.substring(i + 1, i + 2) == '"') {
                        currentField += '"';
                        i += 2;
                    } else {
                        inQuotes = false;
                        i++;
                    }
                } else {
                    if (c == '\n') {
                        lineNumber++;
                    }
                    currentField += c;
                    i++;
                }
            } else {
                if (c == '"') {
                    inQuotes = true;
                    i++;
                } else if (c == ',') {
                    currentRow.add(currentField);
                    currentField = '';
                    i++;
                } else if (c == '\r') {
                    currentRow.add(currentField);
                    currentField = '';
                    rows.add(new CsvRow(currentRow, rowStartLine));
                    currentRow = new List<String>();
                    lineNumber++;
                    rowStartLine = lineNumber;
                    i++;

                    // Delete \n if it's CRLF
                    if (i < len && content.substring(i, i + 1) == '\n') i++;
                } else if (c == '\n') {
                    currentRow.add(currentField);
                    currentField = '';
                    rows.add(new CsvRow(currentRow, rowStartLine));
                    currentRow = new List<String>();
                    lineNumber++;
                    rowStartLine = lineNumber;
                    i++;
                } else {
                    currentField += c;
                    i++;
                }
            }
        }

        // Delete the last row if it's empty
        if (!currentRow.isEmpty() || String.isNotBlank(currentField)) {
            currentRow.add(currentField);
            rows.add(new CsvRow(currentRow, rowStartLine));
        }
        return rows;
    }

    private static Boolean isEmptyRow(List<String> columns) {
        for (String c : columns) {
            if (String.isNotBlank(c)) return false;
        }
        return true;
    }

    private static Boolean isValidHeader(List<String> csvHeader) {
        if (csvHeader == null || csvHeader.size() != REQUIRED_HEADERS.size()) return false;
        for (Integer i = 0; i < REQUIRED_HEADERS.size(); i++) {
            String csvHeader = csvHeader[i] == null ? '' : csvHeader[i].trim();
            String v = csvHeader[i] == null ? '' : csvHeader[i].trim();
            if (v != REQUIRED_HEADERS[i]) return false;
        }
        return true;
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
        String templateName = hasErrors ? TEMPLATE_ERROR : TEMPLATE_COMPLETION;
        List<EmailTemplate> templates = [
            SELECT Subject, HtmlValue
            FROM EmailTemplate
            WHERE DeveloperName = :templateName
            LIMIT 1
        ];

        if (templates.isEmpty()) {
            createEmailLog(templateName, false, STATUS_TEMPLATE_NOT_FOUND, null, MSG_TEMPLATE_NOT_FOUND);
            return;
        }

        EmailTemplate template = templates[0];
        String emailBody = template.HtmlValue;
        String errorDetails = String.join(errorMessages, '<br><br>');
        errorDetails = errorDetails.replace('\n', '<br>');

        Map<String, String> placeholders = new Map<String, String>{
            '{{fileName}}'          => fileName,
            '{{totalTasks}}'        => String.valueOf(totalCount),
            '{{successfulImports}}' => String.valueOf(successCount),
            '{{failedImports}}'     => String.valueOf(errorCount),
            '{{errorMessages}}'     => errorDetails,
            '{{projectUrl}}'        => projectUrl,
            '{{tasksUrl}}'          => tasksUrl
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

        try {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(
                new Messaging.SingleEmailMessage[] { email },
                false
            );
            if (results[0].isSuccess()) {
                createEmailLog(templateName, true, STATUS_SENT, template.Subject, null);
            } else {
                String errorMessage = getSendErrors(results);
                createEmailLog(templateName, true, STATUS_FAILED, template.Subject, errorMessage);
            }
        } catch (Exception e) {
            createEmailLog(templateName, true, STATUS_FAILED, template.Subject, e.getMessage());
        }
    }

    // Delete CSV after import
    private void deleteImportedCSV(ContentVersion cv) {
        if (cv != null && cv.ContentDocumentId != null) {
            delete new ContentDocument (
                Id = cv.ContentDocumentId
            );
        }
    }

    private static String resolvePicklistValue(
        List<Schema.PicklistEntry> picklistValues,
        String csvValue,
        String fieldName,
        List<String> rowErrors
    ) {
        String value = csvValue == null ? '' : csvValue.trim();

        // Check if the value is not blank and exists in the picklist values
        if (String.isNotBlank(value)) {
            for (Schema.PicklistEntry entry : picklistValues) {
                if (
                    entry.isActive() &&
                    entry.getValue().equalsIgnoreCase(value)
                ) {
                    return entry.getValue();
                }
            }
            rowErrors.add('Invalid value for ' + fieldName + ': ' + value);
            return null;
        }

        // Check for default value if the CSV value is blank
        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.isActive() && entry.isDefaultValue()) {
                return entry.getValue();
            }
        }
        return null;
    }

    private void createEmailLog(
        String templateName,
        Boolean templateFound,
        String status,
        String subject, 
        String errorMessage
    ){
        JIP_Email_Send_Log__c emailLog = new JIP_Email_Send_Log__c();
        emailLog.Template_Developer_Name__c = templateName;
        emailLog.Template_Found__c = templateFound;
        emailLog.Send_Status__c = status;
        emailLog.Email_Subject__c = subject;
        emailLog.Error_Message__c = errorMessage;
        emailLog.Recipient_Email__c = userEmail;
        emailLog.JIP_Project__c = projectId;
        emailLog.File_Name__c = fileName;
        emailLog.Attempted_At__c = System.now();
        try {
            insert emailLog;
        } catch (Exception e) {
            System.debug('Error creating email log: ' + e.getMessage());
        }
    }

    private static String getSendErrors(Messaging.SendEmailResult[] results) {
        List<String> errorMessages = new List<String>();
        for (Messaging.SendEmailResult result : results) {
            if (!result.isSuccess()) {
                for (Messaging.SendEmailError error : result.getErrors()) {
                    errorMessages.add(error.getMessage());
                }
            }
        }
        if (errorMessages.isEmpty()) {
            errorMessages.add('Unknown error occurred while sending email.');
        }
        return String.join(errorMessages, '\n');
    }

    private void failImport(ContentVersion cv, String errorMessage) {
        List<String> errorMessages = new List<String>();
        try {
            sendImportResultEmail(0, 0, 1, errorMessages);
        }
        catch (Exception e) {
            System.debug('Error sending failure email: ' + e.getMessage());
        }
        finally {
            deleteImportedCSV(cv);
        }
    }
}
