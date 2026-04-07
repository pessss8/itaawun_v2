# iTa'awun — Project Abstract

**Word Count:** ~300 words

---

## Problem Statement

The International Islamic University Malaysia (IIUM) hosts over 20,000 students, many of whom face financial challenges while pursuing their studies. A significant portion (approximately 7–8% of the student body) are Asnaf recipients—students eligible for Zakat assistance who rely on welfare support. These students, particularly from B40 households, struggle to find flexible, safe, and Shariah-compliant income opportunities on campus.

Currently, student services operate through fragmented WhatsApp groups and word-of-mouth networks. This informal economy presents several critical issues:

1. **No Verification**: Anyone can join university WhatsApp groups, creating safety risks for students engaging in transactions with unverified strangers
2. **Fragmented Access**: Services are scattered across dozens of chat groups, making discovery difficult for both providers and customers
3. **No Accountability**: There is no dispute resolution mechanism, no rating system, and no transaction history
4. **Academic Risk**: Students may neglect studies for income activities without any oversight
5. **Missed Welfare Targeting**: B40 and Asnaf students who most need income support have no priority access to opportunities

## Solution: iTa'awun

iTa'awun (Arabic: التعاون — "The Cooperation") is a centralized web platform that connects IIUM CFS (Centre for Foundation Studies) students for service exchange and micro-entrepreneurship. The platform enables students to:

- **Offer Services**: Create listings for services like printing, laundry, food delivery, tutoring, and barber services
- **Request Help**: Post "Live Gigs" for one-off tasks with reward amounts
- **Book Securely**: Formal booking system with accept/reject workflow and completion tracking
- **Rate & Review**: Build trust through a transparent rating system
- **Admin Oversight**: University administrators can verify vendors, monitor transactions, and intervene in disputes

### Key Differentiators

1. **Verified Community**: Only authenticated IIUM students can access the platform via Supabase authentication
2. **Academic Safeguards**: Admin can set CGPA thresholds—vendors with low CGPA (<2.0) are flagged for review
3. **B40 Priority**: Asnaf verification system gives welfare recipients priority access to vendor opportunities
4. **Shariah Compliance**: Built on principles of Maqasid al-Shariah, emphasizing cooperation (ta'awun) and mutual benefit

## Impact

### Social Impact
- **Economic Empowerment**: Provides dignified income opportunities for B40 and Asnaf students, reducing financial stress and dropout rates
- **Safety & Trust**: Verified user base eliminates risks associated with transacting with strangers
- **Community Building**: Fosters a culture of mutual assistance aligned with Islamic values of cooperation

### Measurable Outcomes (Projected)
- 500+ active users in first semester (CFS IIUM student population)
- 50+ verified vendors, with 60% from B40/Asnaf backgrounds
- 200+ completed bookings monthly
- Average student vendor income: RM150–300/month

### Alignment with National Priorities
- Supports **Shared Prosperity Vision 2030** by empowering B40 youth
- Advances **Islamic Finance leadership** through Shariah-compliant gig economy
- Contributes to **UN SDGs**: No Poverty (SDG 1), Quality Education (SDG 4), Decent Work (SDG 8)

## Technical Implementation

- **Frontend**: Vanilla HTML/CSS/JavaScript (mobile-first responsive design)
- **Backend**: Supabase (PostgreSQL, Authentication, Row-Level Security)
- **Hosting**: GitHub Pages (free, reliable, continuous deployment)
- **Database**: 5-table schema (profiles, services, bookings, ratings, gigs)
- **Security**: Row-Level Security policies ensure users can only access their own data

## Conclusion

iTa'awun transforms the informal, fragmented student service economy into a structured, safe, and equitable platform. By combining technology with Islamic principles of mutual cooperation and welfare prioritization, it creates a sustainable ecosystem where financial need meets community support—with dignity, safety, and academic success at its core.

---

*Prepared for IPO (Innovation & Entrepreneurship Programme) Application 2026*
