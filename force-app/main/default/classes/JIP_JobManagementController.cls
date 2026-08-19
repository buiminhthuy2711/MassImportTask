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
public with sharing class JIP_JobManagementController {
  public List<JIP_Job__c> jobs { get; set; }
  public JIP_Job__c currentJob { get; set; }
  public String searchKeyword { get; set; }
  public Boolean showModal { get; set; }
  public Boolean isEditMode { get; set; }
  public Id deleteJobId { get; set; }
  public String filterStatus { get; set; }
  public String filterPriority { get; set; }

  private static final String JOB_FIELDS =
    'Id, Name, JobTitle__c, Status__c, Priority__c, ' +
    'Company__c, Company__r.Name, Description__c, ' +
    'BudgetRateMin__c, BudgetRateMax__c, WorkLocation__c, ' +
    'StartDate__c, DurationMonths__c, RequiredJapaneseLevel__c, CreatedDate';

  public JIP_JobManagementController() {
    showModal = false;
    isEditMode = false;
    searchKeyword = '';
    filterStatus = '';
    filterPriority = '';
    currentJob = new JIP_Job__c();
    loadJobs();
  }

  public void loadJobs() {
    String query = 'SELECT ' + JOB_FIELDS + ' FROM JIP_Job__c';
    List<String> conditions = new List<String>();

    if (String.isNotBlank(searchKeyword)) {
      String safeKeyword =
        '%' +
        String.escapeSingleQuotes(searchKeyword.trim()) +
        '%';
      conditions.add(
        '(Name LIKE :safeKeyword OR JobTitle__c LIKE :safeKeyword OR WorkLocation__c LIKE :safeKeyword OR Company__r.Name LIKE :safeKeyword)'
      );
    }
    if (String.isNotBlank(filterStatus)) {
      conditions.add('Status__c = :filterStatus');
    }
    if (String.isNotBlank(filterPriority)) {
      conditions.add('Priority__c = :filterPriority');
    }

    if (!conditions.isEmpty()) {
      query += ' WHERE ' + String.join(conditions, ' AND ');
    }
    query += ' ORDER BY CreatedDate DESC LIMIT 200';
    jobs = Database.query(query);
  }

  public void searchJobs() {
    loadJobs();
  }

  public void clearSearch() {
    searchKeyword = '';
    filterStatus = '';
    filterPriority = '';
    loadJobs();
  }

  public void openNewModal() {
    currentJob = new JIP_Job__c();
    isEditMode = false;
    showModal = true;
  }

  public void openEditModal() {
    Id jobId = ApexPages.currentPage().getParameters().get('editId');
    if (jobId != null) {
      currentJob = Database.query(
        'SELECT ' + JOB_FIELDS + ' FROM JIP_Job__c WHERE Id = :jobId LIMIT 1'
      );
      isEditMode = true;
      showModal = true;
    }
  }

  public void closeModal() {
    showModal = false;
    currentJob = new JIP_Job__c();
  }

  public void saveJob() {
    try {
      if (isEditMode) {
        update currentJob;
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            '求人情報を更新しました。'
          )
        );
      } else {
        insert currentJob;
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            '新しい求人を登録しました。'
          )
        );
      }
      showModal = false;
      currentJob = new JIP_Job__c();
      loadJobs();
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'エラー: ' + e.getDmlMessage(0)
        )
      );
    }
  }

  public void deleteJob() {
    try {
      if (deleteJobId != null) {
        JIP_Job__c toDelete = [
          SELECT Id
          FROM JIP_Job__c
          WHERE Id = :deleteJobId
          LIMIT 1
        ];
        delete toDelete;
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            '求人を削除しました。'
          )
        );
        loadJobs();
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
    options.add(new SelectOption('None', 'None'));
    options.add(new SelectOption('Open', 'Open'));
    options.add(new SelectOption('On Hold', 'On Hold'));
    options.add(new SelectOption('Closed', 'Closed'));
    return options;
  }

  public List<SelectOption> getPriorityFilterOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', '-- 全て --'));
    options.add(new SelectOption('High', 'High'));
    options.add(new SelectOption('Medium', 'Medium'));
    options.add(new SelectOption('Low', 'Low'));
    return options;
  }
}