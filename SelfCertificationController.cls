/*
**********************************************************************************************************************
Apex Class Name    : SelfCertificationController
Created Date       : 15/07/2025
@author            : Yahoop
Modification Log:
Ver   	Date         		Author                               Modification
1.0   	15/07/2025  		Yahoop                               Initial Version
**********************************************************************************************************************
@description
This Apex controller class exposes server-side methods to Lightning Web Components (LWC) and Aura components.
It acts as a bridge between the front-end and the `SelfCertificationHandler` class, which contains core logic.

The controller:
- Retrieves pricing data based on a user’s country from custom metadata.
- Creates a new Self Certification record.
- Retrieves all or specific user-submitted certifications.
- Uploads a signed PDF file and links it to the relevant certification.
*/

public with sharing class SelfCertificationController {
    
    /**
     * @description Retrieves pricing metadata (Price and Country) for a given country.
     * Used in LWC to show country-specific pricing.
     * @param country The name of the country to filter by.
     * @return A list of Pricing_Settings__mdt records.
     */
    
    @AuraEnabled(cacheable=true)
    public static List<Pricing_Settings__mdt> getPricingForCountry(String country) {
        return SelfCertificationHandler.fetchPricingByCountry(country);
        
    }
    
     /**
     * @description Creates a new Self_Certification__c record with the provided data.
     * Called when the user submits the self-certification form.
     * @param Email User's email address.
     * @param country Selected country.
     * @param comments Additional comments from user.
     * @param esignature Whether e-signature was checked.
     * @param confirmation Whether the user confirmed the accuracy.
     * @param userId The ID of the user submitting.
     * @param fileID (optional) ID of the uploaded file (not used here).
     * @return The newly created Self_Certification__c record ID.
     */
    
    @AuraEnabled
    public static Id createSelfCertification(
        String Email,
        String country,
        String comments,
        Boolean esignature,
        Boolean confirmation,
        String userId,
        String fileID
    ) {
        return SelfCertificationHandler.createCertification(
            Email, country, comments, esignature, confirmation, userId, fileID
        );
    }
    
     /**
     * @description Retrieves all Self_Certification__c records in the org.
     * Useful for Admin view to show all certifications submitted by all users.
     * @return List of all certification records.
     */
    
    @AuraEnabled(cacheable=true)
    public static List<Self_Certification__c> getAllCertifications() {
        return SelfCertificationHandler.getAllCertifications();
    }
    
     /**
     * @description Retrieves certification records submitted by a specific user.
     * Used in user-specific dashboards or self-view screens.
     * @param userId The ID of the user whose certifications should be fetched.
     * @return List of Self_Certification__c records for the given user.
     */
    
    @AuraEnabled(cacheable=true)
    public static List<Self_Certification__c> getUserCertifications(Id userId) {
        return SelfCertificationHandler.getUserCertifications(userId);
    }
    
      /**
     * @description Uploads a base64-encoded signed PDF and links it to a certification record.
     * Typically triggered after form submission.
     * @param selfCertId ID of the certification record.
     * @param base64Data The base64-encoded PDF file content.
     * @param fileName The name of the PDF file.
     */
    
    
    @AuraEnabled
    public static void uploadSignedPDF(String selfCertId, String base64Data, String fileName) {
        SelfCertificationHandler.uploadSignedPDF(selfCertId, base64Data, fileName);
    }
}