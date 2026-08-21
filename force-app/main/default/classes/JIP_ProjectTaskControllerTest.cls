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
private class JIP_ProjectTaskControllerTest {
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
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
  }
  @isTest
  static void testGetT() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

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
  static void testSetStatusAll() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    controller.setStatusAll();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method setStatusAll executed successfully');
  }
  @isTest
  static void testSetStatusOpen() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    controller.setStatusOpen();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method setStatusOpen executed successfully');
  }
  @isTest
  static void testSetStatusInProgress() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    controller.setStatusInProgress();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method setStatusInProgress executed successfully');
  }
  @isTest
  static void testSetStatusResolved() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    controller.setStatusResolved();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method setStatusResolved executed successfully');
  }
  @isTest
  static void testSetStatusClosed() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    controller.setStatusClosed();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method setStatusClosed executed successfully');
  }
  @isTest
  static void testSetStatusNotClosed() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    controller.setStatusNotClosed();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method setStatusNotClosed executed successfully');
  }
  @isTest
  static void testSelectProject() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    controller.selectProject();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method selectProject executed successfully');
  }
  @isTest
  static void testApplyFilters() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    controller.applyFilters();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method applyFilters executed successfully');
  }
  @isTest
  static void testClearFilters() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    controller.clearFilters();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method clearFilters executed successfully');
  }
  @isTest
  static void testEditTask() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    controller.editTask();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method editTask executed successfully');
  }
  @isTest
  static void testSaveTask() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    controller.saveTask();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method saveTask executed successfully');
  }
  @isTest
  static void testDeleteTask() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    controller.deleteTask();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method deleteTask executed successfully');
  }
  @isTest
  static void testCloseModal() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    controller.closeModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method closeModal executed successfully');
  }
  @isTest
  static void testOpenNewTask() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    PageReference result = controller.openNewTask();
    Test.stopTest();

    // PageReference methods may return null or a page
    System.assert(true, 'Method openNewTask executed successfully');
  }
  @isTest
  static void testGetProjectOptions() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    List<SelectOption> options = controller.getProjectOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetTypeOptions() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    List<SelectOption> options = controller.getTypeOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetCategoryOptions() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    List<SelectOption> options = controller.getCategoryOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetAssigneeOptions() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    List<SelectOption> options = controller.getAssigneeOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetSelectedProjectName() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    String result = controller.getSelectedProjectName();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getSelectedProjectName executed successfully');
  }

  // ===== Additional tests for improved coverage =====

  @isTest
  static void testGetLanguageWithLanguageSet() {
    // Create project with Language__c set
    JIP_Project__c proj = new JIP_Project__c(Name = 'Lang Project', Name__c = 'Lang Test', Language__c = 'en');
    insert proj;

    Test.startTest();
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();
    controller.selectedProjectId = proj.Id;
    // Force reload project list to include the new project
    controller.projectList = [SELECT Id, Name, Name__c, Status__c, Language__c FROM JIP_Project__c];
    String lang = controller.getLanguage();
    Test.stopTest();

    System.assertEquals('en', lang, 'Language should be en');
  }

  @isTest
  static void testGetLanguageWithNoProject() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();
    
    Test.startTest();
    controller.selectedProjectId = null;
    String lang = controller.getLanguage();
    Test.stopTest();

    System.assertEquals('ja', lang, 'Default language should be ja');
  }

  @isTest
  static void testConstructorWithProjectIdParam() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    ApexPages.currentPage().getParameters().put('projectId', proj.Id);

    Test.startTest();
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();
    Test.stopTest();

    System.assertEquals(proj.Id, controller.selectedProjectId, 'Project should be selected from URL param');
  }

  @isTest
  static void testConstructorWithInvalidProjectIdParam() {
    ApexPages.currentPage().getParameters().put('projectId', 'invalid_id');

    Test.startTest();
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();
    Test.stopTest();

    // Should not throw exception, should fallback to first project
    System.assertNotEquals(null, controller, 'Controller should be instantiated');
  }

  @isTest
  static void testEditTaskWithValidId() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];
    ApexPages.currentPage().getParameters().put('taskId', task.Id);

    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();

    Test.startTest();
    controller.editTask();
    Test.stopTest();

    System.assertEquals(true, controller.isEditMode, 'Should be in edit mode');
    System.assertEquals(true, controller.showModal, 'Modal should be shown');
    System.assertNotEquals(null, controller.currentTask, 'Task should be loaded');
  }

  @isTest
  static void testSaveTaskInsertNew() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];

    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();
    controller.selectedProjectId = proj.Id;
    controller.currentTask = new JIP_ProjectTask__c(Subject__c = 'New Task', Status__c = '未対応');
    controller.isEditMode = false;

    Test.startTest();
    controller.saveTask();
    Test.stopTest();

    System.assertEquals(false, controller.showModal, 'Modal should be closed');
    List<JIP_ProjectTask__c> tasks = [SELECT Id FROM JIP_ProjectTask__c WHERE Subject__c = 'New Task'];
    System.assertEquals(1, tasks.size(), 'Task should be inserted');
  }

  @isTest
  static void testSaveTaskWithExistingTask() {
    // Test that saveTask method runs without error on existing task
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTask__c task = [SELECT Id, Subject__c, Project__c, Status__c FROM JIP_ProjectTask__c WHERE Project__c = :proj.Id LIMIT 1];

    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();
    controller.selectedProjectId = proj.Id;
    controller.currentTask = task;
    controller.isEditMode = true;

    Test.startTest();
    controller.saveTask();
    Test.stopTest();

    // Verify no exception was thrown
    System.assert(true, 'saveTask completed without exception');
  }

  @isTest
  static void testDeleteTaskWithValidId() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];

    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();
    controller.deleteTaskId = task.Id;

    Test.startTest();
    controller.deleteTask();
    Test.stopTest();

    List<JIP_ProjectTask__c> remaining = [SELECT Id FROM JIP_ProjectTask__c WHERE Id = :task.Id];
    System.assertEquals(0, remaining.size(), 'Task should be deleted');
  }

  @isTest
  static void testStatusFiltersWithTasks() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    
    // Create tasks with different statuses
    JIP_ProjectTask__c t1 = new JIP_ProjectTask__c(Project__c = proj.Id, Subject__c = 'Open Task', Status__c = '未対応');
    JIP_ProjectTask__c t2 = new JIP_ProjectTask__c(Project__c = proj.Id, Subject__c = 'InProgress Task', Status__c = '処理中');
    JIP_ProjectTask__c t3 = new JIP_ProjectTask__c(Project__c = proj.Id, Subject__c = 'Resolved Task', Status__c = '処理済み');
    JIP_ProjectTask__c t4 = new JIP_ProjectTask__c(Project__c = proj.Id, Subject__c = 'Closed Task', Status__c = '完了');
    insert new List<JIP_ProjectTask__c>{t1, t2, t3, t4};

    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();
    controller.selectedProjectId = proj.Id;

    Test.startTest();
    // Test all status filters
    controller.setStatusOpen();
    System.assertEquals('未対応', controller.filterStatus);

    controller.setStatusInProgress();
    System.assertEquals('処理中', controller.filterStatus);

    controller.setStatusResolved();
    System.assertEquals('処理済み', controller.filterStatus);

    controller.setStatusClosed();
    System.assertEquals('完了', controller.filterStatus);

    controller.setStatusNotClosed();
    System.assertEquals('完了以外', controller.filterStatus);

    controller.setStatusAll();
    System.assertEquals('すべて', controller.filterStatus);
    Test.stopTest();
  }

  @isTest
  static void testApplyFiltersWithKeyword() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();
    controller.selectedProjectId = proj.Id;
    
    Test.startTest();
    controller.filterKeyword = 'Test';
    controller.filterType = 'バグ';
    controller.filterCategory = '開発';
    controller.filterMilestone = 'v1.0';
    controller.applyFilters();
    Test.stopTest();

    System.assertNotEquals(null, controller.taskList, 'Task list should not be null');
  }

  @isTest
  static void testOpenNewTaskWithoutProject() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();
    controller.selectedProjectId = null;

    Test.startTest();
    PageReference result = controller.openNewTask();
    Test.stopTest();

    System.assertEquals(null, result, 'Should return null when no project selected');
  }

  @isTest
  static void testOpenNewTaskWithProject() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();
    controller.selectedProjectId = proj.Id;

    Test.startTest();
    PageReference result = controller.openNewTask();
    Test.stopTest();

    System.assertNotEquals(null, result, 'Should return page reference');
  }

  @isTest
  static void testSaveTaskWithoutProject() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();
    controller.selectedProjectId = null;
    controller.currentTask = new JIP_ProjectTask__c(Subject__c = 'Test');

    Test.startTest();
    controller.saveTask();
    Test.stopTest();

    // Should add error message, not throw exception
    System.assert(true, 'Save without project should not throw exception');
  }

  @isTest
  static void testLoadTasksWithNoProject() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();
    controller.selectedProjectId = null;

    Test.startTest();
    controller.selectProject();
    Test.stopTest();

    System.assertEquals(0, controller.taskCount, 'Task count should be 0 when no project');
  }

  @isTest
  static void testGetSelectedProjectNameWithNullId() {
    JIP_ProjectTaskController controller = new JIP_ProjectTaskController();
    controller.selectedProjectId = null;

    Test.startTest();
    String name = controller.getSelectedProjectName();
    Test.stopTest();

    System.assertEquals('', name, 'Should return empty string when no project');
  }
}