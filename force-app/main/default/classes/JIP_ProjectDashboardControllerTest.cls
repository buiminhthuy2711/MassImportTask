/**
 * Copyright (c) 2023-2026 JIP Academy (Tokyo, Japan).
 * Developed by JIP Academy R&D Team / Nguyen Minh Phuong.
 * All rights reserved.
 */
@isTest
private class JIP_ProjectDashboardControllerTest {
  @testSetup
  static void setupTestData() {
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
    JIP_ProjectMember__c member = JIP_TestDataFactory.createProjectMember(
      proj.Id,
      worker.Id,
      true
    );
  }

  @isTest
  static void testGetProgressRate() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    Map<String, Integer> result = JIP_ProjectDashboardController.getProgressRate(
      proj.Id
    );
    Test.stopTest();
    System.assertNotEquals(null, result, 'Progress rate should not be null');
  }

  @isTest
  static void testGetTaskStatusDistribution() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    List<JIP_ProjectDashboardController.StatusCount> result = JIP_ProjectDashboardController.getTaskStatusDistribution(
      proj.Id
    );
    Test.stopTest();
    System.assertNotEquals(
      null,
      result,
      'Status distribution should not be null'
    );
  }

  @isTest
  static void testGetGanttData() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    List<JIP_ProjectDashboardController.GanttTask> result = JIP_ProjectDashboardController.getGanttData(
      proj.Id
    );
    Test.stopTest();
    System.assertNotEquals(null, result, 'Gantt data should not be null');
  }

  @isTest
  static void testGetBurndownData() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    JIP_ProjectDashboardController.BurndownData result = JIP_ProjectDashboardController.getBurndownData(
      proj.Id
    );
    Test.stopTest();
    System.assertNotEquals(null, result, 'Burndown data should not be null');
  }

  @isTest
  static void testGetVelocityData() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    List<JIP_ProjectDashboardController.SprintVelocity> result = JIP_ProjectDashboardController.getVelocityData(
      proj.Id
    );
    Test.stopTest();
    System.assertNotEquals(null, result, 'Velocity data should not be null');
  }

  @isTest
  static void testGetCompletionTrend() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    List<JIP_ProjectDashboardController.DateCount> result = JIP_ProjectDashboardController.getCompletionTrend(
      proj.Id
    );
    Test.stopTest();
    System.assertNotEquals(null, result, 'Completion trend should not be null');
  }

  @isTest
  static void testGetBugTrend() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    List<JIP_ProjectDashboardController.DateCount> result = JIP_ProjectDashboardController.getBugTrend(
      proj.Id
    );
    Test.stopTest();
    System.assertNotEquals(null, result, 'Bug trend should not be null');
  }

  @isTest
  static void testGetBugFixTrend() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    List<JIP_ProjectDashboardController.DateCount> result = JIP_ProjectDashboardController.getBugFixTrend(
      proj.Id
    );
    Test.stopTest();
    System.assertNotEquals(null, result, 'Bug fix trend should not be null');
  }

  @isTest
  static void testGetBugStatusDistribution() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    List<JIP_ProjectDashboardController.StatusCount> result = JIP_ProjectDashboardController.getBugStatusDistribution(
      proj.Id
    );
    Test.stopTest();
    System.assertNotEquals(
      null,
      result,
      'Bug status distribution should not be null'
    );
  }

  @isTest
  static void testGetOverdueTasks() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    List<JIP_ProjectDashboardController.OverdueInfo> result = JIP_ProjectDashboardController.getOverdueTasks(
      proj.Id
    );
    Test.stopTest();
    System.assertNotEquals(null, result, 'Overdue tasks should not be null');
  }

  @isTest
  static void testGetOverdueCount() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    Integer result = JIP_ProjectDashboardController.getOverdueCount(proj.Id);
    Test.stopTest();
    System.assertNotEquals(null, result, 'Overdue count should not be null');
  }

  @isTest
  static void testGetCriticalPathData() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    List<JIP_ProjectDashboardController.GanttTask> result = JIP_ProjectDashboardController.getCriticalPathData(
      proj.Id
    );
    Test.stopTest();
    System.assertNotEquals(
      null,
      result,
      'Critical path data should not be null'
    );
  }

  @isTest
  static void testGetMemberTaskLoad() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    List<JIP_ProjectDashboardController.MemberLoad> result = JIP_ProjectDashboardController.getMemberTaskLoad(
      proj.Id
    );
    Test.stopTest();
    System.assertNotEquals(null, result, 'Member task load should not be null');
  }

  @isTest
  static void testGetUtilizationData() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    List<JIP_ProjectDashboardController.UtilizationInfo> result = JIP_ProjectDashboardController.getUtilizationData(
      proj.Id
    );
    Test.stopTest();
    System.assertNotEquals(null, result, 'Utilization data should not be null');
  }

  @isTest
  static void testGetBudgetVsActual() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    JIP_ProjectDashboardController.BudgetInfo result = JIP_ProjectDashboardController.getBudgetVsActual(
      proj.Id
    );
    Test.stopTest();
    System.assertNotEquals(null, result, 'Budget info should not be null');
  }

  @isTest
  static void testGetSCurveData() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    JIP_ProjectDashboardController.SCurveData result = JIP_ProjectDashboardController.getSCurveData(
      proj.Id
    );
    Test.stopTest();
    System.assertNotEquals(null, result, 'SCurve data should not be null');
  }

  @isTest
  static void testGetProjectList() {
    Test.startTest();
    List<JIP_ProjectDashboardController.ProjectOption> result = JIP_ProjectDashboardController.getProjectList();
    Test.stopTest();
    System.assertNotEquals(null, result, 'Project list should not be null');
  }

  @isTest
  static void testDashboardWithAssignedCompletedTasks() {
    JIP_Department__c dept = JIP_TestDataFactory.createDepartment(
      'Dash Dept',
      true
    );
    JIP_Worker__c worker = new JIP_Worker__c(
      Name = 'Dashboard Worker',
      Email__c = 'dash.worker@test.com',
      Department__c = dept.Id,
      LastName__c = 'Tanaka',
      FirstName__c = 'Taro'
    );
    insert worker;

    JIP_Project__c proj = new JIP_Project__c(
      Name = 'Dash Project',
      Name__c = 'Dash Project',
      Status__c = 'Active',
      StartDate__c = Date.today().addDays(-30),
      EndDate__c = Date.today().addDays(30),
      Budget__c = 1000000,
      ActualCost__c = 500000
    );
    insert proj;

    // Completed task with sprint+storypoints+hours+assignee
    JIP_ProjectTask__c completedTask = new JIP_ProjectTask__c(
      Subject__c = 'Completed Task',
      Project__c = proj.Id,
      Status__c = '完了',
      Priority__c = '中',
      StartDate__c = Date.today().addDays(-10),
      DueDate__c = Date.today().addDays(-5),
      CompletedDate__c = Date.today().addDays(-3),
      Assignee__c = worker.Id,
      Sprint__c = 'Sprint 1',
      StoryPoints__c = 5,
      EstimatedHours__c = 10,
      ActualHours__c = 8
    );
    insert completedTask;

    // Overdue in-progress task (high priority) - covers overdue, critical path, memberLoad '処理中'
    JIP_ProjectTask__c overdueTask = new JIP_ProjectTask__c(
      Subject__c = 'Overdue Task',
      Project__c = proj.Id,
      Status__c = '処理中',
      Priority__c = '高',
      StartDate__c = Date.today().addDays(-20),
      DueDate__c = Date.today().addDays(-1),
      Assignee__c = worker.Id,
      EstimatedHours__c = 5,
      ActualHours__c = 7
    );
    insert overdueTask;

    // Not started task - covers memberLoad '未対応'
    JIP_ProjectTask__c notStartedTask = new JIP_ProjectTask__c(
      Subject__c = 'Not Started Task',
      Project__c = proj.Id,
      Status__c = '未対応',
      Priority__c = '低',
      StartDate__c = Date.today(),
      DueDate__c = Date.today().addDays(7),
      Assignee__c = worker.Id,
      EstimatedHours__c = 3,
      ActualHours__c = 0
    );
    insert notStartedTask;

    // Resolved task - covers memberLoad '処理済み'
    JIP_ProjectTask__c resolvedTask = new JIP_ProjectTask__c(
      Subject__c = 'Resolved Task',
      Project__c = proj.Id,
      Status__c = '処理済み',
      Priority__c = '中',
      StartDate__c = Date.today().addDays(-5),
      DueDate__c = Date.today().addDays(2),
      Assignee__c = worker.Id,
      EstimatedHours__c = 4,
      ActualHours__c = 3
    );
    insert resolvedTask;

    Test.startTest();

    Map<String, Integer> progress = JIP_ProjectDashboardController.getProgressRate(
      proj.Id
    );
    System.assert(progress.get('total') >= 4);

    List<JIP_ProjectDashboardController.StatusCount> statusDist = JIP_ProjectDashboardController.getTaskStatusDistribution(
      proj.Id
    );
    System.assert(statusDist.size() >= 3);

    List<JIP_ProjectDashboardController.GanttTask> gantt = JIP_ProjectDashboardController.getGanttData(
      proj.Id
    );
    System.assert(!gantt.isEmpty());

    JIP_ProjectDashboardController.BurndownData burndown = JIP_ProjectDashboardController.getBurndownData(
      proj.Id
    );
    System.assert(!burndown.completedByDate.isEmpty());

    List<JIP_ProjectDashboardController.SprintVelocity> velocity = JIP_ProjectDashboardController.getVelocityData(
      proj.Id
    );
    System.assert(!velocity.isEmpty());

    List<JIP_ProjectDashboardController.DateCount> completionTrend = JIP_ProjectDashboardController.getCompletionTrend(
      proj.Id
    );
    System.assert(!completionTrend.isEmpty());

    Integer overdueCount = JIP_ProjectDashboardController.getOverdueCount(
      proj.Id
    );
    System.assert(overdueCount > 0);

    List<JIP_ProjectDashboardController.OverdueInfo> overdue = JIP_ProjectDashboardController.getOverdueTasks(
      proj.Id
    );
    System.assert(!overdue.isEmpty());

    List<JIP_ProjectDashboardController.GanttTask> critPath = JIP_ProjectDashboardController.getCriticalPathData(
      proj.Id
    );
    System.assert(!critPath.isEmpty());

    List<JIP_ProjectDashboardController.MemberLoad> memberLoad = JIP_ProjectDashboardController.getMemberTaskLoad(
      proj.Id
    );
    System.assert(!memberLoad.isEmpty());

    List<JIP_ProjectDashboardController.UtilizationInfo> utilization = JIP_ProjectDashboardController.getUtilizationData(
      proj.Id
    );
    System.assert(!utilization.isEmpty());

    JIP_ProjectDashboardController.BudgetInfo budget = JIP_ProjectDashboardController.getBudgetVsActual(
      proj.Id
    );
    System.assertNotEquals(null, budget);

    JIP_ProjectDashboardController.SCurveData sCurve = JIP_ProjectDashboardController.getSCurveData(
      proj.Id
    );
    System.assert(!sCurve.plannedByDate.isEmpty());

    Test.stopTest();
  }

  @isTest
  static void testDashboardWithBugTasks() {
    JIP_Department__c dept = JIP_TestDataFactory.createDepartment(
      'Bug Dept',
      true
    );
    JIP_Worker__c worker = new JIP_Worker__c(
      Name = 'Bug Worker',
      Email__c = 'bug.worker@test.com',
      Department__c = dept.Id,
      LastName__c = 'Suzuki',
      FirstName__c = 'Hanako'
    );
    insert worker;

    JIP_Project__c proj = new JIP_Project__c(
      Name = 'Bug Project',
      Name__c = 'Bug Project',
      Status__c = 'Active',
      StartDate__c = Date.today().addDays(-30),
      EndDate__c = Date.today().addDays(30)
    );
    insert proj;

    JIP_ProjectTask__c openBug = new JIP_ProjectTask__c(
      Subject__c = 'Open Bug',
      Project__c = proj.Id,
      Status__c = '処理中',
      Priority__c = '高',
      TaskType__c = 'バグ',
      StartDate__c = Date.today().addDays(-10),
      DueDate__c = Date.today().addDays(-1),
      Assignee__c = worker.Id
    );
    insert openBug;

    JIP_ProjectTask__c fixedBug = new JIP_ProjectTask__c(
      Subject__c = 'Fixed Bug',
      Project__c = proj.Id,
      Status__c = '完了',
      Priority__c = '中',
      TaskType__c = 'バグ',
      StartDate__c = Date.today().addDays(-15),
      DueDate__c = Date.today().addDays(-10),
      CompletedDate__c = Date.today().addDays(-8),
      Assignee__c = worker.Id,
      Sprint__c = 'Sprint 2',
      StoryPoints__c = 3
    );
    insert fixedBug;

    Test.startTest();
    List<JIP_ProjectDashboardController.DateCount> bugTrend = JIP_ProjectDashboardController.getBugTrend(
      proj.Id
    );
    System.assert(!bugTrend.isEmpty());

    List<JIP_ProjectDashboardController.DateCount> bugFixTrend = JIP_ProjectDashboardController.getBugFixTrend(
      proj.Id
    );
    System.assert(!bugFixTrend.isEmpty());

    List<JIP_ProjectDashboardController.StatusCount> bugStatus = JIP_ProjectDashboardController.getBugStatusDistribution(
      proj.Id
    );
    System.assert(!bugStatus.isEmpty());
    Test.stopTest();
  }

  @isTest
  static void testGetOverdueTasksWithUnassigned() {
    JIP_Project__c proj = new JIP_Project__c(
      Name = 'Overdue Proj',
      Name__c = 'Overdue Proj',
      Status__c = 'Active',
      StartDate__c = Date.today().addDays(-30),
      EndDate__c = Date.today().addDays(30)
    );
    insert proj;

    JIP_ProjectTask__c unassignedOverdue = new JIP_ProjectTask__c(
      Subject__c = 'Unassigned Overdue',
      Project__c = proj.Id,
      Status__c = '未対応',
      Priority__c = '高',
      StartDate__c = Date.today().addDays(-20),
      DueDate__c = Date.today().addDays(-5)
    );
    insert unassignedOverdue;

    Test.startTest();
    List<JIP_ProjectDashboardController.OverdueInfo> overdue = JIP_ProjectDashboardController.getOverdueTasks(
      proj.Id
    );
    Test.stopTest();
    System.assertNotEquals(null, overdue);
  }
}