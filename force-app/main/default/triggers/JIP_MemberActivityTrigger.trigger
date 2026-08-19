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
trigger JIP_MemberActivityTrigger on JIP_ProjectMember__c(
  after insert,
  after delete
) {
  if (Trigger.isAfter) {
    if (Trigger.isInsert) {
      JIP_ProjectActivityHelper.onMemberInsert(Trigger.new);
    } else if (Trigger.isDelete) {
      JIP_ProjectActivityHelper.onMemberDelete(Trigger.old);
    }
  }
}