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
trigger JIP_CandidateTrigger on JIP_Candidate__c(before insert, before update) {
  // Date dateD = Date.today();
  // //Đã deploy từ VSCode => updated nội dung từ dev console
  // for (JIP_Candidate__c candidate: trigger.new) {
  //     if (trigger.isInsert) {
  //         // 3.CurrentStatus__c set mặc định - Nếu insert mà CurrentStatus__c trống thì set 'Active'
  //         if (candidate.CurrentStatus__c == null) {
  //             candidate.CurrentStatus__c = 'Active';
  //         }

  //         // 4.PipelineStatus__c set mặc định - Nếu insert mà PipelineStatus__c trống thì set 'New'
  //         if (candidate.PipelineStatus__c == null) {
  //             candidate.PipelineStatus__c = 'New';
  //         }

  //         // 5.AvailabilityDate__c set mặc định - Nếu insert mà AvailabilityDate__c trống thì set Date.today()
  //         if (candidate.AvailabilityDate__c == null) {
  //             candidate.AvailabilityDate__c = dateD;
  //         }

  //         // 6.ExpectedRate__c set mặc định - Nếu ExpectedRate__c trống thì set 5000
  //         if (candidate.ExpectedRate__c == null) {
  //             candidate.ExpectedRate__c = 5000;
  //         }

  //     }

  //     // 1.FullName__c tự set nếu để trống - Nếu FullName__c trống thì set = Name
  //     if (String.isBlank(candidate.Full_name__c)) {
  //         candidate.Full_name__c = candidate.Name;
  //     }

  //     // 2.Email__c chuẩn hoá - Nếu Email__c có giá trị thì toLowerCase()
  //     if (!String.isBlank(candidate.Email__c)) {
  //         candidate.Email__c = candidate.Email__c.toLowerCase();
  //     }
  // }
}