/*
**********************************************************************************************************************
Apex Class Name    : SelfCertificationHandler
Created Date       : 15/07/2025
@author            : Yahoop
Modification Log:
Ver   	Date         		Author                               Modification
1.0   	15/07/2025   		 Yahoop                             Initial Version
**********************************************************************************************************************
*/


public class SelfCertificationHandler {
    
    public static List<Pricing_Settings__mdt> fetchPricingByCountry(String country) {
        if(country == Null){
            return Null;
        }
        return [
            SELECT Country__c, Price__c
            FROM Pricing_Settings__mdt
            WHERE Country__c = :country
        ];
    }
    
    public static Id createCertification(
        String email,
        String country,
        String comments,
        Boolean eSignature,
        Boolean confirmation,
        String userId,
        String fileId
    ) {
        if(string.isBlank(userId) || string.isBlank(email)){
            return Null;
        }
        
        Date today = Date.today();
        Date nextDueDate = today.addYears(1);
        
        User sysAdmin = [
            SELECT Id, Email FROM User
            WHERE Profile.Name = 'System Administrator' AND IsActive = true
            LIMIT 1
        ];
        
        Self_Certification__c cert = new Self_Certification__c(
            Country__c = country,
            Submitted_By__c = userId,
            Certification_Period__c = today,
            Next_Due_Date__c = nextDueDate,
            Certified_By__c = sysAdmin.Id,
            E_Signature__c = eSignature,
            Email__c = email,
            Confirmation__c = confirmation,
            Comments__c = comments,
            Status__c = 'Submitted'
        );
        
        insert cert;
        return cert.Id;
    }
    
    public static List<Self_Certification__c> getAllCertifications() {
            return [
                SELECT Id, Country__c, Certified_By__c, Certified_By__r.Name,
                Status__c, Certification_Period__c, Next_Due_Date__c,
                Submitted_By__c, Submitted_By__r.Name
                FROM Self_Certification__c
                ORDER BY Certification_Period__c DESC
            ];
        }
    
    public static List<Self_Certification__c> getUserCertifications(Id userId) {
            return [
                SELECT Id, Country__c, Certification_Period__c, Next_Due_Date__c,
                Status__c, Certified_By__r.Name
                FROM Self_Certification__c
                WHERE Submitted_By__c = :userId
                ORDER BY Certification_Period__c DESC
            ];
        }
    
    
    public static void uploadSignedPDF(String selfCertId, String base64Data, String fileName) {
        if (String.isBlank(selfCertId) || String.isBlank(base64Data) || String.isBlank(fileName)) {
            return;
        }
        try{
        
        ContentVersion cv = new ContentVersion(
            Title = fileName,
            PathOnClient = fileName,
            VersionData = EncodingUtil.base64Decode(base64Data)
        );
        insert cv;
        
        ContentDocument doc = [
            SELECT Id FROM ContentDocument
            WHERE LatestPublishedVersionId = :cv.Id
            LIMIT 1
        ];
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = doc.Id,
            LinkedEntityId = selfCertId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
        }
        catch(Exception e) {
        System.debug('Error in uploadSignedPDF: ' + e.getMessage());
        }
    }
}