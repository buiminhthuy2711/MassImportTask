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
public with sharing class JIP_GanttChartController {
  // Project selection
  public Id selectedProjectId { get; set; }
  public List<JIP_Project__c> projectList { get; set; }

  // Filters
  public String filterType { get; set; }
  public String filterStatus { get; set; }
  public String filterCategory { get; set; }
  public String filterMilestone { get; set; }
  public Id filterAssignee { get; set; }

  // Gantt settings
  public Date ganttStartDate { get; set; }
  public String ganttScale { get; set; } // 日, 週, 月
  public String ganttGrouping { get; set; } // なし, 担当者, 種別, カテゴリー

  // Tasks
  public List<JIP_ProjectTask__c> taskList { get; set; }

  // Task detail popup
  public JIP_ProjectTask__c selectedTask { get; set; }
  public List<JIP_TaskComment__c> taskComments { get; set; }
  public String newComment { get; set; }
  public Boolean showTaskPopup { get; set; }
  public Id popupTaskId { get; set; }

  // Drag & drop date update
  public Id dragTaskId { get; set; }
  public String dragNewStart { get; set; }
  public String dragNewEnd { get; set; }

  // Left panel visibility
  public Boolean showLeftPanel { get; set; }

  public JIP_GanttChartController() {
    projectList = [
      SELECT Id, Name, Name__c, Status__c, Language__c
      FROM JIP_Project__c
      ORDER BY Name ASC
      LIMIT 200
    ];
    filterType = '';
    filterStatus = '';
    filterCategory = '';
    filterMilestone = '';
    ganttScale = '日';
    ganttGrouping = 'なし';
    ganttStartDate = Date.today().toStartOfWeek();
    showTaskPopup = false;
    showLeftPanel = true;
    newComment = '';
    taskComments = new List<JIP_TaskComment__c>();

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

  public List<SelectOption> getStatusOptions() {
    List<SelectOption> opts = new List<SelectOption>();
    opts.add(new SelectOption('', '--'));
    opts.add(new SelectOption('未対応', '未対応'));
    opts.add(new SelectOption('処理中', '処理中'));
    opts.add(new SelectOption('処理済み', '処理済み'));
    opts.add(new SelectOption('完了', '完了'));
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

  public List<SelectOption> getScaleOptions() {
    List<SelectOption> opts = new List<SelectOption>();
    opts.add(new SelectOption('日', '日'));
    opts.add(new SelectOption('週', '週'));
    opts.add(new SelectOption('月', '月'));
    return opts;
  }

  public List<SelectOption> getGroupingOptions() {
    List<SelectOption> opts = new List<SelectOption>();
    opts.add(new SelectOption('なし', 'なし'));
    opts.add(new SelectOption('担当者', '担当者'));
    opts.add(new SelectOption('種別', '種別'));
    opts.add(new SelectOption('カテゴリー', 'カテゴリー'));
    return opts;
  }

  // ===== Actions =====
  public void selectProject() {
    showTaskPopup = false;
    loadTasks();
  }

  public void applyFilters() {
    showTaskPopup = false;
    loadTasks();
  }

  public void clearFilters() {
    filterType = '';
    filterStatus = '';
    filterCategory = '';
    filterMilestone = '';
    filterAssignee = null;
    showTaskPopup = false;
    loadTasks();
  }

  public void goToday() {
    ganttStartDate = Date.today().toStartOfWeek();
    showTaskPopup = false;
  }

  public void goPrev() {
    if (ganttScale == '日') {
      ganttStartDate = ganttStartDate.addDays(-7);
    } else if (ganttScale == '週') {
      ganttStartDate = ganttStartDate.addDays(-28);
    } else {
      ganttStartDate = ganttStartDate.addMonths(-1);
    }
    showTaskPopup = false;
  }

  public void goNext() {
    if (ganttScale == '日') {
      ganttStartDate = ganttStartDate.addDays(7);
    } else if (ganttScale == '週') {
      ganttStartDate = ganttStartDate.addDays(28);
    } else {
      ganttStartDate = ganttStartDate.addMonths(1);
    }
    showTaskPopup = false;
  }

  public void changeScale() {
    showTaskPopup = false;
  }

  public void changeGrouping() {
    showTaskPopup = false;
  }

  public void toggleLeftPanel() {
    showLeftPanel = !showLeftPanel;
  }

  // Task detail popup
  public void openTaskPopup() {
    if (popupTaskId == null) {
      return;
    }
    List<JIP_ProjectTask__c> tasks = [
      SELECT
        Id,
        Name,
        Project__c,
        Project__r.Name,
        Project__r.Name__c,
        TaskType__c,
        Subject__c,
        Assignee__c,
        Assignee__r.LastName__c,
        Assignee__r.FirstName__c,
        Assignee__r.Name,
        Status__c,
        Category__c,
        Priority__c,
        Milestone__c,
        StartDate__c,
        DueDate__c,
        EstimatedHours__c,
        ActualHours__c,
        Description__c,
        RegisteredBy__c,
        CreatedDate,
        LastModifiedDate
      FROM JIP_ProjectTask__c
      WHERE Id = :popupTaskId
      LIMIT 1
    ];
    if (!tasks.isEmpty()) {
      selectedTask = tasks[0];
      loadTaskComments();
      showTaskPopup = true;
    }
  }

  public void closeTaskPopup() {
    showTaskPopup = false;
    selectedTask = null;
    taskComments = new List<JIP_TaskComment__c>();
    newComment = '';
  }

  private void loadTaskComments() {
    if (selectedTask == null) {
      taskComments = new List<JIP_TaskComment__c>();
      return;
    }
    taskComments = [
      SELECT Id, CommentBody__c, CommentBy__c, CreatedDate
      FROM JIP_TaskComment__c
      WHERE ProjectTask__c = :selectedTask.Id
      ORDER BY CreatedDate ASC
      LIMIT 200
    ];
  }

  public void addComment() {
    if (String.isBlank(newComment) || selectedTask == null) {
      return;
    }
    try {
      JIP_TaskComment__c c = new JIP_TaskComment__c(
        ProjectTask__c = selectedTask.Id,
        CommentBody__c = newComment,
        CommentBy__c = UserInfo.getName()
      );
      insert c;
      newComment = '';
      loadTaskComments();
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'コメントエラー: ' + e.getMessage()
        )
      );
    }
  }

  // Drag & drop: update task dates
  public void updateTaskDates() {
    if (dragTaskId == null) {
      return;
    }
    try {
      Date newStart = parseDate(dragNewStart);
      Date newEnd = parseDate(dragNewEnd);
      if (newStart == null) {
        return;
      }

      JIP_ProjectTask__c t = new JIP_ProjectTask__c(
        Id = dragTaskId,
        StartDate__c = newStart,
        DueDate__c = newEnd
      );
      update t;
      loadTasks();
      // Refresh popup if same task
      if (
        showTaskPopup &&
        selectedTask != null &&
        selectedTask.Id == dragTaskId
      ) {
        popupTaskId = dragTaskId;
        openTaskPopup();
      }
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          '日付更新エラー: ' + e.getMessage()
        )
      );
    }
  }

  // Popup detail helpers
  public String getPopupAssigneeName() {
    if (selectedTask == null || selectedTask.Assignee__c == null) {
      return '';
    }
    String n = '';
    if (selectedTask.Assignee__r.LastName__c != null) {
      n += selectedTask.Assignee__r.LastName__c;
    }
    if (selectedTask.Assignee__r.FirstName__c != null) {
      n += ' ' + selectedTask.Assignee__r.FirstName__c;
    }
    if (String.isBlank(n)) {
      n = selectedTask.Assignee__r.Name;
    }
    return n;
  }

  public String getPopupAssigneeInitial() {
    String name = getPopupAssigneeName();
    return String.isNotBlank(name) ? name.substring(0, 1) : '';
  }

  // ===== Data Loading =====
  private void loadTasks() {
    if (selectedProjectId == null) {
      taskList = new List<JIP_ProjectTask__c>();
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
    if (String.isNotBlank(filterStatus)) {
      soql += ' AND Status__c = :filterStatus';
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

    soql += ' ORDER BY CreatedDate ASC LIMIT 200';
    taskList = Database.query(soql);
  }

  // JSON for JavaScript Gantt rendering
  public String getTasksJson() {
    List<Map<String, Object>> items = new List<Map<String, Object>>();
    for (JIP_ProjectTask__c t : taskList) {
      Map<String, Object> m = new Map<String, Object>();
      m.put('id', t.Id);
      m.put('name', t.Name);
      m.put('subject', t.Subject__c);
      m.put('type', t.TaskType__c);
      m.put('status', t.Status__c);
      m.put('category', t.Category__c);
      m.put('priority', t.Priority__c);
      m.put('milestone', t.Milestone__c);
      m.put(
        'startDate',
        t.StartDate__c != null ? formatDate(t.StartDate__c) : null
      );
      m.put('dueDate', t.DueDate__c != null ? formatDate(t.DueDate__c) : null);
      String aName = '';
      if (t.Assignee__c != null) {
        if (t.Assignee__r.LastName__c != null) {
          aName += t.Assignee__r.LastName__c;
        }
        if (t.Assignee__r.FirstName__c != null) {
          aName += ' ' + t.Assignee__r.FirstName__c;
        }
        if (String.isBlank(aName)) {
          aName = t.Assignee__r.Name;
        }
      }
      m.put('assignee', aName);
      m.put(
        'assigneeInitial',
        String.isNotBlank(aName) ? aName.substring(0, 1) : ''
      );
      items.add(m);
    }
    return JSON.serialize(items);
  }

  public String getGanttStartDateStr() {
    return formatDate(ganttStartDate);
  }

  private String formatDate(Date d) {
    return String.valueOf(d.year()) +
      '-' +
      String.valueOf(d.month()).leftPad(2, '0') +
      '-' +
      String.valueOf(d.day()).leftPad(2, '0');
  }

  private Date parseDate(String s) {
    if (String.isBlank(s)) {
      return null;
    }
    try {
      List<String> parts = s.split('-');
      return Date.newInstance(
        Integer.valueOf(parts[0]),
        Integer.valueOf(parts[1]),
        Integer.valueOf(parts[2])
      );
    } catch (Exception e) {
      return null;
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