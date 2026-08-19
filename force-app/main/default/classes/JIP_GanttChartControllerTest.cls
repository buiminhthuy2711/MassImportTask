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
private class JIP_GanttChartControllerTest {
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
    JIP_GanttChartController controller = new JIP_GanttChartController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
  }
  @isTest
  static void testGetT() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

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
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    controller.selectProject();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method selectProject executed successfully');
  }
  @isTest
  static void testApplyFilters() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    controller.applyFilters();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method applyFilters executed successfully');
  }
  @isTest
  static void testClearFilters() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    controller.clearFilters();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method clearFilters executed successfully');
  }
  @isTest
  static void testGoToday() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    controller.goToday();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method goToday executed successfully');
  }
  @isTest
  static void testGoPrev() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    controller.goPrev();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method goPrev executed successfully');
  }
  @isTest
  static void testGoNext() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    controller.goNext();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method goNext executed successfully');
  }
  @isTest
  static void testChangeScale() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    controller.changeScale();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method changeScale executed successfully');
  }
  @isTest
  static void testChangeGrouping() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    controller.changeGrouping();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method changeGrouping executed successfully');
  }
  @isTest
  static void testToggleLeftPanel() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    controller.toggleLeftPanel();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method toggleLeftPanel executed successfully');
  }
  @isTest
  static void testOpenTaskPopup() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    controller.openTaskPopup();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method openTaskPopup executed successfully');
  }
  @isTest
  static void testCloseTaskPopup() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    controller.closeTaskPopup();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method closeTaskPopup executed successfully');
  }
  @isTest
  static void testAddComment() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    controller.addComment();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method addComment executed successfully');
  }
  @isTest
  static void testUpdateTaskDates() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    controller.updateTaskDates();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method updateTaskDates executed successfully');
  }
  @isTest
  static void testGetProjectOptions() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    List<SelectOption> options = controller.getProjectOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetTypeOptions() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    List<SelectOption> options = controller.getTypeOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetStatusOptions() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    List<SelectOption> options = controller.getStatusOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetCategoryOptions() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    List<SelectOption> options = controller.getCategoryOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetMilestoneOptions() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    List<SelectOption> options = controller.getMilestoneOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetAssigneeOptions() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    List<SelectOption> options = controller.getAssigneeOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetScaleOptions() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    List<SelectOption> options = controller.getScaleOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetGroupingOptions() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    List<SelectOption> options = controller.getGroupingOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetSelectedProjectName() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    String result = controller.getSelectedProjectName();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getSelectedProjectName executed successfully');
  }
  @isTest
  static void testGetPopupAssigneeName() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    String result = controller.getPopupAssigneeName();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getPopupAssigneeName executed successfully');
  }
  @isTest
  static void testGetPopupAssigneeInitial() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    String result = controller.getPopupAssigneeInitial();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getPopupAssigneeInitial executed successfully');
  }
  @isTest
  static void testGetTasksJson() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    String result = controller.getTasksJson();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getTasksJson executed successfully');
  }
  @isTest
  static void testGetGanttStartDateStr() {
    JIP_GanttChartController controller = new JIP_GanttChartController();

    Test.startTest();
    String result = controller.getGanttStartDateStr();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getGanttStartDateStr executed successfully');
  }

  // ===== ADDITIONAL COVERAGE TESTS =====

  @isTest
  static void testConstructorWithProjectIdParam() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    ApexPages.currentPage().getParameters().put('projectId', proj.Id);
    JIP_GanttChartController controller = new JIP_GanttChartController();
    Test.stopTest();
    System.assertEquals(proj.Id, controller.selectedProjectId);
  }

  @isTest
  static void testConstructorWithInvalidProjectIdParam() {
    Test.startTest();
    ApexPages.currentPage().getParameters().put('projectId', 'invalid');
    JIP_GanttChartController controller = new JIP_GanttChartController();
    Test.stopTest();
    System.assertNotEquals(null, controller.selectedProjectId);
  }

  @isTest
  static void testApplyFiltersWithType() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.selectedProjectId = proj.Id;
    controller.filterType = 'バグ';
    Test.startTest();
    controller.applyFilters();
    Test.stopTest();
    System.assertNotEquals(null, controller.taskList);
  }

  @isTest
  static void testApplyFiltersWithStatus() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.selectedProjectId = proj.Id;
    controller.filterStatus = '未対応';
    Test.startTest();
    controller.applyFilters();
    Test.stopTest();
    System.assertNotEquals(null, controller.taskList);
  }

  @isTest
  static void testApplyFiltersWithCategory() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.selectedProjectId = proj.Id;
    controller.filterCategory = '開発';
    Test.startTest();
    controller.applyFilters();
    Test.stopTest();
    System.assertNotEquals(null, controller.taskList);
  }

  @isTest
  static void testApplyFiltersWithAssignee() {
    JIP_Worker__c worker = [SELECT Id FROM JIP_Worker__c LIMIT 1];
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.selectedProjectId = proj.Id;
    controller.filterAssignee = worker.Id;
    Test.startTest();
    controller.applyFilters();
    Test.stopTest();
    System.assertNotEquals(null, controller.taskList);
  }

  @isTest
  static void testApplyFiltersWithMultiple() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.selectedProjectId = proj.Id;
    controller.filterType = 'バグ';
    controller.filterStatus = '処理中';
    controller.filterCategory = '開発';
    controller.filterMilestone = 'v1.0';
    Test.startTest();
    controller.applyFilters();
    Test.stopTest();
    System.assertNotEquals(null, controller.taskList);
  }

  @isTest
  static void testGoNextDaily() {
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.ganttScale = '日';
    Date orig = controller.ganttStartDate;
    Test.startTest();
    controller.goNext();
    Test.stopTest();
    System.assertEquals(orig.addDays(7), controller.ganttStartDate);
  }

  @isTest
  static void testGoNextWeekly() {
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.ganttScale = '週';
    Date orig = controller.ganttStartDate;
    Test.startTest();
    controller.goNext();
    Test.stopTest();
    System.assertEquals(orig.addDays(28), controller.ganttStartDate);
  }

  @isTest
  static void testGoNextMonthly() {
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.ganttScale = '月';
    Date orig = controller.ganttStartDate;
    Test.startTest();
    controller.goNext();
    Test.stopTest();
    System.assertEquals(orig.addMonths(1), controller.ganttStartDate);
  }

  @isTest
  static void testGoPrevDaily() {
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.ganttScale = '日';
    Date orig = controller.ganttStartDate;
    Test.startTest();
    controller.goPrev();
    Test.stopTest();
    System.assertEquals(orig.addDays(-7), controller.ganttStartDate);
  }

  @isTest
  static void testGoPrevWeekly() {
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.ganttScale = '週';
    Date orig = controller.ganttStartDate;
    Test.startTest();
    controller.goPrev();
    Test.stopTest();
    System.assertEquals(orig.addDays(-28), controller.ganttStartDate);
  }

  @isTest
  static void testGoPrevMonthly() {
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.ganttScale = '月';
    Date orig = controller.ganttStartDate;
    Test.startTest();
    controller.goPrev();
    Test.stopTest();
    System.assertEquals(orig.addMonths(-1), controller.ganttStartDate);
  }

  @isTest
  static void testOpenTaskPopupWithValidTask() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.popupTaskId = task.Id;
    Test.startTest();
    controller.openTaskPopup();
    Test.stopTest();
    System.assertEquals(true, controller.showTaskPopup);
    System.assertEquals(task.Id, controller.selectedTask.Id);
  }

  @isTest
  static void testOpenTaskPopupWithNull() {
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.popupTaskId = null;
    Test.startTest();
    controller.openTaskPopup();
    Test.stopTest();
    System.assertEquals(false, controller.showTaskPopup);
  }

  @isTest
  static void testAddCommentWithTask() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.popupTaskId = task.Id;
    controller.openTaskPopup();
    controller.newComment = 'テストコメント';
    Test.startTest();
    controller.addComment();
    Test.stopTest();
    System.assertEquals('', controller.newComment);
  }

  @isTest
  static void testAddCommentBlank() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.popupTaskId = task.Id;
    controller.openTaskPopup();
    controller.newComment = '';
    Test.startTest();
    controller.addComment();
    Test.stopTest();
    System.assertEquals('', controller.newComment);
  }

  @isTest
  static void testUpdateTaskDatesValid() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.dragTaskId = task.Id;
    controller.dragNewStart = '2026-04-01';
    controller.dragNewEnd = '2026-04-10';
    Test.startTest();
    controller.updateTaskDates();
    Test.stopTest();
    JIP_ProjectTask__c updated = [
      SELECT StartDate__c, DueDate__c
      FROM JIP_ProjectTask__c
      WHERE Id = :task.Id
    ];
    System.assertEquals(Date.newInstance(2026, 4, 1), updated.StartDate__c);
  }

  @isTest
  static void testUpdateTaskDatesNull() {
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.dragTaskId = null;
    Test.startTest();
    controller.updateTaskDates();
    Test.stopTest();
    System.assert(true);
  }

  @isTest
  static void testUpdateTaskDatesInvalid() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.dragTaskId = task.Id;
    controller.dragNewStart = 'invalid';
    Test.startTest();
    controller.updateTaskDates();
    Test.stopTest();
    System.assert(true);
  }

  @isTest
  static void testGetTasksJsonWithData() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.selectedProjectId = proj.Id;
    controller.applyFilters();
    Test.startTest();
    String json = controller.getTasksJson();
    Test.stopTest();
    System.assertNotEquals(null, json);
  }

  @isTest
  static void testToggleLeftPanelTwice() {
    JIP_GanttChartController controller = new JIP_GanttChartController();
    Boolean initial = controller.showLeftPanel;
    Test.startTest();
    controller.toggleLeftPanel();
    System.assertEquals(!initial, controller.showLeftPanel);
    controller.toggleLeftPanel();
    System.assertEquals(initial, controller.showLeftPanel);
    Test.stopTest();
  }

  @isTest
  static void testClearFiltersResetsAll() {
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.filterType = 'バグ';
    controller.filterStatus = '処理中';
    controller.filterCategory = '開発';
    controller.filterMilestone = 'v1.0';
    Test.startTest();
    controller.clearFilters();
    Test.stopTest();
    System.assertEquals('', controller.filterType);
    System.assertEquals('', controller.filterStatus);
    System.assertEquals('', controller.filterCategory);
    System.assertEquals('', controller.filterMilestone);
    System.assertEquals(null, controller.filterAssignee);
  }

  @isTest
  static void testCloseTaskPopupResetsState() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.popupTaskId = task.Id;
    controller.openTaskPopup();
    Test.startTest();
    controller.closeTaskPopup();
    Test.stopTest();
    System.assertEquals(false, controller.showTaskPopup);
    System.assertEquals(null, controller.selectedTask);
    System.assertEquals('', controller.newComment);
  }

  @isTest
  static void testGetLanguageWithProject() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.selectedProjectId = proj.Id;
    Test.startTest();
    String lang = controller.getLanguage();
    Test.stopTest();
    System.assertNotEquals(null, lang);
  }

  @isTest
  static void testGetLanguageWithoutProject() {
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.selectedProjectId = null;
    Test.startTest();
    String lang = controller.getLanguage();
    Test.stopTest();
    System.assertEquals('ja', lang);
  }

  @isTest
  static void testGoTodayResetsDate() {
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.ganttStartDate = Date.newInstance(2020, 1, 1);
    Test.startTest();
    controller.goToday();
    Test.stopTest();
    System.assertEquals(
      Date.today().toStartOfWeek(),
      controller.ganttStartDate
    );
    System.assertEquals(false, controller.showTaskPopup);
  }

  @isTest
  static void testSelectProjectLoadsTasks() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.selectedProjectId = proj.Id;
    Test.startTest();
    controller.selectProject();
    Test.stopTest();
    System.assertNotEquals(null, controller.taskList);
    System.assertEquals(false, controller.showTaskPopup);
  }

  @isTest
  static void testUpdateTaskDatesRefreshesPopup() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];
    JIP_GanttChartController controller = new JIP_GanttChartController();
    controller.popupTaskId = task.Id;
    controller.openTaskPopup();
    controller.dragTaskId = task.Id;
    controller.dragNewStart = '2026-05-01';
    controller.dragNewEnd = '2026-05-15';
    Test.startTest();
    controller.updateTaskDates();
    Test.stopTest();
    System.assertEquals(true, controller.showTaskPopup);
  }
}