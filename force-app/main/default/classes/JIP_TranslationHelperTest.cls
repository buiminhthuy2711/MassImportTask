/**
 * Copyright (c) 2023-2026 JIP Academy (Tokyo, Japan).
 * Developed by JIP Academy R&D Team / Nguyen Minh Phuong.
 * All rights reserved.
 */
@isTest
private class JIP_TranslationHelperTest {
  @isTest
  static void testGetTranslationJapanese() {
    Test.startTest();
    String result = JIP_TranslationHelper.get('save', 'ja');
    Test.stopTest();
    System.assertEquals(
      '保存',
      result,
      'Expected Japanese translation for save'
    );
  }

  @isTest
  static void testGetTranslationEnglish() {
    Test.startTest();
    String result = JIP_TranslationHelper.get('save', 'en');
    Test.stopTest();
    System.assertEquals(
      'Save',
      result,
      'Expected English translation for save'
    );
  }

  @isTest
  static void testGetTranslationDefault() {
    Test.startTest();
    String result = JIP_TranslationHelper.get('cancel', null);
    Test.stopTest();
    System.assertEquals(
      'キャンセル',
      result,
      'Expected Japanese (default) translation for cancel'
    );
  }

  @isTest
  static void testGetTranslationEmptyLang() {
    Test.startTest();
    String result = JIP_TranslationHelper.get('edit', '');
    Test.stopTest();
    System.assertEquals(
      '編集',
      result,
      'Expected Japanese (default) translation for edit'
    );
  }

  @isTest
  static void testGetTranslationNotFound() {
    Test.startTest();
    String result = JIP_TranslationHelper.get('nonexistent_key', 'ja');
    Test.stopTest();
    System.assertEquals(
      'nonexistent_key',
      result,
      'Expected key to be returned when translation not found'
    );
  }

  @isTest
  static void testGetAllTranslationsJapanese() {
    Test.startTest();
    Map<String, String> translations = JIP_TranslationHelper.getAllTranslations(
      'ja'
    );
    Test.stopTest();
    System.assertNotEquals(
      null,
      translations,
      'Translations map should not be null'
    );
    System.assert(
      translations.size() > 0,
      'Translations map should not be empty'
    );
    System.assertEquals(
      '保存',
      translations.get('save'),
      'Expected Japanese translation for save in map'
    );
  }

  @isTest
  static void testGetAllTranslationsEnglish() {
    Test.startTest();
    Map<String, String> translations = JIP_TranslationHelper.getAllTranslations(
      'en'
    );
    Test.stopTest();
    System.assertNotEquals(
      null,
      translations,
      'Translations map should not be null'
    );
    System.assert(
      translations.size() > 0,
      'Translations map should not be empty'
    );
    System.assertEquals(
      'Save',
      translations.get('save'),
      'Expected English translation for save in map'
    );
  }

  @isTest
  static void testGetAllTranslationsDefault() {
    Test.startTest();
    Map<String, String> translations = JIP_TranslationHelper.getAllTranslations(
      null
    );
    Test.stopTest();
    System.assertNotEquals(
      null,
      translations,
      'Translations map should not be null'
    );
    System.assertEquals(
      '保存',
      translations.get('save'),
      'Expected Japanese (default) translation'
    );
  }

  @isTest
  static void testMultipleTranslations() {
    Test.startTest();
    String save = JIP_TranslationHelper.get('save', 'en');
    String cancel = JIP_TranslationHelper.get('cancel', 'en');
    String edit = JIP_TranslationHelper.get('edit', 'en');
    String delete_trans = JIP_TranslationHelper.get('delete', 'en');
    Test.stopTest();
    System.assertEquals('Save', save);
    System.assertEquals('Cancel', cancel);
    System.assertEquals('Edit', edit);
    System.assertEquals('Delete', delete_trans);
  }
}