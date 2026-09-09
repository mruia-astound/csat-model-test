trigger LeadConversionTrigger on Lead (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert) {
        LeadConversionHandler.handleAfterInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        LeadConversionHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}
