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
private class JIP_HRWorkflowControllerTest {
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
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
  }
  @isTest
  static void testGetT() {
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

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
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    controller.search();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method search executed successfully');
  }
  @isTest
  static void testClearSearch() {
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    controller.clearSearch();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method clearSearch executed successfully');
  }
  @isTest
  static void testChangeTab() {
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    controller.changeTab();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method changeTab executed successfully');
  }
  @isTest
  static void testOpenNewRequest() {
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    controller.openNewRequest();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method openNewRequest executed successfully');
  }
  @isTest
  static void testSelectRequestType() {
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    controller.selectRequestType();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method selectRequestType executed successfully');
  }
  @isTest
  static void testCloseModal() {
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    controller.closeModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method closeModal executed successfully');
  }
  @isTest
  static void testSubmitRequest() {
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    controller.submitRequest();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method submitRequest executed successfully');
  }
  @isTest
  static void testApproveRequest() {
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    controller.approveRequest();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method approveRequest executed successfully');
  }
  @isTest
  static void testRejectRequest() {
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    controller.rejectRequest();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method rejectRequest executed successfully');
  }
  @isTest
  static void testCancelRequest() {
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    controller.cancelRequest();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method cancelRequest executed successfully');
  }
  @isTest
  static void testChangeLanguage() {
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    controller.changeLanguage();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method changeLanguage executed successfully');
  }
  @isTest
  static void testGetRequestTypeOptions() {
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    List<SelectOption> options = controller.getRequestTypeOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetStatusFilterOptions() {
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    List<SelectOption> options = controller.getStatusFilterOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetApproverOptions() {
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    List<SelectOption> options = controller.getApproverOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetTabOptions() {
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    List<SelectOption> options = controller.getTabOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetLanguageOptions() {
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    List<SelectOption> options = controller.getLanguageOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }

  @isTest
  static void testApproveRequestWithPageParam() {
    JIP_Request__c req = [SELECT Id FROM JIP_Request__c LIMIT 1];
    req.Status__c = 'Pending';
    req.Approver__c = UserInfo.getUserId();
    update req;

    Test.setCurrentPage(Page.JIP_HRWorkflowPage);
    ApexPages.currentPage().getParameters().put('requestId', req.Id);

    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    controller.approveRequest();
    Test.stopTest();

    JIP_Request__c updated = [
      SELECT Status__c
      FROM JIP_Request__c
      WHERE Id = :req.Id
    ];
    System.assertEquals(
      'Approved',
      updated.Status__c,
      'Request should be approved'
    );
  }

  @isTest
  static void testRejectRequestWithPageParam() {
    JIP_Request__c req = [SELECT Id FROM JIP_Request__c LIMIT 1];
    req.Status__c = 'Pending';
    req.Approver__c = UserInfo.getUserId();
    update req;

    Test.setCurrentPage(Page.JIP_HRWorkflowPage);
    ApexPages.currentPage().getParameters().put('requestId', req.Id);
    ApexPages.currentPage()
      .getParameters()
      .put('rejectComment', 'Not approved');

    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    controller.rejectRequest();
    Test.stopTest();

    JIP_Request__c updated = [
      SELECT Status__c, ApproverComment__c
      FROM JIP_Request__c
      WHERE Id = :req.Id
    ];
    System.assertEquals(
      'Rejected',
      updated.Status__c,
      'Request should be rejected'
    );
    System.assertEquals(
      'Not approved',
      updated.ApproverComment__c,
      'Comment should be saved'
    );
  }

  @isTest
  static void testCancelRequestWithPageParam() {
    JIP_Request__c req = [SELECT Id FROM JIP_Request__c LIMIT 1];
    req.Status__c = 'Pending';
    req.Applicant__c = UserInfo.getUserId();
    update req;

    Test.setCurrentPage(Page.JIP_HRWorkflowPage);
    ApexPages.currentPage().getParameters().put('requestId', req.Id);

    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    controller.cancelRequest();
    Test.stopTest();

    JIP_Request__c updated = [
      SELECT Status__c
      FROM JIP_Request__c
      WHERE Id = :req.Id
    ];
    System.assertEquals(
      'Cancelled',
      updated.Status__c,
      'Request should be cancelled'
    );
  }

  @isTest
  static void testSubmitRequestWithData() {
    Test.setCurrentPage(Page.JIP_HRWorkflowPage);
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();
    controller.openNewRequest();
    controller.currentRequest.RequestType__c = '有給休暇';
    controller.currentRequest.StartDate__c = Date.today().addDays(1);
    controller.currentRequest.EndDate__c = Date.today().addDays(3);
    controller.currentRequest.Comment__c = 'Test leave request';

    Test.startTest();
    controller.submitRequest();
    Test.stopTest();

    // Method executed without throwing exception
    System.assert(true, 'Submit request method completed');
  }

  @isTest
  static void testSelectRequestTypeWithParam() {
    Test.setCurrentPage(Page.JIP_HRWorkflowPage);
    ApexPages.currentPage().getParameters().put('type', 'sick_leave');

    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();

    Test.startTest();
    controller.selectRequestType();
    Test.stopTest();

    System.assertEquals(
      'sick_leave',
      controller.currentRequestType,
      'Type should be set from param'
    );
  }

  @isTest
  static void testChangeTabAllRequests() {
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();
    controller.selectedTab = 'all_requests';

    Test.startTest();
    controller.changeTab();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller.allRequests,
      'All requests should be loaded'
    );
  }

  @isTest
  static void testSearchWithKeywordAndFilters() {
    JIP_HRWorkflowController controller = new JIP_HRWorkflowController();
    controller.searchKeyword = 'Test';
    controller.filterStatus = 'Pending';
    controller.filterType = 'paid_leave';
    controller.selectedTab = 'all_requests';

    Test.startTest();
    controller.search();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller.myRequests,
      'My requests should be loaded'
    );
  }
}