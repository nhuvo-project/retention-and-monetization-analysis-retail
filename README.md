# Diagnosing Retention Collapse & Monetization Inefficiencies in Retail E-commerce

## Executive Summary

The Look generates demand effectively but fails to retain and fully monetize customers after acquisition.

Using cohort analysis, customer segmentation, and category-level revenue diagnostics across a star-schema retail dataset, this project identifies retention decay and monetization inefficiencies as the primary constraints to sustainable growth.

### Core Findings
- Revenue depends disproportionately on repeat buyers
- Retention collapses shortly after first purchase
- Returns create meaningful revenue leakage
- High-demand categories remain under-monetized
- Inventory allocation is already demand-aligned

### Strategic Implication
Long-term growth depends on increasing customer lifetime value rather than expanding acquisition volume alone.

Key strategic priorities include:
- Strengthening post-purchase retention
- Reducing return-driven value leakage
- Improving category monetization efficiency

---

## Deliverables

### Interactive Dashboard
https://datastudio.google.com/s/nEryUEoN0qE

### Presentation Deck
- PDF Version: `/presentation/full_case_deck.pdf`
- Interactive Canva Version: https://canva.link/0n20o196xnejk99

---

## Business Problem

The Look converts traffic into first purchases effectively but struggles to retain and monetize customers over time.

As a result, growth remains heavily acquisition-dependent rather than driven by compounding customer value.

---

## Analytical Framework

### Growth Structure
- Acquisition vs. repeat customer contribution
- Revenue stability and customer dynamics

### Retention & Purchase Behavior
- Cohort retention decay
- Repurchase frequency
- Customer value concentration

### Revenue Leakage
- Return-driven revenue erosion
- Category-level return exposure

### Category Monetization
- Demand-to-revenue conversion efficiency
- Pricing and monetization performance

### Operational Validation
- Inventory allocation vs. realized demand

---

## Analytical Methodology

### Data Preparation
- Cleaned and validated transaction-level retail data
- Duplicate and missing-value validation
- Business-rule filtering and feature engineering

### Data Modeling
Star-schema structure across:
- Customers
- Orders
- Products
- Inventory

### SQL Techniques
- CTEs
- Window functions
- Cohort analysis
- Customer segmentation
- Ranking & contribution analysis

---

## Key Findings

| Area | Finding |
|---|---|
| Growth Structure | Revenue growth remains acquisition-driven with limited repeat expansion |
| Customer Value | Repeat buyers contribute disproportionate revenue relative to customer share |
| Retention | Customer activity declines sharply after first purchase |
| Returns | Fit-sensitive categories experience elevated return leakage |
| Category Monetization | High sales volume does not consistently translate into strong monetization |
| Inventory Alignment | Inventory allocation is already closely aligned with customer demand |

---

## Dashboard Coverage

Executive-level monitoring across:
- Revenue dynamics
- Customer retention
- Repeat purchase behavior
- Return leakage
- Category monetization
- Inventory-demand alignment

---

## Strategic Priorities

- Strengthen post-purchase retention
- Reduce return-driven value leakage
- Improve monetization efficiency across underperforming categories

> Sustainable growth depends on expanding customer lifetime value rather than acquisition volume alone.

---

## Limitations & Future Improvements

This project was built on simulated retail data with simplified operational assumptions.

Potential future enhancements include:
- Marketing attribution analysis
- Pricing elasticity modeling
- Customer satisfaction metrics
- Supply chain lead-time integration
- Promotion and campaign effectiveness analysis
