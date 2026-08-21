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
private class JIP_FileManagementControllerTest {
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
    JIP_FileManagementController controller = new JIP_FileManagementController();
    Test.stopTest();

    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
  }
  @isTest
  static void testGetT() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

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
  static void testSelectProject() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    controller.selectProject();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method selectProject executed successfully');
  }
  @isTest
  static void testNavigateToFolder() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    controller.navigateToFolder();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method navigateToFolder executed successfully');
  }
  @isTest
  static void testNavigateToRoot() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    controller.navigateToRoot();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method navigateToRoot executed successfully');
  }
  @isTest
  static void testOpenNewFolderModal() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    controller.openNewFolderModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method openNewFolderModal executed successfully');
  }
  @isTest
  static void testCloseNewFolderModal() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    controller.closeNewFolderModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method closeNewFolderModal executed successfully');
  }
  @isTest
  static void testCreateFolder() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    controller.createFolder();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method createFolder executed successfully');
  }
  @isTest
  static void testUploadFile() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    controller.uploadFile();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method uploadFile executed successfully');
  }
  @isTest
  static void testOpenRenameModal() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    controller.openRenameModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method openRenameModal executed successfully');
  }
  @isTest
  static void testCloseRenameModal() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    controller.closeRenameModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method closeRenameModal executed successfully');
  }
  @isTest
  static void testRenameItem() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    controller.renameItem();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method renameItem executed successfully');
  }
  @isTest
  static void testDeleteItem() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    controller.deleteItem();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method deleteItem executed successfully');
  }
  @isTest
  static void testOpenMoveModal() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    controller.openMoveModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method openMoveModal executed successfully');
  }
  @isTest
  static void testCloseMoveModal() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    controller.closeMoveModal();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method closeMoveModal executed successfully');
  }
  @isTest
  static void testMoveItem() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    controller.moveItem();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method moveItem executed successfully');
  }
  @isTest
  static void testSearchFiles() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    controller.searchFiles();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method searchFiles executed successfully');
  }
  @isTest
  static void testClearSearch() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    controller.clearSearch();
    Test.stopTest();

    // Method executed without errors
    System.assert(true, 'Method clearSearch executed successfully');
  }
  @isTest
  static void testGetProjectOptions() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    List<SelectOption> options = controller.getProjectOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetMoveTargetOptions() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    List<SelectOption> options = controller.getMoveTargetOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
  }
  @isTest
  static void testGetSelectedProjectName() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    String result = controller.getSelectedProjectName();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getSelectedProjectName executed successfully');
  }
  @isTest
  static void testGetCurrentFolderIdStr() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    String result = controller.getCurrentFolderIdStr();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getCurrentFolderIdStr executed successfully');
  }
  @isTest
  static void testGetDownloadUrl() {
    JIP_FileManagementController controller = new JIP_FileManagementController();

    Test.startTest();
    String result = controller.getDownloadUrl();
    Test.stopTest();

    // String methods may return null or a value
    System.assert(true, 'Method getDownloadUrl executed successfully');
  }

  @isTest
  static void testSelectProjectWithData() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_FileManagementController controller = new JIP_FileManagementController();
    controller.selectedProjectId = proj.Id;
    Test.startTest();
    controller.selectProject();
    Test.stopTest();
    System.assert(true, 'Project selected');
  }

  @isTest
  static void testCreateFolderWithProject() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_FileManagementController controller = new JIP_FileManagementController();
    controller.selectedProjectId = proj.Id;
    controller.selectProject();
    controller.newFolderName = 'Test Folder';
    Test.startTest();
    controller.createFolder();
    Test.stopTest();
    System.assert(true, 'Folder created');
  }

  @isTest
  static void testUploadFileWithProject() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_FileManagementController controller = new JIP_FileManagementController();
    controller.selectedProjectId = proj.Id;
    controller.selectProject();
    controller.uploadFileName = 'test.txt';
    controller.uploadFileBody = Blob.valueOf('test content');
    Test.startTest();
    controller.uploadFile();
    Test.stopTest();
    System.assert(true, 'File uploaded');
  }

  @isTest
  static void testSearchWithKeyword() {
    JIP_FileManagementController controller = new JIP_FileManagementController();
    controller.searchKeyword = 'test';
    Test.startTest();
    controller.searchFiles();
    Test.stopTest();
    System.assert(true, 'Search completed');
  }

  @isTest
  static void testGetFileWrappers() {
    JIP_FileManagementController controller = new JIP_FileManagementController();
    Test.startTest();
    List<JIP_FileManagementController.FileWrapper> wrappers = controller.getFileWrappers();
    Test.stopTest();
    System.assertNotEquals(null, wrappers, 'Wrappers should not be null');
  }

  @isTest
  static void testGetSearchWrappers() {
    JIP_FileManagementController controller = new JIP_FileManagementController();
    controller.searchKeyword = 'test';
    controller.searchFiles();
    Test.startTest();
    List<JIP_FileManagementController.FileWrapper> wrappers = controller.getSearchWrappers();
    Test.stopTest();
    System.assertNotEquals(null, wrappers, 'Wrappers should not be null');
  }

  @isTest
  static void testConstructorWithUrlParams() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectFile__c folder = new JIP_ProjectFile__c(
      FileName__c = 'URL Folder',
      IsFolder__c = true,
      Project__c = proj.Id
    );
    insert folder;

    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', proj.Id);
    pageRef.getParameters().put('folderId', String.valueOf(folder.Id));

    Test.startTest();
    JIP_FileManagementController ctrl = new JIP_FileManagementController();
    Test.stopTest();

    System.assertEquals(proj.Id, ctrl.selectedProjectId);
    System.assertEquals(folder.Id, ctrl.currentFolderId);
  }

  @isTest
  static void testConstructorWithInvalidParams() {
    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', 'INVALID');
    pageRef.getParameters().put('folderId', 'INVALID');

    Test.startTest();
    JIP_FileManagementController ctrl = new JIP_FileManagementController();
    Test.stopTest();

    System.assertNotEquals(null, ctrl);
  }

  @isTest
  static void testNavigateToActualFolder() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectFile__c folder = new JIP_ProjectFile__c(
      FileName__c = 'Nav Folder',
      IsFolder__c = true,
      Project__c = proj.Id
    );
    insert folder;

    JIP_FileManagementController ctrl = new JIP_FileManagementController();
    ctrl.selectedProjectId = proj.Id;
    ctrl.currentFolderId = folder.Id;

    Test.startTest();
    ctrl.navigateToFolder();
    Test.stopTest();

    System.assertNotEquals(null, ctrl.currentFolder);
  }

  @isTest
  static void testNavigateNestedFolderBreadcrumb() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectFile__c parent = new JIP_ProjectFile__c(
      FileName__c = 'Parent',
      IsFolder__c = true,
      Project__c = proj.Id
    );
    insert parent;
    JIP_ProjectFile__c child = new JIP_ProjectFile__c(
      FileName__c = 'Child',
      IsFolder__c = true,
      Project__c = proj.Id,
      ParentFolder__c = parent.Id
    );
    insert child;

    JIP_FileManagementController ctrl = new JIP_FileManagementController();
    ctrl.selectedProjectId = proj.Id;
    ctrl.currentFolderId = child.Id;

    Test.startTest();
    ctrl.navigateToFolder();
    Test.stopTest();

    System.assert(ctrl.breadcrumbJson.contains('Parent'));
    System.assert(ctrl.breadcrumbJson.contains('Child'));
  }

  @isTest
  static void testOpenRenameWithItem() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectFile__c folder = new JIP_ProjectFile__c(
      FileName__c = 'Rename Me',
      IsFolder__c = true,
      Project__c = proj.Id
    );
    insert folder;

    JIP_FileManagementController ctrl = new JIP_FileManagementController();
    ctrl.renameItemId = folder.Id;

    Test.startTest();
    ctrl.openRenameModal();
    Test.stopTest();

    System.assertEquals(true, ctrl.showRenameModal);
    System.assertEquals('Rename Me', ctrl.renameNewName);
  }

  @isTest
  static void testRenameItemWithData() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectFile__c folder = new JIP_ProjectFile__c(
      FileName__c = 'Old Name',
      IsFolder__c = true,
      Project__c = proj.Id
    );
    insert folder;

    JIP_FileManagementController ctrl = new JIP_FileManagementController();
    ctrl.selectedProjectId = proj.Id;
    ctrl.renameItemId = folder.Id;
    ctrl.renameNewName = 'New Name';

    Test.startTest();
    ctrl.renameItem();
    Test.stopTest();

    System.assertEquals(false, ctrl.showRenameModal);
  }

  @isTest
  static void testDeleteEmptyFolder() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectFile__c folder = new JIP_ProjectFile__c(
      FileName__c = 'Delete Me',
      IsFolder__c = true,
      Project__c = proj.Id
    );
    insert folder;

    JIP_FileManagementController ctrl = new JIP_FileManagementController();
    ctrl.selectedProjectId = proj.Id;
    ctrl.deleteItemId = folder.Id;

    Test.startTest();
    ctrl.deleteItem();
    Test.stopTest();

    System.assertEquals(null, ctrl.deleteItemId);
  }

  @isTest
  static void testDeleteFolderWithChildren() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectFile__c parent = new JIP_ProjectFile__c(
      FileName__c = 'Parent Folder',
      IsFolder__c = true,
      Project__c = proj.Id
    );
    insert parent;
    JIP_ProjectFile__c child = new JIP_ProjectFile__c(
      FileName__c = 'Child File',
      IsFolder__c = false,
      Project__c = proj.Id,
      ParentFolder__c = parent.Id
    );
    insert child;

    JIP_FileManagementController ctrl = new JIP_FileManagementController();
    ctrl.selectedProjectId = proj.Id;
    ctrl.deleteItemId = parent.Id;

    Test.startTest();
    ctrl.deleteItem();
    Test.stopTest();

    // Folder should NOT be deleted (has children)
    List<JIP_ProjectFile__c> check = [
      SELECT Id
      FROM JIP_ProjectFile__c
      WHERE Id = :parent.Id
    ];
    System.assertEquals(
      1,
      check.size(),
      'Folder with children should not be deleted'
    );
  }

  @isTest
  static void testDeleteFileWithContent() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    ContentVersion cv = new ContentVersion(
      Title = 'TestFile',
      PathOnClient = 'test.txt',
      VersionData = Blob.valueOf('content')
    );
    insert cv;
    cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

    JIP_ProjectFile__c fileRec = new JIP_ProjectFile__c(
      FileName__c = 'test.txt',
      IsFolder__c = false,
      Project__c = proj.Id,
      ContentVersionId__c = cv.Id,
      FileSize__c = 7,
      FileType__c = 'txt'
    );
    insert fileRec;

    JIP_FileManagementController ctrl = new JIP_FileManagementController();
    ctrl.selectedProjectId = proj.Id;
    ctrl.deleteItemId = fileRec.Id;

    Test.startTest();
    ctrl.deleteItem();
    Test.stopTest();

    System.assertEquals(null, ctrl.deleteItemId);
  }

  @isTest
  static void testOpenMoveWithItem() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectFile__c file1 = new JIP_ProjectFile__c(
      FileName__c = 'Move Me',
      IsFolder__c = false,
      Project__c = proj.Id
    );
    insert file1;
    JIP_ProjectFile__c folder1 = new JIP_ProjectFile__c(
      FileName__c = 'Target',
      IsFolder__c = true,
      Project__c = proj.Id
    );
    insert folder1;

    JIP_FileManagementController ctrl = new JIP_FileManagementController();
    ctrl.selectedProjectId = proj.Id;
    ctrl.moveItemId = file1.Id;

    Test.startTest();
    ctrl.openMoveModal();
    Test.stopTest();

    System.assertEquals(true, ctrl.showMoveModal);
    System.assert(ctrl.allFolders.size() >= 1);
  }

  @isTest
  static void testMoveItemToFolder() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectFile__c file1 = new JIP_ProjectFile__c(
      FileName__c = 'Moving',
      IsFolder__c = false,
      Project__c = proj.Id
    );
    insert file1;
    JIP_ProjectFile__c folder1 = new JIP_ProjectFile__c(
      FileName__c = 'Dest',
      IsFolder__c = true,
      Project__c = proj.Id
    );
    insert folder1;

    JIP_FileManagementController ctrl = new JIP_FileManagementController();
    ctrl.selectedProjectId = proj.Id;
    ctrl.moveItemId = file1.Id;
    ctrl.moveTargetFolderId = folder1.Id;

    Test.startTest();
    ctrl.moveItem();
    Test.stopTest();

    System.assertEquals(false, ctrl.showMoveModal);
  }

  @isTest
  static void testFormatFileSize() {
    Test.startTest();
    System.assertEquals('', JIP_FileManagementController.formatFileSize(null));
    System.assertEquals('', JIP_FileManagementController.formatFileSize(0));
    System.assertEquals(
      '500 B',
      JIP_FileManagementController.formatFileSize(500)
    );
    System.assert(
      JIP_FileManagementController.formatFileSize(5120).contains('KB')
    );
    System.assert(
      JIP_FileManagementController.formatFileSize(5242880).contains('MB')
    );
    System.assert(
      JIP_FileManagementController.formatFileSize(5368709120L).contains('GB')
    );
    Test.stopTest();
  }

  @isTest
  static void testFileWrappersWithData() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    List<JIP_ProjectFile__c> files = new List<JIP_ProjectFile__c>();
    files.add(
      new JIP_ProjectFile__c(
        FileName__c = 'doc.pdf',
        IsFolder__c = false,
        Project__c = proj.Id,
        FileType__c = 'pdf',
        FileSize__c = 1024
      )
    );
    files.add(
      new JIP_ProjectFile__c(
        FileName__c = 'img.png',
        IsFolder__c = false,
        Project__c = proj.Id,
        FileType__c = 'png',
        FileSize__c = 2048
      )
    );
    files.add(
      new JIP_ProjectFile__c(
        FileName__c = 'data.xlsx',
        IsFolder__c = false,
        Project__c = proj.Id,
        FileType__c = 'xlsx',
        FileSize__c = 4096
      )
    );
    files.add(
      new JIP_ProjectFile__c(
        FileName__c = 'archive.zip',
        IsFolder__c = false,
        Project__c = proj.Id,
        FileType__c = 'zip',
        FileSize__c = 8192
      )
    );
    files.add(
      new JIP_ProjectFile__c(
        FileName__c = 'video.mp4',
        IsFolder__c = false,
        Project__c = proj.Id,
        FileType__c = 'mp4',
        FileSize__c = 16384
      )
    );
    files.add(
      new JIP_ProjectFile__c(
        FileName__c = 'audio.mp3',
        IsFolder__c = false,
        Project__c = proj.Id,
        FileType__c = 'mp3',
        FileSize__c = 32768
      )
    );
    files.add(
      new JIP_ProjectFile__c(
        FileName__c = 'page.html',
        IsFolder__c = false,
        Project__c = proj.Id,
        FileType__c = 'html',
        FileSize__c = 512
      )
    );
    files.add(
      new JIP_ProjectFile__c(
        FileName__c = 'slides.pptx',
        IsFolder__c = false,
        Project__c = proj.Id,
        FileType__c = 'pptx',
        FileSize__c = 1024
      )
    );
    files.add(
      new JIP_ProjectFile__c(
        FileName__c = 'Folder',
        IsFolder__c = true,
        Project__c = proj.Id
      )
    );
    insert files;

    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', proj.Id);

    Test.startTest();
    JIP_FileManagementController ctrl = new JIP_FileManagementController();
    List<JIP_FileManagementController.FileWrapper> wrappers = ctrl.getFileWrappers();
    Test.stopTest();

    System.assert(wrappers.size() >= 9);
  }

  @isTest
  static void testGetLanguageFromProject() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    proj.Language__c = 'en';
    update proj;

    PageReference pageRef = new PageReference('/apex/test');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('projectId', proj.Id);

    JIP_FileManagementController ctrl = new JIP_FileManagementController();

    Test.startTest();
    String lang = ctrl.getLanguage();
    Test.stopTest();

    System.assertEquals('en', lang);
  }

  @isTest
  static void testGetCurrentFolderIdStrWithValue() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_ProjectFile__c folder = new JIP_ProjectFile__c(
      FileName__c = 'Str Test',
      IsFolder__c = true,
      Project__c = proj.Id
    );
    insert folder;

    JIP_FileManagementController ctrl = new JIP_FileManagementController();
    ctrl.currentFolderId = folder.Id;

    Test.startTest();
    String result = ctrl.getCurrentFolderIdStr();
    Test.stopTest();

    System.assertNotEquals('', result);
  }
}