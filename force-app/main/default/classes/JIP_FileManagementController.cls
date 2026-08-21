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
public with sharing class JIP_FileManagementController {
  // Project selection
  public Id selectedProjectId { get; set; }
  public List<JIP_Project__c> projectList { get; set; }

  // Current folder
  public Id currentFolderId { get; set; }
  public JIP_ProjectFile__c currentFolder { get; set; }

  // Files & folders in current view
  public List<JIP_ProjectFile__c> fileList { get; set; }

  // Breadcrumb
  public String breadcrumbJson { get; set; }

  // Search
  public String searchKeyword { get; set; }
  public Boolean isSearchMode { get; set; }
  public List<JIP_ProjectFile__c> searchResults { get; set; }

  // New folder
  public String newFolderName { get; set; }
  public Boolean showNewFolderModal { get; set; }

  // Rename
  public Id renameItemId { get; set; }
  public String renameNewName { get; set; }
  public Boolean showRenameModal { get; set; }

  // Delete
  public Id deleteItemId { get; set; }

  // File upload
  public transient Blob uploadFileBody { get; set; }
  public String uploadFileName { get; set; }

  // Move
  public Id moveItemId { get; set; }
  public Id moveTargetFolderId { get; set; }
  public Boolean showMoveModal { get; set; }
  public List<JIP_ProjectFile__c> allFolders { get; set; }

  public JIP_FileManagementController() {
    projectList = [
      SELECT Id, Name, Name__c, Status__c, Language__c
      FROM JIP_Project__c
      ORDER BY Name ASC
      LIMIT 200
    ];
    showNewFolderModal = false;
    showRenameModal = false;
    showMoveModal = false;
    isSearchMode = false;
    searchKeyword = '';
    newFolderName = '';
    renameNewName = '';
    fileList = new List<JIP_ProjectFile__c>();
    searchResults = new List<JIP_ProjectFile__c>();
    allFolders = new List<JIP_ProjectFile__c>();
    breadcrumbJson = '[]';

    String pid = ApexPages.currentPage().getParameters().get('projectId');
    if (String.isNotBlank(pid)) {
      try {
        selectedProjectId = (Id) pid;
      } catch (Exception e) {
        selectedProjectId = null;
      }
    }
    if (selectedProjectId == null && !projectList.isEmpty()) {
      selectedProjectId = projectList[0].Id;
    }

    String fid = ApexPages.currentPage().getParameters().get('folderId');
    if (String.isNotBlank(fid)) {
      try {
        currentFolderId = (Id) fid;
      } catch (Exception e) {
        currentFolderId = null;
      }
    }

    loadFiles();
  }

  // ===== Option Getters =====
  public List<SelectOption> getProjectOptions() {
    List<SelectOption> opts = new List<SelectOption>();
    for (JIP_Project__c p : projectList) {
      String label = p.Name__c != null ? p.Name__c : p.Name;
      opts.add(new SelectOption(p.Id, label));
    }
    return opts;
  }

  public String getSelectedProjectName() {
    if (selectedProjectId == null) {
      return '';
    }
    for (JIP_Project__c p : projectList) {
      if (p.Id == selectedProjectId) {
        return p.Name__c != null ? p.Name__c : p.Name;
      }
    }
    return '';
  }

  public String getCurrentFolderIdStr() {
    return currentFolderId != null ? String.valueOf(currentFolderId) : '';
  }

  // ===== Actions =====
  public void selectProject() {
    currentFolderId = null;
    currentFolder = null;
    isSearchMode = false;
    searchKeyword = '';
    loadFiles();
  }

  public void navigateToFolder() {
    isSearchMode = false;
    searchKeyword = '';
    loadCurrentFolder();
    loadFiles();
  }

  public void navigateToRoot() {
    currentFolderId = null;
    currentFolder = null;
    isSearchMode = false;
    searchKeyword = '';
    loadFiles();
  }

  // Create folder
  public void openNewFolderModal() {
    newFolderName = '';
    showNewFolderModal = true;
  }

  public void closeNewFolderModal() {
    showNewFolderModal = false;
    newFolderName = '';
  }

  public void createFolder() {
    if (selectedProjectId == null || String.isBlank(newFolderName)) {
      return;
    }
    try {
      JIP_ProjectFile__c folder = new JIP_ProjectFile__c(
        FileName__c = newFolderName.trim(),
        IsFolder__c = true,
        Project__c = selectedProjectId,
        ParentFolder__c = currentFolderId,
        UploadedBy__c = UserInfo.getName()
      );
      insert folder;
      showNewFolderModal = false;
      newFolderName = '';
      loadFiles();
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'フォルダ作成エラー: ' + e.getMessage()
        )
      );
    }
  }

  // Upload file
  public void uploadFile() {
    if (
      selectedProjectId == null ||
      uploadFileBody == null ||
      String.isBlank(uploadFileName)
    ) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.WARNING,
          'ファイルを選択してください。'
        )
      );
      return;
    }
    try {
      // Determine file type from extension
      String fileType = '';
      if (uploadFileName.contains('.')) {
        fileType = uploadFileName.substringAfterLast('.').toLowerCase();
      }

      // Create ContentVersion (Salesforce File)
      ContentVersion cv = new ContentVersion(
        Title = uploadFileName,
        PathOnClient = uploadFileName,
        VersionData = uploadFileBody
      );
      insert cv;

      // Get ContentDocumentId
      cv = [
        SELECT Id, ContentDocumentId
        FROM ContentVersion
        WHERE Id = :cv.Id
        LIMIT 1
      ];

      // Create file record
      JIP_ProjectFile__c fileRec = new JIP_ProjectFile__c(
        FileName__c = uploadFileName,
        IsFolder__c = false,
        Project__c = selectedProjectId,
        ParentFolder__c = currentFolderId,
        FileSize__c = uploadFileBody.size(),
        FileType__c = fileType,
        ContentVersionId__c = cv.Id,
        UploadedBy__c = UserInfo.getName()
      );
      insert fileRec;

      uploadFileBody = null;
      uploadFileName = '';
      loadFiles();
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'アップロードエラー: ' + e.getMessage()
        )
      );
    }
  }

  // Rename
  public void openRenameModal() {
    if (renameItemId == null) {
      return;
    }
    List<JIP_ProjectFile__c> items = [
      SELECT Id, FileName__c
      FROM JIP_ProjectFile__c
      WHERE Id = :renameItemId
      LIMIT 1
    ];
    if (!items.isEmpty()) {
      renameNewName = items[0].FileName__c;
      showRenameModal = true;
    }
  }

  public void closeRenameModal() {
    showRenameModal = false;
    renameNewName = '';
    renameItemId = null;
  }

  public void renameItem() {
    if (renameItemId == null || String.isBlank(renameNewName)) {
      return;
    }
    try {
      JIP_ProjectFile__c item = new JIP_ProjectFile__c(
        Id = renameItemId,
        FileName__c = renameNewName.trim()
      );
      update item;
      showRenameModal = false;
      renameNewName = '';
      renameItemId = null;
      loadFiles();
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          '名前変更エラー: ' + e.getMessage()
        )
      );
    }
  }

  // Delete
  public void deleteItem() {
    if (deleteItemId == null) {
      return;
    }
    try {
      // Check if folder has children
      JIP_ProjectFile__c item = [
        SELECT Id, IsFolder__c, ContentVersionId__c
        FROM JIP_ProjectFile__c
        WHERE Id = :deleteItemId
        LIMIT 1
      ];
      if (item.IsFolder__c) {
        Integer childCount = [
          SELECT COUNT()
          FROM JIP_ProjectFile__c
          WHERE ParentFolder__c = :deleteItemId
        ];
        if (childCount > 0) {
          ApexPages.addMessage(
            new ApexPages.Message(
              ApexPages.Severity.WARNING,
              'フォルダにファイルが含まれているため削除できません。先に中のファイルを削除してください。'
            )
          );
          return;
        }
      }
      // Delete ContentDocument if exists
      if (String.isNotBlank(item.ContentVersionId__c)) {
        try {
          ContentVersion cv = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :item.ContentVersionId__c
            LIMIT 1
          ];
          if (cv != null) {
            delete [
              SELECT Id
              FROM ContentDocument
              WHERE Id = :cv.ContentDocumentId
            ];
          }
        } catch (Exception ex) {
          // ContentVersion may already be deleted
        }
      }
      delete item;
      deleteItemId = null;
      loadFiles();
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          '削除エラー: ' + e.getMessage()
        )
      );
    }
  }

  // Move
  public void openMoveModal() {
    if (moveItemId == null) {
      return;
    }
    showMoveModal = true;
    moveTargetFolderId = null;
    loadAllFolders();
  }

  public void closeMoveModal() {
    showMoveModal = false;
    moveItemId = null;
    moveTargetFolderId = null;
  }

  public void moveItem() {
    if (moveItemId == null) {
      return;
    }
    try {
      JIP_ProjectFile__c item = new JIP_ProjectFile__c(
        Id = moveItemId,
        ParentFolder__c = moveTargetFolderId
      );
      update item;
      showMoveModal = false;
      moveItemId = null;
      moveTargetFolderId = null;
      loadFiles();
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          '移動エラー: ' + e.getMessage()
        )
      );
    }
  }

  public List<SelectOption> getMoveTargetOptions() {
    List<SelectOption> opts = new List<SelectOption>();
    opts.add(new SelectOption('', 'ルート（最上位）'));
    for (JIP_ProjectFile__c f : allFolders) {
      if (f.Id != moveItemId) {
        opts.add(new SelectOption(f.Id, f.FileName__c));
      }
    }
    return opts;
  }

  // Search
  public void searchFiles() {
    if (String.isBlank(searchKeyword)) {
      isSearchMode = false;
      loadFiles();
      return;
    }
    isSearchMode = true;
    String likeKey =
      '%' +
      String.escapeSingleQuotes(searchKeyword.trim()) +
      '%';
    searchResults = [
      SELECT
        Id,
        Name,
        FileName__c,
        IsFolder__c,
        FileSize__c,
        FileType__c,
        ContentVersionId__c,
        ParentFolder__c,
        ParentFolder__r.FileName__c,
        UploadedBy__c,
        CreatedDate,
        LastModifiedDate
      FROM JIP_ProjectFile__c
      WHERE Project__c = :selectedProjectId AND FileName__c LIKE :likeKey
      ORDER BY IsFolder__c DESC, FileName__c ASC
      LIMIT 200
    ];
  }

  public void clearSearch() {
    searchKeyword = '';
    isSearchMode = false;
    loadFiles();
  }

  // Download URL helper
  public String getDownloadUrl() {
    return '/sfc/servlet.shepherd/version/download/';
  }

  // ===== Data Loading =====
  private void loadFiles() {
    if (selectedProjectId == null) {
      fileList = new List<JIP_ProjectFile__c>();
      breadcrumbJson = '[]';
      return;
    }

    if (currentFolderId != null) {
      loadCurrentFolder();
    } else {
      currentFolder = null;
    }

    fileList = [
      SELECT
        Id,
        Name,
        FileName__c,
        IsFolder__c,
        FileSize__c,
        FileType__c,
        ContentVersionId__c,
        ParentFolder__c,
        UploadedBy__c,
        CreatedDate,
        LastModifiedDate
      FROM JIP_ProjectFile__c
      WHERE
        Project__c = :selectedProjectId
        AND ParentFolder__c = :currentFolderId
      ORDER BY IsFolder__c DESC, FileName__c ASC
      LIMIT 500
    ];

    buildBreadcrumb();
  }

  private void loadCurrentFolder() {
    if (currentFolderId == null) {
      currentFolder = null;
      return;
    }
    List<JIP_ProjectFile__c> folders = [
      SELECT Id, FileName__c, ParentFolder__c
      FROM JIP_ProjectFile__c
      WHERE Id = :currentFolderId AND IsFolder__c = TRUE
      LIMIT 1
    ];
    if (!folders.isEmpty()) {
      currentFolder = folders[0];
    } else {
      currentFolderId = null;
      currentFolder = null;
    }
  }

  private void loadAllFolders() {
    if (selectedProjectId == null) {
      allFolders = new List<JIP_ProjectFile__c>();
      return;
    }
    allFolders = [
      SELECT Id, FileName__c, ParentFolder__c
      FROM JIP_ProjectFile__c
      WHERE Project__c = :selectedProjectId AND IsFolder__c = TRUE
      ORDER BY FileName__c ASC
      LIMIT 200
    ];
  }

  private void buildBreadcrumb() {
    List<Map<String, String>> crumbs = new List<Map<String, String>>();

    if (currentFolderId == null) {
      breadcrumbJson = '[]';
      return;
    }

    // Load all folders for this project to walk up the chain
    Map<Id, JIP_ProjectFile__c> folderMap = new Map<Id, JIP_ProjectFile__c>();
    List<JIP_ProjectFile__c> allProjectFolders = [
      SELECT Id, FileName__c, ParentFolder__c
      FROM JIP_ProjectFile__c
      WHERE Project__c = :selectedProjectId AND IsFolder__c = TRUE
      LIMIT 500
    ];
    for (JIP_ProjectFile__c f : allProjectFolders) {
      folderMap.put(f.Id, f);
    }

    // Walk up
    Id cid = currentFolderId;
    Integer safety = 0;
    while (cid != null && safety < 10) {
      JIP_ProjectFile__c f = folderMap.get(cid);
      if (f == null)
        break;
      Map<String, String> crumb = new Map<String, String>();
      crumb.put('id', String.valueOf(f.Id));
      crumb.put('name', f.FileName__c);
      crumbs.add(crumb);
      cid = f.ParentFolder__c;
      safety++;
    }

    // Reverse
    List<Map<String, String>> reversed = new List<Map<String, String>>();
    for (Integer i = crumbs.size() - 1; i >= 0; i--) {
      reversed.add(crumbs[i]);
    }
    breadcrumbJson = JSON.serialize(reversed);
  }

  // Format file size
  public static String formatFileSize(Decimal sizeBytes) {
    if (sizeBytes == null || sizeBytes == 0)
      return '';
    if (sizeBytes < 1024)
      return sizeBytes.intValue() + ' B';
    if (sizeBytes < 1048576)
      return (sizeBytes / 1024).setScale(1, RoundingMode.HALF_UP) + ' KB';
    if (sizeBytes < 1073741824)
      return (sizeBytes / 1048576).setScale(1, RoundingMode.HALF_UP) + ' MB';
    return (sizeBytes / 1073741824).setScale(2, RoundingMode.HALF_UP) + ' GB';
  }

  // For VF page: Get file items with formatted size
  public List<FileWrapper> getFileWrappers() {
    List<FileWrapper> wrappers = new List<FileWrapper>();
    String lang = getLanguage();
    for (JIP_ProjectFile__c f : fileList) {
      wrappers.add(new FileWrapper(f, lang));
    }
    return wrappers;
  }

  public List<FileWrapper> getSearchWrappers() {
    List<FileWrapper> wrappers = new List<FileWrapper>();
    String lang = getLanguage();
    for (JIP_ProjectFile__c f : searchResults) {
      wrappers.add(new FileWrapper(f, lang));
    }
    return wrappers;
  }

  // Wrapper class
  public class FileWrapper {
    public JIP_ProjectFile__c file { get; set; }
    public String formattedSize { get; set; }
    public String fileIcon { get; set; }
    public String displayType { get; set; }

    public FileWrapper(JIP_ProjectFile__c f, String lang) {
      this.file = f;
      this.formattedSize = formatFileSize(f.FileSize__c);
      this.fileIcon = getIconForType(f);
      if (f.IsFolder__c) {
        this.displayType = JIP_TranslationHelper.get('folder', lang);
      } else {
        this.displayType = f.FileType__c;
      }
    }

    private String getIconForType(JIP_ProjectFile__c f) {
      if (f.IsFolder__c)
        return '\uD83D\uDCC1'; // folder icon
      String ext = f.FileType__c != null ? f.FileType__c.toLowerCase() : '';
      if (ext == 'pdf')
        return '\uD83D\uDCC4';
      if (ext == 'doc' || ext == 'docx')
        return '\uD83D\uDCC4';
      if (ext == 'xls' || ext == 'xlsx' || ext == 'csv')
        return '\uD83D\uDCC4';
      if (ext == 'ppt' || ext == 'pptx')
        return '\uD83D\uDCC4';
      if (
        ext == 'jpg' ||
        ext == 'jpeg' ||
        ext == 'png' ||
        ext == 'gif' ||
        ext == 'svg' ||
        ext == 'bmp'
      )
        return '\uD83D\uDDBC';
      if (
        ext == 'zip' ||
        ext == 'rar' ||
        ext == '7z' ||
        ext == 'tar' ||
        ext == 'gz'
      )
        return '\uD83D\uDDDC';
      if (ext == 'mp4' || ext == 'avi' || ext == 'mov' || ext == 'wmv')
        return '\uD83C\uDFA5';
      if (ext == 'mp3' || ext == 'wav' || ext == 'flac')
        return '\uD83C\uDFB5';
      if (ext == 'txt' || ext == 'log')
        return '\uD83D\uDCC4';
      if (
        ext == 'html' ||
        ext == 'css' ||
        ext == 'js' ||
        ext == 'json' ||
        ext == 'xml'
      )
        return '\uD83D\uDCC4';
      return '\uD83D\uDCC4'; // default file icon
    }
  }

  // ===== Multi-language support =====
  public String getLanguage() {
    if (selectedProjectId == null)
      return 'ja';
    for (JIP_Project__c p : projectList) {
      if (p.Id == selectedProjectId) {
        return String.isBlank(p.Language__c) ? 'ja' : p.Language__c;
      }
    }
    return 'ja';
  }

  public Map<String, String> getT() {
    return JIP_TranslationHelper.getAllTranslations(getLanguage());
  }
}