# Salesforce-Profiles-Deployment
Salesforce Profiles Deployment

### 1. List metadatas 

List the following metadatas 

* CustomApplication
* DataCategoryGroup
* ApexClass
* ApexPage
* CustomObject
* StandardField
* CustomField
* RecordType
* CustomTab
* Layout
* ExternalDataSource
* UserPermission

...

from the Source & Target

### 2. Intersect metadatas 

Interesct the listed metadatas between Source & Target 

### 3. Substract metadatas

Substract the Source list from the Target list for :

* DataCategoryGroup
* StandardField
* CustomField
* RecordType
* CustomTab
* UserPermission

### 4. Generate the package xml

Generate the package xml to extract the profiles

### 5. Clean the profiles

Clean the metadatas that exists in Source but not in Target 

* DataCategoryGroup
* StandardField
* CustomField
* RecordType
* CustomTab
* UserPermission



