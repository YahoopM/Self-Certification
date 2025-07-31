import { LightningElement, track, wire } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.Name';
import COUNTRY_FIELD from '@salesforce/schema/User.Country';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import getPricingByCountry from '@salesforce/apex/SelfCertificationController.getPricingForCountry';
import createSelfCertification from '@salesforce/apex/SelfCertificationController.createSelfCertification';
import getUserCertifications from '@salesforce/apex/SelfCertificationController.getUserCertifications';
import uploadSignedPDF from '@salesforce/apex/SelfCertificationController.uploadSignedPDF';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Country', fieldName: 'Country__c' },
    { label: 'Certification Date', fieldName: 'Certification_Period__c', type: 'date' },
    { label: 'Next Due Date', fieldName: 'Next_Due_Date__c', type: 'date' },
    { label: 'Certified By', fieldName: 'Certified_By_Name' },
    { label: 'Status', fieldName: 'Status__c' }
];


export default class SelfCertificationUser extends LightningElement {
@track userName = '';
@track userCountry = '';
@track userEmail = '';
@track certificationPeriod = new Date().getFullYear();
@track confirmation = false;
@track comments = '';
@track eSignature = false;
@track recordId = '';
@track pricingData = [];
@track uploadedFileId = '';
@track userId = USER_ID;
@track error;
@track showForm = false; 
@track userSubmissions = [];
@track usercertifications = [];
@track submissionColumns   = COLUMNS;
//@track certificationPeriod = new Date().getFullYear().toString(); 
selectedFile;
@track currentPage = 1;
@track pageSize = 5;
@track totalPages = 0;
@track paginatedCertifications = [];

get isPreviousDisabled() {
    return this.currentPage === 1;
}
get isNextDisabled() {
    return this.currentPage === this.totalPages || this.totalPages === 0;
}



// Step 1: Get user details
@wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD, COUNTRY_FIELD, EMAIL_FIELD] })
userInfo({ error, data }) {
if (data) {
    this.userName = data.fields.Name.value;
    this.userCountry = data.fields.Country.value;
    this.userEmail = data.fields.Email.value; 
    console.log('Fetched Email:', this.userEmail);
    // Fetch pricing data for the user's country
    getPricingByCountry({ country: this.userCountry })
        .then(result => {
            console.log('Pricing data:', result);
            this.pricingData = result;
        })
        .catch(err => {
            console.error('Error fetching pricing:', err);
        });
} else if (error) {
    console.error('Error fetching user info:', error);
}
}





loadUserCertifications(){
getUserCertifications({ userId: this.userId })
    .then(result => {
        console.log('User Certifications:', result);
        const mapped = result.map(record => ({
            ...record,
            Certified_By_Name: record.Certified_By__r ? record.Certified_By__r.Name : '',
            Next_Due_Date__c: record.Next_due_date__c
        }));

        this.usercertifications = mapped;
        this.totalPages = Math.ceil(mapped.length / this.pageSize);
        this.currentPage = 1;
        this.updatePaginatedData();
        
    })
    .catch(error => {
        console.error('Error fetching user certifications:', error);
        this.showToast('Error', 'Failed to load certifications.', 'error');
    });
    
}
connectedCallback() {
this.loadUserCertifications();
}

resetForm() {
    this.comments = '';
    this.confirmation = false;
    this.eSignature = false;
    this.selectedFile = null;
    this.recordId = '';
}

handleCreateClick() {
this.showForm = true;
}
handleCloseForm() {
this.showForm = false;
this.resetForm();


}

handleConfirmation(event) {
this.confirmation = event.target.checked;
}

handleComments(event) {
this.comments = event.target.value;
}

handleESignature(event) {
this.eSignature = event.target.checked;
}


handleNext() {
if (this.currentPage < this.totalPages) {
    this.currentPage++;
    this.updatePaginatedData();
}
}

handlePrevious() {
if (this.currentPage > 1) {
    this.currentPage--;
    this.updatePaginatedData();
}
}
updatePaginatedData() {
    const startIndex = (this.currentPage - 1) * this.pageSize;
    const endIndex = this.currentPage * this.pageSize;
    this.userSubmissions = this.usercertifications.slice(startIndex, endIndex);
}


handleFileChange(event) {
    console.log('File input changed:', event);
    let file = event.target.files[0];
    console.log('Selected file:', file);
    if (file && file.type === "application/pdf") {
        this.selectedFile = file;   
        this.showToast('Success', 'PDF file selected successfully!', 'success');
    } else {
        this.selectedFile = null;
        this.showToast('Error', 'Please upload a valid PDF file.', 'error');
    }
}



handleFileUploadError(event) {
console.error('Upload Error:', JSON.stringify(event.detail));
alert('Upload failed: ' + event.detail.message);
}

handleSubmit() {
if (!this.confirmation || !this.eSignature) {
    this.showToast('Error', 'Please confirm and e-sign before submitting.', 'error');
    return;
}

if (!this.selectedFile) {
    this.showToast('Error', 'Please select a PDF file.', 'error');
    return;
}
console.log('Submitting Self-Certification with:', this.certificationPeriod);
createSelfCertification({
    country: this.userCountry,
    Email: this.userEmail,
    comments: this.comments,
    esignature: this.eSignature,
    confirmation: this.confirmation,
    userId: USER_ID
})
.then(recordId => {
    this.recordId = recordId;

    let reader = new FileReader();
    reader.onloadend = () => {
        const base64 = reader.result.split(',')[1];

        uploadSignedPDF({
            selfCertId: recordId,
            base64Data: base64,
            fileName: this.selectedFile.name
        })
        .then(() => {
            this.showToast('Success', 'Self-Certification submitted successfully!', 'success');
            this.loadUserCertifications();
            
            this.comments = '';
            this.confirmation = false;
            this.eSignature = false;
            this.selectedFile = null;
            this.recordId = '';

            
            const fileInput = this.template.querySelector('lightning-input[type="file"]');
            if (fileInput) {
                fileInput.value = null;
            }
            
            
            
        })
        .catch(error => {
            console.error('PDF upload error:', error);
            this.showToast('Error', 'File upload failed.', 'error');
        });
    };

    reader.readAsDataURL(this.selectedFile);
    
})
.catch(error => {
    console.error('Record creation error:', error);
    this.showToast('Error', 'Failed to create Self-Certification record.', 'error');
});
this.handleCloseForm();


}




showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant, mode: 'dismissable' }));
    }



}
