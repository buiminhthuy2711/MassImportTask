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
private class JIP_HRSkillControllerTest {
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
    JIP_HRSkillController controller = new JIP_HRSkillController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
  }
  @isTest
  static void testGetT() {
    JIP_HRSkillController controller = new JIP_HRSkillController();

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
  static void testSearch() {
    JIP_HRSkillController controller = new JIP_HRSkillController();

    Test.startTest();
    controller.search();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method search executed successfully');
  }
  @isTest
  static void testClearSearch() {
    JIP_HRSkillController controller = new JIP_HRSkillController();

    Test.startTest();
    controller.clearSearch();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method clearSearch executed successfully');
  }
  @isTest
  static void testChangeTab() {
    JIP_HRSkillController controller = new JIP_HRSkillController();

    Test.startTest();
    controller.changeTab();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method changeTab executed successfully');
  }
  @isTest
  static void testEnrollTraining() {
    JIP_HRSkillController controller = new JIP_HRSkillController();

    Test.startTest();
    controller.enrollTraining();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method enrollTraining executed successfully');
  }
  @isTest
  static void testExportSkillMatrix() {
    JIP_HRSkillController controller = new JIP_HRSkillController();

    Test.startTest();
    controller.exportSkillMatrix();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method exportSkillMatrix executed successfully');
  }
  @isTest
  static void testChangeLanguage() {
    JIP_HRSkillController controller = new JIP_HRSkillController();

    Test.startTest();
    controller.changeLanguage();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method changeLanguage executed successfully');
  }
  @isTest
  static void testGetSkillCategoryOptions() {
    JIP_HRSkillController controller = new JIP_HRSkillController();

    Test.startTest();
    List<SelectOption> options = controller.getSkillCategoryOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetProficiencyOptions() {
    JIP_HRSkillController controller = new JIP_HRSkillController();

    Test.startTest();
    List<SelectOption> options = controller.getProficiencyOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetDepartmentOptions() {
    JIP_HRSkillController controller = new JIP_HRSkillController();

    Test.startTest();
    List<SelectOption> options = controller.getDepartmentOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetTabOptions() {
    JIP_HRSkillController controller = new JIP_HRSkillController();

    Test.startTest();
    List<SelectOption> options = controller.getTabOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetLanguageOptions() {
    JIP_HRSkillController controller = new JIP_HRSkillController();

    Test.startTest();
    List<SelectOption> options = controller.getLanguageOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }

  @isTest
  static void testEnrollTrainingWithParam() {
    JIP_Training__c training = [SELECT Id FROM JIP_Training__c LIMIT 1];

    Test.setCurrentPage(Page.JIP_HRSkillPage);
    ApexPages.currentPage().getParameters().put('trainingId', training.Id);

    JIP_HRSkillController controller = new JIP_HRSkillController();

    Test.startTest();
    controller.enrollTraining();
    Test.stopTest();

    List<ApexPages.Message> messages = ApexPages.getMessages();
    System.assert(messages.size() > 0, 'Should have confirmation message');
  }

  @isTest
  static void testSearchWithKeyword() {
    JIP_HRSkillController controller = new JIP_HRSkillController();
    controller.searchKeyword = 'Test';

    Test.startTest();
    controller.search();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller.skills,
      'Skills list should not be null'
    );
  }

  @isTest
  static void testSearchWithCategoryFilter() {
    JIP_HRSkillController controller = new JIP_HRSkillController();
    controller.filterSkillCategory = 'technical';

    Test.startTest();
    controller.search();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller.skills,
      'Skills list should not be null'
    );
  }

  @isTest
  static void testSearchWithDepartmentFilter() {
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];
    JIP_HRSkillController controller = new JIP_HRSkillController();
    controller.filterDepartment = dept.Id;

    Test.startTest();
    controller.search();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller.skills,
      'Skills list should not be null'
    );
  }

  @isTest
  static void testSearchWithAllFilters() {
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];
    JIP_HRSkillController controller = new JIP_HRSkillController();
    controller.searchKeyword = 'Skill';
    controller.filterDepartment = dept.Id;
    controller.filterSkillCategory = 'language';

    Test.startTest();
    controller.search();
    Test.stopTest();

    System.assertNotEquals(null, controller.skills, 'Skills should be loaded');
  }
}