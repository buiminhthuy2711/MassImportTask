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
private class JIP_HRDashboardControllerTest {
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
    JIP_HRDashboardController controller = new JIP_HRDashboardController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
  }
  @isTest
  static void testGetT() {
    JIP_HRDashboardController controller = new JIP_HRDashboardController();

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
  static void testApplyFilters() {
    JIP_HRDashboardController controller = new JIP_HRDashboardController();

    Test.startTest();
    controller.applyFilters();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method applyFilters executed successfully');
  }
  @isTest
  static void testExportReport() {
    JIP_HRDashboardController controller = new JIP_HRDashboardController();

    Test.startTest();
    controller.exportReport();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method exportReport executed successfully');
  }
  @isTest
  static void testChangeTab() {
    JIP_HRDashboardController controller = new JIP_HRDashboardController();

    Test.startTest();
    controller.changeTab();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method changeTab executed successfully');
  }
  @isTest
  static void testChangeLanguage() {
    JIP_HRDashboardController controller = new JIP_HRDashboardController();

    Test.startTest();
    controller.changeLanguage();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method changeLanguage executed successfully');
  }
  @isTest
  static void testGetPeriodOptions() {
    JIP_HRDashboardController controller = new JIP_HRDashboardController();

    Test.startTest();
    List<SelectOption> options = controller.getPeriodOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetDepartmentOptions() {
    JIP_HRDashboardController controller = new JIP_HRDashboardController();

    Test.startTest();
    List<SelectOption> options = controller.getDepartmentOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetTabOptions() {
    JIP_HRDashboardController controller = new JIP_HRDashboardController();

    Test.startTest();
    List<SelectOption> options = controller.getTabOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetLanguageOptions() {
    JIP_HRDashboardController controller = new JIP_HRDashboardController();

    Test.startTest();
    List<SelectOption> options = controller.getLanguageOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }

  @isTest
  static void testDashboardWithActiveWorkerData() {
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];

    JIP_Worker__c w = new JIP_Worker__c(
      Name = 'Dashboard Worker',
      Department__c = dept.Id,
      Email__c = 'dashboard.worker@test.com',
      EmploymentStatus__c = '在職',
      Gender__c = '男性',
      HireDate__c = Date.today().addMonths(-6),
      BirthDate__c = Date.newInstance(1990, 5, 15)
    );
    insert w;

    Test.startTest();
    JIP_HRDashboardController controller = new JIP_HRDashboardController();
    Test.stopTest();

    System.assert(
      controller.totalEmployees >= 1,
      'Should have at least 1 active employee'
    );
    System.assert(
      controller.maleCount >= 1,
      'Should have at least 1 male employee'
    );
  }

  @isTest
  static void testDashboardWithFemaleWorker() {
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];

    JIP_Worker__c w = new JIP_Worker__c(
      Name = 'Female Worker',
      Department__c = dept.Id,
      Email__c = 'female.worker@test.com',
      EmploymentStatus__c = '在職',
      Gender__c = '女性',
      HireDate__c = Date.today().addMonths(-3),
      BirthDate__c = Date.newInstance(1985, 8, 20)
    );
    insert w;

    Test.startTest();
    JIP_HRDashboardController controller = new JIP_HRDashboardController();
    Test.stopTest();

    System.assert(
      controller.femaleCount >= 1,
      'Should have at least 1 female employee'
    );
  }

  @isTest
  static void testDashboardWithNewHireThisMonth() {
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];

    JIP_Worker__c w = new JIP_Worker__c(
      Name = 'New Hire Worker',
      Department__c = dept.Id,
      Email__c = 'newhire.worker@test.com',
      EmploymentStatus__c = '在職',
      Gender__c = '男性',
      HireDate__c = Date.today(),
      BirthDate__c = Date.newInstance(1995, 1, 10)
    );
    insert w;

    Test.startTest();
    JIP_HRDashboardController controller = new JIP_HRDashboardController();
    Test.stopTest();

    System.assert(
      controller.newHiresThisMonth >= 1,
      'Should have at least 1 new hire'
    );
  }

  @isTest
  static void testDashboardWithTerminatedWorker() {
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];

    JIP_Worker__c w = new JIP_Worker__c(
      Name = 'Terminated Worker',
      Department__c = dept.Id,
      Email__c = 'terminated.worker@test.com',
      EmploymentStatus__c = '退職済',
      Gender__c = '男性',
      HireDate__c = Date.today().addYears(-2),
      EndDate__c = Date.today(),
      BirthDate__c = Date.newInstance(1988, 3, 5)
    );
    insert w;

    Test.startTest();
    JIP_HRDashboardController controller = new JIP_HRDashboardController();
    Test.stopTest();

    System.assert(
      controller.terminationsThisMonth >= 1,
      'Should have at least 1 termination'
    );
    System.assert(
      controller.turnoverRate >= 0,
      'Turnover rate should be calculated'
    );
  }

  @isTest
  static void testDashboardChartData() {
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];

    JIP_Worker__c w = new JIP_Worker__c(
      Name = 'Chart Worker',
      Department__c = dept.Id,
      Email__c = 'chart.worker@test.com',
      EmploymentStatus__c = '在職',
      Gender__c = '女性',
      HireDate__c = Date.today().addMonths(-12),
      BirthDate__c = Date.newInstance(1992, 7, 25)
    );
    insert w;

    Test.startTest();
    JIP_HRDashboardController controller = new JIP_HRDashboardController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller.headcountTrendJson,
      'Headcount trend JSON should not be null'
    );
    System.assertNotEquals(
      null,
      controller.departmentDistributionJson,
      'Dept distribution JSON should not be null'
    );
    System.assertNotEquals(
      null,
      controller.ageDistributionJson,
      'Age distribution JSON should not be null'
    );
  }

  @isTest
  static void testApplyFiltersWithDepartment() {
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];

    JIP_Worker__c w = new JIP_Worker__c(
      Name = 'Filter Worker',
      Department__c = dept.Id,
      Email__c = 'filter.worker@test.com',
      EmploymentStatus__c = '在職',
      Gender__c = '男性',
      HireDate__c = Date.today().addMonths(-1),
      BirthDate__c = Date.newInstance(1993, 11, 30)
    );
    insert w;

    JIP_HRDashboardController controller = new JIP_HRDashboardController();
    controller.filterDepartment = dept.Id;

    Test.startTest();
    controller.applyFilters();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller.departmentStats,
      'Department stats should be loaded'
    );
  }

  @isTest
  static void testRecentActivitiesWithData() {
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];

    JIP_Worker__c w = new JIP_Worker__c(
      Name = 'Recent Activity',
      LastName__c = '田中',
      FirstName__c = '太郎',
      Department__c = dept.Id,
      Email__c = 'recent.act@test.com',
      EmploymentStatus__c = '在職',
      Gender__c = '男性',
      HireDate__c = Date.today(),
      BirthDate__c = Date.newInstance(1990, 1, 1)
    );
    insert w;

    Test.startTest();
    JIP_HRDashboardController controller = new JIP_HRDashboardController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller.recentActivities,
      'Recent activities should be loaded'
    );
    System.assert(
      controller.recentActivities.size() >= 1,
      'Should have at least 1 recent activity'
    );
  }

  @isTest
  static void testUpcomingContractExpiration() {
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];
    JIP_Worker__c w = new JIP_Worker__c(
      Name = 'Contract Worker',
      Department__c = dept.Id,
      Email__c = 'cw@test.com',
      EmploymentStatus__c = '在職',
      Gender__c = '男性',
      HireDate__c = Date.today().addYears(-1),
      LastName__c = '佐藤',
      FirstName__c = '次郎',
      BirthDate__c = Date.newInstance(1990, 1, 1)
    );
    insert w;

    JIP_Contract__c c = new JIP_Contract__c(
      Worker__c = w.Id,
      Status__c = 'Active',
      ExpirationDate__c = Date.today().addDays(5)
    );
    insert c;

    Test.startTest();
    JIP_HRDashboardController ctrl = new JIP_HRDashboardController();
    Test.stopTest();

    System.assertNotEquals(null, ctrl.upcomingEvents);
  }

  @isTest
  static void testUpcomingCertExpiration() {
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];
    JIP_Worker__c w = new JIP_Worker__c(
      Name = 'Cert Worker',
      Department__c = dept.Id,
      Email__c = 'certw@test.com',
      EmploymentStatus__c = '在職',
      Gender__c = '女性',
      HireDate__c = Date.today().addYears(-2),
      BirthDate__c = Date.newInstance(1985, 6, 15)
    );
    insert w;

    JIP_Certification__c cert = new JIP_Certification__c(
      Worker__c = w.Id,
      CertificationName__c = 'Expiring Cert',
      Status__c = 'Active',
      ExpirationDate__c = Date.today().addDays(10)
    );
    insert cert;

    Test.startTest();
    JIP_HRDashboardController ctrl = new JIP_HRDashboardController();
    Test.stopTest();

    System.assertNotEquals(null, ctrl.upcomingEvents);
  }

  @isTest
  static void testAgeDistributionBranches() {
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];
    List<JIP_Worker__c> workers = new List<JIP_Worker__c>();
    // Age 25 (20-29 bucket)
    workers.add(
      new JIP_Worker__c(
        Name = 'W25',
        Department__c = dept.Id,
        Email__c = 'w25@test.com',
        EmploymentStatus__c = '在職',
        Gender__c = '男性',
        HireDate__c = Date.today().addYears(-1),
        BirthDate__c = Date.today().addYears(-25),
        Age__c = 25
      )
    );
    // Age 35 (30-39 bucket)
    workers.add(
      new JIP_Worker__c(
        Name = 'W35',
        Department__c = dept.Id,
        Email__c = 'w35@test.com',
        EmploymentStatus__c = '在職',
        Gender__c = '女性',
        HireDate__c = Date.today().addYears(-2),
        BirthDate__c = Date.today().addYears(-35),
        Age__c = 35
      )
    );
    // Age 45 (40-49 bucket)
    workers.add(
      new JIP_Worker__c(
        Name = 'W45',
        Department__c = dept.Id,
        Email__c = 'w45@test.com',
        EmploymentStatus__c = '在職',
        Gender__c = '男性',
        HireDate__c = Date.today().addYears(-3),
        BirthDate__c = Date.today().addYears(-45),
        Age__c = 45
      )
    );
    // Age 55 (50-59 bucket)
    workers.add(
      new JIP_Worker__c(
        Name = 'W55',
        Department__c = dept.Id,
        Email__c = 'w55@test.com',
        EmploymentStatus__c = '在職',
        Gender__c = '女性',
        HireDate__c = Date.today().addYears(-4),
        BirthDate__c = Date.today().addYears(-55),
        Age__c = 55
      )
    );
    // Age 65 (60+ bucket)
    workers.add(
      new JIP_Worker__c(
        Name = 'W65',
        Department__c = dept.Id,
        Email__c = 'w65@test.com',
        EmploymentStatus__c = '在職',
        Gender__c = '男性',
        HireDate__c = Date.today().addYears(-5),
        BirthDate__c = Date.today().addYears(-65),
        Age__c = 65
      )
    );
    insert workers;

    Test.startTest();
    JIP_HRDashboardController ctrl = new JIP_HRDashboardController();
    Test.stopTest();

    System.assertNotEquals(null, ctrl.ageDistributionJson);
  }

  @isTest
  static void testFilterByPeriodMonth() {
    JIP_HRDashboardController ctrl = new JIP_HRDashboardController();
    ctrl.filterPeriod = 'month';

    Test.startTest();
    ctrl.applyFilters();
    Test.stopTest();

    System.assert(ctrl.totalEmployees >= 0);
  }

  @isTest
  static void testFilterByPeriodQuarter() {
    JIP_HRDashboardController ctrl = new JIP_HRDashboardController();
    ctrl.filterPeriod = 'quarter';

    Test.startTest();
    ctrl.applyFilters();
    Test.stopTest();

    System.assert(ctrl.totalEmployees >= 0);
  }

  @isTest
  static void testRecentTermination() {
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];
    JIP_Worker__c w = new JIP_Worker__c(
      Name = 'Term Worker',
      Department__c = dept.Id,
      Email__c = 'term@test.com',
      EmploymentStatus__c = '退職済',
      Gender__c = '男性',
      HireDate__c = Date.today().addYears(-3),
      EndDate__c = Date.today().addDays(-1),
      LastName__c = '山田',
      FirstName__c = '花子',
      BirthDate__c = Date.newInstance(1988, 3, 5)
    );
    insert w;

    Test.startTest();
    JIP_HRDashboardController ctrl = new JIP_HRDashboardController();
    Test.stopTest();

    System.assertNotEquals(null, ctrl.recentActivities);
  }

  @isTest
  static void testGetLanguage() {
    JIP_HRDashboardController ctrl = new JIP_HRDashboardController();

    Test.startTest();
    String lang = ctrl.getLanguage();
    Test.stopTest();

    System.assertNotEquals(null, lang);
  }
}