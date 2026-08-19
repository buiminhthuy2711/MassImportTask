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
public with sharing class JIP_ProjectManagementController {
  public List<JIP_Project__c> projects { get; set; }
  public JIP_Project__c currentProject { get; set; }
  public String searchKeyword { get; set; }
  public Boolean showModal { get; set; }
  public Boolean isEditMode { get; set; }
  public Id deleteProjectId { get; set; }
  public String filterStatus { get; set; }

  private static final String PROJECT_FIELDS =
    'Id, Name, Name__c, Status__c, ' +
    'ClientCompany__c, ClientCompany__r.Name, ' +
    'Manager__c, Manager__r.Name, ' +
    'StartDate__c, EndDate__c, TechStack__c, CreatedDate';

  public JIP_ProjectManagementController() {
    showModal = false;
    isEditMode = false;
    searchKeyword = '';
    filterStatus = '';
    currentProject = new JIP_Project__c();
    loadProjects();
  }

  public void loadProjects() {
    String query = 'SELECT ' + PROJECT_FIELDS + ' FROM JIP_Project__c';
    List<String> conditions = new List<String>();

    if (String.isNotBlank(searchKeyword)) {
      String safeKeyword =
        '%' +
        String.escapeSingleQuotes(searchKeyword.trim()) +
        '%';
      conditions.add(
        '(Name LIKE :safeKeyword OR Name__c LIKE :safeKeyword OR TechStack__c LIKE :safeKeyword OR ClientCompany__r.Name LIKE :safeKeyword)'
      );
    }
    if (String.isNotBlank(filterStatus)) {
      conditions.add('Status__c = :filterStatus');
    }

    if (!conditions.isEmpty()) {
      query += ' WHERE ' + String.join(conditions, ' AND ');
    }
    query += ' ORDER BY CreatedDate DESC LIMIT 200';
    projects = Database.query(query);
  }

  public void searchProjects() {
    loadProjects();
  }

  public void clearSearch() {
    searchKeyword = '';
    filterStatus = '';
    loadProjects();
  }

  public void openNewModal() {
    currentProject = new JIP_Project__c();
    isEditMode = false;
    showModal = true;
  }

  public void openEditModal() {
    Id projectId = ApexPages.currentPage().getParameters().get('editId');
    if (projectId != null) {
      currentProject = Database.query(
        'SELECT ' +
          PROJECT_FIELDS +
          ' FROM JIP_Project__c WHERE Id = :projectId LIMIT 1'
      );
      isEditMode = true;
      showModal = true;
    }
  }

  public void closeModal() {
    showModal = false;
    currentProject = new JIP_Project__c();
  }

  public void saveProject() {
    try {
      if (isEditMode) {
        update currentProject;
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            'プロジェクト情報を更新しました。'
          )
        );
      } else {
        insert currentProject;
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            '新しいプロジェクトを登録しました。'
          )
        );
      }
      showModal = false;
      currentProject = new JIP_Project__c();
      loadProjects();
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'エラー: ' + e.getDmlMessage(0)
        )
      );
    }
  }

  public void deleteProject() {
    try {
      if (deleteProjectId != null) {
        JIP_Project__c toDelete = [
          SELECT Id
          FROM JIP_Project__c
          WHERE Id = :deleteProjectId
          LIMIT 1
        ];
        delete toDelete;
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            'プロジェクトを削除しました。'
          )
        );
        loadProjects();
      }
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          '削除エラー: ' + e.getDmlMessage(0)
        )
      );
    }
  }

  public List<SelectOption> getStatusFilterOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', '-- 全て --'));
    options.add(new SelectOption('New', 'New'));
    options.add(new SelectOption('Active', 'Active'));
    options.add(new SelectOption('Completed', 'Completed'));
    options.add(new SelectOption('On Hold', 'On Hold'));
    return options;
  }
}