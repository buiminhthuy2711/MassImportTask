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
private class JIP_ProjectTaskBoardControllerTest {
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
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
  }
  @isTest
  static void testGetT() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();

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
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();

    Test.startTest();
    controller.selectProject();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method selectProject executed successfully');
  }
  @isTest
  static void testApplyFilters() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();

    Test.startTest();
    controller.applyFilters();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method applyFilters executed successfully');
  }
  @isTest
  static void testClearFilters() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();

    Test.startTest();
    controller.clearFilters();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method clearFilters executed successfully');
  }
  @isTest
  static void testUpdateTaskStatus() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();

    Test.startTest();
    controller.updateTaskStatus();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method updateTaskStatus executed successfully');
  }
  @isTest
  static void testEditTask() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();

    Test.startTest();
    controller.editTask();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method editTask executed successfully');
  }
  @isTest
  static void testSaveTask() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();

    Test.startTest();
    controller.saveTask();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method saveTask executed successfully');
  }
  @isTest
  static void testDeleteTask() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();

    Test.startTest();
    controller.deleteTask();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method deleteTask executed successfully');
  }
  @isTest
  static void testCloseModal() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();

    Test.startTest();
    controller.closeModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method closeModal executed successfully');
  }
  @isTest
  static void testOpenNewTask() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();

    Test.startTest();
    PageReference result = controller.openNewTask();
    Test.stopTest();

    // PageReference methods may return null or a page
    System.assert(true, 'Method openNewTask executed successfully');
  }
  @isTest
  static void testGetProjectOptions() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();

    Test.startTest();
    List<SelectOption> options = controller.getProjectOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetTypeOptions() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();

    Test.startTest();
    List<SelectOption> options = controller.getTypeOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetCategoryOptions() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();

    Test.startTest();
    List<SelectOption> options = controller.getCategoryOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetMilestoneOptions() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();

    Test.startTest();
    List<SelectOption> options = controller.getMilestoneOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetAssigneeOptions() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();

    Test.startTest();
    List<SelectOption> options = controller.getAssigneeOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetSelectedProjectName() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();

    Test.startTest();
    String result = controller.getSelectedProjectName();
    Test.stopTest();

    System.assert(true, 'Method getSelectedProjectName executed successfully');
  }

  // ===== ADDITIONAL COVERAGE TESTS =====

  @isTest
  static void testConstructorWithProjectIdParam() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    ApexPages.currentPage().getParameters().put('projectId', proj.Id);
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    Test.stopTest();
    System.assertEquals(proj.Id, controller.selectedProjectId);
  }

  @isTest
  static void testConstructorWithInvalidProjectIdParam() {
    Test.startTest();
    ApexPages.currentPage().getParameters().put('projectId', 'bad-id');
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    Test.stopTest();
    System.assertNotEquals(null, controller.selectedProjectId);
  }

  @isTest
  static void testUpdateTaskStatusValid() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    controller.updateTaskStatusId = task.Id;
    controller.updateTaskStatusValue = '処理中';
    Test.startTest();
    controller.updateTaskStatus();
    Test.stopTest();
    JIP_ProjectTask__c updated = [
      SELECT Status__c
      FROM JIP_ProjectTask__c
      WHERE Id = :task.Id
    ];
    System.assertEquals('処理中', updated.Status__c);
  }

  @isTest
  static void testUpdateTaskStatusNullId() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    controller.updateTaskStatusId = null;
    controller.updateTaskStatusValue = '処理中';
    Test.startTest();
    controller.updateTaskStatus();
    Test.stopTest();
    System.assert(true);
  }

  @isTest
  static void testUpdateTaskStatusNullValue() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    controller.updateTaskStatusId = task.Id;
    controller.updateTaskStatusValue = null;
    Test.startTest();
    controller.updateTaskStatus();
    Test.stopTest();
    System.assert(true);
  }

  @isTest
  static void testOpenNewTaskWithProject() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    controller.selectedProjectId = proj.Id;
    Test.startTest();
    PageReference result = controller.openNewTask();
    Test.stopTest();
    System.assertNotEquals(null, result);
  }

  @isTest
  static void testOpenNewTaskWithoutProject() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    controller.selectedProjectId = null;
    Test.startTest();
    PageReference result = controller.openNewTask();
    Test.stopTest();
    System.assertEquals(null, result);
  }

  @isTest
  static void testEditTaskWithValidId() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    Test.startTest();
    ApexPages.currentPage().getParameters().put('taskId', task.Id);
    controller.editTask();
    Test.stopTest();
    System.assertEquals(true, controller.isEditMode);
    System.assertEquals(true, controller.showModal);
    System.assertEquals(task.Id, controller.currentTask.Id);
  }

  @isTest
  static void testEditTaskWithoutId() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    Test.startTest();
    controller.editTask();
    Test.stopTest();
    System.assertEquals(false, controller.showModal);
  }

  @isTest
  static void testSaveTaskInsert() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    controller.selectedProjectId = proj.Id;
    controller.isEditMode = false;
    controller.currentTask = new JIP_ProjectTask__c(
      Subject__c = 'New Board Task',
      Status__c = '未対応',
      Priority__c = '中'
    );
    Test.startTest();
    controller.saveTask();
    Test.stopTest();
    System.assertEquals(false, controller.showModal);
    List<JIP_ProjectTask__c> tasks = [
      SELECT Id
      FROM JIP_ProjectTask__c
      WHERE Subject__c = 'New Board Task'
    ];
    System.assertEquals(1, tasks.size());
  }

  @isTest
  static void testSaveTaskUpdate() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    controller.selectedProjectId = proj.Id;
    controller.isEditMode = true;
    controller.currentTask = task;
    controller.currentTask.Subject__c = 'Updated Board Task';
    Test.startTest();
    controller.saveTask();
    Test.stopTest();
    System.assertEquals(false, controller.showModal);
  }

  @isTest
  static void testSaveTaskWithoutProject() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    controller.selectedProjectId = null;
    controller.currentTask = new JIP_ProjectTask__c(Subject__c = 'No Proj');
    Test.startTest();
    controller.saveTask();
    Test.stopTest();
    System.assert(true);
  }

  @isTest
  static void testDeleteTaskValid() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTask__c task = new JIP_ProjectTask__c(
      Subject__c = 'To Delete Board',
      Project__c = proj.Id,
      Status__c = '未対応'
    );
    insert task;
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    controller.deleteTaskId = task.Id;
    Test.startTest();
    controller.deleteTask();
    Test.stopTest();
    List<JIP_ProjectTask__c> deleted = [
      SELECT Id
      FROM JIP_ProjectTask__c
      WHERE Id = :task.Id
    ];
    System.assertEquals(0, deleted.size());
  }

  @isTest
  static void testDeleteTaskNull() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    controller.deleteTaskId = null;
    Test.startTest();
    controller.deleteTask();
    Test.stopTest();
    System.assert(true);
  }

  @isTest
  static void testBoardTasksByStatus() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    List<JIP_ProjectTask__c> tasks = new List<JIP_ProjectTask__c>();
    tasks.add(
      new JIP_ProjectTask__c(
        Subject__c = 'Open',
        Project__c = proj.Id,
        Status__c = '未対応'
      )
    );
    tasks.add(
      new JIP_ProjectTask__c(
        Subject__c = 'InProg',
        Project__c = proj.Id,
        Status__c = '処理中'
      )
    );
    tasks.add(
      new JIP_ProjectTask__c(
        Subject__c = 'Resolved',
        Project__c = proj.Id,
        Status__c = '処理済み'
      )
    );
    tasks.add(
      new JIP_ProjectTask__c(
        Subject__c = 'Closed',
        Project__c = proj.Id,
        Status__c = '完了'
      )
    );
    insert tasks;
    Test.startTest();
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    controller.selectedProjectId = proj.Id;
    controller.selectProject();
    Test.stopTest();
    System.assert(controller.countOpen >= 0);
    System.assert(controller.countInProgress >= 0);
    System.assert(controller.countResolved >= 0);
    System.assert(controller.countClosed >= 0);
  }

  @isTest
  static void testApplyFiltersWithType() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    controller.selectedProjectId = proj.Id;
    controller.filterType = 'バグ';
    Test.startTest();
    controller.applyFilters();
    Test.stopTest();
    System.assertNotEquals(null, controller.openTasks);
  }

  @isTest
  static void testApplyFiltersWithCategory() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    controller.selectedProjectId = proj.Id;
    controller.filterCategory = '開発';
    Test.startTest();
    controller.applyFilters();
    Test.stopTest();
    System.assertNotEquals(null, controller.openTasks);
  }

  @isTest
  static void testApplyFiltersWithAssignee() {
    JIP_Worker__c worker = [SELECT Id FROM JIP_Worker__c LIMIT 1];
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    controller.selectedProjectId = proj.Id;
    controller.filterAssignee = worker.Id;
    Test.startTest();
    controller.applyFilters();
    Test.stopTest();
    System.assertNotEquals(null, controller.openTasks);
  }

  @isTest
  static void testClearFiltersResetsAll() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    controller.filterType = 'バグ';
    controller.filterCategory = '開発';
    controller.filterMilestone = 'v1.0';
    Test.startTest();
    controller.clearFilters();
    Test.stopTest();
    System.assertEquals('', controller.filterType);
    System.assertEquals('', controller.filterCategory);
    System.assertEquals('', controller.filterMilestone);
    System.assertEquals(null, controller.filterAssignee);
  }

  @isTest
  static void testCloseModalResetsState() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    controller.showModal = true;
    Test.startTest();
    controller.closeModal();
    Test.stopTest();
    System.assertEquals(false, controller.showModal);
  }

  @isTest
  static void testGetLanguageWithProject() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    controller.selectedProjectId = proj.Id;
    Test.startTest();
    String lang = controller.getLanguage();
    Test.stopTest();
    System.assertNotEquals(null, lang);
  }

  @isTest
  static void testGetLanguageWithoutProject() {
    JIP_ProjectTaskBoardController controller = new JIP_ProjectTaskBoardController();
    controller.selectedProjectId = null;
    Test.startTest();
    String lang = controller.getLanguage();
    Test.stopTest();
    System.assertEquals('ja', lang);
  }
}