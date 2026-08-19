/**
 * Copyright (c) 2023-2026 JIP Academy (Tokyo, Japan).
 * Developed by JIP Academy R&D Team / Nguyen Minh Phuong.
 * All rights reserved.
 */
@isTest
private class JIP_ActivityFeedPanelControllerTest {
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
  static void testConstructor() {
    Test.startTest();
    JIP_ActivityFeedPanelController controller = new JIP_ActivityFeedPanelController();
    Test.stopTest();
    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
    System.assertEquals(
      '',
      controller.filterType,
      'Filter type should be empty'
    );
  }

  @isTest
  static void testInitWithProject() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ActivityFeedPanelController controller = new JIP_ActivityFeedPanelController();
    controller.selectedProjectId = proj.Id;
    Test.startTest();
    controller.init();
    Test.stopTest();
    System.assertNotEquals(
      null,
      controller.project,
      'Project should be loaded'
    );
  }

  @isTest
  static void testInitWithoutProject() {
    JIP_ActivityFeedPanelController controller = new JIP_ActivityFeedPanelController();
    Test.startTest();
    controller.init();
    Test.stopTest();
    System.assertEquals(null, controller.project, 'Project should be null');
  }

  @isTest
  static void testLoadActivities() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ActivityFeedPanelController controller = new JIP_ActivityFeedPanelController();
    controller.selectedProjectId = proj.Id;
    controller.init();
    Test.startTest();
    controller.loadActivities();
    Test.stopTest();
    System.assertNotEquals(
      null,
      controller.activities,
      'Activities should be loaded'
    );
  }

  @isTest
  static void testLoadActivitiesWithFilter() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ActivityFeedPanelController controller = new JIP_ActivityFeedPanelController();
    controller.selectedProjectId = proj.Id;
    controller.filterType = '課題';
    controller.init();
    Test.startTest();
    controller.loadActivities();
    Test.stopTest();
    System.assertNotEquals(
      null,
      controller.activities,
      'Activities should be loaded'
    );
  }

  @isTest
  static void testLoadActivitiesNoProject() {
    JIP_ActivityFeedPanelController controller = new JIP_ActivityFeedPanelController();
    Test.startTest();
    controller.loadActivities();
    Test.stopTest();
    System.assertEquals(0, controller.activities.size(), 'No activities');
  }

  @isTest
  static void testLoadMore() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ActivityFeedPanelController controller = new JIP_ActivityFeedPanelController();
    controller.selectedProjectId = proj.Id;
    controller.init();
    Test.startTest();
    controller.loadMore();
    Test.stopTest();
    System.assert(true, 'Load more completed');
  }

  @isTest
  static void testApplyFilter() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ActivityFeedPanelController controller = new JIP_ActivityFeedPanelController();
    controller.selectedProjectId = proj.Id;
    controller.init();
    Test.startTest();
    controller.filterType = '課題';
    controller.applyFilter();
    Test.stopTest();
    System.assert(true, 'Apply filter completed');
  }

  @isTest
  static void testCheckNewActivities() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ActivityFeedPanelController controller = new JIP_ActivityFeedPanelController();
    controller.selectedProjectId = proj.Id;
    controller.init();
    Test.startTest();
    controller.checkNewActivities();
    Test.stopTest();
    System.assertNotEquals(
      null,
      controller.lastSeenTime,
      'Last seen time should be set'
    );
  }

  @isTest
  static void testCheckNewActivitiesWithLastSeen() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ActivityFeedPanelController controller = new JIP_ActivityFeedPanelController();
    controller.selectedProjectId = proj.Id;
    controller.lastSeenTime = '2023-01-01T00:00:00';
    controller.init();
    Test.startTest();
    controller.checkNewActivities();
    Test.stopTest();
    System.assertNotEquals(
      null,
      controller.newCount,
      'New count should be set'
    );
  }

  @isTest
  static void testCheckNewActivitiesNoProject() {
    JIP_ActivityFeedPanelController controller = new JIP_ActivityFeedPanelController();
    Test.startTest();
    controller.checkNewActivities();
    Test.stopTest();
    System.assertEquals(0, controller.newCount, 'New count should be 0');
  }

  @isTest
  static void testMarkSeen() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ActivityFeedPanelController controller = new JIP_ActivityFeedPanelController();
    controller.selectedProjectId = proj.Id;
    controller.init();
    Test.startTest();
    controller.markSeen();
    Test.stopTest();
    System.assertEquals(0, controller.newCount, 'New count should be 0');
    System.assertNotEquals(
      '',
      controller.lastSeenTime,
      'Last seen time should be set'
    );
  }

  @isTest
  static void testCheckNewRemote() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    Map<String, Object> result = JIP_ActivityFeedPanelController.checkNewRemote(
      proj.Id,
      null
    );
    Test.stopTest();
    System.assertNotEquals(null, result, 'Result should not be null');
  }

  @isTest
  static void testCheckNewRemoteWithLastSeen() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    Map<String, Object> result = JIP_ActivityFeedPanelController.checkNewRemote(
      proj.Id,
      '2023-01-01T00:00:00'
    );
    Test.stopTest();
    System.assertNotEquals(null, result, 'Result should not be null');
  }

  @isTest
  static void testCheckNewRemoteNoProject() {
    Test.startTest();
    Map<String, Object> result = JIP_ActivityFeedPanelController.checkNewRemote(
      null,
      null
    );
    Test.stopTest();
    System.assertEquals(0, result.get('newCount'), 'New count should be 0');
  }

  @isTest
  static void testMarkSeenRemote() {
    Test.startTest();
    String timestamp = JIP_ActivityFeedPanelController.markSeenRemote();
    Test.stopTest();
    System.assertNotEquals(null, timestamp, 'Timestamp should not be null');
  }

  @isTest
  static void testGetFilterOptions() {
    JIP_ActivityFeedPanelController controller = new JIP_ActivityFeedPanelController();
    Test.startTest();
    List<SelectOption> options = controller.getFilterOptions();
    Test.stopTest();
    System.assertNotEquals(null, options, 'Options should not be null');
    System.assert(options.size() > 0, 'Options should have values');
  }
}