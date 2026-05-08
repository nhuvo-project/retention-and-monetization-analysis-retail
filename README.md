# Diagnosing Retention Collapse & Monetization Inefficiencies in Fashion E-commerce

## Executive Summary

The Look has a retention problem, not a demand problem.

Using cohort analysis, customer segmentation, and revenue modeling across a star-schema structure, this project identifies where customer value breaks down after acquisition.

### Core Findings
- Repeat buyers are few but drive disproportionate revenue
- Retention collapses shortly after first purchase
- High-volume categories underperform on monetization
- Fit-sensitive products generate elevated return leakage
- Inventory is already aligned with demand

### Strategic Implication
Growth depends less on acquiring more customers and more on increasing customer lifetime value through:
- Stronger retention
- Lower return leakage
- Better category monetization

---

## Business Problem

The Look converts traffic into first purchases effectively but struggles to retain and monetize customers over time.

Growth remains heavily acquisition-dependent rather than driven by compounding customer value.

---

## Analytical Framework

- **Growth Structure** — acquisition vs. repeat demand
- **Retention & Purchase Behavior** — retention decay, repurchase frequency, value concentration
- **Revenue Leakage** — return-driven revenue erosion
- **Category Monetization** — demand-to-revenue conversion efficiency
- **Operational Validation** — whether inventory constrains performance

---

## Data & Modeling

- Cleaned and validated transaction-level retail data
- Duplicate and missing value handling
- Star-schema structure across:
  - Customers
  - Orders
  - Products
  - Inventory

### SQL Techniques
- CTEs
- Window functions
- Cohort analysis
- Customer segmentation
- Ranking & revenue contribution analysis

---

## Key Findings

| Area | Finding |
|---|---|
| Growth | Acquisition-driven; repeat customer expansion remains weak |
| Customer Value | Repeat buyers contribute disproportionate revenue |
| Retention | Activity declines sharply after first purchase |
| Returns | Fit-sensitive categories experience elevated return rates |
| Category Performance | High order volume does not consistently translate into strong monetization |
| Inventory | Inventory allocation is already demand-aligned |

---

## Strategic Priorities

- Strengthen post-purchase retention
- Reduce return-driven value leakage
- Improve monetization efficiency across underperforming categories

> Long-term growth depends on customer lifetime value expansion, not acquisition volume alone.

---

## Dashboard Scope

Executive-level monitoring across:
- Retention performance
- Revenue contribution
- Return behavior
- Category monetization
- Inventory alignment

---

## Limitations & Next Steps

Built on simulated retail data with simplified operational assumptions.

Future improvements:
- Marketing attribution
- Pricing elasticity
- Customer satisfaction metrics
- Supply chain lead-time integration
