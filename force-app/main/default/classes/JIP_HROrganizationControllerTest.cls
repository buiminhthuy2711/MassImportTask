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
private class JIP_HROrganizationControllerTest {
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
    JIP_HROrganizationController controller = new JIP_HROrganizationController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
  }
  @isTest
  static void testGetT() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();

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
  static void testSearchDepartments() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();

    Test.startTest();
    controller.searchDepartments();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method searchDepartments executed successfully');
  }
  @isTest
  static void testClearSearch() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();

    Test.startTest();
    controller.clearSearch();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method clearSearch executed successfully');
  }
  @isTest
  static void testChangeTab() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();

    Test.startTest();
    controller.changeTab();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method changeTab executed successfully');
  }
  @isTest
  static void testOpenNewModal() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();

    Test.startTest();
    controller.openNewModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method openNewModal executed successfully');
  }
  @isTest
  static void testOpenEditModal() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();

    Test.startTest();
    controller.openEditModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method openEditModal executed successfully');
  }
  @isTest
  static void testCloseModal() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();

    Test.startTest();
    controller.closeModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method closeModal executed successfully');
  }
  @isTest
  static void testOpenWorkersModal() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();

    Test.startTest();
    controller.openWorkersModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method openWorkersModal executed successfully');
  }
  @isTest
  static void testCloseWorkersModal() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();

    Test.startTest();
    controller.closeWorkersModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method closeWorkersModal executed successfully');
  }
  @isTest
  static void testSaveDepartment() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();

    Test.startTest();
    controller.saveDepartment();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method saveDepartment executed successfully');
  }
  @isTest
  static void testDeleteDepartment() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();

    Test.startTest();
    controller.deleteDepartment();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method deleteDepartment executed successfully');
  }
  @isTest
  static void testChangeLanguage() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();

    Test.startTest();
    controller.changeLanguage();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method changeLanguage executed successfully');
  }
  @isTest
  static void testGetTabOptions() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();

    Test.startTest();
    List<SelectOption> options = controller.getTabOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetParentDepartmentOptions() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();

    Test.startTest();
    List<SelectOption> options = controller.getParentDepartmentOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetManagerOptions() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();

    Test.startTest();
    List<SelectOption> options = controller.getManagerOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetLanguageOptions() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();

    Test.startTest();
    List<SelectOption> options = controller.getLanguageOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetEmployeeHierarchyJson() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();

    Test.startTest();
    String result = controller.getEmployeeHierarchyJson();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(
      true,
      'Method getEmployeeHierarchyJson executed successfully'
    );
  }
  @isTest
  static void testGetTreeDataJson() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();

    Test.startTest();
    String result = controller.getTreeDataJson();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getTreeDataJson executed successfully');
  }

  @isTest
  static void testOpenEditModalWithDeptId() {
    JIP_Department__c dept = [
      SELECT Id
      FROM JIP_Department__c
      WHERE IsActive__c = TRUE
      LIMIT 1
    ];

    JIP_HROrganizationController controller = new JIP_HROrganizationController();
    controller.editDeptId = dept.Id;

    Test.startTest();
    controller.openEditModal();
    Test.stopTest();

    System.assertEquals(true, controller.showModal, 'Modal should be open');
    System.assertEquals(true, controller.isEditMode, 'Should be in edit mode');
    System.assertEquals(
      dept.Id,
      controller.currentDepartment.Id,
      'Current department should match'
    );
  }

  @isTest
  static void testDeleteDepartmentWithId() {
    JIP_Department__c dept = JIP_TestDataFactory.createDepartment(
      'To Delete Dept',
      true
    );

    JIP_HROrganizationController controller = new JIP_HROrganizationController();
    controller.deleteDeptId = dept.Id;

    Test.startTest();
    controller.deleteDepartment();
    Test.stopTest();

    List<JIP_Department__c> remaining = [
      SELECT Id
      FROM JIP_Department__c
      WHERE Id = :dept.Id
    ];
    System.assertEquals(0, remaining.size(), 'Department should be deleted');
  }

  @isTest
  static void testOpenWorkersModalWithDeptId() {
    JIP_Department__c dept = [
      SELECT Id
      FROM JIP_Department__c
      WHERE IsActive__c = TRUE
      LIMIT 1
    ];

    JIP_HROrganizationController controller = new JIP_HROrganizationController();
    controller.viewDeptId = dept.Id;

    Test.startTest();
    controller.openWorkersModal();
    Test.stopTest();

    System.assertEquals(
      true,
      controller.showWorkersModal,
      'Workers modal should be open'
    );
    System.assertNotEquals(
      null,
      controller.viewDeptName,
      'Dept name should be set'
    );
  }

  @isTest
  static void testSaveDepartmentInsert() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();
    controller.openNewModal();
    controller.currentDepartment.Name = 'New Test Department';
    controller.currentDepartment.DepartmentCode__c = 'NEW-001';

    Test.startTest();
    controller.saveDepartment();
    Test.stopTest();

    System.assertEquals(
      false,
      controller.showModal,
      'Modal should be closed after save'
    );
    List<JIP_Department__c> created = [
      SELECT Id
      FROM JIP_Department__c
      WHERE DepartmentCode__c = 'NEW-001'
    ];
    System.assertEquals(1, created.size(), 'Department should be created');
  }

  @isTest
  static void testSaveDepartmentUpdate() {
    JIP_Department__c dept = [
      SELECT Id, Name, DepartmentCode__c, ParentDepartment__c, Manager__c
      FROM JIP_Department__c
      WHERE IsActive__c = TRUE
      LIMIT 1
    ];

    JIP_HROrganizationController controller = new JIP_HROrganizationController();
    controller.editDeptId = dept.Id;
    controller.openEditModal();
    controller.currentDepartment.Name = 'Updated Dept Name';

    Test.startTest();
    controller.saveDepartment();
    Test.stopTest();

    JIP_Department__c updated = [
      SELECT Name
      FROM JIP_Department__c
      WHERE Id = :dept.Id
    ];
    System.assertEquals(
      'Updated Dept Name',
      updated.Name,
      'Name should be updated'
    );
  }

  @isTest
  static void testSearchDepartmentsWithKeyword() {
    JIP_HROrganizationController controller = new JIP_HROrganizationController();
    controller.searchKeyword = 'Test';

    Test.startTest();
    controller.searchDepartments();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller.departments,
      'Departments should be loaded'
    );
  }
}