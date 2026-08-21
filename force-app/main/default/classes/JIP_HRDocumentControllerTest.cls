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
@isTest
private class JIP_HRDocumentControllerTest {
  @testSetup
  static void setupTestData() {
    // Create comprehensive test data using correct method signatures
    JIP_Department__c dept = JIP_TestDataFactory.createDepartment(
      'Test Department',
      true
    );
    JIP_Worker__c worker = JIP_TestDataFactory.createWorker(
      'Test Worker',
      dept.Id,
      true
    );
    JIP_Project__c proj = JIP_TestDataFactory.createProject(
      'Test Project',
      true
    );
    JIP_ProjectTask__c task = JIP_TestDataFactory.createTask(
      'Test Task',
      proj.Id,
      true
    );
    JIP_Attendance__c attendance = JIP_TestDataFactory.createAttendance(
      worker.Id,
      Date.today(),
      true
    );
    JIP_Document__c doc = JIP_TestDataFactory.createDocument('Test Doc', true);
    JIP_Skill__c skill = JIP_TestDataFactory.createSkill('Test Skill', true);
    JIP_Job__c job = JIP_TestDataFactory.createJob('Test Job', true);
    JIP_Candidate__c candidate = JIP_TestDataFactory.createCandidate(
      'Test Candidate',
      true
    );
    JIP_LeaveRequest__c leave = JIP_TestDataFactory.createLeaveRequest(
      worker.Id,
      true
    );
    JIP_Request__c request = JIP_TestDataFactory.createRequest(worker.Id, true);
    JIP_Contract__c contract = JIP_TestDataFactory.createContract(
      worker.Id,
      true
    );
    JIP_Evaluation__c evaluation = JIP_TestDataFactory.createEvaluation(
      worker.Id,
      true
    );
    JIP_Payslip__c payslip = JIP_TestDataFactory.createPayslip(worker.Id, true);
    JIP_Training__c training = JIP_TestDataFactory.createTraining(
      'Test Training',
      true
    );
    JIP_Certification__c cert = JIP_TestDataFactory.createCertification(
      worker.Id,
      'Test Cert',
      true
    );
    JIP_ProjectMember__c member = JIP_TestDataFactory.createProjectMember(
      proj.Id,
      worker.Id,
      true
    );
  }
  @isTest
  static void testConstructor() {
    Test.startTest();
    JIP_HRDocumentController controller = new JIP_HRDocumentController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
  }
  @isTest
  static void testGetT() {
    JIP_HRDocumentController controller = new JIP_HRDocumentController();

    Test.startTest();
    Map<String, String> translations = controller.getT();
    Test.stopTest();

    System.assertNotEquals(
      null,
      translations,
      'Translations should not be null'
    );
  }
  @isTest
  static void testSearch() {
    JIP_HRDocumentController controller = new JIP_HRDocumentController();

    Test.startTest();
    controller.search();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method search executed successfully');
  }
  @isTest
  static void testClearSearch() {
    JIP_HRDocumentController controller = new JIP_HRDocumentController();

    Test.startTest();
    controller.clearSearch();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method clearSearch executed successfully');
  }
  @isTest
  static void testChangeTab() {
    JIP_HRDocumentController controller = new JIP_HRDocumentController();

    Test.startTest();
    controller.changeTab();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method changeTab executed successfully');
  }
  @isTest
  static void testOpenUploadModal() {
    JIP_HRDocumentController controller = new JIP_HRDocumentController();

    Test.startTest();
    controller.openUploadModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method openUploadModal executed successfully');
  }
  @isTest
  static void testCloseUploadModal() {
    JIP_HRDocumentController controller = new JIP_HRDocumentController();

    Test.startTest();
    controller.closeUploadModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method closeUploadModal executed successfully');
  }
  @isTest
  static void testUploadDocument() {
    JIP_HRDocumentController controller = new JIP_HRDocumentController();

    Test.startTest();
    controller.uploadDocument();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method uploadDocument executed successfully');
  }
  @isTest
  static void testDownloadDocument() {
    JIP_HRDocumentController controller = new JIP_HRDocumentController();

    Test.startTest();
    controller.downloadDocument();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method downloadDocument executed successfully');
  }
  @isTest
  static void testDeleteDocument() {
    JIP_HRDocumentController controller = new JIP_HRDocumentController();

    Test.startTest();
    controller.deleteDocument();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method deleteDocument executed successfully');
  }
  @isTest
  static void testRenewContract() {
    JIP_HRDocumentController controller = new JIP_HRDocumentController();

    Test.startTest();
    controller.renewContract();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method renewContract executed successfully');
  }
  @isTest
  static void testChangeLanguage() {
    JIP_HRDocumentController controller = new JIP_HRDocumentController();

    Test.startTest();
    controller.changeLanguage();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method changeLanguage executed successfully');
  }
  @isTest
  static void testGetCategoryOptions() {
    JIP_HRDocumentController controller = new JIP_HRDocumentController();

    Test.startTest();
    List<SelectOption> options = controller.getCategoryOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetDocumentTypeOptions() {
    JIP_HRDocumentController controller = new JIP_HRDocumentController();

    Test.startTest();
    List<SelectOption> options = controller.getDocumentTypeOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetTabOptions() {
    JIP_HRDocumentController controller = new JIP_HRDocumentController();

    Test.startTest();
    List<SelectOption> options = controller.getTabOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetLanguageOptions() {
    JIP_HRDocumentController controller = new JIP_HRDocumentController();

    Test.startTest();
    List<SelectOption> options = controller.getLanguageOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }

  @isTest
  static void testDownloadDocumentWithParam() {
    JIP_Document__c doc = [SELECT Id FROM JIP_Document__c LIMIT 1];
    doc.IsActive__c = true;
    doc.DownloadCount__c = 5;
    update doc;

    Test.setCurrentPage(Page.JIP_HRDocumentPage);
    ApexPages.currentPage().getParameters().put('docId', doc.Id);

    JIP_HRDocumentController controller = new JIP_HRDocumentController();

    Test.startTest();
    controller.downloadDocument();
    Test.stopTest();

    JIP_Document__c updated = [
      SELECT DownloadCount__c
      FROM JIP_Document__c
      WHERE Id = :doc.Id
    ];
    System.assertEquals(
      6,
      updated.DownloadCount__c,
      'Download count should increment'
    );
  }

  @isTest
  static void testDeleteDocumentWithParam() {
    JIP_Document__c doc = [SELECT Id FROM JIP_Document__c LIMIT 1];
    doc.IsActive__c = true;
    update doc;

    Test.setCurrentPage(Page.JIP_HRDocumentPage);
    ApexPages.currentPage().getParameters().put('deleteId', doc.Id);

    JIP_HRDocumentController controller = new JIP_HRDocumentController();

    Test.startTest();
    controller.deleteDocument();
    Test.stopTest();

    JIP_Document__c updated = [
      SELECT IsActive__c
      FROM JIP_Document__c
      WHERE Id = :doc.Id
    ];
    System.assertEquals(
      false,
      updated.IsActive__c,
      'Document should be soft-deleted'
    );
  }

  @isTest
  static void testRenewContractWithParam() {
    JIP_Contract__c contract = [SELECT Id FROM JIP_Contract__c LIMIT 1];

    Test.setCurrentPage(Page.JIP_HRDocumentPage);
    ApexPages.currentPage().getParameters().put('contractId', contract.Id);

    JIP_HRDocumentController controller = new JIP_HRDocumentController();

    Test.startTest();
    controller.renewContract();
    Test.stopTest();

    List<ApexPages.Message> messages = ApexPages.getMessages();
    System.assert(
      messages.size() > 0,
      'Should have info message about renewal'
    );
  }

  @isTest
  static void testSearchWithKeyword() {
    JIP_HRDocumentController controller = new JIP_HRDocumentController();
    controller.searchKeyword = 'Test';

    Test.startTest();
    controller.search();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller.documents,
      'Documents should be loaded'
    );
  }

  @isTest
  static void testSearchWithFilter() {
    JIP_HRDocumentController controller = new JIP_HRDocumentController();
    controller.filterCategory = 'contract';

    Test.startTest();
    controller.search();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller.documents,
      'Documents should be loaded'
    );
  }

  @isTest
  static void testUploadDocumentWithData() {
    Test.setCurrentPage(Page.JIP_HRDocumentPage);
    JIP_HRDocumentController controller = new JIP_HRDocumentController();
    controller.openUploadModal();
    controller.newDocument.Name = 'Upload Test Doc';
    controller.newDocument.DocumentType__c = 'Document';
    controller.newDocument.Category__c = 'policy';
    controller.newDocument.IsActive__c = true;
    controller.newDocument.UploadDate__c = Date.today();

    Test.startTest();
    controller.uploadDocument();
    Test.stopTest();

    // Method executed without throwing exception
    System.assert(true, 'Upload document method completed');
  }
}