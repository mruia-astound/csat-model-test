public with sharing class LeadConversionService {
    
    public static Boolean isEligibleForConversion(Lead lead) {
        if (lead.Account_ID__c == null || String.isBlank(lead.Account_ID__c)) {
            return false;
        }
        if (lead.Contact_ID__c == null || String.isBlank(lead.Contact_ID__c)) {
            return false;
        }
        if (!lead.Marketing_Lead__c) {
            return false;
        }
        return hasEngagementCriteria(lead);
    }
    
    private static Boolean hasEngagementCriteria(Lead lead) {
        if (lead.Purchase_Plans__c == 'Yes') {
            return true;
        }
        if (lead.Customer_Engagement_Type__c == 'Quote Request' || 
            lead.Customer_Engagement_Type__c == 'Demo Request' || 
            lead.Customer_Engagement_Type__c == 'Contact Me') {
            return true;
        }
        if (lead.Contact_Me__c) {
            return true;
        }
        return false;
    }
    
    public static Boolean validateAccountContactMatch(Lead lead, Map<Id, Account> accountMap, Map<Id, Contact> contactMap) {
        Id accountId = lead.Account_ID__c;
        Id contactId = lead.Contact_ID__c;
        
        if (!accountMap.containsKey(accountId) || !contactMap.containsKey(contactId)) {
            return false;
        }
        
        Account account = accountMap.get(accountId);
        Contact contact = contactMap.get(contactId);
        
        if (String.isBlank(lead.Company) || String.isBlank(account.Name)) {
            return false;
        }
        if (String.isBlank(lead.Email) || String.isBlank(contact.Email)) {
            return false;
        }
        
        if (lead.Company != account.Name) {
            return false;
        }
        if (lead.Email != contact.Email) {
            return false;
        }
        
        return true;
    }
    
    public static Boolean checkForExistingOpportunity(Id accountId, Id contactId, Map<Id, List<Opportunity>> accountOppsMap) {
        return accountOppsMap.containsKey(accountId) && !accountOppsMap.get(accountId).isEmpty();
    }
    
    public static void convertLeads(List<Lead> leadsToConvert) {
        if (leadsToConvert == null || leadsToConvert.isEmpty()) {
            return;
        }
        
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        
        for (Lead lead : leadsToConvert) {
            if (lead.Account_ID__c != null) {
                accountIds.add(lead.Account_ID__c);
            }
            if (lead.Contact_ID__c != null) {
                contactIds.add(lead.Contact_ID__c);
            }
        }
        
        Map<Id, Account> accountMap = new Map<Id, Account>([
            SELECT Id, Name 
            FROM Account 
            WHERE Id IN :accountIds
        ]);
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, Email 
            FROM Contact 
            WHERE Id IN :contactIds
        ]);
        
        Map<Id, List<Opportunity>> accountOppsMap = new Map<Id, List<Opportunity>>();
        for (Opportunity opp : [
            SELECT Id, AccountId 
            FROM Opportunity 
            WHERE AccountId IN :accountIds
        ]) {
            if (!accountOppsMap.containsKey(opp.AccountId)) {
                accountOppsMap.put(opp.AccountId, new List<Opportunity>());
            }
            accountOppsMap.get(opp.AccountId).add(opp);
        }
        
        LeadStatus convertedStatus = [
            SELECT MasterLabel 
            FROM LeadStatus 
            WHERE IsConverted = true 
            LIMIT 1
        ];
        
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        Map<Id, Lead> leadIdToLeadMap = new Map<Id, Lead>();
        
        for (Lead lead : leadsToConvert) {
            if (!validateAccountContactMatch(lead, accountMap, contactMap)) {
                continue;
            }
            
            if (checkForExistingOpportunity(lead.Account_ID__c, lead.Contact_ID__c, accountOppsMap)) {
                continue;
            }
            
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lead.Id);
            lc.setAccountId(lead.Account_ID__c);
            lc.setContactId(lead.Contact_ID__c);
            lc.setConvertedStatus(convertedStatus.MasterLabel);
            lc.setDoNotCreateOpportunity(false);
            
            leadConverts.add(lc);
            leadIdToLeadMap.put(lead.Id, lead);
        }
        
        if (leadConverts.isEmpty()) {
            return;
        }
        
        List<Database.LeadConvertResult> results = Database.convertLead(leadConverts, false);
        
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        
        for (Integer i = 0; i < results.size(); i++) {
            Database.LeadConvertResult result = results[i];
            if (result.isSuccess()) {
                Id oppId = result.getOpportunityId();
                if (oppId != null) {
                    Opportunity opp = new Opportunity(
                        Id = oppId,
                        CloseDate = Date.today().addMonths(4)
                    );
                    opportunitiesToUpdate.add(opp);
                }
            }
        }
        
        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
    }
}
