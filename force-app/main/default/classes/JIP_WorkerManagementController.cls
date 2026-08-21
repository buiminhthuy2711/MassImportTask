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
public with sharing class JIP_WorkerManagementController {
  public List<JIP_Worker__c> workers { get; set; }
  public Map<Id, String> avatarUrlsByWorkerId { get; set; }
  public JIP_Worker__c currentWorker { get; set; }
  public String searchKeyword { get; set; }
  public Boolean showModal { get; set; }
  public Boolean isEditMode { get; set; }
  public Id deleteWorkerId { get; set; }

  // Filter properties
  public String filterStatus { get; set; }
  public String filterContractType { get; set; }
  public String filterDepartment { get; set; }

  // Statistics
  public Integer totalCount { get; set; }
  public Integer activeCount { get; set; }
  public Integer leaveCount { get; set; }
  public Integer newHireCount { get; set; }

  private static final String WORKER_FIELDS =
    'Id, Name, Worker_Code__c, FirstName__c, LastName__c, ' +
    'LastNameKana__c, FirstNameKana__c, Email__c, Phone__c, Gender__c, BirthDate__c, ' +
    'Department__c, Department__r.Name, Position__c, EmploymentStatus__c, ContractType__c, ' +
    'HireDate__c, EndDate__c, Salary__c, PostalCode__c, Address__c, ' +
    'NearestStation__c, CommutingAllowance__c, BloodType__c, Nationality__c, ' +
    'EmergencyContactName__c, EmergencyContactPhone__c, ' +
    'InsuranceNumber__c, PensionNumber__c, MyNumber__c, ' +
    'BankName__c, BankBranch__c, BankAccountNumber__c, BankAccountType__c, Notes__c';

  public JIP_WorkerManagementController() {
    showModal = false;
    isEditMode = false;
    searchKeyword = '';
    filterStatus = '';
    filterContractType = '';
    filterDepartment = '';
    avatarUrlsByWorkerId = new Map<Id, String>();
    currentWorker = new JIP_Worker__c();
    loadStatistics();
    loadWorkers();
  }

  private void loadStatistics() {
    totalCount = [SELECT COUNT() FROM JIP_Worker__c];
    activeCount = [
      SELECT COUNT()
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c = '在職'
    ];
    leaveCount = [
      SELECT COUNT()
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c = '休職中'
    ];

    Date firstOfMonth = Date.today().toStartOfMonth();
    newHireCount = [
      SELECT COUNT()
      FROM JIP_Worker__c
      WHERE HireDate__c >= :firstOfMonth
    ];
  }

  public List<SelectOption> getDepartmentOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', 'すべて'));

    for (JIP_Department__c dept : [
      SELECT Id, Name
      FROM JIP_Department__c
      WHERE IsActive__c = TRUE
      ORDER BY Name
    ]) {
      options.add(new SelectOption(dept.Id, dept.Name));
    }
    return options;
  }

  public void loadWorkers() {
    List<String> conditions = new List<String>();

    if (String.isNotBlank(searchKeyword)) {
      String safeKeyword =
        '%' +
        String.escapeSingleQuotes(searchKeyword.trim()) +
        '%';
      conditions.add(
        '(Name LIKE :safeKeyword OR LastName__c LIKE :safeKeyword OR FirstName__c LIKE :safeKeyword OR Worker_Code__c LIKE :safeKeyword)'
      );
    }

    if (String.isNotBlank(filterStatus)) {
      conditions.add('EmploymentStatus__c = :filterStatus');
    }

    if (String.isNotBlank(filterContractType)) {
      conditions.add('ContractType__c = :filterContractType');
    }

    if (String.isNotBlank(filterDepartment)) {
      conditions.add('Department__c = :filterDepartment');
    }

    String query = 'SELECT ' + WORKER_FIELDS + ' FROM JIP_Worker__c';
    if (!conditions.isEmpty()) {
      query += ' WHERE ' + String.join(conditions, ' AND ');
    }
    query += ' ORDER BY Worker_Code__c ASC NULLS LAST LIMIT 200';

    workers = Database.query(query);
    loadAvatarImageUrls();
  }

  private void loadAvatarImageUrls() {
    avatarUrlsByWorkerId.clear();
    if (workers == null || workers.isEmpty()) {
      return;
    }

    Set<Id> workerIds = new Set<Id>();
    for (JIP_Worker__c w : workers) {
      if (w.Id != null) {
        workerIds.add(w.Id);
        // Pre-populate key to avoid Visualforce map key-not-found errors.
        avatarUrlsByWorkerId.put(w.Id, '');
      }
    }

    if (workerIds.isEmpty()) {
      return;
    }

    Set<String> imageTypes = new Set<String>{
      'PNG',
      'JPG',
      'JPEG',
      'GIF',
      'WEBP'
    };
    List<ContentDocumentLink> avatarLinks = [
      SELECT
        LinkedEntityId,
        ContentDocument.FileType,
        ContentDocument.LastModifiedDate,
        ContentDocument.LatestPublishedVersionId
      FROM ContentDocumentLink
      WHERE LinkedEntityId IN :workerIds
      ORDER BY LinkedEntityId ASC, ContentDocument.LastModifiedDate DESC
      LIMIT 1000
    ];

    for (ContentDocumentLink link : avatarLinks) {
      if (link.LinkedEntityId == null) {
        continue;
      }

      String fileType = link.ContentDocument.FileType != null
        ? link.ContentDocument.FileType.toUpperCase()
        : '';
      if (
        !imageTypes.contains(fileType) ||
        link.ContentDocument.LatestPublishedVersionId == null
      ) {
        continue;
      }

      // Only set if not already set (first image only per worker)
      if (String.isBlank(avatarUrlsByWorkerId.get(link.LinkedEntityId))) {
        avatarUrlsByWorkerId.put(
          link.LinkedEntityId,
          '/sfc/servlet.shepherd/version/download/' +
          link.ContentDocument.LatestPublishedVersionId
        );
      }
    }
  }

  public void searchWorkers() {
    loadWorkers();
  }

  public void clearSearch() {
    searchKeyword = '';
    filterStatus = '';
    filterContractType = '';
    filterDepartment = '';
    loadWorkers();
  }

  public PageReference exportCSV() {
    // TODO: Implement CSV export
    ApexPages.addMessage(
      new ApexPages.Message(
        ApexPages.Severity.INFO,
        'CSV出力機能は開発中です。'
      )
    );
    return null;
  }

  public void openNewModal() {
    currentWorker = new JIP_Worker__c();
    isEditMode = false;
    showModal = true;
  }

  public void openEditModal() {
    Id workerId = ApexPages.currentPage().getParameters().get('editId');
    if (workerId != null) {
      currentWorker = Database.query(
        'SELECT ' +
          WORKER_FIELDS +
          ' FROM JIP_Worker__c WHERE Id = :workerId LIMIT 1'
      );
      isEditMode = true;
      showModal = true;
    }
  }

  public void closeModal() {
    showModal = false;
    currentWorker = new JIP_Worker__c();
  }

  public void saveWorker() {
    try {
      if (isEditMode) {
        update currentWorker;
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            '社員情報を更新しました。'
          )
        );
      } else {
        insert currentWorker;
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            '新しい社員を登録しました。'
          )
        );
      }
      showModal = false;
      currentWorker = new JIP_Worker__c();
      loadStatistics();
      loadWorkers();
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'エラー: ' + e.getDmlMessage(0)
        )
      );
    }
  }

  public void deleteWorker() {
    try {
      if (deleteWorkerId != null) {
        JIP_Worker__c toDelete = [
          SELECT Id
          FROM JIP_Worker__c
          WHERE Id = :deleteWorkerId
          LIMIT 1
        ];
        delete toDelete;
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            '社員を削除しました。'
          )
        );
        loadStatistics();
        loadWorkers();
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
}