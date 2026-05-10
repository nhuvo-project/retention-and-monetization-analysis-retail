# Assumptions & Limitations

## Business Assumptions
- Revenue is measured using `sale_price`
- Returned orders are excluded from realized demand calculations
- Repeat customers are defined as customers with more than one order
- Monthly cohorts are based on first purchase month

## Dataset Limitations
- `sold_at` was unavailable, therefore inventory turnover analysis was excluded
- No explicit sizing or fit-feedback variables were available
- Marketing spend data was unavailable, limiting Customer Acquisition Cost analysis
- Discount analysis was approximated using retail vs sale price differences
