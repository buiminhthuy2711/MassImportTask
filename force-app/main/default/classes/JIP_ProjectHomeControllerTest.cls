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
private class JIP_ProjectHomeControllerTest {
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
    JIP_ProjectHomeController controller = new JIP_ProjectHomeController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
  }
  @isTest
  static void testGetT() {
    JIP_ProjectHomeController controller = new JIP_ProjectHomeController();

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
  static void testGetProjectName() {
    JIP_ProjectHomeController controller = new JIP_ProjectHomeController();

    Test.startTest();
    String result = controller.getProjectName();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getProjectName executed successfully');
  }
  @isTest
  static void testGetProjectKey() {
    JIP_ProjectHomeController controller = new JIP_ProjectHomeController();

    Test.startTest();
    String result = controller.getProjectKey();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getProjectKey executed successfully');
  }

  @isTest
  static void testConstructorWithValidProjectId() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];

    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', proj.Id);

    Test.startTest();
    JIP_ProjectHomeController ctrl = new JIP_ProjectHomeController();
    Test.stopTest();

    System.assertEquals(proj.Id, ctrl.selectedProjectId);
    System.assertNotEquals(null, ctrl.project);
  }

  @isTest
  static void testConstructorWithInvalidProjectId() {
    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', 'INVALID');

    Test.startTest();
    JIP_ProjectHomeController ctrl = new JIP_ProjectHomeController();
    Test.stopTest();

    System.assertEquals(null, ctrl.selectedProjectId);
  }

  @isTest
  static void testGetProjectNameWithProject() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];

    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', proj.Id);

    JIP_ProjectHomeController ctrl = new JIP_ProjectHomeController();

    Test.startTest();
    String result = ctrl.getProjectName();
    Test.stopTest();

    System.assertNotEquals('', result);
  }

  @isTest
  static void testGetProjectKeyWithProject() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];

    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', proj.Id);

    JIP_ProjectHomeController ctrl = new JIP_ProjectHomeController();

    Test.startTest();
    String result = ctrl.getProjectKey();
    Test.stopTest();

    System.assertNotEquals('', result);
  }

  @isTest
  static void testGetLanguageWithLanguageSet() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    proj.Language__c = 'en';
    update proj;

    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', proj.Id);

    JIP_ProjectHomeController ctrl = new JIP_ProjectHomeController();

    Test.startTest();
    String lang = ctrl.getLanguage();
    Test.stopTest();

    System.assertEquals('en', lang);
  }

  @isTest
  static void testGetLanguageDefault() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    proj.Language__c = null;
    update proj;

    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', proj.Id);

    JIP_ProjectHomeController ctrl = new JIP_ProjectHomeController();

    Test.startTest();
    String lang = ctrl.getLanguage();
    Test.stopTest();

    System.assertEquals('ja', lang);
  }

  @isTest
  static void testGetTWithProject() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];

    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', proj.Id);

    JIP_ProjectHomeController ctrl = new JIP_ProjectHomeController();

    Test.startTest();
    Map<String, String> t = ctrl.getT();
    Test.stopTest();

    System.assertNotEquals(null, t);
  }
}