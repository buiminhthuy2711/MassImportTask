/**
 * Copyright (c) 2023-2026 JIP Academy (Tokyo, Japan).
 * Developed by JIP Academy R&D Team / Nguyen Minh Phuong.
 * All rights reserved.
 */
@isTest
private class JIP_SidebarControllerTest {
  @testSetup
  static void setupTestData() {
    JIP_Project__c proj = JIP_TestDataFactory.createProject(
      'Test Project',
      true
    );
  }

  @isTest
  static void testConstructor() {
    Test.startTest();
    JIP_SidebarController controller = new JIP_SidebarController();
    Test.stopTest();
    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
  }

  @isTest
  static void testGetLanguageNoProject() {
    JIP_SidebarController controller = new JIP_SidebarController();
    Test.startTest();
    String lang = controller.getLanguage();
    Test.stopTest();
    System.assertEquals('ja', lang, 'Default language should be ja');
  }

  @isTest
  static void testGetLanguageWithProject() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_SidebarController controller = new JIP_SidebarController();
    controller.projectIdParam = proj.Id;
    Test.startTest();
    String lang = controller.getLanguage();
    Test.stopTest();
    System.assertNotEquals(null, lang, 'Language should not be null');
  }

  @isTest
  static void testGetT() {
    JIP_SidebarController controller = new JIP_SidebarController();
    Test.startTest();
    Map<String, String> t = controller.getT();
    Test.stopTest();
    System.assertNotEquals(null, t, 'Translations should not be null');
  }

  @isTest
  static void testGetTWithProject() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_SidebarController controller = new JIP_SidebarController();
    controller.projectIdParam = proj.Id;
    Test.startTest();
    Map<String, String> t = controller.getT();
    Test.stopTest();
    System.assertNotEquals(null, t, 'Translations should not be null');
  }
}