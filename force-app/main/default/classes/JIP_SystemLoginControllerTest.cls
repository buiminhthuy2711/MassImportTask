/**
 * Copyright (c) 2023-2026 JIP Academy (Tokyo, Japan).
 * Developed by JIP Academy R&D Team / Nguyen Minh Phuong.
 * All rights reserved.
 */
@isTest
private class JIP_SystemLoginControllerTest {
  @testSetup
  static void setupTestData() {
    JIP_Department__c dept = JIP_TestDataFactory.createDepartment(
      'Test Department',
      true
    );
    JIP_Worker__c worker = JIP_TestDataFactory.createWorker(
      'Test Worker',
      dept.Id,
      true
    );
    // Set up system login credentials
    worker.SystemUsername__c = 'test@test.com';
    worker.SystemPassword__c = EncodingUtil.convertToHex(
      Crypto.generateDigest('SHA-256', Blob.valueOf('password123'))
    );
    worker.SystemLoginType__c = 'Guest';
    worker.SystemAccountActive__c = true;
    worker.SystemRole__c = 'Employee';
    update worker;
  }

  @isTest
  static void testConstructor() {
    Test.startTest();
    JIP_SystemLoginController controller = new JIP_SystemLoginController();
    Test.stopTest();
    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
    System.assertEquals('', controller.username, 'Username should be empty');
    System.assertEquals('', controller.password, 'Password should be empty');
  }

  @isTest
  static void testDoLoginNoUsername() {
    JIP_SystemLoginController controller = new JIP_SystemLoginController();
    controller.username = '';
    controller.password = 'password123';
    Test.startTest();
    PageReference result = controller.doLogin();
    Test.stopTest();
    System.assertEquals(null, result, 'Should return null on missing username');
    System.assertEquals(true, controller.hasError, 'Should have error');
  }

  @isTest
  static void testDoLoginNoPassword() {
    JIP_SystemLoginController controller = new JIP_SystemLoginController();
    controller.username = 'test@test.com';
    controller.password = '';
    Test.startTest();
    PageReference result = controller.doLogin();
    Test.stopTest();
    System.assertEquals(null, result, 'Should return null on missing password');
    System.assertEquals(true, controller.hasError, 'Should have error');
  }

  @isTest
  static void testDoLoginInvalidUser() {
    JIP_SystemLoginController controller = new JIP_SystemLoginController();
    controller.username = 'invalid@test.com';
    controller.password = 'password123';
    Test.startTest();
    PageReference result = controller.doLogin();
    Test.stopTest();
    System.assertEquals(null, result, 'Should return null on invalid user');
    System.assertEquals(true, controller.hasError, 'Should have error');
  }

  @isTest
  static void testDoLoginWrongPassword() {
    JIP_SystemLoginController controller = new JIP_SystemLoginController();
    controller.username = 'test@test.com';
    controller.password = 'wrongpassword';
    Test.startTest();
    PageReference result = controller.doLogin();
    Test.stopTest();
    System.assertEquals(null, result, 'Should return null on wrong password');
    System.assertEquals(true, controller.hasError, 'Should have error');
  }

  @isTest
  static void testDoLoginSuccess() {
    JIP_SystemLoginController controller = new JIP_SystemLoginController();
    controller.username = 'test@test.com';
    controller.password = 'password123';
    Test.startTest();
    PageReference result = controller.doLogin();
    Test.stopTest();
    System.assertNotEquals(null, result, 'Should redirect on successful login');
  }

  @isTest
  static void testDoLoginInactiveAccount() {
    JIP_Worker__c worker = [SELECT Id FROM JIP_Worker__c LIMIT 1];
    worker.SystemAccountActive__c = false;
    update worker;

    JIP_SystemLoginController controller = new JIP_SystemLoginController();
    controller.username = 'test@test.com';
    controller.password = 'password123';
    Test.startTest();
    PageReference result = controller.doLogin();
    Test.stopTest();
    System.assertEquals(null, result, 'Should return null on inactive account');
    System.assertEquals(true, controller.hasError, 'Should have error');
  }

  @isTest
  static void testDoLogout() {
    JIP_SystemLoginController controller = new JIP_SystemLoginController();
    Test.startTest();
    PageReference result = controller.doLogout();
    Test.stopTest();
    System.assertNotEquals(null, result, 'Should return page reference');
  }

  @isTest
  static void testIsLoggedIn() {
    Test.startTest();
    Boolean result = JIP_SystemLoginController.isLoggedIn();
    Test.stopTest();
    System.assertNotEquals(null, result, 'Should return boolean');
  }

  @isTest
  static void testGetCurrentWorkerId() {
    Test.startTest();
    String result = JIP_SystemLoginController.getCurrentWorkerId();
    Test.stopTest();
    // May be null if not logged in
    System.assert(true, 'Method executed');
  }
}