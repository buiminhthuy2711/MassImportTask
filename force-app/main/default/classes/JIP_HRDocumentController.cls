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
public with sharing class JIP_HRDocumentController {
  // ===== Properties =====
  public String language { get; set; }
  public String searchKeyword { get; set; }
  public String filterCategory { get; set; }
  public String selectedTab { get; set; }

  // Data lists
  public List<DocumentWrapper> documents { get; set; }
  public List<TemplateWrapper> templates { get; set; }
  public List<ContractWrapper> contracts { get; set; }

  // Modal control
  public Boolean showUploadModal { get; set; }
  public JIP_Document__c newDocument { get; set; }

  // Statistics
  public Integer totalDocuments { get; set; }
  public Integer pendingContracts { get; set; }
  public Integer expiringContracts { get; set; }
  public Integer templatesCount { get; set; }

  // ===== Constructor =====
  public JIP_HRDocumentController() {
    language = 'ja';
    searchKeyword = '';
    filterCategory = '';
    selectedTab = 'documents';
    showUploadModal = false;
    newDocument = new JIP_Document__c();

    loadStatistics();
    loadDocuments();
    loadTemplates();
    loadContracts();
  }

  // ===== Multi-language Support =====
  public String getLanguage() {
    return String.isBlank(language) ? 'ja' : language;
  }

  public Map<String, String> getT() {
    return JIP_TranslationHelper.getAllTranslations(getLanguage());
  }

  // ===== Data Loading Methods =====
  private void loadStatistics() {
    totalDocuments = [
      SELECT COUNT()
      FROM JIP_Document__c
      WHERE IsActive__c = TRUE
    ];
    templatesCount = [
      SELECT COUNT()
      FROM JIP_Document__c
      WHERE DocumentType__c = 'Template' AND IsActive__c = TRUE
    ];
    pendingContracts = [
      SELECT COUNT()
      FROM JIP_Contract__c
      WHERE Status__c = 'Pending'
    ];
    expiringContracts = [
      SELECT COUNT()
      FROM JIP_Contract__c
      WHERE
        Status__c = 'Active'
        AND ExpirationDate__c <= :Date.today().addDays(30)
        AND ExpirationDate__c >= :Date.today()
    ];
  }

  private void loadDocuments() {
    documents = new List<DocumentWrapper>();

    String query =
      'SELECT Id, Name, DocumentType__c, Category__c, Description__c, ' +
      'UploadedBy__c, UploadedBy__r.Name, UploadDate__c, FileSize__c, FileExtension__c, ' +
      'DownloadCount__c, IsActive__c, LastModifiedDate ' +
      'FROM JIP_Document__c WHERE IsActive__c = true';

    if (String.isNotBlank(filterCategory)) {
      query += ' AND Category__c = :filterCategory';
    }

    if (String.isNotBlank(searchKeyword)) {
      String safeKeyword =
        '%' +
        String.escapeSingleQuotes(searchKeyword.trim()) +
        '%';
      query += ' AND Name LIKE :safeKeyword';
    }

    query += ' ORDER BY LastModifiedDate DESC LIMIT 200';

    for (JIP_Document__c d : Database.query(query)) {
      documents.add(new DocumentWrapper(d, getT()));
    }
  }

  private void loadTemplates() {
    templates = new List<TemplateWrapper>();

    for (JIP_Document__c t : [
      SELECT
        Id,
        Name,
        Category__c,
        Description__c,
        FileExtension__c,
        DownloadCount__c,
        LastModifiedDate
      FROM JIP_Document__c
      WHERE DocumentType__c = 'Template' AND IsActive__c = TRUE
      ORDER BY Category__c, Name
      LIMIT 100
    ]) {
      templates.add(new TemplateWrapper(t, getT()));
    }
  }

  private void loadContracts() {
    contracts = new List<ContractWrapper>();

    for (JIP_Contract__c c : [
      SELECT
        Id,
        Name,
        Worker__c,
        Worker__r.Name,
        Worker__r.LastName__c,
        Worker__r.FirstName__c,
        Worker__r.Worker_Code__c,
        Worker__r.Department__r.Name,
        ContractType__c,
        StartDate__c,
        ExpirationDate__c,
        Status__c
      FROM JIP_Contract__c
      WHERE Status__c IN ('Active', 'Pending')
      ORDER BY ExpirationDate__c ASC NULLS LAST
      LIMIT 200
    ]) {
      contracts.add(new ContractWrapper(c, getT()));
    }
  }

  // ===== Action Methods =====
  public void search() {
    loadDocuments();
  }

  public void clearSearch() {
    searchKeyword = '';
    filterCategory = '';
    loadDocuments();
  }

  public void changeTab() {
    // Tab bound via property
  }

  public void openUploadModal() {
    newDocument = new JIP_Document__c();
    newDocument.IsActive__c = true;
    newDocument.UploadDate__c = Date.today();
    showUploadModal = true;
  }

  public void closeUploadModal() {
    showUploadModal = false;
    newDocument = new JIP_Document__c();
  }

  public void uploadDocument() {
    try {
      insert newDocument;

      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.CONFIRM,
          getT().get('upload_complete')
        )
      );

      showUploadModal = false;
      newDocument = new JIP_Document__c();
      loadStatistics();
      loadDocuments();
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0))
      );
    }
  }

  public void downloadDocument() {
    try {
      Id docId = ApexPages.currentPage().getParameters().get('docId');
      if (docId != null) {
        JIP_Document__c doc = [
          SELECT Id, DownloadCount__c
          FROM JIP_Document__c
          WHERE Id = :docId
          LIMIT 1
        ];
        doc.DownloadCount__c =
          (doc.DownloadCount__c == null ? 0 : doc.DownloadCount__c) + 1;
        update doc;

        loadDocuments();
      }
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void deleteDocument() {
    try {
      Id docId = ApexPages.currentPage().getParameters().get('deleteId');
      if (docId != null) {
        JIP_Document__c doc = [
          SELECT Id
          FROM JIP_Document__c
          WHERE Id = :docId
          LIMIT 1
        ];
        doc.IsActive__c = false; // Soft delete
        update doc;

        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            getT().get('doc_deleted')
          )
        );

        loadStatistics();
        loadDocuments();
      }
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0))
      );
    }
  }

  public void renewContract() {
    try {
      Id contractId = ApexPages.currentPage().getParameters().get('contractId');
      if (contractId != null) {
        // Contract renewal logic here
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.INFO,
            getT().get('contract_renewal') + ': ' + getT().get('in_progress')
          )
        );
      }
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void changeLanguage() {
    loadDocuments();
    loadTemplates();
    loadContracts();
  }

  // ===== Select Options =====
  public List<SelectOption> getCategoryOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', getT().get('all')));
    options.add(new SelectOption('contract', getT().get('contracts')));
    options.add(new SelectOption('policy', getT().get('policies')));
    options.add(new SelectOption('manual', getT().get('manuals')));
    options.add(new SelectOption('template', getT().get('templates')));
    options.add(new SelectOption('form', getT().get('forms')));
    options.add(new SelectOption('report', getT().get('reports')));
    return options;
  }

  public List<SelectOption> getDocumentTypeOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('Document', getT().get('doc_document')));
    options.add(new SelectOption('Template', getT().get('doc_template')));
    options.add(new SelectOption('Policy', getT().get('policies')));
    options.add(new SelectOption('Manual', getT().get('manuals')));
    return options;
  }

  public List<SelectOption> getTabOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('documents', getT().get('doc_document')));
    options.add(new SelectOption('contracts', getT().get('contracts')));
    options.add(new SelectOption('templates', getT().get('templates')));
    options.add(new SelectOption('policies', getT().get('policies')));
    return options;
  }

  public List<SelectOption> getLanguageOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('ja', '日本語'));
    options.add(new SelectOption('en', 'English'));
    return options;
  }

  // ===== Wrapper Classes =====
  public class DocumentWrapper {
    public JIP_Document__c record { get; set; }
    public String docName { get; set; }
    public String docType { get; set; }
    public String category { get; set; }
    public String categoryLabel { get; set; }
    public String description { get; set; }
    public String uploadedBy { get; set; }
    public Date uploadDate { get; set; }
    public String fileSize { get; set; }
    public String fileExtension { get; set; }
    public Integer downloadCount { get; set; }
    public String iconClass { get; set; }

    public DocumentWrapper(JIP_Document__c d, Map<String, String> t) {
      this.record = d;
      this.docName = d.Name;
      this.docType = d.DocumentType__c;
      this.category = d.Category__c;
      this.description = d.Description__c;
      this.uploadedBy = d.UploadedBy__r != null ? d.UploadedBy__r.Name : '-';
      this.uploadDate = d.UploadDate__c;
      this.downloadCount = d.DownloadCount__c != null
        ? Integer.valueOf(d.DownloadCount__c)
        : 0;
      this.fileExtension = d.FileExtension__c;

      // Category label
      if (d.Category__c == 'contract') {
        this.categoryLabel = t.get('contracts');
      } else if (d.Category__c == 'policy') {
        this.categoryLabel = t.get('policies');
      } else if (d.Category__c == 'manual') {
        this.categoryLabel = t.get('manuals');
      } else if (d.Category__c == 'template') {
        this.categoryLabel = t.get('templates');
      } else {
        this.categoryLabel = d.Category__c;
      }

      // File size formatting
      if (d.FileSize__c != null) {
        Decimal sizeKb = d.FileSize__c / 1024;
        if (sizeKb < 1024) {
          this.fileSize = sizeKb.setScale(1) + ' KB';
        } else {
          this.fileSize = (sizeKb / 1024).setScale(1) + ' MB';
        }
      } else {
        this.fileSize = '-';
      }

      // Icon based on file type
      if (d.FileExtension__c == 'pdf') {
        this.iconClass = 'doctype:pdf';
      } else if (d.FileExtension__c == 'xlsx' || d.FileExtension__c == 'xls') {
        this.iconClass = 'doctype:excel';
      } else if (d.FileExtension__c == 'docx' || d.FileExtension__c == 'doc') {
        this.iconClass = 'doctype:word';
      } else if (d.FileExtension__c == 'pptx' || d.FileExtension__c == 'ppt') {
        this.iconClass = 'doctype:ppt';
      } else {
        this.iconClass = 'doctype:unknown';
      }
    }
  }

  public class TemplateWrapper {
    public JIP_Document__c record { get; set; }
    public String templateName { get; set; }
    public String category { get; set; }
    public String description { get; set; }
    public String fileExtension { get; set; }
    public Integer downloadCount { get; set; }
    public Datetime lastModified { get; set; }

    public TemplateWrapper(
      JIP_Document__c t,
      Map<String, String> translations
    ) {
      this.record = t;
      this.templateName = t.Name;
      this.category = t.Category__c;
      this.description = t.Description__c;
      this.fileExtension = t.FileExtension__c;
      this.downloadCount = t.DownloadCount__c != null
        ? Integer.valueOf(t.DownloadCount__c)
        : 0;
      this.lastModified = t.LastModifiedDate;
    }
  }

  public class ContractWrapper {
    public JIP_Contract__c record { get; set; }
    public String contractNumber { get; set; }
    public String employeeCode { get; set; }
    public String employeeName { get; set; }
    public String departmentName { get; set; }
    public String contractType { get; set; }
    public Date startDate { get; set; }
    public Date expirationDate { get; set; }
    public String status { get; set; }
    public String statusClass { get; set; }
    public Boolean isExpiringSoon { get; set; }
    public Integer daysRemaining { get; set; }

    public ContractWrapper(JIP_Contract__c c, Map<String, String> t) {
      this.record = c;
      this.contractNumber = c.Name;
      this.contractType = c.ContractType__c;
      this.startDate = c.StartDate__c;
      this.expirationDate = c.ExpirationDate__c;

      // Employee info
      if (c.Worker__r != null) {
        this.employeeCode = c.Worker__r.Worker_Code__c;
        if (c.Worker__r.LastName__c != null) {
          this.employeeName = c.Worker__r.LastName__c;
          if (c.Worker__r.FirstName__c != null) {
            this.employeeName += ' ' + c.Worker__r.FirstName__c;
          }
        } else {
          this.employeeName = c.Worker__r.Name;
        }
        this.departmentName = c.Worker__r.Department__r != null
          ? c.Worker__r.Department__r.Name
          : '-';
      }

      // Calculate expiration
      if (c.ExpirationDate__c != null) {
        this.daysRemaining = Date.today().daysBetween(c.ExpirationDate__c);
        this.isExpiringSoon =
          this.daysRemaining <= 30 &&
          this.daysRemaining >= 0;
      } else {
        this.daysRemaining = -1;
        this.isExpiringSoon = false;
      }

      // Status styling
      if (c.Status__c == 'Active') {
        if (isExpiringSoon) {
          this.status = t.get('contract_expiring');
          this.statusClass = 'slds-badge slds-badge_warning';
        } else {
          this.status = t.get('active');
          this.statusClass = 'slds-badge slds-badge_success';
        }
      } else if (c.Status__c == 'Pending') {
        this.status = t.get('pending_signature');
        this.statusClass = 'slds-badge slds-badge_info';
      } else if (c.Status__c == 'Expired') {
        this.status = t.get('expired');
        this.statusClass = 'slds-badge slds-badge_error';
      } else {
        this.status = c.Status__c;
        this.statusClass = 'slds-badge';
      }
    }
  }
}