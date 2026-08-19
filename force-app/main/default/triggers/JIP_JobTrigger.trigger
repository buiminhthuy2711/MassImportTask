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
trigger JIP_JobTrigger on JIP_Job__c(before insert, before update) {
  // String detailedDate = System.now().format('yyyyMMddHHmmss');
  // String dateStr = Date.today().format();
  // String tDBAccount = System.Label.TBD_Account;

  // for (JIP_Job__c job: trigger.new) {
  //     if (trigger.isInsert) {
  //         // 1.Name nếu trống thì set = 'JOB-' + yyyyMMddHHmmss (tạo mã tạm) JOB-20260224231010
  //         if (String.isBlank(job.Name)) {
  //             job.Name = 'JOB-' + detailedDate;
  //         }

  //         // 2.JobTitle__c khi insert nếu có giá trị thì prefix = '[' + Date.today().format() + ']' + JobTitle__c
  //         if (!String.isBlank(job.JobTitle__c)) {
  //             job.JobTitle__c = '[' + dateStr + ']' + job.JobTitle__c;
  //         }

  //         // 3.Company__c nếu trống thì set = 'TBD'

  //         // NOTE: Company__c is a Lookup(Account), not a String.
  // 		// Requirement says default to 'TBD', but Lookup fields require an Account Id.
  //         if (String.isBlank(job.Company__c)) {
  //             job.Company__c = tDBAccount;
  //         }

  //         // 4.StartDate__c set giá trị mặc định là TODAY
  //         if (job.StartDate__c == null) {
  //             job.StartDate__c = Date.today();
  //         }

  //         // 5.DurationMonths__c nếu không được nhập giá trị thì set 6 tháng
  //         if (job.DurationMonths__c == null) {
  //             job.DurationMonths__c = 6;
  //         }

  //         // 6.WorkLocation__c nếu trống thì set = 'Remote'
  //         if (String.isBlank(job.WorkLocation__c)) {
  //             job.WorkLocation__c = 'Remote';
  //         }

  //         // 7.RequiredJapaneseLevel__c nếu trống thì set = 'N3'
  //         if (String.isBlank(job.RequiredJapaneseLevel__c)) {
  //             job.RequiredJapaneseLevel__c = 'N3';
  //         }

  //         // 8.BudgetRateMin__c nếu không được nhập giá trị thì set 5000 USD
  //         if (job.BudgetRateMin__c == null) {
  //             job.BudgetRateMin__c = 5000;
  //         }

  //         // 10.Priority__c nếu trống thì set = 'Medium'
  //         if (String.isBlank(job.Priority__c)) {
  //             job.Priority__c = 'Medium';
  //         }

  //         // 11.Status__c set giá trị mặc định OPEN
  //         if (String.isBlank(job.Status__c)) {
  //             job.Status__c = 'Open';
  //         }
  //     }
  //     // 9.BudgetRateMax__c nếu có nhập và nhỏ hơn BudgetRateMin__c thì throw error
  //     if (job.BudgetRateMax__c != null && job.BudgetRateMin__c != null && job.BudgetRateMax__c < job.BudgetRateMin__c) {
  //         job.BudgetRateMax__c.addError('Budget Max must be greater than Budget Min');
  //     }

  //     // 12.Description__c nếu có giá trị thì trim() và nếu dài > 32000 ký tự thì throw error
  //     if (job.Description__c != null) {
  //         job.Description__c = job.Description__c.trim();
  //         if (job.Description__c.length() > 32000)
  //             job.Description__c.addError('Description should not exceed over 32000 characters');
  //     }
  // }
}