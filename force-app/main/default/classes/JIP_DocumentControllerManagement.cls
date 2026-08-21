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
public with sharing class JIP_DocumentControllerManagement {
  // Project selection
  public Id selectedProjectId { get; set; }
  public List<JIP_Project__c> projectList { get; set; }

  // Document tree
  public List<JIP_ProjectDocument__c> documentList { get; set; }
  public String documentTreeJson { get; set; }

  // Selected document
  public JIP_ProjectDocument__c selectedDocument { get; set; }
  public Id selectedDocumentId { get; set; }
  public Boolean isEditMode { get; set; }

  // New/Rename
  public String newDocTitle { get; set; }
  public Id newDocParentId { get; set; }

  // Search
  public String searchKeyword { get; set; }

  // Trash view
  public Boolean showTrash { get; set; }
  public List<JIP_ProjectDocument__c> trashList { get; set; }

  // Breadcrumb
  public String breadcrumbJson { get; set; }

  public JIP_DocumentControllerManagement() {
    projectList = [
      SELECT Id, Name, Name__c, Status__c
      FROM JIP_Project__c
      ORDER BY Name ASC
      LIMIT 200
    ];
    isEditMode = false;
    showTrash = false;
    searchKeyword = '';
    newDocTitle = '';
    trashList = new List<JIP_ProjectDocument__c>();

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

    String docId = ApexPages.currentPage().getParameters().get('docId');
    if (String.isNotBlank(docId)) {
      try {
        selectedDocumentId = (Id) docId;
      } catch (Exception e) {
        selectedDocumentId = null;
      }
    }

    loadDocuments();

    if (selectedDocumentId != null) {
      loadSelectedDocument();
    } else if (!documentList.isEmpty()) {
      selectedDocumentId = documentList[0].Id;
      loadSelectedDocument();
    }
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

  // ===== Actions =====
  public void selectProject() {
    selectedDocumentId = null;
    selectedDocument = null;
    isEditMode = false;
    showTrash = false;
    loadDocuments();
    if (!documentList.isEmpty()) {
      selectedDocumentId = documentList[0].Id;
      loadSelectedDocument();
    }
  }

  public void selectDocument() {
    showTrash = false;
    isEditMode = false;
    loadSelectedDocument();
  }

  public void enterEditMode() {
    isEditMode = true;
  }

  public void cancelEdit() {
    isEditMode = false;
    loadSelectedDocument();
  }

  public void saveDocument() {
    if (selectedDocument == null) {
      return;
    }
    try {
      update selectedDocument;
      isEditMode = false;
      loadDocuments();
      loadSelectedDocument();
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          '保存エラー: ' + e.getMessage()
        )
      );
    }
  }

  public void createDocument() {
    if (selectedProjectId == null) {
      return;
    }
    try {
      String title = String.isNotBlank(newDocTitle) ? newDocTitle : '無題';
      JIP_ProjectDocument__c doc = new JIP_ProjectDocument__c(
        Title__c = title,
        Project__c = selectedProjectId,
        ParentDocument__c = newDocParentId,
        Content__c = '',
        SortOrder__c = documentList.size(),
        IsInTrash__c = false
      );
      insert doc;
      newDocTitle = '';
      newDocParentId = null;
      loadDocuments();
      selectedDocumentId = doc.Id;
      loadSelectedDocument();
      isEditMode = true;
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          '作成エラー: ' + e.getMessage()
        )
      );
    }
  }

  public void createChildDocument() {
    if (selectedProjectId == null || newDocParentId == null) {
      return;
    }
    try {
      String title = String.isNotBlank(newDocTitle) ? newDocTitle : '無題';
      JIP_ProjectDocument__c doc = new JIP_ProjectDocument__c(
        Title__c = title,
        Project__c = selectedProjectId,
        ParentDocument__c = newDocParentId,
        Content__c = '',
        SortOrder__c = 0,
        IsInTrash__c = false
      );
      insert doc;
      newDocTitle = '';
      newDocParentId = null;
      loadDocuments();
      selectedDocumentId = doc.Id;
      loadSelectedDocument();
      isEditMode = true;
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          '作成エラー: ' + e.getMessage()
        )
      );
    }
  }

  public void moveToTrash() {
    if (selectedDocumentId == null) {
      return;
    }
    try {
      JIP_ProjectDocument__c doc = new JIP_ProjectDocument__c(
        Id = selectedDocumentId,
        IsInTrash__c = true
      );
      update doc;
      selectedDocumentId = null;
      selectedDocument = null;
      isEditMode = false;
      loadDocuments();
      if (!documentList.isEmpty()) {
        selectedDocumentId = documentList[0].Id;
        loadSelectedDocument();
      }
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          '削除エラー: ' + e.getMessage()
        )
      );
    }
  }

  public void restoreFromTrash() {
    if (selectedDocumentId == null) {
      return;
    }
    try {
      JIP_ProjectDocument__c doc = new JIP_ProjectDocument__c(
        Id = selectedDocumentId,
        IsInTrash__c = false
      );
      update doc;
      selectedDocumentId = null;
      selectedDocument = null;
      showTrash = true;
      loadDocuments();
      loadTrash();
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          '復元エラー: ' + e.getMessage()
        )
      );
    }
  }

  public void deleteFromTrash() {
    if (selectedDocumentId == null) {
      return;
    }
    try {
      JIP_ProjectDocument__c doc = [
        SELECT Id
        FROM JIP_ProjectDocument__c
        WHERE Id = :selectedDocumentId
        LIMIT 1
      ];
      delete doc;
      selectedDocumentId = null;
      selectedDocument = null;
      loadTrash();
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          '完全削除エラー: ' + e.getMessage()
        )
      );
    }
  }

  public void openTrash() {
    showTrash = true;
    selectedDocument = null;
    selectedDocumentId = null;
    isEditMode = false;
    loadTrash();
  }

  public void closeTrash() {
    showTrash = false;
    loadDocuments();
    if (!documentList.isEmpty()) {
      selectedDocumentId = documentList[0].Id;
      loadSelectedDocument();
    }
  }

  public void searchDocuments() {
    loadDocuments();
  }

  // ===== Data Loading =====
  private void loadDocuments() {
    if (selectedProjectId == null) {
      documentList = new List<JIP_ProjectDocument__c>();
      documentTreeJson = '[]';
      return;
    }

    String soql =
      'SELECT Id, Name, Title__c, ParentDocument__c, SortOrder__c, ' +
      'CreatedDate, LastModifiedDate, CreatedByName__c ' +
      'FROM JIP_ProjectDocument__c ' +
      'WHERE Project__c = :selectedProjectId AND IsInTrash__c = false';

    if (String.isNotBlank(searchKeyword)) {
      String likeKey = '%' + String.escapeSingleQuotes(searchKeyword) + '%';
      soql += ' AND Title__c LIKE :likeKey';
    }

    soql += ' ORDER BY SortOrder__c ASC, CreatedDate ASC LIMIT 500';
    documentList = Database.query(soql);
    buildDocumentTree();
  }

  private void loadSelectedDocument() {
    if (selectedDocumentId == null) {
      selectedDocument = null;
      breadcrumbJson = '[]';
      return;
    }
    List<JIP_ProjectDocument__c> docs = [
      SELECT
        Id,
        Name,
        Title__c,
        Content__c,
        ParentDocument__c,
        Project__c,
        SortOrder__c,
        IsInTrash__c,
        CreatedDate,
        LastModifiedDate,
        CreatedByName__c
      FROM JIP_ProjectDocument__c
      WHERE Id = :selectedDocumentId
      LIMIT 1
    ];
    if (!docs.isEmpty()) {
      selectedDocument = docs[0];
      buildBreadcrumb();
    } else {
      selectedDocument = null;
      breadcrumbJson = '[]';
    }
  }

  private void loadTrash() {
    if (selectedProjectId == null) {
      trashList = new List<JIP_ProjectDocument__c>();
      return;
    }
    trashList = [
      SELECT Id, Name, Title__c, CreatedDate, LastModifiedDate
      FROM JIP_ProjectDocument__c
      WHERE Project__c = :selectedProjectId AND IsInTrash__c = TRUE
      ORDER BY LastModifiedDate DESC
      LIMIT 200
    ];
  }

  // Build JSON tree for JavaScript rendering
  private void buildDocumentTree() {
    // Build parent-child map
    Map<Id, List<JIP_ProjectDocument__c>> childrenMap = new Map<Id, List<JIP_ProjectDocument__c>>();
    List<JIP_ProjectDocument__c> roots = new List<JIP_ProjectDocument__c>();

    for (JIP_ProjectDocument__c d : documentList) {
      if (d.ParentDocument__c == null) {
        roots.add(d);
      } else {
        if (!childrenMap.containsKey(d.ParentDocument__c)) {
          childrenMap.put(
            d.ParentDocument__c,
            new List<JIP_ProjectDocument__c>()
          );
        }
        childrenMap.get(d.ParentDocument__c).add(d);
      }
    }

    List<Map<String, Object>> tree = new List<Map<String, Object>>();
    for (JIP_ProjectDocument__c r : roots) {
      tree.add(buildNode(r, childrenMap));
    }
    documentTreeJson = JSON.serialize(tree);
  }

  private Map<String, Object> buildNode(
    JIP_ProjectDocument__c doc,
    Map<Id, List<JIP_ProjectDocument__c>> childrenMap
  ) {
    Map<String, Object> node = new Map<String, Object>();
    node.put('id', doc.Id);
    node.put('title', doc.Title__c != null ? doc.Title__c : '無題');
    node.put('name', doc.Name);

    List<Map<String, Object>> children = new List<Map<String, Object>>();
    if (childrenMap.containsKey(doc.Id)) {
      for (JIP_ProjectDocument__c child : childrenMap.get(doc.Id)) {
        children.add(buildNode(child, childrenMap));
      }
    }
    node.put('children', children);
    return node;
  }

  // Build breadcrumb path from selected document to root
  private void buildBreadcrumb() {
    List<Map<String, String>> crumbs = new List<Map<String, String>>();
    if (selectedDocument == null) {
      breadcrumbJson = '[]';
      return;
    }

    // Build a lookup map from loaded documents
    Map<Id, JIP_ProjectDocument__c> docMap = new Map<Id, JIP_ProjectDocument__c>();
    for (JIP_ProjectDocument__c d : documentList) {
      docMap.put(d.Id, d);
    }

    // Walk up the parent chain
    Id currentId = selectedDocument.Id;
    Integer safety = 0;
    while (currentId != null && safety < 10) {
      JIP_ProjectDocument__c d = docMap.get(currentId);
      if (d == null) {
        break;
      }
      Map<String, String> crumb = new Map<String, String>();
      crumb.put('id', d.Id);
      crumb.put('title', d.Title__c != null ? d.Title__c : '無題');
      crumbs.add(crumb);
      currentId = d.ParentDocument__c;
      safety++;
    }
    // Reverse list to get root-to-leaf order
    List<Map<String, String>> reversed = new List<Map<String, String>>();
    for (Integer i = crumbs.size() - 1; i >= 0; i--) {
      reversed.add(crumbs.get(i));
    }
    breadcrumbJson = JSON.serialize(reversed);
  }
}