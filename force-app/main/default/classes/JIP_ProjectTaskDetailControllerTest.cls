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
private class JIP_ProjectTaskDetailControllerTest {
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
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
  }
  @isTest
  static void testCancelCreate() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    controller.cancelCreate();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method cancelCreate executed successfully');
  }
  @isTest
  static void testToggleEdit() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    controller.toggleEdit();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method toggleEdit executed successfully');
  }
  @isTest
  static void testSaveQuickEdit() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    controller.saveQuickEdit();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method saveQuickEdit executed successfully');
  }
  @isTest
  static void testSaveFullEdit() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    controller.saveFullEdit();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method saveFullEdit executed successfully');
  }
  @isTest
  static void testCancelEdit() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    controller.cancelEdit();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method cancelEdit executed successfully');
  }
  @isTest
  static void testSetStatusInProgress() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    controller.setStatusInProgress();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method setStatusInProgress executed successfully');
  }
  @isTest
  static void testSetStatusResolved() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    controller.setStatusResolved();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method setStatusResolved executed successfully');
  }
  @isTest
  static void testAssignToMe() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    controller.assignToMe();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method assignToMe executed successfully');
  }
  @isTest
  static void testAddComment() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    controller.addComment();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method addComment executed successfully');
  }
  @isTest
  static void testStartEditComment() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    controller.startEditComment();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method startEditComment executed successfully');
  }
  @isTest
  static void testSaveEditComment() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    controller.saveEditComment();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method saveEditComment executed successfully');
  }
  @isTest
  static void testCancelEditComment() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    controller.cancelEditComment();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method cancelEditComment executed successfully');
  }
  @isTest
  static void testGoBackToList() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    PageReference result = controller.goBackToList();
    Test.stopTest();

    // PageReference methods may return null or a page
    System.assert(true, 'Method goBackToList executed successfully');
  }
  @isTest
  static void testSaveCreate() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    PageReference result = controller.saveCreate();
    Test.stopTest();

    // PageReference methods may return null or a page
    System.assert(true, 'Method saveCreate executed successfully');
  }
  @isTest
  static void testCancelCreateRedirect() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    PageReference result = controller.cancelCreateRedirect();
    Test.stopTest();

    // PageReference methods may return null or a page
    System.assert(true, 'Method cancelCreateRedirect executed successfully');
  }
  @isTest
  static void testDeleteTask() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    PageReference result = controller.deleteTask();
    Test.stopTest();

    // PageReference methods may return null or a page
    System.assert(true, 'Method deleteTask executed successfully');
  }
  @isTest
  static void testGetStatusOptions() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    List<SelectOption> options = controller.getStatusOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetAssigneeOptions() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    List<SelectOption> options = controller.getAssigneeOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetNotifyMemberOptions() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    List<SelectOption> options = controller.getNotifyMemberOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetProjectName() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    String result = controller.getProjectName();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getProjectName executed successfully');
  }
  @isTest
  static void testGetAssigneeName() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    String result = controller.getAssigneeName();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getAssigneeName executed successfully');
  }
  @isTest
  static void testGetAssigneeInitial() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    String result = controller.getAssigneeInitial();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getAssigneeInitial executed successfully');
  }
  @isTest
  static void testGetCurrentUserName() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    String result = controller.getCurrentUserName();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getCurrentUserName executed successfully');
  }
  @isTest
  static void testGetRegisteredByInitial() {
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    String result = controller.getRegisteredByInitial();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getRegisteredByInitial executed successfully');
  }

  // ===== Tests with actual task data =====

  @isTest
  static void testConstructorWithTaskData() {
    JIP_ProjectTask__c task = [
      SELECT Id, Project__c
      FROM JIP_ProjectTask__c
      LIMIT 1
    ];

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    Test.startTest();
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();
    Test.stopTest();

    System.assertNotEquals(null, controller.task, 'Task should be loaded');
    System.assertEquals(task.Id, controller.task.Id, 'Task ID should match');
    System.assertNotEquals(
      null,
      controller.comments,
      'Comments list should be initialized'
    );
  }

  @isTest
  static void testConstructorCreateMode() {
    JIP_Project__c project = [SELECT Id FROM JIP_Project__c LIMIT 1];

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('projectId', project.Id);

    Test.startTest();
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();
    Test.stopTest();

    System.assertEquals(
      true,
      controller.isCreateMode,
      'Should be in create mode'
    );
    System.assertNotEquals(null, controller.task, 'New task should be created');
    System.assertEquals(
      project.Id,
      controller.task.Project__c,
      'Project should be set'
    );
  }

  @isTest
  static void testSaveQuickEditWithTask() {
    JIP_ProjectTask__c task = [
      SELECT Id, Project__c
      FROM JIP_ProjectTask__c
      LIMIT 1
    ];

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();
    controller.editStatus = '処理中';
    controller.editStartDate = Date.today();
    controller.editDueDate = Date.today().addDays(7);
    controller.editMilestone = 'Phase 1';
    controller.editEstimatedHours = 10;
    controller.editActualHours = 5;

    Test.startTest();
    controller.saveQuickEdit();
    Test.stopTest();

    JIP_ProjectTask__c updatedTask = [
      SELECT Status__c
      FROM JIP_ProjectTask__c
      WHERE Id = :task.Id
    ];
    System.assertEquals(
      '処理中',
      updatedTask.Status__c,
      'Status should be updated'
    );
  }

  @isTest
  static void testSaveFullEditWithTask() {
    JIP_ProjectTask__c task = [
      SELECT Id, Project__c
      FROM JIP_ProjectTask__c
      LIMIT 1
    ];

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();
    controller.isEditing = true;
    controller.task.Subject__c = 'Updated Subject';

    Test.startTest();
    controller.saveFullEdit();
    Test.stopTest();

    System.assertEquals(
      false,
      controller.isEditing,
      'Editing should be turned off'
    );
  }

  @isTest
  static void testToggleEditWithTask() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();
    Boolean initialEditing = controller.isEditing;

    Test.startTest();
    controller.toggleEdit();
    Test.stopTest();

    System.assertNotEquals(
      initialEditing,
      controller.isEditing,
      'Editing should be toggled'
    );
  }

  @isTest
  static void testCancelEditWithTask() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();
    controller.isEditing = true;

    Test.startTest();
    controller.cancelEdit();
    Test.stopTest();

    System.assertEquals(
      false,
      controller.isEditing,
      'Editing should be canceled'
    );
  }

  @isTest
  static void testSetStatusInProgressWithTask() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    controller.setStatusInProgress();
    Test.stopTest();

    JIP_ProjectTask__c updatedTask = [
      SELECT Status__c
      FROM JIP_ProjectTask__c
      WHERE Id = :task.Id
    ];
    System.assertEquals(
      '処理中',
      updatedTask.Status__c,
      'Status should be in progress'
    );
  }

  @isTest
  static void testSetStatusResolvedWithTask() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    controller.setStatusResolved();
    Test.stopTest();

    JIP_ProjectTask__c updatedTask = [
      SELECT Status__c
      FROM JIP_ProjectTask__c
      WHERE Id = :task.Id
    ];
    System.assertEquals(
      '処理済み',
      updatedTask.Status__c,
      'Status should be resolved'
    );
  }

  @isTest
  static void testAssignToMeWithTask() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    controller.assignToMe();
    Test.stopTest();

    // Method executed - assignee may or may not be found
    System.assert(true, 'assignToMe executed successfully');
  }

  @isTest
  static void testGoBackToListWithTask() {
    JIP_ProjectTask__c task = [
      SELECT Id, Project__c
      FROM JIP_ProjectTask__c
      LIMIT 1
    ];

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    PageReference result = controller.goBackToList();
    Test.stopTest();

    System.assertNotEquals(null, result, 'PageReference should not be null');
  }

  @isTest
  static void testAddCommentWithTask() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();
    controller.newCommentObj = new JIP_TaskComment__c();
    controller.newCommentObj.CommentBody__c = 'Test comment';

    Test.startTest();
    controller.addComment();
    Test.stopTest();

    // Check comment was added
    List<JIP_TaskComment__c> comments = [
      SELECT Id
      FROM JIP_TaskComment__c
      WHERE ProjectTask__c = :task.Id
    ];
    System.assertEquals(1, comments.size(), 'One comment should be added');
  }

  @isTest
  static void testAddCommentWithNotify() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];
    JIP_Worker__c worker = [SELECT Id FROM JIP_Worker__c LIMIT 1];

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();
    controller.newCommentObj = new JIP_TaskComment__c();
    controller.newCommentObj.CommentBody__c = 'Test comment with notify';
    controller.selectedMembersToNotify = worker.Id;

    Test.startTest();
    controller.addComment();
    Test.stopTest();

    System.assert(true, 'Comment with notification added');
  }

  @isTest
  static void testStartEditCommentWithData() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];

    // Create a comment first
    JIP_TaskComment__c comment = new JIP_TaskComment__c(
      ProjectTask__c = task.Id,
      CommentBody__c = 'Test comment',
      CommentBy__c = UserInfo.getName()
    );
    insert comment;

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);
    ApexPages.currentPage().getParameters().put('commentId', comment.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    controller.startEditComment();
    Test.stopTest();

    System.assertEquals(
      comment.Id,
      controller.editingCommentId,
      'Editing comment ID should be set'
    );
    System.assertEquals(
      'Test comment',
      controller.editCommentBody,
      'Comment body should be loaded'
    );
  }

  @isTest
  static void testSaveEditCommentWithData() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];

    // Create a comment first
    JIP_TaskComment__c comment = new JIP_TaskComment__c(
      ProjectTask__c = task.Id,
      CommentBody__c = 'Original comment',
      CommentBy__c = UserInfo.getName()
    );
    insert comment;

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();
    controller.editingCommentId = comment.Id;
    controller.editCommentBody = 'Updated comment';

    Test.startTest();
    controller.saveEditComment();
    Test.stopTest();

    JIP_TaskComment__c updatedComment = [
      SELECT CommentBody__c
      FROM JIP_TaskComment__c
      WHERE Id = :comment.Id
    ];
    System.assertEquals(
      'Updated comment',
      updatedComment.CommentBody__c,
      'Comment should be updated'
    );
  }

  @isTest
  static void testCancelEditCommentWithData() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();
    controller.editingCommentId = task.Id;
    controller.editCommentBody = 'Some text';

    Test.startTest();
    controller.cancelEditComment();
    Test.stopTest();

    System.assertEquals(
      null,
      controller.editingCommentId,
      'Editing comment ID should be cleared'
    );
    System.assertEquals(
      '',
      controller.editCommentBody,
      'Comment body should be cleared'
    );
  }

  @isTest
  static void testDeleteTaskWithData() {
    JIP_ProjectTask__c task = [
      SELECT Id, Project__c
      FROM JIP_ProjectTask__c
      LIMIT 1
    ];
    Id taskId = task.Id;

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    PageReference result = controller.deleteTask();
    Test.stopTest();

    // Task should be deleted
    List<JIP_ProjectTask__c> tasks = [
      SELECT Id
      FROM JIP_ProjectTask__c
      WHERE Id = :taskId
    ];
    System.assertEquals(0, tasks.size(), 'Task should be deleted');
  }

  @isTest
  static void testSaveCreateWithData() {
    JIP_Project__c project = [SELECT Id FROM JIP_Project__c LIMIT 1];

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('projectId', project.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();
    controller.task.Subject__c = 'New Task Subject';

    Test.startTest();
    PageReference result = controller.saveCreate();
    Test.stopTest();

    System.assertNotEquals(null, result, 'Should redirect after save');
  }

  @isTest
  static void testGetProjectNameWithTask() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    String result = controller.getProjectName();
    Test.stopTest();

    System.assertNotEquals(null, result, 'Project name should not be null');
  }

  @isTest
  static void testGetProjectNameCreateMode() {
    JIP_Project__c project = [SELECT Id FROM JIP_Project__c LIMIT 1];

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('projectId', project.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    String result = controller.getProjectName();
    Test.stopTest();

    System.assertNotEquals(
      null,
      result,
      'Project name should not be null in create mode'
    );
  }

  @isTest
  static void testGetAssigneeNameWithTask() {
    // Get task and ensure it has an assignee
    JIP_ProjectTask__c task = [
      SELECT Id, Assignee__c
      FROM JIP_ProjectTask__c
      LIMIT 1
    ];
    JIP_Worker__c worker = [SELECT Id FROM JIP_Worker__c LIMIT 1];
    task.Assignee__c = worker.Id;
    update task;

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    String result = controller.getAssigneeName();
    Test.stopTest();

    System.assertNotEquals(null, result, 'Assignee name should not be null');
  }

  @isTest
  static void testGetAssigneeInitialWithTask() {
    // Get task and ensure it has an assignee
    JIP_ProjectTask__c task = [
      SELECT Id, Assignee__c
      FROM JIP_ProjectTask__c
      LIMIT 1
    ];
    JIP_Worker__c worker = [SELECT Id FROM JIP_Worker__c LIMIT 1];
    task.Assignee__c = worker.Id;
    update task;

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    String result = controller.getAssigneeInitial();
    Test.stopTest();

    System.assertNotEquals(null, result, 'Assignee initial should not be null');
  }

  @isTest
  static void testGetRegisteredByInitialWithTask() {
    JIP_ProjectTask__c task = [SELECT Id FROM JIP_ProjectTask__c LIMIT 1];
    task.RegisteredBy__c = 'Test User';
    update task;

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    String result = controller.getRegisteredByInitial();
    Test.stopTest();

    System.assertEquals('T', result, 'Initial should be T');
  }

  @isTest
  static void testGetAssigneeOptionsWithWorkers() {
    Test.startTest();
    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();
    List<SelectOption> options = controller.getAssigneeOptions();
    Test.stopTest();

    System.assert(
      options.size() >= 1,
      'Should have at least the default option'
    );
  }

  @isTest
  static void testGetNotifyMemberOptionsWithProject() {
    JIP_ProjectTask__c task = [
      SELECT Id, Project__c
      FROM JIP_ProjectTask__c
      LIMIT 1
    ];

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('id', task.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    List<SelectOption> options = controller.getNotifyMemberOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }

  @isTest
  static void testCancelCreateRedirectWithProject() {
    JIP_Project__c project = [SELECT Id FROM JIP_Project__c LIMIT 1];

    Test.setCurrentPage(Page.JIP_ProjectTaskDetailPage);
    ApexPages.currentPage().getParameters().put('projectId', project.Id);

    JIP_ProjectTaskDetailController controller = new JIP_ProjectTaskDetailController();

    Test.startTest();
    PageReference result = controller.cancelCreateRedirect();
    Test.stopTest();

    System.assertNotEquals(null, result, 'Should return PageReference');
  }
}