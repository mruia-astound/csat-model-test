public with sharing class LeadConversionHandler {
    
    private static Set<Id> processedLeadIds = new Set<Id>();
    
    public static void handleAfterInsert(List<Lead> newLeads) {
        List<Lead> eligibleLeads = new List<Lead>();
        
        for (Lead lead : newLeads) {
            if (lead.IsConverted) {
                continue;
            }
            if (processedLeadIds.contains(lead.Id)) {
                continue;
            }
            if (LeadConversionService.isEligibleForConversion(lead)) {
                eligibleLeads.add(lead);
                processedLeadIds.add(lead.Id);
            }
        }
        
        if (!eligibleLeads.isEmpty()) {
            LeadConversionService.convertLeads(eligibleLeads);
        }
    }
    
    public static void handleAfterUpdate(List<Lead> updatedLeads, Map<Id, Lead> oldLeadMap) {
        List<Lead> eligibleLeads = new List<Lead>();
        
        for (Lead newLead : updatedLeads) {
            if (newLead.IsConverted) {
                continue;
            }
            if (processedLeadIds.contains(newLead.Id)) {
                continue;
            }
            
            Lead oldLead = oldLeadMap.get(newLead.Id);
            
            Boolean becameEligible = 
                (!oldLead.Marketing_Lead__c && newLead.Marketing_Lead__c) ||
                (oldLead.Purchase_Plans__c != 'Yes' && newLead.Purchase_Plans__c == 'Yes') ||
                (oldLead.Customer_Engagement_Type__c != 'Quote Request' && newLead.Customer_Engagement_Type__c == 'Quote Request') ||
                (oldLead.Customer_Engagement_Type__c != 'Demo Request' && newLead.Customer_Engagement_Type__c == 'Demo Request') ||
                (oldLead.Customer_Engagement_Type__c != 'Contact Me' && newLead.Customer_Engagement_Type__c == 'Contact Me') ||
                (!oldLead.Contact_Me__c && newLead.Contact_Me__c) ||
                (oldLead.Account_ID__c != newLead.Account_ID__c && newLead.Account_ID__c != null) ||
                (oldLead.Contact_ID__c != newLead.Contact_ID__c && newLead.Contact_ID__c != null);
            
            if (becameEligible && LeadConversionService.isEligibleForConversion(newLead)) {
                eligibleLeads.add(newLead);
                processedLeadIds.add(newLead.Id);
            }
        }
        
        if (!eligibleLeads.isEmpty()) {
            LeadConversionService.convertLeads(eligibleLeads);
        }
    }
}
