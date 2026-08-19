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
public with sharing class JIP_ProjectTaskDetailController {
  public JIP_ProjectTask__c task { get; set; }
  public List<JIP_TaskComment__c> comments { get; set; }
  public String newComment { get; set; }
  public Boolean isEditing { get; set; }
  public Boolean isCreateMode { get; set; }
  public String taskId { get; set; }
  public Id projectId { get; set; }

  // Quick-edit sidebar fields
  public String editStatus { get; set; }
  public Id editAssignee { get; set; }
  public Date editStartDate { get; set; }
  public Date editDueDate { get; set; }
  public String editMilestone { get; set; }
  public Decimal editEstimatedHours { get; set; }
  public Decimal editActualHours { get; set; }

  // For rich text comment input
  public JIP_TaskComment__c newCommentObj { get; set; }

  // For notifying project members (comma-separated IDs)
  public String selectedMembersToNotify { get; set; }

  // For editing comment
  public Id editingCommentId { get; set; }
  public String editCommentBody { get; set; }

  public JIP_ProjectTaskDetailController() {
    selectedMembersToNotify = '';
    editingCommentId = null;
    editCommentBody = '';
    taskId = ApexPages.currentPage().getParameters().get('id');
    String pid = ApexPages.currentPage().getParameters().get('projectId');
    isEditing = false;
    isCreateMode = false;
    newComment = '';

    if (String.isNotBlank(pid)) {
      try {
        projectId = (Id) pid;
      } catch (Exception e) {
        projectId = null;
      }
    }

    // Initialize newCommentObj for rich text comment input
    newCommentObj = new JIP_TaskComment__c();

    if (String.isBlank(taskId) && projectId != null) {
      // CREATE MODE: no task id, but projectId provided
      isCreateMode = true;
      task = new JIP_ProjectTask__c(
        Project__c = projectId,
        TaskType__c = '基本操作',
        Status__c = '未対応',
        Priority__c = '中',
        StartDate__c = Date.today(),
        RegisteredBy__c = UserInfo.getName()
      );
      comments = new List<JIP_TaskComment__c>();
    } else {
      loadTask();
      loadComments();
    }
  }

  private void loadTask() {
    if (String.isBlank(taskId)) {
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
      WHERE Id = :taskId
      LIMIT 1
    ];
    if (!tasks.isEmpty()) {
      task = tasks[0];
      projectId = task.Project__c;
      editStatus = task.Status__c;
      editAssignee = task.Assignee__c;
      editStartDate = task.StartDate__c;
      editDueDate = task.DueDate__c;
      editMilestone = task.Milestone__c;
      editEstimatedHours = task.EstimatedHours__c;
      editActualHours = task.ActualHours__c;
    }
  }

  private void loadComments() {
    if (String.isBlank(taskId)) {
      comments = new List<JIP_TaskComment__c>();
      return;
    }
    comments = [
      SELECT Id, CommentBody__c, CommentBy__c, NotifiedMembers__c, CreatedDate
      FROM JIP_TaskComment__c
      WHERE ProjectTask__c = :taskId
      ORDER BY CreatedDate ASC
      LIMIT 200
    ];
  }

  // Getters
  public String getProjectName() {
    if (task == null) {
      return '';
    }
    if (isCreateMode) {
      List<JIP_Project__c> projs = [
        SELECT Name, Name__c
        FROM JIP_Project__c
        WHERE Id = :projectId
        LIMIT 1
      ];
      if (!projs.isEmpty()) {
        return projs[0].Name__c != null ? projs[0].Name__c : projs[0].Name;
      }
      return '';
    }
    return task.Project__r.Name__c != null
      ? task.Project__r.Name__c
      : task.Project__r.Name;
  }

  public String getAssigneeName() {
    if (task == null || task.Assignee__c == null) {
      return '';
    }
    String n = '';
    if (task.Assignee__r.LastName__c != null) {
      n += task.Assignee__r.LastName__c;
    }
    if (task.Assignee__r.FirstName__c != null) {
      n += ' ' + task.Assignee__r.FirstName__c;
    }
    if (String.isBlank(n)) {
      n = task.Assignee__r.Name;
    }
    return n;
  }

  public String getAssigneeInitial() {
    String name = getAssigneeName();
    return String.isNotBlank(name) ? name.substring(0, 1) : '';
  }

  public String getCurrentUserName() {
    return UserInfo.getName();
  }

  public String getRegisteredByInitial() {
    if (task == null || String.isBlank(task.RegisteredBy__c)) {
      return '';
    }
    return task.RegisteredBy__c.substring(0, 1);
  }

  public List<SelectOption> getStatusOptions() {
    List<SelectOption> opts = new List<SelectOption>();
    opts.add(new SelectOption('未対応', '未対応'));
    opts.add(new SelectOption('処理中', '処理中'));
    opts.add(new SelectOption('処理済み', '処理済み'));
    opts.add(new SelectOption('完了', '完了'));
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

  // Get project members for comment notification
  public List<SelectOption> getNotifyMemberOptions() {
    List<SelectOption> opts = new List<SelectOption>();
    if (projectId == null) {
      return opts;
    }
    List<JIP_ProjectMember__c> members = [
      SELECT
        Id,
        Worker__c,
        Worker__r.Name,
        Worker__r.LastName__c,
        Worker__r.FirstName__c
      FROM JIP_ProjectMember__c
      WHERE Project__c = :projectId
      ORDER BY Worker__r.LastName__c ASC
      LIMIT 50
    ];
    for (JIP_ProjectMember__c m : members) {
      String label = '';
      if (m.Worker__r.LastName__c != null) {
        label += m.Worker__r.LastName__c;
      }
      if (m.Worker__r.FirstName__c != null) {
        label += ' ' + m.Worker__r.FirstName__c;
      }
      if (String.isBlank(label)) {
        label = m.Worker__r.Name;
      }
      opts.add(new SelectOption(m.Worker__c, label));
    }
    return opts;
  }

  // Actions
  public PageReference goBackToList() {
    PageReference pr = Page.JIP_ProjectTaskPage;
    if (projectId != null) {
      pr.getParameters().put('projectId', String.valueOf(projectId));
    }
    pr.setRedirect(true);
    return pr;
  }

  public PageReference saveCreate() {
    if (task == null) {
      return null;
    }
    try {
      insert task;
      // Redirect to the newly created task detail page
      PageReference pr = Page.JIP_ProjectTaskDetailPage;
      pr.getParameters().put('id', task.Id);
      pr.setRedirect(true);
      return pr;
    } catch (Exception e) {
      addError('登録エラー: ' + e.getMessage());
      return null;
    }
  }

  public void cancelCreate() {
    // Just redirect back to task list
  }

  public PageReference cancelCreateRedirect() {
    return goBackToList();
  }

  public void toggleEdit() {
    isEditing = !isEditing;
  }

  public void saveQuickEdit() {
    if (task == null) {
      return;
    }
    try {
      task.Status__c = editStatus;
      task.Assignee__c = editAssignee;
      task.StartDate__c = editStartDate;
      task.DueDate__c = editDueDate;
      task.Milestone__c = editMilestone;
      task.EstimatedHours__c = editEstimatedHours;
      task.ActualHours__c = editActualHours;
      update task;
      addSuccess('課題を更新しました。');
      loadTask();
    } catch (Exception e) {
      addError('更新エラー: ' + e.getMessage());
    }
  }

  public void saveFullEdit() {
    if (task == null) {
      return;
    }
    try {
      update task;
      isEditing = false;
      addSuccess('課題を更新しました。');
      loadTask();
    } catch (Exception e) {
      addError('更新エラー: ' + e.getMessage());
    }
  }

  public void cancelEdit() {
    isEditing = false;
    loadTask();
  }

  public void setStatusInProgress() {
    if (task == null) {
      return;
    }
    try {
      task.Status__c = '処理中';
      update task;
      addSuccess('状態を「処理中」に変更しました。');
      loadTask();
    } catch (Exception e) {
      addError('更新エラー: ' + e.getMessage());
    }
  }

  public void setStatusResolved() {
    if (task == null) {
      return;
    }
    try {
      task.Status__c = '処理済み';
      update task;
      addSuccess('状態を「処理済み」に変更しました。');
      loadTask();
    } catch (Exception e) {
      addError('更新エラー: ' + e.getMessage());
    }
  }

  public void assignToMe() {
    if (task == null) {
      return;
    }
    try {
      // Find worker matching current user name
      String userName = UserInfo.getName();
      List<JIP_Worker__c> workers = [
        SELECT Id
        FROM JIP_Worker__c
        WHERE LastName__c != NULL
        ORDER BY LastName__c ASC
        LIMIT 1
      ];
      if (!workers.isEmpty()) {
        task.Assignee__c = workers[0].Id;
        editAssignee = workers[0].Id;
        update task;
        addSuccess('担当者を設定しました。');
        loadTask();
      } else {
        addError('ワーカーが見つかりません。');
      }
    } catch (Exception e) {
      addError('更新エラー: ' + e.getMessage());
    }
  }

  public void addComment() {
    if (
      newCommentObj == null ||
      String.isBlank(newCommentObj.CommentBody__c) ||
      String.isBlank(taskId)
    ) {
      return;
    }
    try {
      // Build notified members display string
      String notifiedNames = '';
      if (String.isNotBlank(selectedMembersToNotify)) {
        List<String> memberIds = selectedMembersToNotify.split(',');
        List<JIP_Worker__c> workers = [
          SELECT Id, Name, LastName__c, FirstName__c
          FROM JIP_Worker__c
          WHERE Id IN :memberIds
        ];
        List<String> names = new List<String>();
        for (JIP_Worker__c w : workers) {
          String n = '';
          if (w.LastName__c != null)
            n += w.LastName__c;
          if (w.FirstName__c != null)
            n += ' ' + w.FirstName__c;
          if (String.isBlank(n))
            n = w.Name;
          names.add(n);
        }
        notifiedNames = String.join(names, ', ');
      }

      JIP_TaskComment__c c = new JIP_TaskComment__c(
        ProjectTask__c = taskId,
        CommentBody__c = newCommentObj.CommentBody__c,
        CommentBy__c = UserInfo.getName(),
        NotifiedMembers__c = notifiedNames
      );
      insert c;
      newCommentObj = new JIP_TaskComment__c();
      selectedMembersToNotify = '';
      addSuccess('コメントを登録しました。');
      loadComments();
    } catch (Exception e) {
      addError('コメントエラー: ' + e.getMessage());
    }
    return;
  }

  public void startEditComment() {
    String cId = ApexPages.currentPage().getParameters().get('commentId');
    if (String.isBlank(cId))
      return;
    for (JIP_TaskComment__c c : comments) {
      if (c.Id == cId) {
        editingCommentId = c.Id;
        editCommentBody = c.CommentBody__c;
        break;
      }
    }
  }

  public void saveEditComment() {
    if (editingCommentId == null || String.isBlank(editCommentBody)) {
      editingCommentId = null;
      editCommentBody = '';
      return;
    }
    try {
      JIP_TaskComment__c c = [
        SELECT Id, CommentBody__c, CommentBy__c
        FROM JIP_TaskComment__c
        WHERE Id = :editingCommentId
        LIMIT 1
      ];
      if (c.CommentBy__c != UserInfo.getName()) {
        addError('他のユーザーのコメントは編集できません。');
        return;
      }
      c.CommentBody__c = editCommentBody;
      update c;
      editingCommentId = null;
      editCommentBody = '';
      addSuccess('コメントを更新しました。');
      loadComments();
    } catch (Exception e) {
      addError('コメント更新エラー: ' + e.getMessage());
    }
  }

  public void cancelEditComment() {
    editingCommentId = null;
    editCommentBody = '';
  }

  public PageReference deleteTask() {
    if (task == null) {
      return null;
    }
    try {
      Id projectId = task.Project__c;
      delete task;
      PageReference pr = Page.JIP_ProjectTaskPage;
      pr.setRedirect(true);
      return pr;
    } catch (Exception e) {
      addError('削除エラー: ' + e.getMessage());
      return null;
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
}