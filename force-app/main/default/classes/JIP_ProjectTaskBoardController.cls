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
public with sharing class JIP_ProjectTaskBoardController {
  // Project selection
  public Id selectedProjectId { get; set; }
  public List<JIP_Project__c> projectList { get; set; }

  // Filters
  public String filterType { get; set; }
  public String filterCategory { get; set; }
  public String filterMilestone { get; set; }
  public Id filterAssignee { get; set; }

  // Board columns
  public List<JIP_ProjectTask__c> openTasks { get; set; }
  public List<JIP_ProjectTask__c> inProgressTasks { get; set; }
  public List<JIP_ProjectTask__c> resolvedTasks { get; set; }
  public List<JIP_ProjectTask__c> closedTasks { get; set; }

  // Counts
  public Integer countOpen { get; set; }
  public Integer countInProgress { get; set; }
  public Integer countResolved { get; set; }
  public Integer countClosed { get; set; }

  // Drag & drop
  public Id updateTaskStatusId { get; set; }
  public String updateTaskStatusValue { get; set; }

  // CRUD modal
  public JIP_ProjectTask__c currentTask { get; set; }
  public Boolean showModal { get; set; }
  public Boolean isEditMode { get; set; }
  public Id deleteTaskId { get; set; }

  public JIP_ProjectTaskBoardController() {
    projectList = [
      SELECT Id, Name, Name__c, Status__c, Language__c
      FROM JIP_Project__c
      ORDER BY Name ASC
      LIMIT 200
    ];
    filterType = '';
    filterCategory = '';
    filterMilestone = '';
    showModal = false;
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

    openTasks = new List<JIP_ProjectTask__c>();
    inProgressTasks = new List<JIP_ProjectTask__c>();
    resolvedTasks = new List<JIP_ProjectTask__c>();
    closedTasks = new List<JIP_ProjectTask__c>();

    loadBoardTasks();
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

  public List<SelectOption> getMilestoneOptions() {
    List<SelectOption> opts = new List<SelectOption>();
    opts.add(new SelectOption('', '--'));
    if (selectedProjectId != null) {
      List<AggregateResult> milestones = [
        SELECT Milestone__c
        FROM JIP_ProjectTask__c
        WHERE Project__c = :selectedProjectId AND Milestone__c != NULL
        GROUP BY Milestone__c
        ORDER BY Milestone__c ASC
      ];
      for (AggregateResult ar : milestones) {
        String m = (String) ar.get('Milestone__c');
        if (String.isNotBlank(m)) {
          opts.add(new SelectOption(m, m));
        }
      }
    }
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

  public void selectProject() {
    loadBoardTasks();
  }

  public void applyFilters() {
    loadBoardTasks();
  }

  public void clearFilters() {
    filterType = '';
    filterCategory = '';
    filterMilestone = '';
    filterAssignee = null;
    loadBoardTasks();
  }

  public void updateTaskStatus() {
    if (
      updateTaskStatusId != null && String.isNotBlank(updateTaskStatusValue)
    ) {
      try {
        JIP_ProjectTask__c task = new JIP_ProjectTask__c(
          Id = updateTaskStatusId,
          Status__c = updateTaskStatusValue
        );
        update task;
        loadBoardTasks();
      } catch (Exception e) {
        addError('ステータス更新エラー: ' + e.getMessage());
      }
    }
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
      loadBoardTasks();
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
        loadBoardTasks();
      } catch (Exception e) {
        addError('削除エラー: ' + e.getMessage());
      }
    }
  }

  public void closeModal() {
    showModal = false;
  }

  private void loadBoardTasks() {
    if (selectedProjectId == null) {
      openTasks = new List<JIP_ProjectTask__c>();
      inProgressTasks = new List<JIP_ProjectTask__c>();
      resolvedTasks = new List<JIP_ProjectTask__c>();
      closedTasks = new List<JIP_ProjectTask__c>();
      countOpen = 0;
      countInProgress = 0;
      countResolved = 0;
      countClosed = 0;
      return;
    }

    String soql =
      'SELECT Id, Name, Project__c, TaskType__c, Subject__c, ' +
      'Assignee__c, Assignee__r.LastName__c, Assignee__r.FirstName__c, Assignee__r.Name, ' +
      'Status__c, Category__c, Priority__c, Milestone__c, ' +
      'StartDate__c, DueDate__c, EstimatedHours__c, ActualHours__c, ' +
      'Description__c, RegisteredBy__c, CreatedDate, LastModifiedDate ' +
      'FROM JIP_ProjectTask__c ' +
      'WHERE Project__c = :selectedProjectId';

    if (String.isNotBlank(filterType)) {
      soql += ' AND TaskType__c = :filterType';
    }
    if (String.isNotBlank(filterCategory)) {
      soql += ' AND Category__c = :filterCategory';
    }
    if (String.isNotBlank(filterMilestone)) {
      soql += ' AND Milestone__c = :filterMilestone';
    }
    if (filterAssignee != null) {
      soql += ' AND Assignee__c = :filterAssignee';
    }

    soql += ' ORDER BY CreatedDate DESC LIMIT 200';
    List<JIP_ProjectTask__c> allTasks = Database.query(soql);

    openTasks = new List<JIP_ProjectTask__c>();
    inProgressTasks = new List<JIP_ProjectTask__c>();
    resolvedTasks = new List<JIP_ProjectTask__c>();
    closedTasks = new List<JIP_ProjectTask__c>();

    for (JIP_ProjectTask__c t : allTasks) {
      if (t.Status__c == '未対応') {
        openTasks.add(t);
      } else if (t.Status__c == '処理中') {
        inProgressTasks.add(t);
      } else if (t.Status__c == '処理済み') {
        resolvedTasks.add(t);
      } else if (t.Status__c == '完了') {
        closedTasks.add(t);
      }
    }

    countOpen = openTasks.size();
    countInProgress = inProgressTasks.size();
    countResolved = resolvedTasks.size();
    countClosed = closedTasks.size();
  }

  private void addSuccess(String msg) {
    ApexPages.addMessage(
      new ApexPages.Message(ApexPages.Severity.CONFIRM, msg)
    );
  }

  private void addError(String msg) {
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
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