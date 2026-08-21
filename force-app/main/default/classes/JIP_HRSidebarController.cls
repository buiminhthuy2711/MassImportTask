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
/**
 * @description Controller for HR Sidebar Component
 * Handles login check and session management
 */
public with sharing class JIP_HRSidebarController {
  // Session cookie keys (same as JIP_SystemLoginController)
  private static final String SESSION_WORKER_ID = 'JIP_WorkerId';
  private static final String SESSION_WORKER_NAME = 'JIP_WorkerName';
  private static final String SESSION_ROLE = 'JIP_Role';
  private static final String SESSION_LOGIN_TYPE = 'JIP_LoginType';

  // Current user info
  public Boolean isLoggedIn { get; set; }
  public String currentWorkerName { get; set; }
  public String currentRole { get; set; }
  public String currentWorkerId { get; set; }
  public String currentLoginType { get; set; }
  public Boolean isSalesforceUser { get; set; }
  public String logoutUrl { get; set; }
  public String avatarUrl { get; set; }

  /**
   * @description Constructor - check login status
   */
  public JIP_HRSidebarController() {
    checkLoginStatus();
  }

  /**
   * @description Check if user is logged in via cookies or Salesforce User
   */
  private void checkLoginStatus() {
    isSalesforceUser = false;
    logoutUrl = '/apex/JIP_SystemLoginPage?logout=1';
    avatarUrl = '';

    try {
      // First, check if current Salesforce user has a linked Worker account
      Id currentUserId = UserInfo.getUserId();
      if (currentUserId != null) {
        List<JIP_Worker__c> linkedWorkers = [
          SELECT
            Id,
            Name,
            LastName__c,
            FirstName__c,
            SystemRole__c,
            SystemLoginType__c,
            SystemAccountActive__c
          FROM JIP_Worker__c
          WHERE
            User__c = :currentUserId
            AND SystemLoginType__c = 'SalesforceUser'
            AND SystemAccountActive__c = TRUE
          LIMIT 1
        ];

        if (!linkedWorkers.isEmpty()) {
          // Salesforce User is linked to a Worker - auto login
          JIP_Worker__c worker = linkedWorkers[0];
          isLoggedIn = true;
          isSalesforceUser = true;
          currentWorkerId = worker.Id;
          currentWorkerName =
            (worker.LastName__c != null ? worker.LastName__c : '') +
            ' ' +
            (worker.FirstName__c != null ? worker.FirstName__c : '');
          currentRole = worker.SystemRole__c;
          currentLoginType = 'SalesforceUser';
          logoutUrl = '/secur/logout.jsp';
          // Load avatar from ContentDocumentLink
          loadWorkerAvatar(worker.Id);
          return;
        }
      }

      // If not a Salesforce linked user, check cookies for Guest login
      Map<String, Cookie> cookies = ApexPages.currentPage().getCookies();
      Cookie workerIdCookie = cookies.get(SESSION_WORKER_ID);

      if (
        workerIdCookie != null && String.isNotBlank(workerIdCookie.getValue())
      ) {
        isLoggedIn = true;
        currentWorkerId = workerIdCookie.getValue();

        Cookie nameCookie = cookies.get(SESSION_WORKER_NAME);
        currentWorkerName = nameCookie != null ? nameCookie.getValue() : '';

        Cookie roleCookie = cookies.get(SESSION_ROLE);
        currentRole = roleCookie != null ? roleCookie.getValue() : '';

        Cookie loginTypeCookie = cookies.get(SESSION_LOGIN_TYPE);
        currentLoginType = loginTypeCookie != null
          ? loginTypeCookie.getValue()
          : 'Guest';

        // Load avatar from ContentDocumentLink for Guest too
        loadWorkerAvatar(currentWorkerId);
      } else {
        isLoggedIn = false;
        currentWorkerId = '';
        currentWorkerName = '';
        currentRole = '';
        currentLoginType = '';
      }
    } catch (Exception ex) {
      isLoggedIn = false;
      currentWorkerId = '';
      currentWorkerName = '';
      currentRole = '';
      currentLoginType = '';
    }
  }

  /**
   * @description Get role display label
   */
  public String getRoleLabel() {
    if (currentRole == 'Admin') {
      return '管理者';
    } else if (currentRole == 'Manager') {
      return 'マネージャー';
    } else if (currentRole == 'Employee') {
      return '従業員';
    } else if (currentRole == 'ReadOnly') {
      return '閲覧者';
    }
    return currentRole;
  }

  /**
   * @description Logout action
   */
  public PageReference doLogout() {
    // Clear all session cookies with path '/' and null for backward compatibility
    Cookie c1 = new Cookie(SESSION_WORKER_ID, '', '/', 0, false);
    Cookie c2 = new Cookie(SESSION_WORKER_NAME, '', '/', 0, false);
    Cookie c3 = new Cookie(SESSION_ROLE, '', '/', 0, false);
    Cookie c4 = new Cookie(SESSION_LOGIN_TYPE, '', '/', 0, false);
    Cookie c5 = new Cookie(SESSION_WORKER_ID, '', null, 0, false);
    Cookie c6 = new Cookie(SESSION_WORKER_NAME, '', null, 0, false);
    Cookie c7 = new Cookie(SESSION_ROLE, '', null, 0, false);
    Cookie c8 = new Cookie(SESSION_LOGIN_TYPE, '', null, 0, false);
    ApexPages.currentPage()
      .setCookies(new List<Cookie>{ c1, c2, c3, c4, c5, c6, c7, c8 });

    // Redirect to login page
    PageReference pr = Page.JIP_SystemLoginPage;
    pr.setRedirect(true);
    return pr;
  }

  /**
   * @description Check if current user has admin role
   */
  public Boolean getIsAdmin() {
    return currentRole == 'Admin';
  }

  /**
   * @description Check if current user has manager role
   */
  public Boolean getIsManager() {
    return currentRole == 'Manager' || currentRole == 'Admin';
  }

  /**
   * @description Load worker avatar from ContentDocumentLink
   */
  private void loadWorkerAvatar(String workerId) {
    avatarUrl = '';

    if (String.isBlank(workerId)) {
      return;
    }

    try {
      List<ContentDocumentLink> avatarLinks = [
        SELECT
          ContentDocument.LatestPublishedVersionId,
          ContentDocument.FileType,
          ContentDocument.LastModifiedDate
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :workerId
        ORDER BY ContentDocument.LastModifiedDate DESC
        LIMIT 10
      ];

      Set<String> imageTypes = new Set<String>{
        'PNG',
        'JPG',
        'JPEG',
        'GIF',
        'WEBP'
      };

      for (ContentDocumentLink link : avatarLinks) {
        String fileType = link.ContentDocument.FileType != null
          ? link.ContentDocument.FileType.toUpperCase()
          : '';
        if (
          imageTypes.contains(fileType) &&
          link.ContentDocument.LatestPublishedVersionId != null
        ) {
          avatarUrl =
            '/sfc/servlet.shepherd/version/download/' +
            link.ContentDocument.LatestPublishedVersionId;
          break;
        }
      }
    } catch (Exception ex) {
      avatarUrl = '';
    }
  }
}