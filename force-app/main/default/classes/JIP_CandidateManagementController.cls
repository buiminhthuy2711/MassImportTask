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
public with sharing class JIP_CandidateManagementController {
  public List<JIP_Candidate__c> candidates { get; set; }
  public JIP_Candidate__c currentCandidate { get; set; }
  public String searchKeyword { get; set; }
  public Boolean showModal { get; set; }
  public Boolean isEditMode { get; set; }
  public Id deleteCandidateId { get; set; }
  public String filterPipeline { get; set; }
  public String filterStatus { get; set; }

  private static final String CANDIDATE_FIELDS =
    'Id, Name, Name__c, Full_name__c, Email__c, Phone__c, ' +
    'Nationality__c, Location__c, CurrentStatus__c, PipelineStatus__c, Source__c, ' +
    'EngLishLevel__c, JapaneseLevel__c, JapaneseConversation__c, ' +
    'ExpectedRate__c, AvailabilityDate__c, VisaStatus__c, VisaExpiry__c, Work_Style__c';

  public JIP_CandidateManagementController() {
    showModal = false;
    isEditMode = false;
    searchKeyword = '';
    filterPipeline = '';
    filterStatus = '';
    currentCandidate = new JIP_Candidate__c();
    loadCandidates();
  }

  public void loadCandidates() {
    String query = 'SELECT ' + CANDIDATE_FIELDS + ' FROM JIP_Candidate__c';
    List<String> conditions = new List<String>();

    if (String.isNotBlank(searchKeyword)) {
      String safeKeyword =
        '%' +
        String.escapeSingleQuotes(searchKeyword.trim()) +
        '%';
      conditions.add(
        '(Name LIKE :safeKeyword OR Full_name__c LIKE :safeKeyword OR Email__c LIKE :safeKeyword OR Location__c LIKE :safeKeyword)'
      );
    }
    if (String.isNotBlank(filterPipeline)) {
      conditions.add('PipelineStatus__c = :filterPipeline');
    }
    if (String.isNotBlank(filterStatus)) {
      conditions.add('CurrentStatus__c = :filterStatus');
    }

    if (!conditions.isEmpty()) {
      query += ' WHERE ' + String.join(conditions, ' AND ');
    }
    query += ' ORDER BY CreatedDate DESC LIMIT 200';
    candidates = Database.query(query);
  }

  public void searchCandidates() {
    loadCandidates();
  }

  public void clearSearch() {
    searchKeyword = '';
    filterPipeline = '';
    filterStatus = '';
    loadCandidates();
  }

  public void openNewModal() {
    currentCandidate = new JIP_Candidate__c();
    isEditMode = false;
    showModal = true;
  }

  public void openEditModal() {
    Id candidateId = ApexPages.currentPage().getParameters().get('editId');
    if (candidateId != null) {
      currentCandidate = Database.query(
        'SELECT ' +
          CANDIDATE_FIELDS +
          ' FROM JIP_Candidate__c WHERE Id = :candidateId LIMIT 1'
      );
      isEditMode = true;
      showModal = true;
    }
  }

  public void closeModal() {
    showModal = false;
    currentCandidate = new JIP_Candidate__c();
  }

  public void saveCandidate() {
    try {
      if (isEditMode) {
        update currentCandidate;
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            '候補者情報を更新しました。'
          )
        );
      } else {
        insert currentCandidate;
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            '新しい候補者を登録しました。'
          )
        );
      }
      showModal = false;
      currentCandidate = new JIP_Candidate__c();
      loadCandidates();
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'エラー: ' + e.getDmlMessage(0)
        )
      );
    }
  }

  public void deleteCandidate() {
    try {
      if (deleteCandidateId != null) {
        JIP_Candidate__c toDelete = [
          SELECT Id
          FROM JIP_Candidate__c
          WHERE Id = :deleteCandidateId
          LIMIT 1
        ];
        delete toDelete;
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            '候補者を削除しました。'
          )
        );
        loadCandidates();
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

  public List<SelectOption> getPipelineOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', '-- 全て --'));
    options.add(new SelectOption('New', 'New'));
    options.add(new SelectOption('Applied', 'Applied'));
    options.add(new SelectOption('Screening', 'Screening'));
    options.add(new SelectOption('Interview', 'Interview'));
    options.add(new SelectOption('Offer', 'Offer'));
    options.add(new SelectOption('Hired', 'Hired'));
    options.add(new SelectOption('Rejected', 'Rejected'));
    return options;
  }

  public List<SelectOption> getStatusOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', '-- 全て --'));
    options.add(new SelectOption('Active', 'Active'));
    options.add(new SelectOption('Inactive', 'Inactive'));
    options.add(new SelectOption('None', 'None'));
    return options;
  }
}