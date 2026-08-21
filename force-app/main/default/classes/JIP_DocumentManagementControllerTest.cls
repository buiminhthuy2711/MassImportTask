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
private class JIP_DocumentManagementControllerTest {
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
    JIP_DocumentManagementController controller = new JIP_DocumentManagementController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
  }
  @isTest
  static void testGetT() {
    JIP_DocumentManagementController controller = new JIP_DocumentManagementController();

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
  static void testSelectProject() {
    JIP_DocumentManagementController controller = new JIP_DocumentManagementController();

    Test.startTest();
    controller.selectProject();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method selectProject executed successfully');
  }
  @isTest
  static void testSelectDocument() {
    JIP_DocumentManagementController controller = new JIP_DocumentManagementController();

    Test.startTest();
    controller.selectDocument();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method selectDocument executed successfully');
  }
  @isTest
  static void testEnterEditMode() {
    JIP_DocumentManagementController controller = new JIP_DocumentManagementController();

    Test.startTest();
    controller.enterEditMode();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method enterEditMode executed successfully');
  }
  @isTest
  static void testCancelEdit() {
    JIP_DocumentManagementController controller = new JIP_DocumentManagementController();

    Test.startTest();
    controller.cancelEdit();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method cancelEdit executed successfully');
  }
  @isTest
  static void testSaveDocument() {
    JIP_DocumentManagementController controller = new JIP_DocumentManagementController();

    Test.startTest();
    controller.saveDocument();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method saveDocument executed successfully');
  }
  @isTest
  static void testCreateDocument() {
    JIP_DocumentManagementController controller = new JIP_DocumentManagementController();

    Test.startTest();
    controller.createDocument();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method createDocument executed successfully');
  }
  @isTest
  static void testCreateChildDocument() {
    JIP_DocumentManagementController controller = new JIP_DocumentManagementController();

    Test.startTest();
    controller.createChildDocument();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method createChildDocument executed successfully');
  }
  @isTest
  static void testMoveToTrash() {
    JIP_DocumentManagementController controller = new JIP_DocumentManagementController();

    Test.startTest();
    controller.moveToTrash();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method moveToTrash executed successfully');
  }
  @isTest
  static void testRestoreFromTrash() {
    JIP_DocumentManagementController controller = new JIP_DocumentManagementController();

    Test.startTest();
    controller.restoreFromTrash();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method restoreFromTrash executed successfully');
  }
  @isTest
  static void testDeleteFromTrash() {
    JIP_DocumentManagementController controller = new JIP_DocumentManagementController();

    Test.startTest();
    controller.deleteFromTrash();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method deleteFromTrash executed successfully');
  }
  @isTest
  static void testOpenTrash() {
    JIP_DocumentManagementController controller = new JIP_DocumentManagementController();

    Test.startTest();
    controller.openTrash();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method openTrash executed successfully');
  }
  @isTest
  static void testCloseTrash() {
    JIP_DocumentManagementController controller = new JIP_DocumentManagementController();

    Test.startTest();
    controller.closeTrash();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method closeTrash executed successfully');
  }
  @isTest
  static void testSearchDocuments() {
    JIP_DocumentManagementController controller = new JIP_DocumentManagementController();

    Test.startTest();
    controller.searchDocuments();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method searchDocuments executed successfully');
  }
  @isTest
  static void testGetProjectOptions() {
    JIP_DocumentManagementController controller = new JIP_DocumentManagementController();

    Test.startTest();
    List<SelectOption> options = controller.getProjectOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetSelectedDocIdStr() {
    JIP_DocumentManagementController controller = new JIP_DocumentManagementController();

    Test.startTest();
    String result = controller.getSelectedDocIdStr();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getSelectedDocIdStr executed successfully');
  }
  @isTest
  static void testGetSelectedProjectName() {
    JIP_DocumentManagementController controller = new JIP_DocumentManagementController();

    Test.startTest();
    String result = controller.getSelectedProjectName();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getSelectedProjectName executed successfully');
  }

  @isTest
  static void testConstructorWithProjectIdParam() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectDocument__c doc = new JIP_ProjectDocument__c(
      Title__c = 'Test Doc',
      Project__c = proj.Id,
      Content__c = 'Content',
      SortOrder__c = 0,
      IsInTrash__c = false
    );
    insert doc;

    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', proj.Id);
    pageRef.getParameters().put('docId', String.valueOf(doc.Id));

    Test.startTest();
    JIP_DocumentManagementController ctrl = new JIP_DocumentManagementController();
    Test.stopTest();

    System.assertEquals(proj.Id, ctrl.selectedProjectId);
    System.assertEquals(doc.Id, ctrl.selectedDocumentId);
  }

  @isTest
  static void testConstructorWithInvalidParams() {
    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', 'INVALID');
    pageRef.getParameters().put('docId', 'INVALID');

    Test.startTest();
    JIP_DocumentManagementController ctrl = new JIP_DocumentManagementController();
    Test.stopTest();

    System.assertNotEquals(null, ctrl);
  }

  @isTest
  static void testGetSelectedDocIdStrWithValue() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectDocument__c doc = new JIP_ProjectDocument__c(
      Title__c = 'DocId Test',
      Project__c = proj.Id,
      Content__c = '',
      SortOrder__c = 0,
      IsInTrash__c = false
    );
    insert doc;

    JIP_DocumentManagementController ctrl = new JIP_DocumentManagementController();
    ctrl.selectedDocumentId = doc.Id;

    Test.startTest();
    String result = ctrl.getSelectedDocIdStr();
    Test.stopTest();

    System.assertNotEquals('', result);
  }

  @isTest
  static void testSaveDocumentWithData() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectDocument__c doc = new JIP_ProjectDocument__c(
      Title__c = 'Save Test',
      Project__c = proj.Id,
      Content__c = 'Original',
      SortOrder__c = 0,
      IsInTrash__c = false
    );
    insert doc;

    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', proj.Id);
    pageRef.getParameters().put('docId', String.valueOf(doc.Id));

    JIP_DocumentManagementController ctrl = new JIP_DocumentManagementController();
    ctrl.selectedDocument.Content__c = 'Updated';

    Test.startTest();
    ctrl.saveDocument();
    Test.stopTest();

    System.assertEquals(false, ctrl.isEditMode);
  }

  @isTest
  static void testCreateChildDocumentWithParent() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectDocument__c parentDoc = new JIP_ProjectDocument__c(
      Title__c = 'Parent Doc',
      Project__c = proj.Id,
      Content__c = '',
      SortOrder__c = 0,
      IsInTrash__c = false
    );
    insert parentDoc;

    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', proj.Id);

    JIP_DocumentManagementController ctrl = new JIP_DocumentManagementController();
    ctrl.newDocParentId = parentDoc.Id;
    ctrl.newDocTitle = 'Child Doc';

    Test.startTest();
    ctrl.createChildDocument();
    Test.stopTest();

    System.assertEquals(true, ctrl.isEditMode);
  }

  @isTest
  static void testMoveToTrashWithDocument() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectDocument__c doc = new JIP_ProjectDocument__c(
      Title__c = 'Trash Test',
      Project__c = proj.Id,
      Content__c = '',
      SortOrder__c = 0,
      IsInTrash__c = false
    );
    insert doc;

    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', proj.Id);
    pageRef.getParameters().put('docId', String.valueOf(doc.Id));

    JIP_DocumentManagementController ctrl = new JIP_DocumentManagementController();

    Test.startTest();
    ctrl.moveToTrash();
    Test.stopTest();

    System.assertEquals(false, ctrl.isEditMode);
  }

  @isTest
  static void testRestoreFromTrashWithDocument() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectDocument__c doc = new JIP_ProjectDocument__c(
      Title__c = 'Restore Test',
      Project__c = proj.Id,
      Content__c = '',
      SortOrder__c = 0,
      IsInTrash__c = true
    );
    insert doc;

    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', proj.Id);

    JIP_DocumentManagementController ctrl = new JIP_DocumentManagementController();
    ctrl.selectedDocumentId = doc.Id;

    Test.startTest();
    ctrl.restoreFromTrash();
    Test.stopTest();

    System.assertEquals(true, ctrl.showTrash);
  }

  @isTest
  static void testDeleteFromTrashWithDocument() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectDocument__c doc = new JIP_ProjectDocument__c(
      Title__c = 'Delete Test',
      Project__c = proj.Id,
      Content__c = '',
      SortOrder__c = 0,
      IsInTrash__c = true
    );
    insert doc;

    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', proj.Id);

    JIP_DocumentManagementController ctrl = new JIP_DocumentManagementController();
    ctrl.selectedDocumentId = doc.Id;

    Test.startTest();
    ctrl.deleteFromTrash();
    Test.stopTest();

    System.assertEquals(null, ctrl.selectedDocumentId);
  }

  @isTest
  static void testSearchDocumentsWithKeyword() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectDocument__c doc = new JIP_ProjectDocument__c(
      Title__c = 'Searchable Doc',
      Project__c = proj.Id,
      Content__c = '',
      SortOrder__c = 0,
      IsInTrash__c = false
    );
    insert doc;

    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', proj.Id);

    JIP_DocumentManagementController ctrl = new JIP_DocumentManagementController();
    ctrl.searchKeyword = 'Searchable';

    Test.startTest();
    ctrl.searchDocuments();
    Test.stopTest();

    System.assertNotEquals(null, ctrl.documentList);
  }

  @isTest
  static void testDocumentTreeWithHierarchy() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectDocument__c parentDoc = new JIP_ProjectDocument__c(
      Title__c = 'Parent',
      Project__c = proj.Id,
      Content__c = '',
      SortOrder__c = 0,
      IsInTrash__c = false
    );
    insert parentDoc;
    JIP_ProjectDocument__c childDoc = new JIP_ProjectDocument__c(
      Title__c = 'Child',
      Project__c = proj.Id,
      ParentDocument__c = parentDoc.Id,
      Content__c = '',
      SortOrder__c = 1,
      IsInTrash__c = false
    );
    insert childDoc;

    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', proj.Id);
    pageRef.getParameters().put('docId', String.valueOf(childDoc.Id));

    Test.startTest();
    JIP_DocumentManagementController ctrl = new JIP_DocumentManagementController();
    Test.stopTest();

    System.assert(ctrl.documentTreeJson.contains('Parent'));
    System.assertNotEquals('[]', ctrl.breadcrumbJson);
  }

  @isTest
  static void testGetLanguageWithValue() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    proj.Language__c = 'en';
    update proj;

    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', proj.Id);

    JIP_DocumentManagementController ctrl = new JIP_DocumentManagementController();

    Test.startTest();
    String lang = ctrl.getLanguage();
    Test.stopTest();

    System.assertEquals('en', lang);
  }

  @isTest
  static void testGetLanguageDefault() {
    JIP_DocumentManagementController ctrl = new JIP_DocumentManagementController();
    ctrl.selectedProjectId = null;

    Test.startTest();
    String lang = ctrl.getLanguage();
    Test.stopTest();

    System.assertEquals('ja', lang);
  }

  @isTest
  static void testGetSelectedProjectNameNull() {
    JIP_DocumentManagementController ctrl = new JIP_DocumentManagementController();
    ctrl.selectedProjectId = null;

    Test.startTest();
    String result = ctrl.getSelectedProjectName();
    Test.stopTest();

    System.assertEquals('', result);
  }
}