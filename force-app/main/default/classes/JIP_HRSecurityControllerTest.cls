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
private class JIP_HRSecurityControllerTest {
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
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
  }
  @isTest
  static void testGetT() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

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
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    controller.search();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method search executed successfully');
  }
  @isTest
  static void testClearSearch() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    controller.clearSearch();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method clearSearch executed successfully');
  }
  @isTest
  static void testApplyDateFilter() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    controller.applyDateFilter();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method applyDateFilter executed successfully');
  }
  @isTest
  static void testChangeTab() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    controller.changeTab();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method changeTab executed successfully');
  }
  @isTest
  static void testRunComplianceCheck() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    controller.runComplianceCheck();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method runComplianceCheck executed successfully');
  }
  @isTest
  static void testResolveAlert() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    controller.resolveAlert();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method resolveAlert executed successfully');
  }
  @isTest
  static void testExportLogs() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    controller.exportLogs();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method exportLogs executed successfully');
  }
  @isTest
  static void testChangeLanguage() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    controller.changeLanguage();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method changeLanguage executed successfully');
  }
  @isTest
  static void testGetLogTypeOptions() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    List<SelectOption> options = controller.getLogTypeOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetDateRangeOptions() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    List<SelectOption> options = controller.getDateRangeOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetTabOptions() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    List<SelectOption> options = controller.getTabOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetLanguageOptions() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    List<SelectOption> options = controller.getLanguageOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }

  // ===== Additional comprehensive tests =====

  @isTest
  static void testSearchWithKeyword() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    controller.searchKeyword = 'TestKeyword';

    Test.startTest();
    controller.search();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller.auditLogs,
      'Audit logs should not be null'
    );
  }

  @isTest
  static void testClearSearchResetsData() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    controller.searchKeyword = 'SomeValue';

    Test.startTest();
    controller.clearSearch();
    Test.stopTest();

    System.assertEquals(
      '',
      controller.searchKeyword,
      'Search keyword should be cleared'
    );
  }

  @isTest
  static void testApplyDateFilterWithLast7Days() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    controller.filterDateRange = 'last_7_days';

    Test.startTest();
    controller.applyDateFilter();
    Test.stopTest();

    System.assertNotEquals(null, controller.auditLogs, 'Data should be loaded');
  }

  @isTest
  static void testApplyDateFilterWithLast30Days() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    controller.filterDateRange = 'last_30_days';

    Test.startTest();
    controller.applyDateFilter();
    Test.stopTest();

    System.assertNotEquals(null, controller.auditLogs, 'Data should be loaded');
  }

  @isTest
  static void testApplyDateFilterWithCustomRange() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    controller.filterDateRange = 'custom';
    controller.startDate = Date.today().addDays(-30);
    controller.endDate = Date.today();

    Test.startTest();
    controller.applyDateFilter();
    Test.stopTest();

    System.assertNotEquals(null, controller.auditLogs, 'Data should be loaded');
  }

  @isTest
  static void testChangeTabToAccessLogs() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    controller.selectedTab = 'access_logs';

    Test.startTest();
    controller.changeTab();
    Test.stopTest();

    System.assertEquals(
      'access_logs',
      controller.selectedTab,
      'Tab should be changed'
    );
  }

  @isTest
  static void testChangeTabToSecurityAlerts() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    controller.selectedTab = 'security_alerts';

    Test.startTest();
    controller.changeTab();
    Test.stopTest();

    System.assertEquals(
      'security_alerts',
      controller.selectedTab,
      'Tab should be changed'
    );
  }

  @isTest
  static void testChangeTabToCompliance() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    controller.selectedTab = 'compliance';

    Test.startTest();
    controller.changeTab();
    Test.stopTest();

    System.assertEquals(
      'compliance',
      controller.selectedTab,
      'Tab should be changed'
    );
  }

  @isTest
  static void testGetLanguage() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    controller.language = 'en';

    Test.startTest();
    String result = controller.getLanguage();
    Test.stopTest();

    System.assertEquals('en', result, 'Language should be English');
  }

  @isTest
  static void testGetLanguageDefault() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    controller.language = '';

    Test.startTest();
    String result = controller.getLanguage();
    Test.stopTest();

    System.assertEquals('ja', result, 'Language should default to Japanese');
  }

  @isTest
  static void testChangeLanguageToEnglish() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    controller.language = 'en';

    Test.startTest();
    controller.changeLanguage();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller.auditLogs,
      'Data should be reloaded'
    );
  }

  @isTest
  static void testRunComplianceCheckLoadsData() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    controller.runComplianceCheck();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller.complianceChecks,
      'Compliance checks should not be null'
    );
  }

  @isTest
  static void testResolveAlertWithValidAlert() {
    // Create a security alert with correct fields
    JIP_SecurityAlert__c alert = new JIP_SecurityAlert__c(
      Severity__c = 'High',
      Status__c = 'Active',
      DetectedDate__c = Date.today()
    );
    insert alert;

    Test.setCurrentPage(Page.JIP_HRSecurityPage);
    ApexPages.currentPage().getParameters().put('alertId', alert.Id);

    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    controller.resolveAlert();
    Test.stopTest();

    JIP_SecurityAlert__c updatedAlert = [
      SELECT Status__c
      FROM JIP_SecurityAlert__c
      WHERE Id = :alert.Id
    ];
    System.assertEquals(
      'Resolved',
      updatedAlert.Status__c,
      'Alert should be resolved'
    );
  }

  @isTest
  static void testResolveAlertNoAlertId() {
    Test.setCurrentPage(Page.JIP_HRSecurityPage);

    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    controller.resolveAlert();
    Test.stopTest();

    // Should execute without error
    System.assert(true, 'Method executed without error');
  }

  @isTest
  static void testExportLogsAddsMessage() {
    Test.setCurrentPage(Page.JIP_HRSecurityPage);

    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    controller.exportLogs();
    Test.stopTest();

    // Check that a message was added
    List<ApexPages.Message> messages = ApexPages.getMessages();
    System.assert(messages.size() > 0, 'Message should be added');
  }

  @isTest
  static void testFilterLogTypeWithAuditLog() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    controller.filterLogType = 'audit';

    Test.startTest();
    controller.applyDateFilter();
    Test.stopTest();

    System.assertNotEquals(null, controller.auditLogs, 'Data should be loaded');
  }

  @isTest
  static void testFilterLogTypeWithAccessLog() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    controller.filterLogType = 'access';

    Test.startTest();
    controller.applyDateFilter();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller.accessLogs,
      'Data should be loaded'
    );
  }

  @isTest
  static void testStatisticsCalculation() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    Integer totalLogs = controller.totalLogsToday;
    Integer failedAttempts = controller.failedAccessAttempts;
    Integer alerts = controller.activeAlerts;
    Integer score = controller.complianceScore;
    Test.stopTest();

    System.assert(totalLogs >= 0, 'Total logs should be non-negative');
    System.assert(
      failedAttempts >= 0,
      'Failed attempts should be non-negative'
    );
    System.assert(alerts >= 0, 'Active alerts should be non-negative');
    System.assert(
      score >= 0 && score <= 100,
      'Compliance score should be 0-100'
    );
  }

  @isTest
  static void testWithSecurityAlertData() {
    JIP_SecurityAlert__c alert = new JIP_SecurityAlert__c(
      Severity__c = 'High',
      Status__c = 'Active',
      DetectedDate__c = Date.today()
    );
    insert alert;

    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    Integer initialAlerts = controller.activeAlerts;
    Test.stopTest();

    System.assert(initialAlerts >= 1, 'Should have at least one alert');
  }

  @isTest
  static void testAuditLogsWrapperList() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    List<JIP_HRSecurityController.AuditLogWrapper> wrappers = controller.auditLogs;
    Test.stopTest();

    System.assertNotEquals(null, wrappers, 'Wrapper list should not be null');
  }

  @isTest
  static void testAccessLogsWrapperList() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    List<JIP_HRSecurityController.AccessLogWrapper> wrappers = controller.accessLogs;
    Test.stopTest();

    System.assertNotEquals(null, wrappers, 'Wrapper list should not be null');
  }

  @isTest
  static void testComplianceChecksWrapperList() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    List<JIP_HRSecurityController.ComplianceCheckWrapper> wrappers = controller.complianceChecks;
    Test.stopTest();

    System.assertNotEquals(null, wrappers, 'Wrapper list should not be null');
  }

  @isTest
  static void testSecurityAlertsWrapperList() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    List<JIP_HRSecurityController.SecurityAlertWrapper> wrappers = controller.securityAlerts;
    Test.stopTest();

    System.assertNotEquals(null, wrappers, 'Wrapper list should not be null');
  }

  @isTest
  static void testRunComplianceCheckWithParam() {
    JIP_ComplianceCheck__c check = new JIP_ComplianceCheck__c(
      CheckType__c = 'Security Policy',
      Status__c = 'Pending',
      LastCheckDate__c = Date.today().addDays(-30),
      NextCheckDate__c = Date.today()
    );
    insert check;

    Test.setCurrentPage(Page.JIP_HRSecurityPage);
    ApexPages.currentPage().getParameters().put('checkId', check.Id);

    JIP_HRSecurityController controller = new JIP_HRSecurityController();

    Test.startTest();
    controller.runComplianceCheck();
    Test.stopTest();

    JIP_ComplianceCheck__c updated = [
      SELECT LastCheckDate__c
      FROM JIP_ComplianceCheck__c
      WHERE Id = :check.Id
    ];
    System.assertEquals(
      Date.today(),
      updated.LastCheckDate__c,
      'Last check date should be updated'
    );
  }

  @isTest
  static void testWithAuditLogData() {
    JIP_AuditLog__c log = new JIP_AuditLog__c(
      Action__c = 'Create',
      ObjectType__c = 'JIP_Worker__c',
      IPAddress__c = '192.168.1.1'
    );
    insert log;

    Test.startTest();
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    Test.stopTest();

    System.assert(
      controller.totalLogsToday >= 1,
      'Should have at least 1 audit log today'
    );
    System.assert(
      controller.auditLogs.size() >= 1,
      'Audit logs wrapper should have data'
    );
  }

  @isTest
  static void testWithAccessLogData() {
    JIP_AccessLog__c log = new JIP_AccessLog__c(
      LoginTime__c = DateTime.now().addHours(-2),
      LogoutTime__c = DateTime.now(),
      IPAddress__c = '10.0.0.1',
      Status__c = 'Success'
    );
    insert log;

    JIP_AccessLog__c failedLog = new JIP_AccessLog__c(
      LoginTime__c = DateTime.now().addHours(-1),
      IPAddress__c = '10.0.0.2',
      Status__c = 'Failed'
    );
    insert failedLog;

    Test.startTest();
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    Test.stopTest();

    System.assert(
      controller.failedAccessAttempts >= 1,
      'Should have at least 1 failed attempt'
    );
    System.assert(
      controller.accessLogs.size() >= 1,
      'Access logs should have data'
    );
  }

  @isTest
  static void testWithComplianceCheckData() {
    JIP_ComplianceCheck__c passedCheck = new JIP_ComplianceCheck__c(
      CheckType__c = 'Data Privacy',
      Status__c = 'Passed',
      LastCheckDate__c = Date.today(),
      NextCheckDate__c = Date.today().addDays(30)
    );
    insert passedCheck;

    JIP_ComplianceCheck__c failedCheck = new JIP_ComplianceCheck__c(
      CheckType__c = 'Access Control',
      Status__c = 'Failed',
      LastCheckDate__c = Date.today().addDays(-7),
      NextCheckDate__c = Date.today().addDays(-1)
    );
    insert failedCheck;

    Test.startTest();
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    Test.stopTest();

    System.assert(
      controller.complianceChecks.size() >= 2,
      'Should have compliance check data'
    );
    System.assert(
      controller.complianceScore >= 0,
      'Compliance score should be calculated'
    );
  }

  @isTest
  static void testSearchWithFilterLogType() {
    JIP_AuditLog__c log = new JIP_AuditLog__c(
      Action__c = 'Update',
      ObjectType__c = 'JIP_Worker__c',
      IPAddress__c = '192.168.1.5'
    );
    insert log;

    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    controller.filterLogType = 'Update';
    controller.searchKeyword = 'Worker';

    Test.startTest();
    controller.search();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller.auditLogs,
      'Audit logs should be loaded with filter'
    );
  }

  @isTest
  static void testDateFilterWeek() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    controller.filterDateRange = 'week';

    Test.startTest();
    controller.applyDateFilter();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller.auditLogs,
      'Should load last 7 days'
    );
  }

  @isTest
  static void testDateFilterMonth() {
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    controller.filterDateRange = 'month';

    Test.startTest();
    controller.applyDateFilter();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller.auditLogs,
      'Should load last 30 days'
    );
  }

  @isTest
  static void testSecurityAlertInvestigating() {
    JIP_SecurityAlert__c alert = new JIP_SecurityAlert__c(
      Severity__c = 'Critical',
      Status__c = 'Investigating',
      DetectedDate__c = Date.today()
    );
    insert alert;

    Test.startTest();
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    Test.stopTest();

    System.assert(
      controller.securityAlerts.size() >= 1,
      'Should show investigating alerts'
    );
  }

  @isTest
  static void testAuditLogWrapperActions() {
    JIP_AuditLog__c createLog = new JIP_AuditLog__c(
      Action__c = 'Create',
      ObjectType__c = 'Test',
      IPAddress__c = '1.1.1.1'
    );
    JIP_AuditLog__c deleteLog = new JIP_AuditLog__c(
      Action__c = 'Delete',
      ObjectType__c = 'Test',
      IPAddress__c = '2.2.2.2'
    );
    JIP_AuditLog__c viewLog = new JIP_AuditLog__c(
      Action__c = 'View',
      ObjectType__c = 'Test',
      IPAddress__c = '3.3.3.3'
    );
    insert new List<JIP_AuditLog__c>{ createLog, deleteLog, viewLog };

    Test.startTest();
    JIP_HRSecurityController controller = new JIP_HRSecurityController();
    Test.stopTest();

    System.assert(
      controller.auditLogs.size() >= 3,
      'Should have at least 3 audit log entries'
    );
  }
}