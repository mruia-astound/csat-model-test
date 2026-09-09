@isTest
private class LeadConversionServiceTest {
    
    @testSetup
    static void setupData() {
        
    }
    
    @isTest
    static void testEligibleLeadConversion() {
        Account testAccount = new Account(
            Name = 'Test Company',
            BillingCity = 'Test City'
        );
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Email = 'test@example.com',
            Account_ID__c = testAccount.Id,
            Contact_ID__c = testContact.Id,
            Marketing_Lead__c = true,
            Purchase_Plans__c = 'Yes'
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
        
        Lead convertedLead = [SELECT Id, IsConverted, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId 
                              FROM Lead 
                              WHERE Id = :testLead.Id];
        
        System.assertEquals(true, convertedLead.IsConverted, 'Lead should be converted');
        System.assertEquals(testAccount.Id, convertedLead.ConvertedAccountId, 'Lead should be converted to the correct Account');
        System.assertEquals(testContact.Id, convertedLead.ConvertedContactId, 'Lead should be converted to the correct Contact');
        System.assertNotEquals(null, convertedLead.ConvertedOpportunityId, 'Opportunity should be created');
        
        Opportunity createdOpp = [SELECT Id, CloseDate, AccountId 
                                  FROM Opportunity 
                                  WHERE Id = :convertedLead.ConvertedOpportunityId];
        
        System.assertEquals(testAccount.Id, createdOpp.AccountId, 'Opportunity should be associated with the correct Account');
        Date expectedCloseDate = Date.today().addMonths(4);
        System.assertEquals(expectedCloseDate, createdOpp.CloseDate, 'Opportunity Close Date should be 4 months from today');
    }
    
    @isTest
    static void testOpportunityCloseDate() {
        Account testAccount = new Account(Name = 'Close Date Test Company');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'Close',
            LastName = 'DateTest',
            Email = 'closedate@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Lead testLead = new Lead(
            FirstName = 'Close',
            LastName = 'DateTest',
            Company = 'Close Date Test Company',
            Email = 'closedate@example.com',
            Account_ID__c = testAccount.Id,
            Contact_ID__c = testContact.Id,
            Marketing_Lead__c = true,
            Customer_Engagement_Type__c = 'Demo Request'
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
        
        Lead convertedLead = [SELECT Id, IsConverted, ConvertedOpportunityId 
                              FROM Lead 
                              WHERE Id = :testLead.Id];
        
        System.assertEquals(true, convertedLead.IsConverted, 'Lead should be converted');
        
        Opportunity createdOpp = [SELECT CloseDate FROM Opportunity WHERE Id = :convertedLead.ConvertedOpportunityId];
        
        Date expectedCloseDate = Date.today().addMonths(4);
        System.assertEquals(expectedCloseDate, createdOpp.CloseDate, 'Close Date should be 4 months from creation');
    }
    
    @isTest
    static void testEngagementConditionPurchasePlans() {
        Account testAccount = new Account(Name = 'Purchase Plans Company');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'Purchase',
            LastName = 'PlansTest',
            Email = 'purchase@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Lead testLead = new Lead(
            FirstName = 'Purchase',
            LastName = 'PlansTest',
            Company = 'Purchase Plans Company',
            Email = 'purchase@example.com',
            Account_ID__c = testAccount.Id,
            Contact_ID__c = testContact.Id,
            Marketing_Lead__c = true,
            Purchase_Plans__c = 'Yes'
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
        
        Lead convertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(true, convertedLead.IsConverted, 'Lead with Purchase Plans = Yes should be converted');
    }
    
    @isTest
    static void testEngagementConditionQuoteRequest() {
        Account testAccount = new Account(Name = 'Quote Request Company');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'Quote',
            LastName = 'RequestTest',
            Email = 'quote@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Lead testLead = new Lead(
            FirstName = 'Quote',
            LastName = 'RequestTest',
            Company = 'Quote Request Company',
            Email = 'quote@example.com',
            Account_ID__c = testAccount.Id,
            Contact_ID__c = testContact.Id,
            Marketing_Lead__c = true,
            Customer_Engagement_Type__c = 'Quote Request'
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
        
        Lead convertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(true, convertedLead.IsConverted, 'Lead with Quote Request should be converted');
    }
    
    @isTest
    static void testEngagementConditionDemoRequest() {
        Account testAccount = new Account(Name = 'Demo Request Company');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'Demo',
            LastName = 'RequestTest',
            Email = 'demo@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Lead testLead = new Lead(
            FirstName = 'Demo',
            LastName = 'RequestTest',
            Company = 'Demo Request Company',
            Email = 'demo@example.com',
            Account_ID__c = testAccount.Id,
            Contact_ID__c = testContact.Id,
            Marketing_Lead__c = true,
            Customer_Engagement_Type__c = 'Demo Request'
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
        
        Lead convertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(true, convertedLead.IsConverted, 'Lead with Demo Request should be converted');
    }
    
    @isTest
    static void testEngagementConditionContactMeType() {
        Account testAccount = new Account(Name = 'Contact Me Type Company');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'ContactMe',
            LastName = 'TypeTest',
            Email = 'contactmetype@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Lead testLead = new Lead(
            FirstName = 'ContactMe',
            LastName = 'TypeTest',
            Company = 'Contact Me Type Company',
            Email = 'contactmetype@example.com',
            Account_ID__c = testAccount.Id,
            Contact_ID__c = testContact.Id,
            Marketing_Lead__c = true,
            Customer_Engagement_Type__c = 'Contact Me'
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
        
        Lead convertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(true, convertedLead.IsConverted, 'Lead with Contact Me type should be converted');
    }
    
    @isTest
    static void testEngagementConditionContactMeCheckbox() {
        Account testAccount = new Account(Name = 'Contact Me Checkbox Company');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'ContactMe',
            LastName = 'CheckboxTest',
            Email = 'contactmecheckbox@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Lead testLead = new Lead(
            FirstName = 'ContactMe',
            LastName = 'CheckboxTest',
            Company = 'Contact Me Checkbox Company',
            Email = 'contactmecheckbox@example.com',
            Account_ID__c = testAccount.Id,
            Contact_ID__c = testContact.Id,
            Marketing_Lead__c = true,
            Contact_Me__c = true
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
        
        Lead convertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(true, convertedLead.IsConverted, 'Lead with Contact Me checkbox should be converted');
    }
    
    @isTest
    static void testMissingAccountId() {
        Contact testContact = new Contact(
            FirstName = 'No',
            LastName = 'AccountId',
            Email = 'noaccount@example.com'
        );
        insert testContact;
        
        Lead testLead = new Lead(
            FirstName = 'No',
            LastName = 'AccountId',
            Company = 'No Account Company',
            Email = 'noaccount@example.com',
            Contact_ID__c = testContact.Id,
            Marketing_Lead__c = true,
            Purchase_Plans__c = 'Yes'
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
        
        Lead unconvertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(false, unconvertedLead.IsConverted, 'Lead without Account ID should not be converted');
    }
    
    @isTest
    static void testMissingContactId() {
        Account testAccount = new Account(Name = 'No Contact Company');
        insert testAccount;
        
        Lead testLead = new Lead(
            FirstName = 'No',
            LastName = 'ContactId',
            Company = 'No Contact Company',
            Email = 'nocontact@example.com',
            Account_ID__c = testAccount.Id,
            Marketing_Lead__c = true,
            Purchase_Plans__c = 'Yes'
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
        
        Lead unconvertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(false, unconvertedLead.IsConverted, 'Lead without Contact ID should not be converted');
    }
    
    @isTest
    static void testCompanyMismatch() {
        Account testAccount = new Account(Name = 'Correct Company Name');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'Company',
            LastName = 'Mismatch',
            Email = 'companymismatch@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Lead testLead = new Lead(
            FirstName = 'Company',
            LastName = 'Mismatch',
            Company = 'Different Company Name',
            Email = 'companymismatch@example.com',
            Account_ID__c = testAccount.Id,
            Contact_ID__c = testContact.Id,
            Marketing_Lead__c = true,
            Purchase_Plans__c = 'Yes'
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
        
        Lead unconvertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(false, unconvertedLead.IsConverted, 'Lead with mismatched Company name should not be converted');
    }
    
    @isTest
    static void testEmailMismatch() {
        Account testAccount = new Account(Name = 'Email Mismatch Company');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'Email',
            LastName = 'Mismatch',
            Email = 'correct@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Lead testLead = new Lead(
            FirstName = 'Email',
            LastName = 'Mismatch',
            Company = 'Email Mismatch Company',
            Email = 'different@example.com',
            Account_ID__c = testAccount.Id,
            Contact_ID__c = testContact.Id,
            Marketing_Lead__c = true,
            Purchase_Plans__c = 'Yes'
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
        
        Lead unconvertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(false, unconvertedLead.IsConverted, 'Lead with mismatched Email should not be converted');
    }
    
    @isTest
    static void testMarketingLeadFalse() {
        Account testAccount = new Account(Name = 'Marketing False Company');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'Marketing',
            LastName = 'False',
            Email = 'marketingfalse@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Lead testLead = new Lead(
            FirstName = 'Marketing',
            LastName = 'False',
            Company = 'Marketing False Company',
            Email = 'marketingfalse@example.com',
            Account_ID__c = testAccount.Id,
            Contact_ID__c = testContact.Id,
            Marketing_Lead__c = false,
            Purchase_Plans__c = 'Yes'
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
        
        Lead unconvertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(false, unconvertedLead.IsConverted, 'Lead with Marketing Lead = false should not be converted');
    }
    
    @isTest
    static void testNoEngagementCriteria() {
        Account testAccount = new Account(Name = 'No Engagement Company');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'No',
            LastName = 'Engagement',
            Email = 'noengagement@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Lead testLead = new Lead(
            FirstName = 'No',
            LastName = 'Engagement',
            Company = 'No Engagement Company',
            Email = 'noengagement@example.com',
            Account_ID__c = testAccount.Id,
            Contact_ID__c = testContact.Id,
            Marketing_Lead__c = true
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
        
        Lead unconvertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(false, unconvertedLead.IsConverted, 'Lead without engagement criteria should not be converted');
    }
    
    @isTest
    static void testDuplicateOpportunityPrevention() {
        Account testAccount = new Account(Name = 'Duplicate Opp Company');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'Duplicate',
            LastName = 'OppTest',
            Email = 'duplicateopp@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Opportunity existingOpp = new Opportunity(
            Name = 'Existing Opportunity',
            AccountId = testAccount.Id,
            CloseDate = Date.today().addMonths(3),
            StageName = 'Prospecting'
        );
        insert existingOpp;
        
        Lead testLead = new Lead(
            FirstName = 'Duplicate',
            LastName = 'OppTest',
            Company = 'Duplicate Opp Company',
            Email = 'duplicateopp@example.com',
            Account_ID__c = testAccount.Id,
            Contact_ID__c = testContact.Id,
            Marketing_Lead__c = true,
            Purchase_Plans__c = 'Yes'
        );
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
        
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE AccountId = :testAccount.Id];
        System.assertEquals(1, opps.size(), 'Should not create duplicate Opportunity');
    }
    
    @isTest
    static void testBulkProcessing() {
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        List<Lead> leads = new List<Lead>();
        
        for (Integer i = 0; i < 10; i++) {
            Account acc = new Account(Name = 'Bulk Company ' + i);
            accounts.add(acc);
        }
        insert accounts;
        
        for (Integer i = 0; i < 10; i++) {
            Contact con = new Contact(
                FirstName = 'Bulk',
                LastName = 'Contact' + i,
                Email = 'bulk' + i + '@example.com',
                AccountId = accounts[i].Id
            );
            contacts.add(con);
        }
        insert contacts;
        
        for (Integer i = 0; i < 7; i++) {
            Lead lead = new Lead(
                FirstName = 'Eligible',
                LastName = 'Lead' + i,
                Company = 'Bulk Company ' + i,
                Email = 'bulk' + i + '@example.com',
                Account_ID__c = accounts[i].Id,
                Contact_ID__c = contacts[i].Id,
                Marketing_Lead__c = true,
                Purchase_Plans__c = 'Yes'
            );
            leads.add(lead);
        }
        
        for (Integer i = 7; i < 10; i++) {
            Lead lead = new Lead(
                FirstName = 'Ineligible',
                LastName = 'Lead' + i,
                Company = 'Bulk Company ' + i,
                Email = 'bulk' + i + '@example.com',
                Account_ID__c = accounts[i].Id,
                Contact_ID__c = contacts[i].Id,
                Marketing_Lead__c = false
            );
            leads.add(lead);
        }
        
        Test.startTest();
        insert leads;
        Test.stopTest();
        
        List<Lead> convertedLeads = [SELECT Id, IsConverted FROM Lead WHERE Id IN :leads AND IsConverted = true];
        System.assertEquals(7, convertedLeads.size(), '7 eligible Leads should be converted');
        
        List<Lead> unconvertedLeads = [SELECT Id, IsConverted FROM Lead WHERE Id IN :leads AND IsConverted = false];
        System.assertEquals(3, unconvertedLeads.size(), '3 ineligible Leads should not be converted');
    }
}
