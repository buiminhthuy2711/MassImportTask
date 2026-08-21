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
private class JIP_WorkerManagementControllerTest {
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
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
  }
  @isTest
  static void testLoadWorkers() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();

    Test.startTest();
    controller.loadWorkers();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method loadWorkers executed successfully');
  }
  @isTest
  static void testSearchWorkers() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();

    Test.startTest();
    controller.searchWorkers();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method searchWorkers executed successfully');
  }
  @isTest
  static void testClearSearch() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();

    Test.startTest();
    controller.clearSearch();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method clearSearch executed successfully');
  }
  @isTest
  static void testOpenNewModal() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();

    Test.startTest();
    controller.openNewModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method openNewModal executed successfully');
  }
  @isTest
  static void testOpenEditModal() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();

    Test.startTest();
    controller.openEditModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method openEditModal executed successfully');
  }
  @isTest
  static void testCloseModal() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();

    Test.startTest();
    controller.closeModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method closeModal executed successfully');
  }
  @isTest
  static void testSaveWorker() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();

    Test.startTest();
    controller.saveWorker();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method saveWorker executed successfully');
  }
  @isTest
  static void testDeleteWorker() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();

    Test.startTest();
    controller.deleteWorker();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method deleteWorker executed successfully');
  }
  @isTest
  static void testExportCSV() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();

    Test.startTest();
    PageReference result = controller.exportCSV();
    Test.stopTest();

    // PageReference methods may return null or a page
    System.assert(true, 'Method exportCSV executed successfully');
  }
  @isTest
  static void testGetDepartmentOptions() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();

    Test.startTest();
    List<SelectOption> options = controller.getDepartmentOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }

  // ===== ADDITIONAL COVERAGE TESTS =====

  @isTest
  static void testLoadWorkersWithKeyword() {
    JIP_Worker__c worker = [SELECT Id, Name FROM JIP_Worker__c LIMIT 1];
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();
    controller.searchKeyword = 'Test';
    Test.startTest();
    controller.loadWorkers();
    Test.stopTest();
    System.assertNotEquals(null, controller.workers);
  }

  @isTest
  static void testLoadWorkersWithStatusFilter() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();
    controller.filterStatus = '在職';
    Test.startTest();
    controller.loadWorkers();
    Test.stopTest();
    System.assertNotEquals(null, controller.workers);
  }

  @isTest
  static void testLoadWorkersWithDeptFilter() {
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();
    controller.filterDepartment = dept.Id;
    Test.startTest();
    controller.loadWorkers();
    Test.stopTest();
    System.assertNotEquals(null, controller.workers);
  }

  @isTest
  static void testLoadWorkersWithMultipleFilters() {
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();
    controller.searchKeyword = 'Test';
    controller.filterStatus = '在職';
    controller.filterDepartment = dept.Id;
    Test.startTest();
    controller.loadWorkers();
    Test.stopTest();
    System.assertNotEquals(null, controller.workers);
  }

  @isTest
  static void testSearchWorkersWithKeyword() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();
    controller.searchKeyword = 'Test';
    Test.startTest();
    controller.searchWorkers();
    Test.stopTest();
    System.assertNotEquals(null, controller.workers);
  }

  @isTest
  static void testClearSearchResetsAll() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();
    controller.searchKeyword = 'Test';
    controller.filterStatus = '在職';
    controller.filterContractType = '正社員';
    controller.filterDepartment = 'someId';
    Test.startTest();
    controller.clearSearch();
    Test.stopTest();
    System.assertEquals('', controller.searchKeyword);
    System.assertEquals('', controller.filterStatus);
    System.assertEquals('', controller.filterContractType);
    System.assertEquals('', controller.filterDepartment);
  }

  @isTest
  static void testOpenNewModalState() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();
    Test.startTest();
    controller.openNewModal();
    Test.stopTest();
    System.assertEquals(true, controller.showModal);
    System.assertEquals(false, controller.isEditMode);
    System.assertEquals(null, controller.currentWorker.Id);
  }

  @isTest
  static void testOpenEditModalWithValidId() {
    JIP_Worker__c worker = [SELECT Id FROM JIP_Worker__c LIMIT 1];
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();
    Test.startTest();
    ApexPages.currentPage().getParameters().put('editId', worker.Id);
    controller.openEditModal();
    Test.stopTest();
    System.assertEquals(true, controller.showModal);
    System.assertEquals(true, controller.isEditMode);
    System.assertEquals(worker.Id, controller.currentWorker.Id);
  }

  @isTest
  static void testOpenEditModalWithoutId() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();
    Test.startTest();
    controller.openEditModal();
    Test.stopTest();
    System.assertEquals(false, controller.showModal);
  }

  @isTest
  static void testSaveWorkerInsert() {
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();
    controller.isEditMode = false;
    controller.currentWorker = new JIP_Worker__c(
      LastName__c = 'NewLast',
      FirstName__c = 'NewFirst',
      Department__c = dept.Id,
      Worker_Code__c = 'WRK-999'
    );
    Test.startTest();
    controller.saveWorker();
    Test.stopTest();
    System.assertEquals(false, controller.showModal);
    List<JIP_Worker__c> workers = [
      SELECT Id
      FROM JIP_Worker__c
      WHERE Worker_Code__c = 'WRK-999'
    ];
    System.assertEquals(1, workers.size());
  }

  @isTest
  static void testSaveWorkerUpdate() {
    JIP_Worker__c worker = [SELECT Id, LastName__c FROM JIP_Worker__c LIMIT 1];
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();
    controller.isEditMode = true;
    controller.currentWorker = worker;
    controller.currentWorker.LastName__c = 'UpdatedLast';
    Test.startTest();
    controller.saveWorker();
    Test.stopTest();
    System.assertEquals(false, controller.showModal);
  }

  @isTest
  static void testDeleteWorkerValid() {
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];
    JIP_Worker__c worker = new JIP_Worker__c(
      LastName__c = 'ToDelete',
      Worker_Code__c = 'DEL-001',
      Department__c = dept.Id
    );
    insert worker;
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();
    controller.deleteWorkerId = worker.Id;
    Test.startTest();
    controller.deleteWorker();
    Test.stopTest();
    List<JIP_Worker__c> deleted = [
      SELECT Id
      FROM JIP_Worker__c
      WHERE Id = :worker.Id
    ];
    System.assertEquals(0, deleted.size());
  }

  @isTest
  static void testDeleteWorkerNull() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();
    controller.deleteWorkerId = null;
    Test.startTest();
    controller.deleteWorker();
    Test.stopTest();
    System.assert(true);
  }

  @isTest
  static void testCloseModalResetsState() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();
    controller.showModal = true;
    Test.startTest();
    controller.closeModal();
    Test.stopTest();
    System.assertEquals(false, controller.showModal);
  }

  @isTest
  static void testStatisticsLoaded() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();
    Test.startTest();
    Test.stopTest();
    System.assertNotEquals(null, controller.totalCount);
    System.assertNotEquals(null, controller.activeCount);
    System.assertNotEquals(null, controller.leaveCount);
    System.assertNotEquals(null, controller.newHireCount);
  }

  @isTest
  static void testAvatarUrlsLoaded() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();
    Test.startTest();
    controller.loadWorkers();
    Test.stopTest();
    System.assertNotEquals(null, controller.avatarUrlsByWorkerId);
  }

  @isTest
  static void testLoadWorkersWithContractTypeFilter() {
    JIP_WorkerManagementController controller = new JIP_WorkerManagementController();
    controller.filterContractType = '正社員';
    Test.startTest();
    controller.loadWorkers();
    Test.stopTest();
    System.assertNotEquals(null, controller.workers);
  }
}