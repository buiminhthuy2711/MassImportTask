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
public with sharing class JIP_ProjectSettingsController {
  // Project
  public Id selectedProjectId { get; set; }
  public JIP_Project__c project { get; set; }

  // Settings navigation
  public String activeSection { get; set; }

  // Members
  public List<JIP_ProjectMember__c> members { get; set; }
  public Integer memberCount { get; set; }
  public String searchUserKeyword { get; set; }
  public String filterRole { get; set; }
  public Id addWorkerId { get; set; }
  public String addMemberRole { get; set; }
  public Id removeMemberId { get; set; }
  public String addUserMessage { get; set; }
  public Id adminUserId { get; set; }

  // Edit member role
  public Id editMemberId { get; set; }
  public String editMemberRole { get; set; }

  // Available workers for adding
  public List<JIP_Worker__c> availableWorkers { get; set; }

  public JIP_ProjectSettingsController() {
    activeSection = 'members';
    searchUserKeyword = '';
    filterRole = '';
    addUserMessage = '';
    addMemberRole = 'メンバー';
    members = new List<JIP_ProjectMember__c>();
    availableWorkers = new List<JIP_Worker__c>();

    String pid = ApexPages.currentPage().getParameters().get('projectId');
    if (String.isNotBlank(pid)) {
      try {
        selectedProjectId = (Id) pid;
      } catch (Exception e) {
        selectedProjectId = null;
      }
    }

    String section = ApexPages.currentPage().getParameters().get('section');
    if (String.isNotBlank(section)) {
      activeSection = section;
    }

    if (selectedProjectId != null) {
      loadProject();
      loadMembers();
      loadAvailableWorkers();
    }
  }

  private void loadProject() {
    List<JIP_Project__c> projects = [
      SELECT Id, Name, Name__c, Status__c, Language__c
      FROM JIP_Project__c
      WHERE Id = :selectedProjectId
      LIMIT 1
    ];
    if (!projects.isEmpty()) {
      project = projects[0];
    }
  }

  // Language support
  public String getLanguage() {
    if (project != null && String.isNotBlank(project.Language__c)) {
      return project.Language__c;
    }
    return 'ja'; // Default to Japanese
  }

  public Map<String, String> getT() {
    return JIP_TranslationHelper.getAllTranslations(getLanguage());
  }

  public void saveLanguage() {
    if (project != null) {
      update project;
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.CONFIRM,
          JIP_TranslationHelper.get('msg_save_success', getLanguage())
        )
      );
    }
  }

  public String getProjectDisplayName() {
    if (project == null)
      return '';
    return (project.Name__c != null ? project.Name__c : project.Name) +
      ' (' +
      project.Name +
      ')';
  }

  public String getProjectName() {
    if (project == null)
      return '';
    return project.Name__c != null ? project.Name__c : project.Name;
  }

  // ===== Members =====
  public void loadMembers() {
    String query =
      'SELECT Id, Name, Worker__c, Worker__r.Name, Worker__r.LastName__c, Worker__r.FirstName__c, Worker__r.Email__c, Role__c, JoinDate__c, CreatedDate' +
      ' FROM JIP_ProjectMember__c' +
      ' WHERE Project__c = :selectedProjectId';

    List<String> conditions = new List<String>();
    if (String.isNotBlank(searchUserKeyword)) {
      String kw =
        '%' +
        String.escapeSingleQuotes(searchUserKeyword.trim()) +
        '%';
      conditions.add(
        '(Worker__r.Name LIKE :kw OR Worker__r.Email__c LIKE :kw OR Worker__r.LastName__c LIKE :kw OR Worker__r.FirstName__c LIKE :kw)'
      );
    }
    if (String.isNotBlank(filterRole)) {
      conditions.add('Role__c = :filterRole');
    }
    if (!conditions.isEmpty()) {
      query += ' AND ' + String.join(conditions, ' AND ');
    }
    query += ' ORDER BY CreatedDate ASC LIMIT 200';

    members = Database.query(query);
    memberCount = members.size();
  }

  public void searchMembers() {
    loadMembers();
  }

  public void addMemberToProject() {
    if (addWorkerId == null || selectedProjectId == null) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'ユーザーを選択してください。'
        )
      );
      return;
    }

    // Check if worker is already a member
    List<JIP_ProjectMember__c> existing = [
      SELECT Id
      FROM JIP_ProjectMember__c
      WHERE Project__c = :selectedProjectId AND Worker__c = :addWorkerId
      LIMIT 1
    ];
    if (!existing.isEmpty()) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.WARNING,
          'このユーザーは既にプロジェクトに参加しています。'
        )
      );
      return;
    }

    try {
      JIP_ProjectMember__c newMember = new JIP_ProjectMember__c(
        Project__c = selectedProjectId,
        Worker__c = addWorkerId,
        Role__c = String.isNotBlank(addMemberRole) ? addMemberRole : 'メンバー',
        JoinDate__c = Date.today()
      );
      insert newMember;
      addWorkerId = null;
      addMemberRole = 'メンバー';
      addUserMessage = '';
      loadMembers();
      loadAvailableWorkers();
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.CONFIRM,
          'ユーザーをプロジェクトに追加しました。'
        )
      );
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'エラー: ' + e.getDmlMessage(0)
        )
      );
    }
  }

  public void removeMember() {
    if (removeMemberId == null)
      return;
    try {
      JIP_ProjectMember__c toDelete = [
        SELECT Id
        FROM JIP_ProjectMember__c
        WHERE Id = :removeMemberId
        LIMIT 1
      ];
      delete toDelete;
      loadMembers();
      loadAvailableWorkers();
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.CONFIRM,
          'メンバーを削除しました。'
        )
      );
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'エラー: ' + e.getMessage()
        )
      );
    }
  }

  public void setAdminRole() {
    if (adminUserId == null)
      return;
    try {
      JIP_ProjectMember__c member = [
        SELECT Id, Role__c
        FROM JIP_ProjectMember__c
        WHERE Id = :adminUserId
        LIMIT 1
      ];
      member.Role__c = '管理者';
      update member;
      loadMembers();
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.CONFIRM,
          '管理者権限を設定しました。'
        )
      );
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'エラー: ' + e.getMessage()
        )
      );
    }
  }

  public void startEditMember() {
    if (editMemberId == null)
      return;
    for (JIP_ProjectMember__c m : members) {
      if (m.Id == editMemberId) {
        editMemberRole = m.Role__c;
        break;
      }
    }
  }

  public void cancelEditMember() {
    editMemberId = null;
    editMemberRole = null;
  }

  public void updateMemberRole() {
    if (editMemberId == null || String.isBlank(editMemberRole))
      return;
    try {
      JIP_ProjectMember__c member = [
        SELECT Id, Role__c
        FROM JIP_ProjectMember__c
        WHERE Id = :editMemberId AND Project__c = :selectedProjectId
        LIMIT 1
      ];
      member.Role__c = editMemberRole;
      update member;
      editMemberId = null;
      editMemberRole = null;
      loadMembers();
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.CONFIRM,
          '権限を更新しました。'
        )
      );
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'エラー: ' + e.getMessage()
        )
      );
    }
  }

  public List<SelectOption> getAddRoleOptions() {
    List<SelectOption> opts = new List<SelectOption>();
    opts.add(new SelectOption('メンバー', 'メンバー'));
    opts.add(new SelectOption('管理者', '管理者'));
    opts.add(new SelectOption('ゲスト', 'ゲスト'));
    return opts;
  }

  private void loadAvailableWorkers() {
    // Get IDs of workers already in the project
    Set<Id> existingWorkerIds = new Set<Id>();
    for (JIP_ProjectMember__c m : [
      SELECT Worker__c
      FROM JIP_ProjectMember__c
      WHERE Project__c = :selectedProjectId
    ]) {
      if (m.Worker__c != null) {
        existingWorkerIds.add(m.Worker__c);
      }
    }

    String query = 'SELECT Id, Name, LastName__c, FirstName__c, Email__c FROM JIP_Worker__c';
    if (!existingWorkerIds.isEmpty()) {
      query += ' WHERE Id NOT IN :existingWorkerIds';
    }
    query += ' ORDER BY Name ASC LIMIT 100';
    availableWorkers = Database.query(query);
  }

  public List<SelectOption> getAvailableUserOptions() {
    List<SelectOption> opts = new List<SelectOption>();
    opts.add(new SelectOption('', '-- ユーザーを選択 --'));
    for (JIP_Worker__c w : availableWorkers) {
      String label = '';
      if (w.LastName__c != null || w.FirstName__c != null) {
        label =
          (w.LastName__c != null ? w.LastName__c : '') +
          ' ' +
          (w.FirstName__c != null ? w.FirstName__c : '');
        label = label.trim();
      }
      if (String.isBlank(label)) {
        label = w.Name;
      }
      if (w.Email__c != null) {
        label += ' (' + w.Email__c + ')';
      }
      opts.add(new SelectOption(w.Id, label));
    }
    return opts;
  }

  public List<SelectOption> getRoleFilterOptions() {
    List<SelectOption> opts = new List<SelectOption>();
    opts.add(new SelectOption('', 'すべての権限'));
    opts.add(new SelectOption('管理者', '管理者'));
    opts.add(new SelectOption('メンバー', 'メンバー'));
    opts.add(new SelectOption('ゲスト', 'ゲスト'));
    return opts;
  }

  // ===== Section Navigation =====
  public void switchToBasic() {
    activeSection = 'basic';
  }
  public void switchToMembers() {
    activeSection = 'members';
  }
  public void switchToTheme() {
    activeSection = 'theme';
  }
  public void switchToType() {
    activeSection = 'type';
  }
  public void switchToStatus() {
    activeSection = 'status';
  }
  public void switchToCategory() {
    activeSection = 'category';
  }
  public void switchToMilestone() {
    activeSection = 'milestone';
  }
  public void switchToCustom() {
    activeSection = 'custom';
  }
  public void switchToIntegration() {
    activeSection = 'integration';
  }

  // ===== Navigation =====
  public PageReference goBackToProject() {
    PageReference pr = Page.JIP_ProjectTaskPage;
    pr.getParameters().put('projectId', String.valueOf(selectedProjectId));
    pr.setRedirect(true);
    return pr;
  }

  // ===== Helper =====
  public String getMemberInitial() {
    return '';
  }
}