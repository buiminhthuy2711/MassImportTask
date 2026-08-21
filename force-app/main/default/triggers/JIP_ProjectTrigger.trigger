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
trigger JIP_ProjectTrigger on JIP_Project__c(before insert, before update) {
  // String dateStr = Date.today().format();
  // Date dateD = Date.today();
  // String tDBAccount = System.Label.TBD_Account;

  // for (JIP_Project__c project: trigger.new) {
  //     if (trigger.isInsert) {
  //         // 1.Name tự động prefix ngày tạo - Khi insert thì set = [TODAY] + Name
  //         if (!String.isBlank(project.Name)) {
  //             project.Name = '[' + dateStr + ']' + project.Name;
  //         }

  //         // 2.ClientCompany__c nếu để trống thì set = 'TBD'

  //         // NOTE: ClientCompany__c is a Lookup(Account), not a String.
  // 		// Requirement says default to 'TBD', but Lookups require an Account Id.

  //         if (project.ClientCompany__c == null) {
  //             project.ClientCompany__c = tDBAccount;
  // 		}

  //         // 3.StartDate__c nếu để trống khi insert thì set = Date.today()
  //         if (project.StartDate__c == null) {
  //             project.StartDate__c = dateD;
  //         }

  //         // 6.Manager__c nếu để trống khi insert thì set = UserInfo.getUserId()
  //         if (project.Manager__c == null) {
  //             project.Manager__c = UserInfo.getUserId();
  //         }

  //         // 7.Status__c nếu để trống khi insert thì set = 'New'
  //         if (project.Status__c == null) {
  //             project.Status__c = 'New';
  //         }
  //     }

  //     // 4.EndDate__c nếu có giá trị và nhỏ hơn StartDate__c thì throw error.Gợi ý sử dụng code EndDate__c.addError('End Date must be greater than or equal to Start Date.');
  //     // https://jefersonchaves.medium.com/a-quick-tip-adderror-on-a-field-be5e351b37de
  //     if (project.EndDate__c != null && project.StartDate__c != null && project.EndDate__c < project.StartDate__c) {
  //         project.EndDate__c.addError('End Date must be greater than or equal to Start Date.');
  //     }

  //     // 5.TechStack__c nếu có giá trị thì trim()
  //     if (!String.isBlank(project.TechStack__c)) {
  //         project.TechStack__c = project.TechStack__c.trim();
  //     }

  // }
}