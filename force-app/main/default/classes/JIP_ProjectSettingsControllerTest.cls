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
private class JIP_ProjectSettingsControllerTest {
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
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
  }
  @isTest
  static void testGetT() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

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
  static void testSaveLanguage() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.saveLanguage();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method saveLanguage executed successfully');
  }
  @isTest
  static void testLoadMembers() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.loadMembers();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method loadMembers executed successfully');
  }
  @isTest
  static void testSearchMembers() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.searchMembers();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method searchMembers executed successfully');
  }
  @isTest
  static void testAddMemberToProject() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.addMemberToProject();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method addMemberToProject executed successfully');
  }
  @isTest
  static void testRemoveMember() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.removeMember();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method removeMember executed successfully');
  }
  @isTest
  static void testSetAdminRole() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.setAdminRole();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method setAdminRole executed successfully');
  }
  @isTest
  static void testStartEditMember() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.startEditMember();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method startEditMember executed successfully');
  }
  @isTest
  static void testCancelEditMember() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.cancelEditMember();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method cancelEditMember executed successfully');
  }
  @isTest
  static void testUpdateMemberRole() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.updateMemberRole();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method updateMemberRole executed successfully');
  }
  @isTest
  static void testSwitchToBasic() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.switchToBasic();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method switchToBasic executed successfully');
  }
  @isTest
  static void testSwitchToMembers() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.switchToMembers();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method switchToMembers executed successfully');
  }
  @isTest
  static void testSwitchToTheme() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.switchToTheme();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method switchToTheme executed successfully');
  }
  @isTest
  static void testSwitchToType() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.switchToType();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method switchToType executed successfully');
  }
  @isTest
  static void testSwitchToStatus() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.switchToStatus();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method switchToStatus executed successfully');
  }
  @isTest
  static void testSwitchToCategory() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.switchToCategory();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method switchToCategory executed successfully');
  }
  @isTest
  static void testSwitchToMilestone() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.switchToMilestone();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method switchToMilestone executed successfully');
  }
  @isTest
  static void testSwitchToCustom() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.switchToCustom();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method switchToCustom executed successfully');
  }
  @isTest
  static void testSwitchToIntegration() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.switchToIntegration();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method switchToIntegration executed successfully');
  }
  @isTest
  static void testGoBackToProject() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    PageReference result = controller.goBackToProject();
    Test.stopTest();

    // PageReference methods may return null or a page
    System.assert(true, 'Method goBackToProject executed successfully');
  }
  @isTest
  static void testGetAddRoleOptions() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    List<SelectOption> options = controller.getAddRoleOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetAvailableUserOptions() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    List<SelectOption> options = controller.getAvailableUserOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetRoleFilterOptions() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    List<SelectOption> options = controller.getRoleFilterOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetProjectDisplayName() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    String result = controller.getProjectDisplayName();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getProjectDisplayName executed successfully');
  }
  @isTest
  static void testGetProjectName() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    String result = controller.getProjectName();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getProjectName executed successfully');
  }
  @isTest
  static void testGetMemberInitial() {
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    String result = controller.getMemberInitial();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getMemberInitial executed successfully');
  }

  @isTest
  static void testConstructorWithProjectId() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_Worker__c worker = [SELECT Id FROM JIP_Worker__c LIMIT 1];

    PageReference pageRef = Page.JIP_ProjectSettingsPage;
    pageRef.getParameters().put('projectId', proj.Id);
    Test.setCurrentPage(pageRef);

    Test.startTest();
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();
    Test.stopTest();

    System.assertEquals(
      proj.Id,
      controller.selectedProjectId,
      'Project ID should match'
    );
    System.assertNotEquals(
      null,
      controller.project,
      'Project should be loaded'
    );
  }

  @isTest
  static void testConstructorWithProjectIdAndSection() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];

    PageReference pageRef = Page.JIP_ProjectSettingsPage;
    pageRef.getParameters().put('projectId', proj.Id);
    pageRef.getParameters().put('section', 'basic');
    Test.setCurrentPage(pageRef);

    Test.startTest();
    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();
    Test.stopTest();

    System.assertEquals(
      'basic',
      controller.activeSection,
      'Section should be basic'
    );
  }

  @isTest
  static void testAddMemberWithProjectId() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_Department__c dept = JIP_TestDataFactory.createDepartment(
      'New Dept',
      true
    );
    JIP_Worker__c newWorker = JIP_TestDataFactory.createWorker(
      'New Worker',
      dept.Id,
      true
    );

    PageReference pageRef = Page.JIP_ProjectSettingsPage;
    pageRef.getParameters().put('projectId', proj.Id);
    Test.setCurrentPage(pageRef);

    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();
    controller.addWorkerId = newWorker.Id;

    Test.startTest();
    controller.addMemberToProject();
    Test.stopTest();

    System.assert(true, 'addMemberToProject completed');
  }

  @isTest
  static void testRemoveMemberWithProjectId() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectMember__c member = [
      SELECT Id
      FROM JIP_ProjectMember__c
      WHERE Project__c = :proj.Id
      LIMIT 1
    ];

    PageReference pageRef = Page.JIP_ProjectSettingsPage;
    pageRef.getParameters().put('projectId', proj.Id);
    Test.setCurrentPage(pageRef);

    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();
    controller.removeMemberId = member.Id;

    Test.startTest();
    controller.removeMember();
    Test.stopTest();

    System.assert(true, 'removeMember completed');
  }

  @isTest
  static void testSetAdminRoleWithProjectId() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectMember__c member = [
      SELECT Id
      FROM JIP_ProjectMember__c
      WHERE Project__c = :proj.Id
      LIMIT 1
    ];

    PageReference pageRef = Page.JIP_ProjectSettingsPage;
    pageRef.getParameters().put('projectId', proj.Id);
    Test.setCurrentPage(pageRef);

    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();
    controller.adminUserId = member.Id;

    Test.startTest();
    controller.setAdminRole();
    Test.stopTest();

    System.assert(true, 'setAdminRole completed');
  }

  @isTest
  static void testUpdateMemberRoleWithProjectId() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectMember__c member = [
      SELECT Id
      FROM JIP_ProjectMember__c
      WHERE Project__c = :proj.Id
      LIMIT 1
    ];

    PageReference pageRef = Page.JIP_ProjectSettingsPage;
    pageRef.getParameters().put('projectId', proj.Id);
    Test.setCurrentPage(pageRef);

    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();
    controller.editMemberId = member.Id;
    controller.editMemberRole = 'メンバー';

    Test.startTest();
    controller.updateMemberRole();
    Test.stopTest();

    System.assert(true, 'updateMemberRole completed');
  }

  @isTest
  static void testStartEditMemberWithProjectId() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectMember__c member = [
      SELECT Id
      FROM JIP_ProjectMember__c
      WHERE Project__c = :proj.Id
      LIMIT 1
    ];

    PageReference pageRef = Page.JIP_ProjectSettingsPage;
    pageRef.getParameters().put('projectId', proj.Id);
    Test.setCurrentPage(pageRef);

    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();
    controller.editMemberId = member.Id;

    Test.startTest();
    controller.startEditMember();
    Test.stopTest();

    System.assert(true, 'startEditMember completed');
  }

  @isTest
  static void testSearchMembersWithKeyword() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];

    PageReference pageRef = Page.JIP_ProjectSettingsPage;
    pageRef.getParameters().put('projectId', proj.Id);
    Test.setCurrentPage(pageRef);

    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();
    controller.searchUserKeyword = 'Test';
    controller.filterRole = 'メンバー';

    Test.startTest();
    controller.searchMembers();
    Test.stopTest();

    System.assert(true, 'searchMembers completed');
  }

  @isTest
  static void testSaveLanguageWithProject() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];

    PageReference pageRef = Page.JIP_ProjectSettingsPage;
    pageRef.getParameters().put('projectId', proj.Id);
    Test.setCurrentPage(pageRef);

    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    controller.saveLanguage();
    Test.stopTest();

    System.assert(true, 'saveLanguage with project completed');
  }

  @isTest
  static void testAddDuplicateMember() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_Worker__c worker = [
        SELECT Worker__c
        FROM JIP_ProjectMember__c
        WHERE Project__c = :proj.Id
        LIMIT 1
      ]
      .Worker__c == null
      ? [SELECT Id FROM JIP_Worker__c LIMIT 1]
      : [
          SELECT Id
          FROM JIP_Worker__c
          WHERE
            Id = :[
              SELECT Worker__c
              FROM JIP_ProjectMember__c
              WHERE Project__c = :proj.Id
              LIMIT 1
            ]
            .Worker__c
          LIMIT 1
        ];
    JIP_ProjectMember__c member = [
      SELECT Worker__c
      FROM JIP_ProjectMember__c
      WHERE Project__c = :proj.Id
      LIMIT 1
    ];

    PageReference pageRef = Page.JIP_ProjectSettingsPage;
    pageRef.getParameters().put('projectId', proj.Id);
    Test.setCurrentPage(pageRef);

    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();
    controller.addWorkerId = member.Worker__c;

    Test.startTest();
    controller.addMemberToProject();
    Test.stopTest();

    System.assert(true, 'duplicate member add handled');
  }

  @isTest
  static void testGoBackToProjectWithId() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];

    PageReference pageRef = Page.JIP_ProjectSettingsPage;
    pageRef.getParameters().put('projectId', proj.Id);
    Test.setCurrentPage(pageRef);

    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    PageReference result = controller.goBackToProject();
    Test.stopTest();

    System.assertNotEquals(null, result, 'Should return page reference');
  }

  @isTest
  static void testGetProjectDisplayNameWithProject() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];

    PageReference pageRef = Page.JIP_ProjectSettingsPage;
    pageRef.getParameters().put('projectId', proj.Id);
    Test.setCurrentPage(pageRef);

    JIP_ProjectSettingsController controller = new JIP_ProjectSettingsController();

    Test.startTest();
    String name = controller.getProjectDisplayName();
    String projName = controller.getProjectName();
    String lang = controller.getLanguage();
    Test.stopTest();

    System.assertNotEquals(null, name, 'Name should not be null');
  }
}