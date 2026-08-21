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
public with sharing class JIP_ProjectHomeController {
  // Project
  public Id selectedProjectId { get; set; }
  public JIP_Project__c project { get; set; }

  public JIP_ProjectHomeController() {
    String pid = ApexPages.currentPage().getParameters().get('projectId');
    if (String.isNotBlank(pid)) {
      try {
        selectedProjectId = (Id) pid;
      } catch (Exception e) {
        selectedProjectId = null;
      }
    }

    if (selectedProjectId != null) {
      loadProject();
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

  public String getProjectName() {
    if (project == null)
      return '';
    return project.Name__c != null ? project.Name__c : project.Name;
  }

  public String getProjectKey() {
    if (project == null)
      return '';
    return project.Name;
  }

  // ===== Multi-language support =====
  public String getLanguage() {
    if (project == null || String.isBlank(project.Language__c)) {
      return 'ja';
    }
    return project.Language__c;
  }

  public Map<String, String> getT() {
    return JIP_TranslationHelper.getAllTranslations(getLanguage());
  }
}