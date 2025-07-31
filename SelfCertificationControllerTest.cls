/*
**********************************************************************************************************************
Apex Class Name    : SelfCertificationTest
Created Date       : 15/07/2025
@author            : Yahoop
Modification Log:
Ver   	Date         		Author                               Modification
1.0   	15/07/2025   		 Yahoop                             Initial Version
**********************************************************************************************************************
@description
This is a unit test class for the SelfCertificationController Apex class.
It covers all exposed methods and ensures data integrity, logic correctness, and sufficient code coverage.

The test class validates:
- Creation of self-certification records.
- Retrieval of certifications (all and user-specific).
- File upload and linking to certifications.
*/


@isTest
public class SelfCertificationControllerTest {
    
    /**
     * @description Test setup method to create a reusable System Administrator user.
     */
    @testSetup
    static void setupData() {
        // Create a test user with System Administrator profile
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = new User(
            Alias = 'tadmin',
            Email = 'admin@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testadminuser_' + System.currentTimeMillis() + '@example.com'
        );
        insert adminUser;
    }
    
    /**
     * @description Tests the createSelfCertification method by inserting a new certification record.
     */
    
    @isTest
    static void testCreateSelfCertification() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        
        Test.startTest();
        Id recordId = SelfCertificationController.createSelfCertification(
            'test@example.com',
            'IN',
            'Test Comment',
            true,
            true,
            testUser.Id,
            null
        );
        Test.stopTest();
        
        System.assertNotEquals(null, recordId, 'The certification record ID should not be null.');
        Self_Certification__c cert = [SELECT Id, Country__c FROM Self_Certification__c WHERE Id = :recordId];
        System.assertEquals('IN', cert.Country__c, 'Country should match the input');
    }
    
    /**
     * @description Tests the getUserCertifications method to fetch certifications filtered by user ID.
     */
    
    @isTest
    static void testGetUserCertifications() {
        // Query the user created in @testSetup
        User testUser = [SELECT Id FROM User WHERE Alias = 'tadmin' LIMIT 1];
        
        // Insert a sample certification for this user
        Self_Certification__c cert = new Self_Certification__c(
            Country__c = 'IN',
            Submitted_By__c = testUser.Id,
            Certification_Period__c = Date.today(),
            Next_Due_Date__c = Date.today().addYears(1),
            Certified_By__c = testUser.Id,
            E_Signature__c = true,
            Email__c = 'test@example.com',
            Confirmation__c = true,
            Comments__c = 'User Certification Test',
            Status__c = 'Submitted'
        );
        insert cert;
        
        Test.startTest();
        List<Self_Certification__c> userCerts = SelfCertificationController.getUserCertifications(testUser.Id);
        Test.stopTest();
        
        System.assert(userCerts.size() > 0, 'Expected at least one certification record for the user.');
        System.assertEquals('IN', userCerts[0].Country__c, 'Country should match.');
    }
    
    /**
     * @description Tests the getAllCertifications method to fetch all certification records.
     */
    
    @isTest
    static void testGetAllCertifications() {
        // Query the test user
        User testUser = [SELECT Id FROM User WHERE Alias = 'tadmin' LIMIT 1];
        
        System.runAs(testUser) {
            // Insert test data
            Self_Certification__c cert = new Self_Certification__c(
                Country__c = 'IN',
                Submitted_By__c = testUser.Id,
                Certification_Period__c = Date.today(),
                Next_Due_Date__c = Date.today().addYears(1),
                Certified_By__c = testUser.Id,
                E_Signature__c = true,
                Email__c = 'test@example.com',
                Confirmation__c = true,
                Comments__c = 'Unit Test',
                Status__c = 'Submitted'
            );
            insert cert;
            
            Test.startTest();
            List<Self_Certification__c> result = SelfCertificationController.getAllCertifications();
            Test.stopTest();
            
            System.assert(result.size() > 0, 'Expected at least one certification record.');
            System.assertEquals('IN', result[0].Country__c, 'Country should match');
        }
    }
    
    /**
     * @description Tests the uploadSignedPDF method by creating a dummy file and linking it to a certification.
     */
    
    @isTest
    static void testUploadSignedPDF() {
        // First, create a certification record
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        Self_Certification__c cert = new Self_Certification__c(
            Country__c = 'IN',
            Submitted_By__c = testUser.Id,
            Certification_Period__c = Date.today(),
            Next_Due_Date__c = Date.today().addYears(1),
            Certified_By__c = testUser.Id,
            E_Signature__c = true,
            Email__c = 'test@example.com',
            Confirmation__c = true,
            Comments__c = 'PDF Upload Test',
            Status__c = 'Submitted'
        );
        insert cert;
        
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test PDF content'));
        String fileName = 'TestFile.pdf';
        
        Test.startTest();
        SelfCertificationController.uploadSignedPDF(cert.Id, base64Data, fileName);
        Test.stopTest();
        
        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :cert.Id];
        System.assert(links.size() > 0, 'File should be linked to certification record.');
    }
}