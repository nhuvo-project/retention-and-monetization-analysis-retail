# Cleaned Data

Description:
This folder contains the cleaned and enriched transactional dataset used for business analysis.

Key processing steps:
- Removed cancelled transactions and invalid pricing records
- Filtered rows with missing critical timestamps
- Consolidated transactional and customer-level information
- Standardized order status into:
  - Completed
  - Returned
  - In Progress
- Engineered analytical features, including:
  - Discount percentage
  - Discount tier
  - Customer lifetime type
  - Monthly order cohort
