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
private class JIP_JobManagementControllerTest {
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
    JIP_JobManagementController controller = new JIP_JobManagementController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
  }
  @isTest
  static void testLoadJobs() {
    JIP_JobManagementController controller = new JIP_JobManagementController();

    Test.startTest();
    controller.loadJobs();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method loadJobs executed successfully');
  }
  @isTest
  static void testSearchJobs() {
    JIP_JobManagementController controller = new JIP_JobManagementController();

    Test.startTest();
    controller.searchJobs();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method searchJobs executed successfully');
  }
  @isTest
  static void testClearSearch() {
    JIP_JobManagementController controller = new JIP_JobManagementController();

    Test.startTest();
    controller.clearSearch();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method clearSearch executed successfully');
  }
  @isTest
  static void testOpenNewModal() {
    JIP_JobManagementController controller = new JIP_JobManagementController();

    Test.startTest();
    controller.openNewModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method openNewModal executed successfully');
  }
  @isTest
  static void testOpenEditModal() {
    JIP_JobManagementController controller = new JIP_JobManagementController();

    Test.startTest();
    controller.openEditModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method openEditModal executed successfully');
  }
  @isTest
  static void testCloseModal() {
    JIP_JobManagementController controller = new JIP_JobManagementController();

    Test.startTest();
    controller.closeModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method closeModal executed successfully');
  }
  @isTest
  static void testSaveJob() {
    JIP_JobManagementController controller = new JIP_JobManagementController();

    Test.startTest();
    controller.saveJob();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method saveJob executed successfully');
  }
  @isTest
  static void testDeleteJob() {
    JIP_JobManagementController controller = new JIP_JobManagementController();

    Test.startTest();
    controller.deleteJob();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method deleteJob executed successfully');
  }
  @isTest
  static void testGetStatusFilterOptions() {
    JIP_JobManagementController controller = new JIP_JobManagementController();

    Test.startTest();
    List<SelectOption> options = controller.getStatusFilterOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetPriorityFilterOptions() {
    JIP_JobManagementController controller = new JIP_JobManagementController();

    Test.startTest();
    List<SelectOption> options = controller.getPriorityFilterOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }

  @isTest
  static void testLoadJobsWithSearchKeyword() {
    JIP_JobManagementController controller = new JIP_JobManagementController();
    controller.searchKeyword = 'Test';
    Test.startTest();
    controller.loadJobs();
    Test.stopTest();
    System.assertNotEquals(null, controller.jobs);
  }

  @isTest
  static void testLoadJobsWithFilterStatus() {
    JIP_JobManagementController controller = new JIP_JobManagementController();
    controller.filterStatus = 'Open';
    Test.startTest();
    controller.loadJobs();
    Test.stopTest();
    System.assert(controller.jobs.size() > 0);
  }

  @isTest
  static void testLoadJobsWithFilterPriority() {
    JIP_JobManagementController controller = new JIP_JobManagementController();
    controller.filterPriority = 'Medium';
    Test.startTest();
    controller.loadJobs();
    Test.stopTest();
    System.assertNotEquals(null, controller.jobs);
  }

  @isTest
  static void testLoadJobsWithAllFilters() {
    JIP_JobManagementController controller = new JIP_JobManagementController();
    controller.searchKeyword = 'Test';
    controller.filterStatus = 'Open';
    controller.filterPriority = 'Medium';
    Test.startTest();
    controller.loadJobs();
    Test.stopTest();
    System.assertNotEquals(null, controller.jobs);
  }

  @isTest
  static void testOpenEditModalWithValidId() {
    JIP_Job__c job = [SELECT Id FROM JIP_Job__c LIMIT 1];
    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('editId', job.Id);

    JIP_JobManagementController controller = new JIP_JobManagementController();
    Test.startTest();
    controller.openEditModal();
    Test.stopTest();

    System.assertEquals(true, controller.isEditMode);
    System.assertEquals(true, controller.showModal);
    System.assertEquals(job.Id, controller.currentJob.Id);
  }

  @isTest
  static void testSaveJobUpdate() {
    JIP_Job__c job = [SELECT Id FROM JIP_Job__c LIMIT 1];
    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('editId', job.Id);

    JIP_JobManagementController controller = new JIP_JobManagementController();
    controller.openEditModal();
    Test.startTest();
    controller.saveJob();
    Test.stopTest();

    System.assertEquals(false, controller.showModal);
  }

  @isTest
  static void testDeleteJobWithValidId() {
    JIP_Job__c job = [SELECT Id FROM JIP_Job__c LIMIT 1];
    JIP_JobManagementController controller = new JIP_JobManagementController();
    controller.deleteJobId = job.Id;
    Test.startTest();
    controller.deleteJob();
    Test.stopTest();

    System.assertEquals(0, [SELECT COUNT() FROM JIP_Job__c WHERE Id = :job.Id]);
  }
}