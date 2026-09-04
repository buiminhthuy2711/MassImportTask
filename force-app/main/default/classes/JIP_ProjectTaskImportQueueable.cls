// public with sharing class JIP_ProjectTaskImportQueueable implements Queueable{
//     private static final Integer DML_BATCH_SIZE = 200;
//     private static final Integer MAX_EMAIL_ERRORS = 50;

//     private Id contentVersionId;
//     private Id projectId;
//     private String userEmail;
//     private String fileName;
//     private String registeredByName;

//     public JIP_ProjectTaskImportQueueable(
//          Id contentVersionId,
//          Id projectId,
//          String registeredByName,
//          String userEmail,
//          String fileName
//     )
//     {
//         this.contentVersionId = contentVersionId;
//         this.projectId = projectId;
//         this.registeredByName = registeredByName;
//         this.userEmail = userEmail;
//         this.fileName = fileName;
//     }
//     public void execute(QueueableContext context) {
//         Integer totalCount = 0;
//         Integer successCount = 0;
//         Integer errorCount = 0;
//         List<String> errorMessages = new List<String>();

//         try {
//             ContentVersion cv = [
//                 SELECT Id, VersionData
//                 FROM ContentVersion
//                 WHERE Id = :contentVersionId
//                 WITH USER_MODE
//                 LIMIT 1
//             ];
//             if (cvList.isEmpty()) {
//                 sendResultEmail(0, 0, 0,'The uploaded CSV file is empty.');
//                 return;
//             }
//             String csvContent = cv.VersionData.toString();
//             if (String.isBlank(csvContent)) {
//                 sendResultEmail(0,0,0, 'The uploaded CSV file is empty.');
//                 return;
//             }
//             List<List<String>> records = parseCsv(csvContent);
//             if (records.isEmpty()) {
//                 sendResultEmail(0,0,0, 'The CSV file does not contain any data.');
//                 return;
//             }
//             if (records.size() == 1) {

//                 sendResultEmail(
//                     0,
//                     0,
//                     0,
//                     'The CSV file does not contain any data.'
//                 );

//                 return;
//             }
         /**
 * Copyright (c) 2023-2026 JIP Academy (Tokyo, Japan).
 * Developed by JIP Academy R&D Team / Nguyen Minh Phuong.
 * All rights reserved.
 *
 * Unauthorized copying, modification, distribution, or use of this source code,
 * in whole or in part, is strictly prohibited without prior written permission.
 *
 * @see https://www.jip-academy.com/
 */
public with sharing class JIP_ProjectTaskImportQueueable
    implements Queueable {

    private static final Integer DML_BATCH_SIZE = 200;
    private static final Integer MAX_EMAIL_ERRORS = 50;

    private Id contentVersionId;
    private Id projectId;
    private String registeredByName;
    private String userEmail;
    private String fileName;

    public JIP_ProjectTaskImportQueueable(
        Id contentVersionId,
        Id projectId,
        String registeredByName,
        String userEmail,
        String fileName
    ) {

        this.contentVersionId = contentVersionId;

        this.projectId = projectId;

        this.registeredByName = registeredByName;

        this.userEmail = userEmail;

        this.fileName = fileName;
    }

    // Execute

    public void execute(
        QueueableContext context
    ) {

        Integer totalCount = 0;
        Integer successCount = 0;
        Integer errorCount = 0;

        List<String> errorMessages =
            new List<String>();


        try {
            // 1. Get ContentVersion
            ContentVersion cv = [
                SELECT
                    Id,
                    VersionData
                FROM ContentVersion
                WHERE Id = :contentVersionId
                WITH USER_MODE
                LIMIT 1
            ];

            if (cv.VersionData == null) {
                sendResultEmail(
                    0,
                    0,
                    0,
                    'The uploaded CSV file is empty.'
                );
                return;
            }

            String csvContent =
                cv.VersionData.toString();
            if (String.isBlank(csvContent)) {
                sendResultEmail(
                    0,
                    0,
                    0,
                    'The uploaded CSV file is empty.'
                );

                return;
            }


            // =================================================
            // 2. Parse complete CSV
            // =================================================
            //
            // Do NOT use:
            //
            // csvContent.split('\n')
            //
            // because a quoted CSV field may contain newline.
            //
            List<List<String>> records =
                parseCsv(csvContent);


            if (records.isEmpty()) {

                sendResultEmail(
                    0,
                    0,
                    0,
                    'The CSV file does not contain any data.'
                );

                return;
            }

            if (records.size() == 1) {
                sendResultEmail(
                    0,
                    0,
                    0,
                    'The CSV file does not contain any data.'
                );
                return;
            }

            // 3. Header
            List<String> headers =
                records[0];
            Map<String, Integer> headerIndexMap =
                buildHeaderIndex(headers);
            // 4. Validate required headers
            validateRequiredHeaders(
                headerIndexMap
            );

            // 5. Parse rows
            List<ImportRow> taskBuffer =
                new List<ImportRow>();

            for (
                Integer rowIndex = 1;
                rowIndex < records.size();
                rowIndex++
            ) {

                List<String> values =
                    records[rowIndex];

                // Skip completely empty row
                if (isEmptyRow(values)) {
                    continue;
                }

                /*
                 * CSV row number:
                 * Header = row 1
                 * First data = row 2
                 */
                Integer csvRowNumber =
                    rowIndex + 1;
                totalCount++;
                try {

                    JIP_ProjectTask__c task =
                        buildTask(
                            values,
                            headerIndexMap,
                            csvRowNumber
                        );
                    taskBuffer.add(
                        new ImportRow(
                            csvRowNumber,
                            task
                        )
                    );

                } catch (Exception e) {
                    errorCount++;
                    addErrorMessage(
                        errorMessages,
                        'Row ' +
                        String.valueOf(csvRowNumber) +
                        ': ' +
                        e.getMessage()
                    );
                }

                // Insert every 200 records
                if (
                    taskBuffer.size() >=
                    DML_BATCH_SIZE
                ) {

                    ImportResult result =
                        insertTasks(
                            taskBuffer,
                            errorMessages
                        );


                    successCount +=
                        result.successCount;

                    errorCount +=
                        result.errorCount;


                    taskBuffer.clear();
                }
            }


            // 6. Insert remaining records
            if (!taskBuffer.isEmpty()) {

                ImportResult result =
                    insertTasks(
                        taskBuffer,
                        errorMessages
                    );
                successCount +=
                    result.successCount;

                errorCount +=
                    result.errorCount;
            }

            // 7. Send result email
            sendResultEmail(
                totalCount,
                successCount,
                errorCount,
                buildErrorMessage(
                    errorMessages
                )
            );


        } catch (Exception e) {
            sendResultEmail(
                totalCount,
                successCount,
                errorCount,
                'System Error: ' +
                e.getMessage()
            );
        }
    }


    // =========================================================
    // Build Task
    // =========================================================

//     private JIP_ProjectTask__c buildTask(
//         List<String> values,
//         Map<String, Integer> headerIndexMap,
//         Integer rowNumber
//     ) {

//         JIP_ProjectTask__c task =
//             new JIP_ProjectTask__c();


//         // -----------------------------------------------------
//         // Project
//         // -----------------------------------------------------
//         task.Project__c =
//             projectId;


//         // -----------------------------------------------------
//         // Registered By
//         // -----------------------------------------------------
//         task.RegisteredBy__c =
//             registeredByName;


//         // -----------------------------------------------------
//         // Subject
//         // -----------------------------------------------------
//         task.Subject__c =
//             getRequiredValue(
//                 values,
//                 headerIndexMap,
//                 'subject'
//             );


//         // -----------------------------------------------------
//         // Task Type
//         // -----------------------------------------------------
//         task.TaskType__c =
//             getValue(
//                 values,
//                 headerIndexMap,
//                 'tasktype'
//             );


//         // -----------------------------------------------------
//         // Status
//         // -----------------------------------------------------
//         task.Status__c =
//             getValue(
//                 values,
//                 headerIndexMap,
//                 'status'
//             );


//         // -----------------------------------------------------
//         // Category
//         // -----------------------------------------------------
//         task.Category__c =
//             getValue(
//                 values,
//                 headerIndexMap,
//                 'category'
//             );


//         // -----------------------------------------------------
//         // Priority
//         // -----------------------------------------------------
//         task.Priority__c =
//             getValue(
//                 values,
//                 headerIndexMap,
//                 'priority'
//             );


//         // -----------------------------------------------------
//         // Milestone
//         // -----------------------------------------------------
//         task.Milestone__c =
//             getValue(
//                 values,
//                 headerIndexMap,
//                 'milestone'
//             );


//         // -----------------------------------------------------
//         // Description
//         // -----------------------------------------------------
//         task.Description__c =
//             getValue(
//                 values,
//                 headerIndexMap,
//                 'description'
//             );


//         // -----------------------------------------------------
//         // Start Date
//         // -----------------------------------------------------
//         String startDateValue =
//             getValue(
//                 values,
//                 headerIndexMap,
//                 'startdate'
//             );


//         if (
//             String.isNotBlank(
//                 startDateValue
//             )
//         ) {

//             task.StartDate__c =
//                 parseDate(
//                     startDateValue
//                 );
//         }


//         // -----------------------------------------------------
//         // Due Date
//         // -----------------------------------------------------
//         String dueDateValue =
//             getValue(
//                 values,
//                 headerIndexMap,
//                 'duedate'
//             );


//         if (
//             String.isNotBlank(
//                 dueDateValue
//             )
//         ) {

//             task.DueDate__c =
//                 parseDate(
//                     dueDateValue
//                 );
//         }


//         // -----------------------------------------------------
//         // Estimated Hours
//         // -----------------------------------------------------
//         String estimatedHours =
//             getValue(
//                 values,
//                 headerIndexMap,
//                 'estimatedhours'
//             );


//         if (
//             String.isNotBlank(
//                 estimatedHours
//             )
//         ) {

//             try {

//                 task.EstimatedHours__c =
//                     Decimal.valueOf(
//                         estimatedHours.trim()
//                     );

//             } catch (Exception e) {

//                 throw new ImportException(
//                     'Invalid EstimatedHours: ' +
//                     estimatedHours
//                 );
//             }
//         }


//         return task;
//     }


//     // =========================================================
//     // Insert Tasks
//     // =========================================================

//     private ImportResult insertTasks(
//         List<ImportRow> rows,
//         List<String> errorMessages
//     ) {

//         ImportResult result =
//             new ImportResult();


//         List<JIP_ProjectTask__c> tasks =
//             new List<JIP_ProjectTask__c>();


//         for (ImportRow row : rows) {

//             tasks.add(
//                 row.task
//             );
//         }


//         /*
//          * false = partial success.
//          *
//          * USER_MODE =
//          * CRUD + FLS + sharing/security enforcement.
//          */
//         Database.SaveResult[] results =
//             Database.insert(
//                 tasks,
//                 false,
//                 AccessLevel.USER_MODE
//             );


//         for (
//             Integer i = 0;
//             i < results.size();
//             i++
//         ) {

//             Database.SaveResult resultItem =
//                 results[i];


//             ImportRow row =
//                 rows[i];


//             if (
//                 resultItem.isSuccess()
//             ) {

//                 result.successCount++;

//             } else {

//                 result.errorCount++;


//                 String errorMessage =
//                     'Row ' +
//                     String.valueOf(
//                         row.rowNumber
//                     ) +
//                     ': ';


//                 for (
//                     Database.Error error :
//                     resultItem.getErrors()
//                 ) {

//                     errorMessage +=
//                         error.getStatusCode() +
//                         ' - ' +
//                         error.getMessage() +
//                         ' ';
//                 }


//                 addErrorMessage(
//                     errorMessages,
//                     errorMessage
//                 );
//             }
//         }


//         return result;
//     }


//     // =========================================================
//     // Header
//     // =========================================================

//     private static Map<String, Integer>
//     buildHeaderIndex(
//         List<String> headers
//     ) {

//         Map<String, Integer> result =
//             new Map<String, Integer>();


//         for (
//             Integer i = 0;
//             i < headers.size();
//             i++
//         ) {

//             String header =
//                 headers[i]
//                     .trim()
//                     .toLowerCase();


//             /*
//              * Remove UTF-8 BOM if present.
//              *
//              * Some CSV files exported by Excel
//              * may contain BOM at the first header.
//              */
//             if (
//                 i == 0 &&
//                 header.startsWith('\uFEFF')
//             ) {

//                 header =
//                     header.substring(1);
//             }


//             if (
//                 String.isBlank(header)
//             ) {
//                 continue;
//             }


//             result.put(
//                 header,
//                 i
//             );
//         }


//         return result;
//     }


//     private static void validateRequiredHeaders(
//         Map<String, Integer> headerIndexMap
//     ) {

//         List<String> requiredHeaders =
//             new List<String>{
//                 'subject'
//             };


//         for (
//             String header :
//             requiredHeaders
//         ) {

//             if (
//                 !headerIndexMap.containsKey(
//                     header
//                 )
//             ) {

//                 throw new ImportException(
//                     'Missing required CSV header: ' +
//                     header
//                 );
//             }
//         }
//     }


//     // =========================================================
//     // CSV value
//     // =========================================================

//     private static String getValue(
//         List<String> values,
//         Map<String, Integer> headerIndexMap,
//         String headerName
//     ) {

//         if (
//             !headerIndexMap.containsKey(
//                 headerName
//             )
//         ) {

//             return null;
//         }


//         Integer index =
//             headerIndexMap.get(
//                 headerName
//             );


//         if (
//             index == null ||
//             index >= values.size()
//         ) {

//             return null;
//         }


//         if (
//             values[index] == null
//         ) {

//             return null;
//         }


//         return values[index].trim();
//     }


//     private static String getRequiredValue(
//         List<String> values,
//         Map<String, Integer> headerIndexMap,
//         String headerName
//     ) {

//         String value =
//             getValue(
//                 values,
//                 headerIndexMap,
//                 headerName
//             );


//         if (
//             String.isBlank(value)
//         ) {

//             throw new ImportException(
//                 'Required field "' +
//                 headerName +
//                 '" is empty.'
//             );
//         }


//         return value;
//     }


//     // =========================================================
//     // Date
//     // =========================================================

//     private static Date parseDate(String value) {

//         value = value.trim();
//         try{
//             return Date.valueOf(value);
//         }catch (Exception e) {
//             throw new ImportException(
//                 'Invalid date format: ' + value +
//                 '. Expected yyyy-MM-dd.'
//             );
//         }
//     }


//     // =========================================================
//     // CSV Parser
//     // =========================================================

//     /**
//      * CSV parser supporting:
//      *
//      * 1. Comma inside quoted value
//      * 2. Escaped quote ("")
//      * 3. CRLF
//      * 4. Newline inside quoted value
//      */
//     private static List<List<String>> parseCsv(
//         String csv
//     ) {

//         List<List<String>> records =
//             new List<List<String>>();


//         List<String> currentRecord =
//             new List<String>();


//         String currentValue =
//             '';


//         Boolean insideQuotes =
//             false;


//         for (
//             Integer i = 0;
//             i < csv.length();
//             i++
//         ) {

//             String ch =
//                 csv.substring(
//                     i,
//                     i + 1
//                 );


//             // -------------------------------------------------
//             // Quote
//             // -------------------------------------------------
//             if (ch == '"') {


//                 /*
//                  * Escaped quote:
//                  *
//                  * ""
//                  */
//                 if (
//                     insideQuotes &&
//                     i + 1 < csv.length() &&
//                     csv.substring(
//                         i + 1,
//                         i + 2
//                     ) == '"'
//                 ) {

//                     currentValue += '"';

//                     i++;

//                 } else {

//                     insideQuotes =
//                         !insideQuotes;
//                 }


//             // -------------------------------------------------
//             // Comma
//             // -------------------------------------------------
//             } else if (
//                 ch == ',' &&
//                 !insideQuotes
//             ) {

//                 currentRecord.add(
//                     currentValue
//                 );

//                 currentValue = '';


//             // -------------------------------------------------
//             // Newline
//             // -------------------------------------------------
//             } else if (
//                 (
//                     ch == '\n' ||
//                     ch == '\r'
//                 ) &&
//                 !insideQuotes
//             ) {


//                 /*
//                  * Handle Windows CRLF:
//                  *
//                  * \r\n
//                  */
//                 if (
//                     ch == '\r' &&
//                     i + 1 < csv.length() &&
//                     csv.substring(
//                         i + 1,
//                         i + 2
//                     ) == '\n'
//                 ) {

//                     i++;
//                 }


//                 currentRecord.add(
//                     currentValue
//                 );

//                 currentValue = '';


//                 records.add(
//                     currentRecord
//                 );


//                 currentRecord =
//                     new List<String>();


//             // -------------------------------------------------
//             // Normal character
//             // -------------------------------------------------
//             } else {

//                 currentValue += ch;
//             }
//         }


//         /*
//          * Add last field/record.
//          */
//         if (
//             currentValue != '' ||
//             !currentRecord.isEmpty()
//         ) {

//             currentRecord.add(
//                 currentValue
//             );

//             records.add(
//                 currentRecord
//             );
//         }


//         /*
//          * Reject malformed CSV where quote
//          * was never closed.
//          */
//         if (insideQuotes) {

//             throw new ImportException(
//                 'Invalid CSV format: unclosed quotation mark.'
//             );
//         }


//         return records;
//     }


//     // =========================================================
//     // Empty row
//     // =========================================================

//     private static Boolean isEmptyRow(
//         List<String> values
//     ) {

//         for (
//             String value :
//             values
//         ) {

//             if (
//                 String.isNotBlank(value)
//             ) {

//                 return false;
//             }
//         }


//         return true;
//     }


//     // =========================================================
//     // Error handling
//     // =========================================================

//     private static void addErrorMessage(
//         List<String> errors,
//         String message
//     ) {

//         /*
//          * Keep only a limited number of errors
//          * for email size/readability.
//          *
//          * errorCount is still counted separately.
//          */
//         if (
//             errors.size() <
//             MAX_EMAIL_ERRORS
//         ) {

//             errors.add(message);
//         }
//     }


//     private static String buildErrorMessage(
//         List<String> errors
//     ) {

//         if (
//             errors.isEmpty()
//         ) {

//             return null;
//         }


//         String result =
//             'Some rows failed to import:\n\n';


//         for (
//             String error :
//             errors
//         ) {

//             result +=
//                 '- ' +
//                 error +
//                 '\n';
//         }


//         return result;
//     }


//     // =========================================================
//     // Email
//     // =========================================================

//     private void sendResultEmail(
//         Integer totalCount,
//         Integer successCount,
//         Integer errorCount,
//         String systemError
//     ) {

//         if (
//             String.isBlank(userEmail)
//         ) {

//             return;
//         }


//         String body =
//             'Mass Import Task has finished.\n\n' +

//             'File: ' +
//             fileName +
//             '\n' +

//             'Total Tasks: ' +
//             totalCount +
//             '\n' +

//             'Successful Tasks: ' +
//             successCount +
//             '\n' +

//             'Failed Tasks: ' +
//             errorCount;


//         if (
//             String.isNotBlank(
//                 systemError
//             )
//         ) {

//             body +=
//                 '\n\n' +
//                 systemError;
//         }


//         Messaging.SingleEmailMessage email =
//             new Messaging.SingleEmailMessage();


//         email.setToAddresses(
//             new List<String>{
//                 userEmail
//             }
//         );


//         email.setSubject(
//             'Mass Import Task Result'
//         );


//         email.setPlainTextBody(
//             body
//         );


//         Messaging.sendEmail(
//             new List<Messaging.SingleEmailMessage>{
//                 email
//             }
//         );
//     }


//     // =========================================================
//     // DTO: Import Row
//     // =========================================================

//     private class ImportRow {

//         Integer rowNumber;
//         JIP_ProjectTask__c task;


//         ImportRow(
//             Integer rowNumber,
//             JIP_ProjectTask__c task
//         ) {

//             this.rowNumber =
//                 rowNumber;

//             this.task =
//                 task;
//         }
//     }


//     // =========================================================
//     // DTO: Import Result
//     // =========================================================

//     private class ImportResult {

//         Integer successCount = 0;
//         Integer errorCount = 0;
//     }


//     // =========================================================
//     // Custom Exception
//     // =========================================================

//     private class ImportException
//         extends Exception {
//     }
// }
