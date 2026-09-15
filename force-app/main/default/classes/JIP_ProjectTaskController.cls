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
public with sharing class JIP_ProjectTaskController {
  // Project selection
  public Id selectedProjectId { get; set; }
  public List<JIP_Project__c> projectList { get; set; }

  // Filters
  public String filterStatus { get; set; }
  public String filterType { get; set; }
  public String filterCategory { get; set; }
  public String filterMilestone { get; set; }
  public Id filterAssignee { get; set; }
  public String filterKeyword { get; set; }

  // Tasks
  public List<JIP_ProjectTask__c> taskList { get; set; }
  public Integer taskCount { get; set; }

  // CRUD
  public JIP_ProjectTask__c currentTask { get; set; }
  public Boolean showModal { get; set; }
  public Boolean isEditMode { get; set; }
  public Id deleteTaskId { get; set; }

  // Summary counts
  public Integer countAll { get; set; }
  public Integer countOpen { get; set; }
  public Integer countInProgress { get; set; }
  public Integer countResolved { get; set; }
  public Integer countClosed { get; set; }

  // Mass import
  public Boolean showMassImportModal { get; set; }
  public Boolean showMassImportConfirmModal { get; set; }
  public Blob importFileBody { get; set; }
  public String importFileName { get; set; }
  public Id uploadedContentVersionId { get; set; }
  public String uploadedFileName { get; set; }
  public String selectedFileName { get; set; }
  public Boolean showMassImportStartedModal { get; set; }

  // Language support
  public String getLanguage() {
    if (selectedProjectId == null) {
      return 'ja';
    }
    for (JIP_Project__c p : projectList) {
      if (p.Id == selectedProjectId && String.isNotBlank(p.Language__c)) {
        return p.Language__c;
      }
    }
    return 'ja';
  }

  public Map<String, String> getT() {
    return JIP_TranslationHelper.getAllTranslations(getLanguage());
  }

  public JIP_ProjectTaskController() {
    projectList = [
      SELECT Id, Name, Name__c, Status__c, Language__c
      FROM JIP_Project__c
      ORDER BY Name ASC
      LIMIT 200
    ];
    filterStatus = 'すべて';
    filterType = '';
    filterCategory = '';
    filterMilestone = '';
    filterKeyword = '';
    showModal = false;
    showMassImportModal = false;
    showMassImportModal = false;
    isEditMode = false;

    // Check URL param for projectId
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
    loadTasks();
  }

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

  public List<SelectOption> getTypeOptions() {
    List<SelectOption> opts = new List<SelectOption>();
    opts.add(new SelectOption('', '--'));
    opts.add(new SelectOption('基本操作', '基本操作'));
    opts.add(new SelectOption('プロジェクト設定', 'プロジェクト設定'));
    opts.add(new SelectOption('バグ', 'バグ'));
    opts.add(new SelectOption('要望', '要望'));
    opts.add(new SelectOption('タスク', 'タスク'));
    opts.add(new SelectOption('その他', 'その他'));
    return opts;
  }

  public List<SelectOption> getCategoryOptions() {
    List<SelectOption> opts = new List<SelectOption>();
    opts.add(new SelectOption('', '--'));
    opts.add(new SelectOption('設計', '設計'));
    opts.add(new SelectOption('開発', '開発'));
    opts.add(new SelectOption('テスト', 'テスト'));
    opts.add(new SelectOption('ドキュメント', 'ドキュメント'));
    opts.add(new SelectOption('環境構築', '環境構築'));
    opts.add(new SelectOption('その他', 'その他'));
    return opts;
  }

  public List<SelectOption> getAssigneeOptions() {
    List<SelectOption> opts = new List<SelectOption>();
    opts.add(new SelectOption('', '--'));
    List<JIP_Worker__c> workers = [
      SELECT Id, LastName__c, FirstName__c, Name
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c != '退職済'
      ORDER BY LastName__c ASC
      LIMIT 200
    ];
    for (JIP_Worker__c w : workers) {
      String label = '';
      if (w.LastName__c != null) {
        label += w.LastName__c;
      }
      if (w.FirstName__c != null) {
        label += ' ' + w.FirstName__c;
      }
      if (String.isBlank(label)) {
        label = w.Name;
      }
      opts.add(new SelectOption(w.Id, label));
    }
    return opts;
  }

  // Status filter buttons
  public void setStatusAll() {
    filterStatus = 'すべて';
    loadTasks();
  }
  public void setStatusOpen() {
    filterStatus = '未対応';
    loadTasks();
  }
  public void setStatusInProgress() {
    filterStatus = '処理中';
    loadTasks();
  }
  public void setStatusResolved() {
    filterStatus = '処理済み';
    loadTasks();
  }
  public void setStatusClosed() {
    filterStatus = '完了';
    loadTasks();
  }
  public void setStatusNotClosed() {
    filterStatus = '完了以外';
    loadTasks();
  }

  public void selectProject() {
    loadTasks();
  }

  public void applyFilters() {
    loadTasks();
  }

  public void clearFilters() {
    filterStatus = 'すべて';
    filterType = '';
    filterCategory = '';
    filterMilestone = '';
    filterAssignee = null;
    filterKeyword = '';
    loadTasks();
  }

  // CRUD
  public PageReference openNewTask() {
    if (selectedProjectId == null) {
      addError('プロジェクトを選択してください。');
      return null;
    }
    PageReference pr = Page.JIP_ProjectTaskDetailPage;
    pr.getParameters().put('projectId', String.valueOf(selectedProjectId));
    pr.setRedirect(true);
    return pr;
  }

  public void editTask() {
    String taskId = ApexPages.currentPage().getParameters().get('taskId');
    if (String.isNotBlank(taskId)) {
      List<JIP_ProjectTask__c> tasks = [
        SELECT
          Id,
          Project__c,
          TaskType__c,
          Subject__c,
          Assignee__c,
          Status__c,
          Category__c,
          Priority__c,
          Milestone__c,
          StartDate__c,
          DueDate__c,
          EstimatedHours__c,
          ActualHours__c,
          Description__c,
          RegisteredBy__c
        FROM JIP_ProjectTask__c
        WHERE Id = :taskId
        LIMIT 1
      ];
      if (!tasks.isEmpty()) {
        currentTask = tasks[0];
        isEditMode = true;
        showModal = true;
      }
    }
  }
  public void saveTask() {
    if (selectedProjectId == null) {
      addError('プロジェクトを選択してください。');
      return;
    }
    try {
      currentTask.Project__c = selectedProjectId;
      if (String.isBlank(currentTask.RegisteredBy__c) && !isEditMode) {
        currentTask.RegisteredBy__c = UserInfo.getName();
      }
      if (isEditMode) {
        update currentTask;
        addSuccess('課題を更新しました。');
      } else {
        insert currentTask;
        addSuccess('課題を登録しました。');
      }
      showModal = false;
      loadTasks();
    } catch (Exception e) {
      addError('エラー: ' + e.getMessage());
    }
  }

  public void deleteTask() {
    if (deleteTaskId != null) {
      try {
        JIP_ProjectTask__c t = new JIP_ProjectTask__c(Id = deleteTaskId);
        delete t;
        addSuccess('課題を削除しました。');
        loadTasks();
      } catch (Exception e) {
        addError('削除エラー: ' + e.getMessage());
      }
    }
  }

  public void closeModal() {
    showModal = false;
  }

  private void loadTasks() {
    if (selectedProjectId == null) {
      taskList = new List<JIP_ProjectTask__c>();
      taskCount = 0;
      countAll = 0;
      countOpen = 0;
      countInProgress = 0;
      countResolved = 0;
      countClosed = 0;
      return;
    }

    // Build dynamic SOQL
    String soql =
      'SELECT Id, Name, Project__c, TaskType__c, Subject__c, ' +
      'Assignee__c, Assignee__r.LastName__c, Assignee__r.FirstName__c, Assignee__r.Name, ' +
      'Status__c, Category__c, Priority__c, Milestone__c, ' +
      'StartDate__c, DueDate__c, EstimatedHours__c, ActualHours__c, ' +
      'Description__c, RegisteredBy__c, CreatedDate, LastModifiedDate ' +
      'FROM JIP_ProjectTask__c ' +
      'WHERE Project__c = :selectedProjectId';

    if (filterStatus == '未対応') {
      soql += ' AND Status__c = \'未対応\'';
    } else if (filterStatus == '処理中') {
      soql += ' AND Status__c = \'処理中\'';
    } else if (filterStatus == '処理済み') {
      soql += ' AND Status__c = \'処理済み\'';
    } else if (filterStatus == '完了') {
      soql += ' AND Status__c = \'完了\'';
    } else if (filterStatus == '完了以外') {
      soql += ' AND Status__c != \'完了\'';
    }

    if (String.isNotBlank(filterType)) {
      soql += ' AND TaskType__c = :filterType';
    }
    if (String.isNotBlank(filterCategory)) {
      soql += ' AND Category__c = :filterCategory';
    }
    String mlPattern =
      '%' +
      String.escapeSingleQuotes(
        filterMilestone != null ? filterMilestone : ''
      ) +
      '%';
    if (String.isNotBlank(filterMilestone)) {
      soql += ' AND Milestone__c LIKE :mlPattern';
    }
    if (filterAssignee != null) {
      soql += ' AND Assignee__c = :filterAssignee';
    }
    String kwPattern =
      '%' +
      String.escapeSingleQuotes(filterKeyword != null ? filterKeyword : '') +
      '%';
    if (String.isNotBlank(filterKeyword)) {
      soql += ' AND Subject__c LIKE :kwPattern';
    }

    soql += ' ORDER BY Name DESC LIMIT 200';
    taskList = Database.query(soql);
    taskCount = taskList.size();

    // Count totals for project (unfiltered)
    List<AggregateResult> counts = [
      SELECT Status__c, COUNT(Id) cnt
      FROM JIP_ProjectTask__c
      WHERE Project__c = :selectedProjectId
      GROUP BY Status__c
    ];
    countAll = 0;
    countOpen = 0;
    countInProgress = 0;
    countResolved = 0;
    countClosed = 0;
    for (AggregateResult ar : counts) {
      String s = (String) ar.get('Status__c');
      Integer c = (Integer) ar.get('cnt');
      countAll += c;
      if (s == '未対応') {
        countOpen = c;
      } else if (s == '処理中') {
        countInProgress = c;
      } else if (s == '処理済み') {
        countResolved = c;
      } else if (s == '完了') {
        countClosed = c;
      }
    }
  }

  private void addSuccess(String msg) {
    ApexPages.addMessage(
      new ApexPages.Message(ApexPages.Severity.CONFIRM, msg)
    );
  }

  private void addError(String msg) {
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
  }

  public void closeMassImportModal() {
    showMassImportModal = false;
    importFileBody = null;
    importFileName = null;
  }
  
  public void openMassImportModal() {
    showMassImportModal = true;
    showMassImportConfirmModal = false;
  }
  
  public void closeMassImportConfirmModal() {
    showMassImportConfirmModal = false;
  }

  public void closeMassImportStartedModal() {
    showMassImportStartedModal = false;
  }

  public void openMassImportConfirmModal() {

    if (selectedProjectId == null) {
      addError('Vui lòng chọn dự án.');
      return;
    }
    if (importFileBody == null || String.isBlank(importFileName)) {
      addError('Vui lòng chọn tệp CSV');
      return;
    }
    if (!importFileName.toLowerCase().endsWith('.csv')) {
      addError('Chỉ có thể tải lên tệp CSV');
      return;
    }
    try { // Lưu file
      ContentVersion cv = new ContentVersion();
      cv.Title = importFileName;
      cv.PathOnClient = importFileName;
      cv.VersionData = importFileBody;
      insert cv;
      uploadedContentVersionId = cv.Id;
      uploadedFileName = importFileName;
      showMassImportConfirmModal = true;
    }
    catch (Exception e) {
      addError('Tải tệp thất bại :' + e.getMessage());
    }
  }

  public void importTasks() {
    if (importFileBody == null) {
    addError('Import file was not found.');
    return;
  }
  try {
    String userEmail = UserInfo.getUserEmail();
    System.enqueueJob(
      new JIP_ProjectTaskImportQueueable(
        uploadedContentVersionId,
        selectedProjectId,
        userEmail,
        uploadedFileName
      )
    );
    showMassImportConfirmModal = false;
    showMassImportModal = false;
    showMassImportStartedModal = true;

    importFileBody = null;
    importFileName = null;
    // addSuccess(
    //   'Import has started. You will receive an email when processing is complete.'
    // );
  } catch (Exception e) {
    addError('Import failed: ' + e.getMessage());
  }
}
}