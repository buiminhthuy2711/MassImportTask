public with sharing class JIP_WorkerCodeNormalizer {
        public class Request {
        @InvocableVariable(required=true)
        public Id recordId;

        @InvocableVariable(required=true)
        public String workerCode;
    }

    @InvocableMethod(label='Normalize Worker Code')
    public static void normalizeWorkerCode(List<Request> requests) {

        Set<Id> recordIds = new Set<Id>();

        for (Request req : requests) {
            if (req.recordId != null) {
                recordIds.add(req.recordId);
            }
        }

        if (recordIds.isEmpty()) {
            return;
        }

        Map<Id, JIP_Worker__c> workers = new Map<Id, JIP_Worker__c>(
            [
                SELECT Id, Worker_Code__c
                FROM JIP_Worker__c
                WHERE Id IN :recordIds
            ]
        );

        List<JIP_Worker__c> workersToUpdate = new List<JIP_Worker__c>();

        for (Request req : requests) {

            JIP_Worker__c worker = workers.get(req.recordId);

            if (worker == null || String.isBlank(req.workerCode)) {
                continue;
            }

            String normalizedCode = normalize(req.workerCode);

            if (worker.Worker_Code__c != normalizedCode) {
                worker.Worker_Code__c = normalizedCode;
                workersToUpdate.add(worker);
            }
        }

        if (!workersToUpdate.isEmpty()) {
            update workersToUpdate;
        }
    }

    private static String normalize(String input) {
        if (String.isBlank(input)) {
        return '';
        }
        String result = input.toLowerCase();

        result = result.replace('à', 'a');
        result = result.replace('á', 'a');
        result = result.replace('ạ', 'a');
        result = result.replace('ả', 'a');
        result = result.replace('ã', 'a');

        result = result.replace('â', 'a');
        result = result.replace('ầ', 'a');
        result = result.replace('ấ', 'a');
        result = result.replace('ậ', 'a');
        result = result.replace('ẩ', 'a');
        result = result.replace('ẫ', 'a');

        result = result.replace('ă', 'a');
        result = result.replace('ằ', 'a');
        result = result.replace('ắ', 'a');
        result = result.replace('ặ', 'a');
        result = result.replace('ẳ', 'a');
        result = result.replace('ẵ', 'a');

        result = result.replace('è', 'e');
        result = result.replace('é', 'e');
        result = result.replace('ẹ', 'e');
        result = result.replace('ẻ', 'e');
        result = result.replace('ẽ', 'e');

        result = result.replace('ê', 'e');
        result = result.replace('ề', 'e');
        result = result.replace('ế', 'e');
        result = result.replace('ệ', 'e');
        result = result.replace('ể', 'e');
        result = result.replace('ễ', 'e');

        result = result.replace('ì', 'i');
        result = result.replace('í', 'i');
        result = result.replace('ị', 'i');
        result = result.replace('ỉ', 'i');
        result = result.replace('ĩ', 'i');

        result = result.replace('ò', 'o');
        result = result.replace('ó', 'o');
        result = result.replace('ọ', 'o');
        result = result.replace('ỏ', 'o');
        result = result.replace('õ', 'o');

        result = result.replace('ô', 'o');
        result = result.replace('ồ', 'o');
        result = result.replace('ố', 'o');
        result = result.replace('ộ', 'o');
        result = result.replace('ổ', 'o');
        result = result.replace('ỗ', 'o');

        result = result.replace('ơ', 'o');
        result = result.replace('ờ', 'o');
        result = result.replace('ớ', 'o');
        result = result.replace('ợ', 'o');
        result = result.replace('ở', 'o');
        result = result.replace('ỡ', 'o');

        result = result.replace('ù', 'u');
        result = result.replace('ú', 'u');
        result = result.replace('ụ', 'u');
        result = result.replace('ủ', 'u');
        result = result.replace('ũ', 'u');

        result = result.replace('ư', 'u');
        result = result.replace('ừ', 'u');
        result = result.replace('ứ', 'u');
        result = result.replace('ự', 'u');
        result = result.replace('ử', 'u');
        result = result.replace('ữ', 'u');

        result = result.replace('ỳ', 'y');
        result = result.replace('ý', 'y');
        result = result.replace('ỵ', 'y');
        result = result.replace('ỷ', 'y');
        result = result.replace('ỹ', 'y');

        result = result.replace('đ', 'd');

        return result.toUpperCase();
    }

}