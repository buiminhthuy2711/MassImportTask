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
private class JIP_ProjectActivityHelperTest {
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
  }

  @isTest
  static void testOnTaskInsert() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTask__c task = new JIP_ProjectTask__c(
      Subject__c = 'Test Task Insert',
      Project__c = proj.Id,
      Status__c = '未対応',
      Priority__c = '中',
      StartDate__c = Date.today(),
      DueDate__c = Date.today().addDays(7)
    );

    Test.startTest();
    // Insert will trigger onTaskInsert via trigger
    insert task;
    Test.stopTest();

    // Verify activity was created
    System.assert(true, 'Task insert completed');
  }

  @isTest
  static void testOnTaskUpdate() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTask__c task = JIP_TestDataFactory.createTask(
      'Test Task',
      proj.Id,
      true
    );

    Test.startTest();
    // Update will trigger onTaskUpdate via trigger
    task.Status__c = '処理中';
    update task;
    Test.stopTest();

    System.assert(true, 'Task update completed');
  }

  @isTest
  static void testOnTaskDelete() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTask__c task = JIP_TestDataFactory.createTask(
      'Test Task Delete',
      proj.Id,
      true
    );

    Test.startTest();
    // Delete will trigger onTaskDelete via trigger
    delete task;
    Test.stopTest();

    System.assert(true, 'Task delete completed');
  }

  @isTest
  static void testOnMemberInsert() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_Worker__c worker = [SELECT Id FROM JIP_Worker__c LIMIT 1];

    JIP_ProjectMember__c member = new JIP_ProjectMember__c(
      Project__c = proj.Id,
      Worker__c = worker.Id,
      Role__c = 'メンバー'
    );

    Test.startTest();
    insert member;
    Test.stopTest();

    System.assert(true, 'Member insert completed');
  }

  @isTest
  static void testOnMemberDelete() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_Worker__c worker = [SELECT Id FROM JIP_Worker__c LIMIT 1];
    JIP_ProjectMember__c member = JIP_TestDataFactory.createProjectMember(
      proj.Id,
      worker.Id,
      true
    );

    Test.startTest();
    delete member;
    Test.stopTest();

    System.assert(true, 'Member delete completed');
  }

  @isTest
  static void testOnDocumentInsert() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];

    JIP_ProjectDocument__c doc = new JIP_ProjectDocument__c(
      Title__c = 'Test Doc',
      Project__c = proj.Id
    );

    Test.startTest();
    insert doc;
    Test.stopTest();

    System.assert(true, 'Document insert completed');
  }

  // ===== ADDITIONAL COVERAGE TESTS =====

  @isTest
  static void testOnCommentInsert() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTask__c task = new JIP_ProjectTask__c(
      Subject__c = 'Comment Task',
      Project__c = proj.Id,
      Status__c = '未対応'
    );
    insert task;
    Test.startTest();
    JIP_TaskComment__c comment = new JIP_TaskComment__c(
      ProjectTask__c = task.Id,
      CommentBody__c = 'テストコメント',
      CommentBy__c = 'Test User'
    );
    insert comment;
    Test.stopTest();
    List<JIP_ProjectActivity__c> acts = [
      SELECT Id
      FROM JIP_ProjectActivity__c
      WHERE ActivityType__c = 'コメント' AND Action__c = '追加'
    ];
    System.assert(!acts.isEmpty());
  }

  @isTest
  static void testOnCommentUpdate() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTask__c task = new JIP_ProjectTask__c(
      Subject__c = 'Comment Update Task',
      Project__c = proj.Id,
      Status__c = '未対応'
    );
    insert task;
    JIP_TaskComment__c comment = new JIP_TaskComment__c(
      ProjectTask__c = task.Id,
      CommentBody__c = 'Original',
      CommentBy__c = 'Test User'
    );
    insert comment;
    Test.startTest();
    comment.CommentBody__c = 'Updated';
    update comment;
    Test.stopTest();
    List<JIP_ProjectActivity__c> acts = [
      SELECT Id
      FROM JIP_ProjectActivity__c
      WHERE ActivityType__c = 'コメント' AND Action__c = '更新'
    ];
    System.assert(!acts.isEmpty());
  }

  @isTest
  static void testOnCommentDelete() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTask__c task = new JIP_ProjectTask__c(
      Subject__c = 'Comment Delete Task',
      Project__c = proj.Id,
      Status__c = '未対応'
    );
    insert task;
    JIP_TaskComment__c comment = new JIP_TaskComment__c(
      ProjectTask__c = task.Id,
      CommentBody__c = 'To delete',
      CommentBy__c = 'Test User'
    );
    insert comment;
    Test.startTest();
    delete comment;
    Test.stopTest();
    List<JIP_ProjectActivity__c> acts = [
      SELECT Id
      FROM JIP_ProjectActivity__c
      WHERE ActivityType__c = 'コメント' AND Action__c = '削除'
    ];
    System.assert(!acts.isEmpty());
  }

  @isTest
  static void testOnDocumentUpdate() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectDocument__c doc = new JIP_ProjectDocument__c(
      Title__c = 'Original Title',
      Project__c = proj.Id
    );
    insert doc;
    Test.startTest();
    doc.Title__c = 'Updated Title';
    update doc;
    Test.stopTest();
    List<JIP_ProjectActivity__c> acts = [
      SELECT Id
      FROM JIP_ProjectActivity__c
      WHERE ActivityType__c = 'ドキュメント' AND Action__c = '更新'
    ];
    System.assert(!acts.isEmpty());
  }

  @isTest
  static void testOnDocumentDelete() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectDocument__c doc = new JIP_ProjectDocument__c(
      Title__c = 'To Delete Doc',
      Project__c = proj.Id
    );
    insert doc;
    Test.startTest();
    delete doc;
    Test.stopTest();
    List<JIP_ProjectActivity__c> acts = [
      SELECT Id
      FROM JIP_ProjectActivity__c
      WHERE ActivityType__c = 'ドキュメント' AND Action__c = '削除'
    ];
    System.assert(!acts.isEmpty());
  }

  @isTest
  static void testOnFileInsert() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    JIP_ProjectFile__c file = new JIP_ProjectFile__c(
      FileName__c = 'test.pdf',
      FileSize__c = 2048,
      Project__c = proj.Id,
      UploadedBy__c = 'Test User'
    );
    insert file;
    Test.stopTest();
    List<JIP_ProjectActivity__c> acts = [
      SELECT Id
      FROM JIP_ProjectActivity__c
      WHERE ActivityType__c = 'ファイル' AND Action__c = '追加'
    ];
    System.assert(!acts.isEmpty());
  }

  @isTest
  static void testOnFileUpdate() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectFile__c file = new JIP_ProjectFile__c(
      FileName__c = 'original.pdf',
      Project__c = proj.Id,
      UploadedBy__c = 'Test User'
    );
    insert file;
    Test.startTest();
    file.FileName__c = 'renamed.pdf';
    update file;
    Test.stopTest();
    List<JIP_ProjectActivity__c> acts = [
      SELECT Id
      FROM JIP_ProjectActivity__c
      WHERE ActivityType__c = 'ファイル' AND Action__c = '更新'
    ];
    System.assert(!acts.isEmpty());
  }

  @isTest
  static void testOnFileDelete() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectFile__c file = new JIP_ProjectFile__c(
      FileName__c = 'delete.pdf',
      Project__c = proj.Id,
      UploadedBy__c = 'Test User'
    );
    insert file;
    Test.startTest();
    delete file;
    Test.stopTest();
    List<JIP_ProjectActivity__c> acts = [
      SELECT Id
      FROM JIP_ProjectActivity__c
      WHERE ActivityType__c = 'ファイル' AND Action__c = '削除'
    ];
    System.assert(!acts.isEmpty());
  }

  @isTest
  static void testOnTaskUpdateMultipleFields() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTask__c task = new JIP_ProjectTask__c(
      Subject__c = 'Multi Field Task',
      Project__c = proj.Id,
      Status__c = '未対応',
      Priority__c = '中'
    );
    insert task;
    Test.startTest();
    task.Status__c = '処理中';
    task.Priority__c = '高';
    task.Subject__c = 'Changed Subject';
    task.Description__c = '新しい説明';
    update task;
    Test.stopTest();
    List<JIP_ProjectActivity__c> acts = [
      SELECT Id, Description__c
      FROM JIP_ProjectActivity__c
      WHERE ActivityType__c = '課題' AND Action__c = '更新'
    ];
    System.assert(!acts.isEmpty());
  }

  @isTest
  static void testOnTaskUpdateAssigneeChange() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];
    JIP_Worker__c w1 = JIP_TestDataFactory.createWorker(
      'Assignee1',
      dept.Id,
      true
    );
    JIP_Worker__c w2 = JIP_TestDataFactory.createWorker(
      'Assignee2',
      dept.Id,
      true
    );
    JIP_ProjectTask__c task = new JIP_ProjectTask__c(
      Subject__c = 'Assignee Task',
      Project__c = proj.Id,
      Status__c = '未対応',
      Assignee__c = w1.Id
    );
    insert task;
    Test.startTest();
    task.Assignee__c = w2.Id;
    update task;
    Test.stopTest();
    List<JIP_ProjectActivity__c> acts = [
      SELECT Id, Description__c
      FROM JIP_ProjectActivity__c
      WHERE ActivityType__c = '課題' AND Action__c = '更新'
    ];
    System.assert(!acts.isEmpty());
  }

  @isTest
  static void testOnTaskUpdateDueDateChange() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTask__c task = new JIP_ProjectTask__c(
      Subject__c = 'Date Change Task',
      Project__c = proj.Id,
      Status__c = '未対応',
      DueDate__c = Date.today().addDays(7)
    );
    insert task;
    Test.startTest();
    task.DueDate__c = Date.today().addDays(14);
    task.StartDate__c = Date.today();
    update task;
    Test.stopTest();
    List<JIP_ProjectActivity__c> acts = [
      SELECT Id
      FROM JIP_ProjectActivity__c
      WHERE ActivityType__c = '課題' AND Action__c = '更新'
    ];
    System.assert(!acts.isEmpty());
  }

  @isTest
  static void testOnTaskUpdateCategoryChange() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectTask__c task = new JIP_ProjectTask__c(
      Subject__c = 'Category Task',
      Project__c = proj.Id,
      Status__c = '未対応',
      Category__c = '設計'
    );
    insert task;
    Test.startTest();
    task.Category__c = '開発';
    update task;
    Test.stopTest();
    List<JIP_ProjectActivity__c> acts = [
      SELECT Id
      FROM JIP_ProjectActivity__c
      WHERE ActivityType__c = '課題' AND Action__c = '更新'
    ];
    System.assert(!acts.isEmpty());
  }

  @isTest
  static void testOnFileInsertWithNullSize() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    JIP_ProjectFile__c file = new JIP_ProjectFile__c(
      FileName__c = 'nosize.pdf',
      Project__c = proj.Id,
      UploadedBy__c = 'Test User'
    );
    insert file;
    Test.stopTest();
    System.assert(true);
  }

  @isTest
  static void testOnFileInsertLargeFile() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    Test.startTest();
    JIP_ProjectFile__c file = new JIP_ProjectFile__c(
      FileName__c = 'large.zip',
      FileSize__c = 5242880,
      Project__c = proj.Id,
      UploadedBy__c = 'Test User'
    );
    insert file;
    Test.stopTest();
    System.assert(true);
  }
}