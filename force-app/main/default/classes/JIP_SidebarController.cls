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
public with sharing class JIP_SidebarController {
  public String projectIdParam { get; set; }

  public String getLanguage() {
    if (String.isBlank(projectIdParam)) {
      return 'ja';
    }
    try {
      List<JIP_Project__c> projects = [
        SELECT Language__c
        FROM JIP_Project__c
        WHERE Id = :projectIdParam
        LIMIT 1
      ];
      if (!projects.isEmpty() && String.isNotBlank(projects[0].Language__c)) {
        return projects[0].Language__c;
      }
    } catch (Exception e) {
      // Default to Japanese
    }
    return 'ja';
  }

  public Map<String, String> getT() {
    return JIP_TranslationHelper.getAllTranslations(getLanguage());
  }
}