# iTa'awun — Social Impact Statement

## Executive Summary

iTa'awun is designed to address student financial insecurity through a Shariah-compliant gig economy platform. By prioritizing B40 and Asnaf students for income opportunities, iTa'awun transforms from a neutral marketplace into a **targeted poverty alleviation tool** aligned with Islamic welfare principles.

**Core Mission:** Enable dignified income generation for financially vulnerable IIUM students while maintaining academic excellence and community safety.

---

## Problem: Student Financial Insecurity

### The B40 Reality

Malaysia's B40 household classification (bottom 40% income, <RM2,500/month) includes a significant portion of university students. At IIUM CFS:

- **Estimated B40 Students:** ~400–500 out of 2,000 CFS students
- **Asnaf Recipients:** ~7–8% of student body receive Zakat assistance
- **Monthly Financial Gap:** Average B40 student needs RM300–500/month beyond existing support

### Current Coping Mechanisms (and Their Problems)

| Method | Problem |
|--------|---------|
| **WhatsApp gig hunting** | Unverified strangers, no accountability |
| **Off-campus part-time work** | Time-consuming, transportation costs, safety risks |
| **Increased Zakat dependence** | Dignity concerns, limited funds |
| **Academic neglect** | Some students prioritize work over studies |
| **Debt/credit usage** | Potential riba (interest), financial stress |

### The Dignity Problem

Traditional welfare approaches treat students as **passive recipients** of aid. iTa'awun recognizes that many Asnaf students prefer **dignified income generation** over charity when given the opportunity.

---

## Solution: Welfare-First Platform Design

### 1. Asnaf Verification System

**How it works:**
1. Student submits Asnaf application via platform
2. Uploads supporting documents (Zakat letter, household income proof)
3. Admin verifies through `admin.html` → Asnaf Verification tab
4. Verified status stored in database

**Database Schema:**
```sql
-- profiles table includes:
is_asnaf BOOLEAN DEFAULT false
asnaf_verified_at TIMESTAMP
asnaf_verified_by UUID (admin user ID)
```

**Impact:** Creates an official registry of welfare-eligible students for priority targeting.

---

### 2. B40 Priority Mechanisms

iTa'awun can prioritize B40/Asnaf students through:

#### a) Vendor Approval Priority
When admin reviews vendor applications, B40 status is visible:
```html
<td>${u.is_b40 ? '<span class="s-b40">B40</span>' : '—'}</td>
```

**Policy:** Admin can approve B40 vendors first when slots are limited.

#### b) Live Gigs Priority (Future Feature)
Platform can show B40 students first when claiming gigs:
```sql
-- Priority query (future implementation)
SELECT * FROM gigs 
WHERE status = 'available'
ORDER BY (SELECT is_b40 FROM profiles WHERE id = claimant_id) DESC
```

#### c) Visibility Badge (Future Feature)
B40 vendors can display a badge showing customers their purchase supports welfare students:
```html
<span class="b40-badge">🤲 Supports B40 Student</span>
```

---

### 3. Income Generation Without Riba

All transactions on iTa'awun are **Shariah-compliant**:

| Transaction Type | Islamic Contract | Description |
|-----------------|------------------|-------------|
| Service Sale | **Bay' al-'Urbun** | Customer pays, vendor delivers service |
| Live Gig Reward | **Ju'alah** | Reward-based contract for specified task |
| Vendor Listing | **Ijarah** | Service offered for fixed price |

**No Interest, No Riba:**
- No credit system
- No payment installments
- Direct reward/price model
- All transactions are spot contracts

---

## Maqasid al-Shariah Framework

iTa'awun is designed around the **Five Essentials (Al-Daruriyyat Al-Khams)** of Islamic jurisprudence:

### 1. Hifz al-Din (Protection of Faith)
- Platform facilitates Shariah-compliant income
- No haram services allowed (no gambling, alcohol, etc.)
- Encourages Islamic ethic of mutual assistance (ta'awun)

**Quranic Foundation:**
> *"And cooperate in righteousness and piety, but do not cooperate in sin and aggression."* (Quran 5:2)

### 2. Hifz al-Nafs (Protection of Life)
- Verified user base prevents dangerous encounters with strangers
- All users are authenticated IIUM students
- Reduces need for risky off-campus work

### 3. Hifz al-Nasl (Protection of Lineage)
- Gender interactions remain professional (service-based)
- Admin can intervene in inappropriate communications
- Community accountability through ratings

### 4. Hifz al-Mal (Protection of Wealth)
- Secure transaction framework
- No riba (interest) in any transaction
- Fair pricing through market transparency
- Dispute resolution via admin dashboard

### 5. Hifz al-'Aql (Protection of Intellect)
- **CGPA monitoring** ensures vendors maintain academic standards
- Admin can suspend vendors with CGPA < 2.0
- Platform encourages balance between work and study

---

## Measurable Social Impact

### Year 1 Projections (CFS IIUM Pilot)

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| **B40 Students Earning Income** | 100+ students | Database query: `SELECT COUNT(*) FROM profiles WHERE is_b40=true AND role='vendor'` |
| **Average Monthly Income (B40)** | RM200–400 | Booking data aggregation |
| **Asnaf Verification Applications** | 50+ | `SELECT COUNT(*) FROM profiles WHERE is_asnaf=true` |
| **Completed Bookings** | 500+ | `SELECT COUNT(*) FROM bookings WHERE status='done'` |
| **Student Satisfaction** | 4.0+ stars | Average from ratings table |
| **Vendor CGPA Maintenance** | 90% maintain CGPA ≥ 2.0 | Admin dashboard tracking |

### Long-Term Impact (3 Years)

| Outcome | Year 1 | Year 2 | Year 3 |
|---------|--------|--------|--------|
| Active B40 Vendors | 50 | 150 | 300 |
| Monthly B40 Income Generated | RM10,000 | RM30,000 | RM60,000 |
| Asnaf Students Supported | 30 | 80 | 150 |
| Campus-Wide Adoption | CFS only | All IIUM | Other universities |

---

## Alignment with National Priorities

### 1. Shared Prosperity Vision 2030
**Goal:** Improve B40 household income and economic mobility

**iTa'awun Contribution:**
- Direct income generation for B40 students
- Skills development through entrepreneurship
- Pathway to post-graduation business ventures

### 2. Islamic Finance Leadership
**Goal:** Position Malaysia as global Islamic finance hub

**iTa'awun Contribution:**
- Demonstrates Shariah-compliant gig economy model
- Practical application of Islamic commercial contracts
- Exportable framework for Islamic universities worldwide

### 3. Higher Education Access (SDG 4)
**Goal:** Ensure inclusive and equitable education

**iTa'awun Contribution:**
- Reduces financial dropout risk for B40 students
- Enables students to remain enrolled while earning income
- Academic safeguards (CGPA monitoring) protect educational outcomes

### 4. Decent Work and Economic Growth (SDG 8)
**Goal:** Promote sustainable economic growth and decent work

**iTa'awun Contribution:**
- Creates dignified, flexible work opportunities
- Fair pricing through transparent marketplace
- Safe working environment (on-campus, verified community)

---

## Stakeholder Benefits

### For B40/Asnaf Students
- ✅ Dignified income without charity stigma
- ✅ Flexible hours around class schedule
- ✅ Safe, on-campus opportunities
- ✅ Priority access to vendor slots
- ✅ No transportation costs

### For University Administration
- ✅ Oversight of student economic activity
- ✅ CGPA monitoring prevents academic neglect
- ✅ Dispute resolution mechanism
- ✅ Data for Zakat reporting
- ✅ Enhanced student welfare reputation

### For Zakat/Baitulmal Authorities
- ✅ Verified registry of Asnaf student vendors
- ✅ Impact reports showing fund utilization
- ✅ Measurable outcomes (income generated, bookings completed)
- ✅ Transition pathway from aid to self-sufficiency

### For General Student Body
- ✅ Safe, verified service providers
- ✅ Fair pricing through competition
- ✅ Convenient on-campus services
- ✅ Community building through ta'awun

---

## Risk Mitigation

| Risk | Mitigation Strategy |
|------|---------------------|
| **Academic neglect** | CGPA monitoring, admin suspension power |
| **Exploitation/underpricing** | Admin oversight, minimum price policies |
| **Non-B40 students dominating** | B40 priority in vendor approval |
| **Shariah compliance concerns** | Built on Islamic contract principles |
| **Safety incidents** | Verified user base, admin intervention |
| **Platform misuse** | Service activation/deactivation, user bans |

---

## Conclusion: Beyond Profit to Purpose

iTa'awun represents a **third way** between:
- ❌ Pure charity (dignity concerns, limited funds)
- ❌ Pure capitalism (profit maximization, exploitation risk)
- ✅ **Islamic social economy** (dignified income, welfare priority, community benefit)

By embedding B40 prioritization, Asnaf verification, and Maqasid al-Shariah principles into platform design, iTa'awun creates a **sustainable ecosystem** where:

> **Financial need meets community support—with dignity, safety, and academic success at its core.**

This is not just a gig platform. It is a **poverty alleviation tool**, a **student welfare system**, and a **practical application of Islamic economic principles**—all built for the IIUM community.

---

*Prepared for IPO (Innovation & Entrepreneurship Programme) Application 2026*
