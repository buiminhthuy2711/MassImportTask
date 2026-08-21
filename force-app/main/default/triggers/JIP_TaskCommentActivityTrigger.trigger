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
trigger JIP_TaskCommentActivityTrigger on JIP_TaskComment__c(
  after insert,
  after update,
  after delete
) {
  if (Trigger.isAfter) {
    if (Trigger.isInsert) {
      JIP_ProjectActivityHelper.onCommentInsert(Trigger.new);
    } else if (Trigger.isUpdate) {
      JIP_ProjectActivityHelper.onCommentUpdate(Trigger.new, Trigger.oldMap);
    } else if (Trigger.isDelete) {
      JIP_ProjectActivityHelper.onCommentDelete(Trigger.old);
    }
  }
}