import { LightningElement, track, wire } from 'lwc';
import getAllCertifications from '@salesforce/apex/SelfCertificationAdminController.getAllCertifications';

const COLUMNS = [
    { label: 'Country', fieldName: 'Country__c' },
    { label: 'Certification Date', fieldName: 'Certification_Period__c', type: 'date' },
    { label: 'Next Due Date', fieldName: 'Next_Due_Date__c', type: 'date' },
    { label: 'Submitted By', fieldName: 'Submitted_By_Name' },
    { label: 'Certified By', fieldName: 'Certified_By_Name' },
    { label: 'Status', fieldName: 'Status__c' }
];

export default class SelfCertificationAdmin extends LightningElement {
    @track columns = COLUMNS;
    @track originalData = [];
    @track certifications = [];
    @track error;
    @track searchKey = '';
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
    filters = {
        country: '',
        user: '',
        status: ''
    };

    get countryOptions() {
        const countries = [...new Set(this.originalData.map(r => r.Country__c).filter(Boolean))];
        return [{ label: 'All', value: '' }, ...countries.map(c => ({ label: c, value: c }))];
    }

    get statusOptions() {
        return [
            { label: 'All', value: '' },
            { label: 'Approved', value: 'Approved' },
            { label: 'Rejected', value: 'Rejected' },
            { label: 'Submitted', value: 'Submitted' },
            { label: 'Overdue', value: 'Overdue' }
        ];
    }

    @wire(getAllCertifications)
    wiredCerts({ error, data }) {
    if (data) {
        console.log('Fetched Certifications:', data);
        this.originalData = data.map(record => ({
            ...record,
            Certified_By_Name: record.Certified_By__r ? record.Certified_By__r.Name : '',
            Submitted_By_Name: record.Submitted_By__r ? record.Submitted_By__r.Name : '' ,
            Next_Due_Date__c: record.Next_due_date__c 
         }));
        this.certifications = [...this.originalData];
        this.currentPage = 1;
        this.applyFilters();
    } else if (error) {
        console.error('LWC Wire Error:', JSON.stringify(error));
        this.error = error;
    }
}

    handleFilterChange(event) {
        const { name, value } = event.target;
        this.filters[name] = value;
        this.applyFilters();
    }

    handleSearchChange(event) {
    this.searchKey = event.target.value.toLowerCase();
    this.applyFilters();
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
    const filtered = this.certifications;
    const startIndex = (this.currentPage - 1) * this.pageSize;
    const endIndex = this.currentPage * this.pageSize;
    this.paginatedCertifications = filtered.slice(startIndex, endIndex);
}

   applyFilters() {
    const filtered = this.originalData.filter(record => {
        const country = (record.Country__c || '').toLowerCase();
        const submittedBy = (record.Submitted_By_Name || '').toLowerCase();
        const certifiedBy = (record.Certified_By_Name || '').toLowerCase();
        const status = (record.Status__c || '').toLowerCase();

        const matchesSearch =
            !this.searchKey ||
            country.includes(this.searchKey) ||
            submittedBy.includes(this.searchKey) ||
            certifiedBy.includes(this.searchKey) ||
            status.includes(this.searchKey);

        return matchesSearch;
    });

      this.certifications = filtered;
    this.totalPages = Math.ceil(filtered.length / this.pageSize);

    // Ensure currentPage is not out of range
    if (this.currentPage > this.totalPages) {
        this.currentPage = this.totalPages || 1;
    }

    const start = (this.currentPage - 1) * this.pageSize;
    const end = start + this.pageSize;
    this.paginatedCertifications = filtered.slice(start, end);

}
}
