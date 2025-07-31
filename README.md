# Self-Certification
💼 Self-Certification Management System – Hands-on Salesforce Project
This is a personal hands-on Salesforce project where I designed and developed a Self-Certification Management System using Lightning Web Components (LWC), Apex, and Salesforce Metadata.

🔧 Key Features:
📄 Self-Certification Form: Users can submit certification details with comments, checkbox confirmation, and upload a signed PDF.

🌍 Dynamic Pricing Data: Automatically fetches and displays pricing data based on the user’s country using Custom Metadata Types.

📥 PDF Upload: Uploads and links signed PDF files to the certification record using ContentVersion and ContentDocumentLink.

🧾 My Submissions Table: Displays paginated and sortable user submissions using a Lightning Data Table.

🔁 Auto Refresh: Updates the submission list in real-time after form submission.

🛡️ Validation: Includes UI and backend validations to prevent incomplete or invalid submissions.

👨‍💻 Admin View: (Optional enhancement) To view and manage all user certifications.

🛠 Tech Stack:
Salesforce Apex – for controller logic, file processing, data retrieval

LWC (Lightning Web Components) – for interactive front-end UI

SOQL & DML – for record handling

Custom Metadata Types – for configurable pricing by country

Test Classes – 90%+ coverage for deployment readiness

📚 What I Learned:
Hands-on experience integrating ContentVersion file upload with custom LWC

Writing clean, modular Apex code with separation of concerns (Controller vs Handler)

Using @AuraEnabled(cacheable=true) for efficient wire methods

Managing pagination and real-time UI refresh in LWC

Writing unit tests using @isTest and Test.startTest()/Test.stopTest() for Apex

This project reflects a real-world Salesforce implementation scenario for internal self-declarations or compliance tracking.
🔗 Feel free to fork, clone, or suggest improvements!
