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
 * @description Controller for System Login Page
 * Handles authentication for both Guest and Salesforce User accounts
 */
public without sharing class JIP_SystemLoginController {
  // Login credentials
  public String username { get; set; }
  public String password { get; set; }
  public Boolean rememberMe { get; set; }

  // Error handling
  public String errorMessage { get; set; }
  public Boolean hasError { get; set; }

  // Session info
  public static final String SESSION_WORKER_ID = 'JIP_WorkerId';
  public static final String SESSION_WORKER_NAME = 'JIP_WorkerName';
  public static final String SESSION_ROLE = 'JIP_Role';
  public static final String SESSION_LOGIN_TYPE = 'JIP_LoginType';

  /**
   * @description Constructor
   */
  public JIP_SystemLoginController() {
    username = '';
    password = '';
    rememberMe = false;
    errorMessage = '';
    hasError = false;

    // Check for logout parameter
    String logoutParam = ApexPages.currentPage().getParameters().get('logout');
    if (logoutParam == '1') {
      clearSession();
    }
  }

  /**
   * @description Attempt to login
   */
  public PageReference doLogin() {
    hasError = false;
    errorMessage = '';

    // Validate input
    if (String.isBlank(username)) {
      hasError = true;
      errorMessage = 'ログインIDを入力してください。';
      return null;
    }

    if (String.isBlank(password)) {
      hasError = true;
      errorMessage = 'パスワードを入力してください。';
      return null;
    }

    try {
      // Find worker by username (email)
      List<JIP_Worker__c> workers = [
        SELECT
          Id,
          Name,
          LastName__c,
          FirstName__c,
          Email__c,
          SystemLoginType__c,
          SystemUsername__c,
          SystemPassword__c,
          SystemRole__c,
          SystemAccountActive__c,
          User__c
        FROM JIP_Worker__c
        WHERE SystemUsername__c = :username
        LIMIT 1
      ];

      if (workers.isEmpty()) {
        hasError = true;
        errorMessage = 'ログインIDまたはパスワードが正しくありません。';
        return null;
      }

      JIP_Worker__c worker = workers[0];

      // Check if account is active
      if (!worker.SystemAccountActive__c) {
        hasError = true;
        errorMessage = 'このアカウントは無効化されています。管理者にお問い合わせください。';
        return null;
      }

      // Check login type
      if (worker.SystemLoginType__c == 'Guest') {
        // Guest login - verify password
        String hashedPassword = hashPassword(password);
        if (worker.SystemPassword__c != hashedPassword) {
          hasError = true;
          errorMessage = 'ログインIDまたはパスワードが正しくありません。';
          return null;
        }
      } else if (worker.SystemLoginType__c == 'SalesforceUser') {
        // Salesforce User - should use standard SF login
        hasError = true;
        errorMessage = 'このアカウントはSalesforceログインを使用してください。';
        return null;
      } else {
        hasError = true;
        errorMessage = 'アカウント設定が不正です。管理者にお問い合わせください。';
        return null;
      }

      // Login successful - set session
      setSessionValue(SESSION_WORKER_ID, worker.Id);
      setSessionValue(
        SESSION_WORKER_NAME,
        worker.LastName__c + ' ' + worker.FirstName__c
      );
      setSessionValue(SESSION_ROLE, worker.SystemRole__c);
      setSessionValue(SESSION_LOGIN_TYPE, worker.SystemLoginType__c);

      // Redirect to dashboard
      PageReference pr = Page.JIP_HRDashboardPage;
      pr.setRedirect(true);
      return pr;
    } catch (Exception ex) {
      hasError = true;
      errorMessage = 'ログイン処理中にエラーが発生しました: ' + ex.getMessage();
      return null;
    }
  }

  /**
   * @description Logout and clear session
   */
  public PageReference doLogout() {
    clearSession();
    PageReference pr = Page.JIP_SystemLoginPage;
    pr.setRedirect(true);
    return pr;
  }

  /**
   * @description Hash password using SHA-256
   */
  private String hashPassword(String pwd) {
    Blob hashBlob = Crypto.generateDigest('SHA-256', Blob.valueOf(pwd));
    return EncodingUtil.convertToHex(hashBlob);
  }

  /**
   * @description Set session value (using cookie for guest users)
   */
  private void setSessionValue(String key, String value) {
    // Use path '/' so cookie is accessible from all pages
    Cookie c = new Cookie(key, value, '/', -1, false);
    ApexPages.currentPage().setCookies(new List<Cookie>{ c });
  }

  /**
   * @description Get session value from cookie
   */
  private String getSessionValue(String key) {
    Cookie c = ApexPages.currentPage().getCookies().get(key);
    return c != null ? c.getValue() : null;
  }

  /**
   * @description Clear all session cookies
   */
  private void clearSession() {
    // Clear cookies with path '/' (new format)
    Cookie c1 = new Cookie(SESSION_WORKER_ID, '', '/', 0, false);
    Cookie c2 = new Cookie(SESSION_WORKER_NAME, '', '/', 0, false);
    Cookie c3 = new Cookie(SESSION_ROLE, '', '/', 0, false);
    Cookie c4 = new Cookie(SESSION_LOGIN_TYPE, '', '/', 0, false);
    // Also clear cookies with null path (old format) for backward compatibility
    Cookie c5 = new Cookie(SESSION_WORKER_ID, '', null, 0, false);
    Cookie c6 = new Cookie(SESSION_WORKER_NAME, '', null, 0, false);
    Cookie c7 = new Cookie(SESSION_ROLE, '', null, 0, false);
    Cookie c8 = new Cookie(SESSION_LOGIN_TYPE, '', null, 0, false);
    ApexPages.currentPage()
      .setCookies(new List<Cookie>{ c1, c2, c3, c4, c5, c6, c7, c8 });
  }

  /**
   * @description Static method to check if user is logged in
   */
  public static Boolean isLoggedIn() {
    Cookie c = ApexPages.currentPage().getCookies().get(SESSION_WORKER_ID);
    return c != null && String.isNotBlank(c.getValue());
  }

  /**
   * @description Static method to get current worker ID
   */
  public static String getCurrentWorkerId() {
    Cookie c = ApexPages.currentPage().getCookies().get(SESSION_WORKER_ID);
    return c != null ? c.getValue() : null;
  }

  /**
   * @description Static method to get current worker role
   */
  public static String getCurrentRole() {
    Cookie c = ApexPages.currentPage().getCookies().get(SESSION_ROLE);
    return c != null ? c.getValue() : null;
  }
}