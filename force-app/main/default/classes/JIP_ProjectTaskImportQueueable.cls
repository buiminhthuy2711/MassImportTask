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
        ] ?? null;

        // Check if ContentVersion exists and has data
        if (cv == null || cv.VersionData == null) {
            errorCount++;
            errorMessages.add('ContentVersion not found or has no data.');
            sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
            deleteImportedCSV(cv);
            return;
        }
        
        // Get record limit configuration
        try {
            recordLimitPerImport = Integer.valueOf(
                System.Label.Project_Task_Import_Record_Limit.trim()
            );
        } catch (Exception e) {
            errorCount++;
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

        String versionDataString = cv.VersionData.toString();
        List<String> csvRows = versionDataString.split('\n');

<<<<<<< Updated upstream
        // Check if the number of records exceeds the limit
        if (csvRows.size() - 1 > recordLimitPerImport) {
            errorCount++;
            errorMessages.add('Record limit exceeded. Maximum allowed: ' + recordLimitPerImport);
            sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
=======
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

                if(String.isNotBlank(csvColumns[2])) {
                    workerCodes.add(csvColumns[2].trim());
                }
            }
               // Assignee: nếu có giá trị phải tìm thấy Worker
            Id assigneeId = null;
            String assigneeCode = cols[COL_ASSIGNEE] == null ? '' : cols[COL_ASSIGNEE].trim();
            if (String.isNotBlank(assigneeCode)) {
                assigneeId = workersByCode.get(assigneeCode);
                if (assigneeId == null) {
                    rowErrors.add('Worker with code "' + assigneeCode + '" not found');
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
                    csvTask.Assignee__c = workersByCode.get(csvColumns[2].trim());
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
            
>>>>>>> Stashed changes
            deleteImportedCSV(cv);
            return;
        }
        if (csvRows.size() <= 1) {
            errorCount++;
            errorMessages.add('CSV file is empty or only contains headers.');
            sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
            deleteImportedCSV(cv);
            return;
        }

        // Validate CSV header
        List<String> header = new List<String>{
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
        List<String> csvHeader = csvRows[0].split(',');
        Boolean isValidHeader = header.size() == csvHeader.size();
        if (isValidHeader) {
            for (Integer i = 0; i < header.size(); i++) {
                if (header[i].trim() != csvHeader[i].trim()) {
                    isValidHeader = false;
                    break;
                }
            }
        }
        if (!isValidHeader) {
            errorCount++;
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

            if(String.isNotBlank(csvColumns[2])) {
                workerCodes.add(csvColumns[2].trim());
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
            } else {
                csvTask.Project__c = projectId;
                csvTask.TaskType__c = picklistValueOrDefault(JIP_ProjectTask__c.TaskType__c, csvColumns[0]);
                csvTask.Subject__c = csvColumns[1];
                csvTask.Assignee__c = workersByCode.get(csvColumns[2].trim());
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

        totalCount = tasksToInsert.size() + errorCount;
        try {
            Database.SaveResult[] results = Database.insert(tasksToInsert, true);
            for (Database.SaveResult result : results) {
                successCount++;
            }
        }
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

        sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
        deleteImportedCSV(cv);
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

// public class JIP_ProjectTaskImportQueueable implements Queueable {

//     private Id contentVersionId;
//     private Id projectId;
//     private String userEmail;
//     private String fileName;

//     // Header cố định & index cột
//     private static final List<String> EXPECTED_HEADER = new List<String>{
//         'Type', 'Subject', 'Assignee', 'Status', 'Category',
//         'Priority', 'Version/Milestone', 'Due Date', 'Description'
//     };
//     private static final Integer COL_TYPE        = 0;
//     private static final Integer COL_SUBJECT     = 1;
//     private static final Integer COL_ASSIGNEE    = 2;
//     private static final Integer COL_STATUS      = 3;
//     private static final Integer COL_CATEGORY    = 4;
//     private static final Integer COL_PRIORITY    = 5;
//     private static final Integer COL_MILESTONE   = 6;
//     private static final Integer COL_DUE_DATE    = 7;
//     private static final Integer COL_DESCRIPTION = 8;

//     public JIP_ProjectTaskImportQueueable(Id contentVersionId, Id projectId, String userEmail, String fileName) {
//         this.contentVersionId = contentVersionId;
//         this.projectId        = projectId;
//         this.userEmail        = userEmail;
//         this.fileName         = fileName;
//     }

//     public void execute(QueueableContext context) {
//         Integer totalCount = 0;
//         Integer successCount = 0;
//         Integer errorCount = 0;
//         Integer recordLimitPerImport;
//         List<String> errorMessages = new List<String>();

//         ContentVersion cv = [
//             SELECT Id, Title, VersionData, ContentDocumentId
//             FROM ContentVersion
//             WHERE Id = :contentVersionId
//             LIMIT 1
//         ];

//         // ---- 1. Lấy record limit ----
//         try {
//             recordLimitPerImport = Integer.valueOf(
//                 System.Label.Project_Task_Import_Record_Limit.trim()
//             );
//         } catch (Exception e) {
//             errorCount += 1;
//             errorMessages.add('Invalid record limit configuration: ' + e.getMessage());
//             sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
//             deleteImportedCSV(cv);
//             return;
//         }
//         if (recordLimitPerImport <= 0) {
//             errorCount += 1;
//             errorMessages.add('Record limit configuration must be greater than zero.');
//             sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
//             deleteImportedCSV(cv);
//             return;
//         }

//         if (cv == null || cv.VersionData == null) {
//             return;
//         }

//         // ---- 2. Parse CSV (BOM, CRLF, quoted commas/newlines) ----
//         List<CsvRow> parsedRows;
//         try {
//             parsedRows = parseCsv(cv.VersionData.toString());
//         } catch (Exception e) {
//             errorCount += 1;
//             errorMessages.add('Failed to parse CSV: ' + e.getMessage());
//             sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
//             deleteImportedCSV(cv);
//             return;
//         }

//         // Bỏ dòng trống
//         List<CsvRow> nonEmptyRows = new List<CsvRow>();
//         for (CsvRow r : parsedRows) {
//             if (!isEmptyRow(r.columns)) nonEmptyRows.add(r);
//         }
//         if (nonEmptyRows.isEmpty()) {
//             errorCount += 1;
//             errorMessages.add('CSV file is empty.');
//             sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
//             deleteImportedCSV(cv);
//             return;
//         }

//         // ---- 3. Validate header ----
//         CsvRow headerRow = nonEmptyRows[0];
//         if (!isValidHeader(headerRow.columns)) {
//             errorCount += 1;
//             errorMessages.add('CSV header is missing or invalid. Expected: '
//                 + String.join(EXPECTED_HEADER, ', '));
//             sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
//             deleteImportedCSV(cv);
//             return;
//         }

//         List<CsvRow> dataRows = new List<CsvRow>();
//         for (Integer i = 1; i < nonEmptyRows.size(); i++) {
//             dataRows.add(nonEmptyRows[i]);
//         }
//         if (dataRows.isEmpty()) {
//             errorCount += 1;
//             errorMessages.add('CSV file contains headers only.');
//             sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
//             deleteImportedCSV(cv);
//             return;
//         }

//         // ---- 4. Check record limit ----
//         if (dataRows.size() > recordLimitPerImport) {
//             errorCount += 1;
//             errorMessages.add('CSV file exceeds the maximum allowed number of records: '
//                 + recordLimitPerImport);
//             sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
//             deleteImportedCSV(cv);
//             return;
//         }

//         totalCount = dataRows.size();

//         // ---- 5. Gom Worker Code và query 1 lần ----
//         Set<String> workerCodes = new Set<String>();
//         for (CsvRow row : dataRows) {
//             if (row.columns.size() == EXPECTED_HEADER.size()) {
//                 String wc = row.columns[COL_ASSIGNEE];
//                 if (String.isNotBlank(wc)) workerCodes.add(wc.trim());
//             }
//         }
//         Map<String, Id> workersByCode = new Map<String, Id>();
//         if (!workerCodes.isEmpty()) {
//             for (JIP_Worker__c w : [
//                 SELECT Id, Worker_Code__c
//                 FROM JIP_Worker__c
//                 WHERE Worker_Code__c IN :workerCodes
//             ]) {
//                 workersByCode.put(w.Worker_Code__c, w.Id);
//             }
//         }

//         // Cache picklist describes (tránh describe lặp lại từng dòng)
//         List<Schema.PicklistEntry> typeEntries =
//             JIP_ProjectTask__c.TaskType__c.getDescribe().getPicklistValues();
//         List<Schema.PicklistEntry> statusEntries =
//             JIP_ProjectTask__c.Status__c.getDescribe().getPicklistValues();
//         List<Schema.PicklistEntry> categoryEntries =
//             JIP_ProjectTask__c.Category__c.getDescribe().getPicklistValues();
//         List<Schema.PicklistEntry> priorityEntries =
//             JIP_ProjectTask__c.Priority__c.getDescribe().getPicklistValues();

//         // ---- 6. Validate từng dòng, xây task list ----
//         List<JIP_ProjectTask__c> tasksToInsert = new List<JIP_ProjectTask__c>();
//         List<Integer> taskLineNumbers = new List<Integer>();

//         for (CsvRow row : dataRows) {
//             List<String> cols = row.columns;
//             Integer lineNum = row.lineNumber;

//             if (cols.size() != EXPECTED_HEADER.size()) {
//                 errorCount += 1;
//                 errorMessages.add('Row ' + lineNum + ': Invalid number of columns (expected '
//                     + EXPECTED_HEADER.size() + ', got ' + cols.size() + ')');
//                 continue;
//             }

//             List<String> rowErrors = new List<String>();

//             // ---- Required: Subject ----
//             String subject = cols[COL_SUBJECT] == null ? '' : cols[COL_SUBJECT].trim();
//             if (String.isBlank(subject)) {
//                 rowErrors.add('Subject is required');
//             }

//             // ---- Required + validate format: Due Date ----
//             Date dueDate = null;
//             String dueDateRaw = cols[COL_DUE_DATE] == null ? '' : cols[COL_DUE_DATE].trim();
//             if (String.isBlank(dueDateRaw)) {
//                 rowErrors.add('Due Date is required');
//             } else {
//                 dueDate = parseDueDate(dueDateRaw, rowErrors);
//             }

//             // Assignee: nếu có giá trị phải tìm thấy Worker
//             Id assigneeId = null;
//             String assigneeCode = cols[COL_ASSIGNEE] == null ? '' : cols[COL_ASSIGNEE].trim();
//             if (String.isNotBlank(assigneeCode)) {
//                 assigneeId = workersByCode.get(assigneeCode);
//                 if (assigneeId == null) {
//                     rowErrors.add('Worker with code "' + assigneeCode + '" not found');
//                 }
//             }

//             //  Picklist: validate giá trị hợp lệ (rỗng → dùng default)
//             String taskType = resolvePicklistValue(typeEntries, cols[COL_TYPE], 'Type', rowErrors);
//             String status   = resolvePicklistValue(statusEntries, cols[COL_STATUS], 'Status', rowErrors);
//             String category = resolvePicklistValue(categoryEntries, cols[COL_CATEGORY], 'Category', rowErrors);
//             String priority = resolvePicklistValue(priorityEntries, cols[COL_PRIORITY], 'Priority', rowErrors);

//             // Nếu có lỗi → báo và skip dòng (partial success)
//             if (!rowErrors.isEmpty()) {
//                 errorCount += 1; // 1 dòng lỗi (dù có nhiều message)
//                 for (String err : rowErrors) {
//                     errorMessages.add('Row ' + lineNum + ': ' + err);
//                 }
//                 continue;
//             }

//             // ---- Build record ----
//             JIP_ProjectTask__c task = new JIP_ProjectTask__c();
//             task.Project__c     = projectId;
//             task.TaskType__c    = taskType;
//             task.Subject__c     = subject;
//             task.Assignee__c    = assigneeId;
//             task.Status__c      = status;
//             task.Category__c    = category;
//             task.Priority__c    = priority;
//             task.Milestone__c   = cols[COL_MILESTONE];
//             task.DueDate__c     = dueDate;
//             task.Description__c = cols[COL_DESCRIPTION]; // Được phép trống
//             tasksToInsert.add(task);
//             taskLineNumbers.add(lineNum);
//         }

//         // ---- 7. Insert (partial success: allOrNone = false) ----
//         if (!tasksToInsert.isEmpty()) {
//             Database.SaveResult[] results = Database.insert(tasksToInsert, false);
//             for (Integer i = 0; i < results.size(); i++) {
//                 Database.SaveResult sr = results[i];
//                 if (sr.isSuccess()) {
//                     successCount += 1;
//                 } else {
//                     errorCount += 1;
//                     Integer lineNum = taskLineNumbers[i];
//                     JIP_ProjectTask__c failedTask = tasksToInsert[i];
//                     String taskName = failedTask.Subject__c != null ? failedTask.Subject__c : 'Empty';
//                     for (Database.Error err : sr.getErrors()) {
//                         errorMessages.add('Row ' + lineNum
//                             + '\nTask Name: ' + taskName
//                             + '\nError: ' + err.getMessage());
//                     }
//                 }
//             }
//         }

//         // ---- 8. Gửi mail + dọn file ----
//         try {
//             sendImportResultEmail(totalCount, successCount, errorCount, errorMessages);
//         } catch (Exception e) {
//             System.debug(LoggingLevel.ERROR, 'Email sending failed: ' + e.getMessage());
//         }
//         deleteImportedCSV(cv);
//     }

//     // ============================================================
//     // CSV PARSER (hỗ trợ BOM / CRLF / quoted comma / quoted newline)
//     // ============================================================
//     private class CsvRow {
//         List<String> columns;
//         Integer lineNumber; // số dòng vật lý bắt đầu record
//         CsvRow(List<String> columns, Integer lineNumber) {
//             this.columns = columns;
//             this.lineNumber = lineNumber;
//         }
//     }

//     private static List<CsvRow> parseCsv(String content) {
//         List<CsvRow> rows = new List<CsvRow>();
//         if (String.isBlank(content)) return rows;

//         // Bỏ UTF-8 BOM
//         if (content.startsWith('\uFEFF')) {
//             content = content.substring(1);
//         }

//         List<String> currentRow = new List<String>();
//         String currentField = '';
//         Boolean inQuotes = false;
//         Integer lineNumber = 1;
//         Integer rowStartLine = 1;
//         Integer i = 0;
//         Integer len = content.length();

//         while (i < len) {
//             String c = content.substring(i, i + 1);

//             if (inQuotes) {
//                 if (c == '"') {
//                     // Escaped quote: ""
//                     if (i + 1 < len && content.substring(i + 1, i + 2) == '"') {
//                         currentField += '"';
//                         i += 2;
//                     } else {
//                         inQuotes = false;
//                         i++;
//                     }
//                 } else {
//                     if (c == '\n') lineNumber++;
//                     currentField += c;
//                     i++;
//                 }
//             } else {
//                 if (c == '"') {
//                     inQuotes = true;
//                     i++;
//                 } else if (c == ',') {
//                     currentRow.add(currentField);
//                     currentField = '';
//                     i++;
//                 } else if (c == '\r') {
//                     currentRow.add(currentField);
//                     currentField = '';
//                     rows.add(new CsvRow(currentRow, rowStartLine));
//                     currentRow = new List<String>();
//                     lineNumber++;
//                     rowStartLine = lineNumber;
//                     i++;
//                     // nuốt luôn \n nếu là CRLF
//                     if (i < len && content.substring(i, i + 1) == '\n') i++;
//                 } else if (c == '\n') {
//                     currentRow.add(currentField);
//                     currentField = '';
//                     rows.add(new CsvRow(currentRow, rowStartLine));
//                     currentRow = new List<String>();
//                     lineNumber++;
//                     rowStartLine = lineNumber;
//                     i++;
//                 } else {
//                     currentField += c;
//                     i++;
//                 }
//             }
//         }

//         // Dòng cuối
//         if (!currentRow.isEmpty() || String.isNotBlank(currentField)) {
//             currentRow.add(currentField);
//             rows.add(new CsvRow(currentRow, rowStartLine));
//         }
//         return rows;
//     }

//     private static Boolean isEmptyRow(List<String> columns) {
//         for (String c : columns) {
//             if (String.isNotBlank(c)) return false;
//         }
//         return true;
//     }

//     private static Boolean isValidHeader(List<String> cols) {
//         if (cols == null || cols.size() != EXPECTED_HEADER.size()) return false;
//         for (Integer i = 0; i < EXPECTED_HEADER.size(); i++) {
//             String v = cols[i] == null ? '' : cols[i].trim();
//             if (v != EXPECTED_HEADER[i]) return false;
//         }
//         return true;
//     }

//     // ============================================================
//     // VALIDATION HELPERS
//     // ============================================================
//     private static Date parseDueDate(String raw, List<String> rowErrors) {
//         String s = raw.trim();
//         // YYYY-MM-DD
//         if (!Pattern.matches('\\d{4}-\\d{2}-\\d{2}', s)) {
//             rowErrors.add('Invalid Due Date format: "' + s + '" (expected YYYY-MM-DD)');
//             return null;
//         }
//         try {
//             Date d = Date.valueOf(s);
//             // Kiểm tra chặt: Date.valueOf có thể chuẩn hóa ngày không tồn tại
//             Integer y = Integer.valueOf(s.substring(0, 4));
//             Integer m = Integer.valueOf(s.substring(5, 7));
//             Integer dd = Integer.valueOf(s.substring(8, 10));
//             if (d.year() != y || d.month() != m || d.day() != dd) {
//                 rowErrors.add('Invalid Due Date: "' + s + '" does not exist');
//                 return null;
//             }
//             return d;
//         } catch (Exception e) {
//             rowErrors.add('Invalid Due Date: "' + s + '"');
//             return null;
//         }
//     }

//     private static String resolvePicklistValue(
//         List<Schema.PicklistEntry> entries,
//         String rawValue,
//         String fieldLabel,
//         List<String> rowErrors
//     ) {
//         String v = rawValue == null ? '' : rawValue.trim();
//         if (String.isBlank(v)) {
//             for (Schema.PicklistEntry e : entries) {
//                 if (e.isActive() && e.isDefaultValue()) return e.getValue();
//             }
//             return null;
//         }
//         for (Schema.PicklistEntry e : entries) {
//             if (e.isActive() && e.getValue() == v) return v;
//         }
//         rowErrors.add('Invalid ' + fieldLabel + ' value: "' + v + '"');
//         return null;
//     }

//     // ============================================================
//     // EMAIL & CLEANUP
//     // ============================================================
//     private void sendImportResultEmail(
//         Integer totalCount,
//         Integer successCount,
//         Integer errorCount,
//         List<String> errorMessages
//     ) {
//         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

//         String baseUrl = URL.getOrgDomainUrl().toExternalForm();
//         String projectUrl = baseUrl + '/lightning/r/JIP_Project__c/' + projectId + '/view';
//         String tasksUrl   = baseUrl + '/lightning/n/JIP_TicketManagement?projectId=' + projectId;

//         Boolean hasErrors = errorCount > 0;
//         String templateName = hasErrors ? 'Mass_Import_Error' : 'Mass_Import_Completion';

//         List<EmailTemplate> templates = [
//             SELECT Subject, HtmlValue
//             FROM EmailTemplate
//             WHERE DeveloperName = :templateName
//             LIMIT 1
//         ];
//         if (templates.isEmpty()) {
//             System.debug(LoggingLevel.ERROR, 'Email template not found: ' + templateName);
//             return;
//         }

//         EmailTemplate template = templates[0];
//         String emailBody = template.HtmlValue;
//         String errorDetails = String.join(errorMessages, '<br><br>');
//         errorDetails = errorDetails == null ? '' : errorDetails.replace('\n', '<br>');

//         Map<String, String> placeholders = new Map<String, String>{
//             '{{fileName}}'        => fileName,
//             '{{totalTasks}}'      => String.valueOf(totalCount),
//             '{{successfulImports}}' => String.valueOf(successCount),
//             '{{failedImports}}'   => String.valueOf(errorCount),
//             '{{errorMessages}}'   => errorDetails,
//             '{{projectUrl}}'      => projectUrl,
//             '{{tasksUrl}}'        => tasksUrl
//         };
//         for (String key : placeholders.keySet()) {
//             String value = placeholders.get(key);
//             emailBody = emailBody.replace(key, value == null ? '' : value);
//         }

//         email.setHtmlBody(emailBody);
//         email.setToAddresses(new List<String>{ userEmail });
//         email.setSubject(template.Subject);

//         Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ email });
//     }

//     private void deleteImportedCSV(ContentVersion cv) {
//         if (cv != null && cv.ContentDocumentId != null) {
//             delete new ContentDocument(Id = cv.ContentDocumentId);
//         }
//     }
// }