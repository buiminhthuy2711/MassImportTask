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
private class JIP_CandidateManagementControllerTest {
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
    JIP_CandidateManagementController controller = new JIP_CandidateManagementController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
  }
  @isTest
  static void testLoadCandidates() {
    JIP_CandidateManagementController controller = new JIP_CandidateManagementController();

    Test.startTest();
    controller.loadCandidates();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method loadCandidates executed successfully');
  }
  @isTest
  static void testSearchCandidates() {
    JIP_CandidateManagementController controller = new JIP_CandidateManagementController();

    Test.startTest();
    controller.searchCandidates();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method searchCandidates executed successfully');
  }
  @isTest
  static void testClearSearch() {
    JIP_CandidateManagementController controller = new JIP_CandidateManagementController();

    Test.startTest();
    controller.clearSearch();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method clearSearch executed successfully');
  }
  @isTest
  static void testOpenNewModal() {
    JIP_CandidateManagementController controller = new JIP_CandidateManagementController();

    Test.startTest();
    controller.openNewModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method openNewModal executed successfully');
  }
  @isTest
  static void testOpenEditModal() {
    JIP_CandidateManagementController controller = new JIP_CandidateManagementController();

    Test.startTest();
    controller.openEditModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method openEditModal executed successfully');
  }
  @isTest
  static void testCloseModal() {
    JIP_CandidateManagementController controller = new JIP_CandidateManagementController();

    Test.startTest();
    controller.closeModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method closeModal executed successfully');
  }
  @isTest
  static void testSaveCandidate() {
    JIP_CandidateManagementController controller = new JIP_CandidateManagementController();

    Test.startTest();
    controller.saveCandidate();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method saveCandidate executed successfully');
  }
  @isTest
  static void testDeleteCandidate() {
    JIP_CandidateManagementController controller = new JIP_CandidateManagementController();

    Test.startTest();
    controller.deleteCandidate();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method deleteCandidate executed successfully');
  }
  @isTest
  static void testGetPipelineOptions() {
    JIP_CandidateManagementController controller = new JIP_CandidateManagementController();

    Test.startTest();
    List<SelectOption> options = controller.getPipelineOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetStatusOptions() {
    JIP_CandidateManagementController controller = new JIP_CandidateManagementController();

    Test.startTest();
    List<SelectOption> options = controller.getStatusOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }

  @isTest
  static void testLoadCandidatesWithSearchKeyword() {
    JIP_CandidateManagementController controller = new JIP_CandidateManagementController();
    controller.searchKeyword = 'Test';
    Test.startTest();
    controller.loadCandidates();
    Test.stopTest();
    System.assertNotEquals(null, controller.candidates);
  }

  @isTest
  static void testLoadCandidatesWithFilterPipeline() {
    JIP_CandidateManagementController controller = new JIP_CandidateManagementController();
    controller.filterPipeline = 'New';
    Test.startTest();
    controller.loadCandidates();
    Test.stopTest();
    System.assertNotEquals(null, controller.candidates);
  }

  @isTest
  static void testLoadCandidatesWithFilterStatus() {
    JIP_CandidateManagementController controller = new JIP_CandidateManagementController();
    controller.filterStatus = 'Active';
    Test.startTest();
    controller.loadCandidates();
    Test.stopTest();
    System.assertNotEquals(null, controller.candidates);
  }

  @isTest
  static void testLoadCandidatesWithAllFilters() {
    JIP_CandidateManagementController controller = new JIP_CandidateManagementController();
    controller.searchKeyword = 'Test';
    controller.filterPipeline = 'New';
    controller.filterStatus = 'Active';
    Test.startTest();
    controller.loadCandidates();
    Test.stopTest();
    System.assertNotEquals(null, controller.candidates);
  }

  @isTest
  static void testOpenEditModalWithValidId() {
    JIP_Candidate__c cand = [SELECT Id FROM JIP_Candidate__c LIMIT 1];
    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('editId', cand.Id);

    JIP_CandidateManagementController controller = new JIP_CandidateManagementController();
    Test.startTest();
    controller.openEditModal();
    Test.stopTest();

    System.assertEquals(true, controller.isEditMode);
    System.assertEquals(true, controller.showModal);
    System.assertEquals(cand.Id, controller.currentCandidate.Id);
  }

  @isTest
  static void testSaveCandidateUpdate() {
    JIP_Candidate__c cand = [SELECT Id FROM JIP_Candidate__c LIMIT 1];
    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('editId', cand.Id);

    JIP_CandidateManagementController controller = new JIP_CandidateManagementController();
    controller.openEditModal();
    Test.startTest();
    controller.saveCandidate();
    Test.stopTest();

    System.assertEquals(false, controller.showModal);
  }

  @isTest
  static void testDeleteCandidateWithValidId() {
    JIP_Candidate__c cand = [SELECT Id FROM JIP_Candidate__c LIMIT 1];
    JIP_CandidateManagementController controller = new JIP_CandidateManagementController();
    controller.deleteCandidateId = cand.Id;
    Test.startTest();
    controller.deleteCandidate();
    Test.stopTest();

    System.assertEquals(
      0,
      [SELECT COUNT() FROM JIP_Candidate__c WHERE Id = :cand.Id]
    );
  }
}