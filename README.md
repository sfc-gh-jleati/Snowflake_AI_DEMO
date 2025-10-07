# DAVE Product Analytics Demo - Snowflake Intelligence

A complete Snowflake Intelligence demonstration customized for **DAVE Operating Co**, showcasing AI-powered product analytics for a B2C fintech company.

## 🎯 Overview

This demo is specifically designed for **DAVE's Product and Executive Teams** to demonstrate how Snowflake Intelligence enables natural language analytics across:
- **Product Usage** - How customers use DAVE app features
- **Transaction Analytics** - ExtraCash advances, fees, tips, subscriptions
- **User Acquisition** - Campaign performance, CAC, conversion funnels
- **Team Performance** - Organizational metrics and staffing

## ⚡ Quick Start

### Execute the Setup (5 Minutes)

1. **Open Snowsight** (https://app.snowflake.com) with **ACCOUNTADMIN** role
2. **Create New Worksheet**
3. **Copy & Paste** entire `sql_scripts/demo_setup.sql` file
4. **Click "Run All"** (Ctrl/Cmd + Shift + Enter)
5. **Wait 3-5 minutes** for completion

### Access the Agent

1. Click **"AI & ML"** → **"Intelligence"** in Snowsight
2. Select **"DAVE Product Analytics Agent"**
3. Start asking questions in natural language!

## 🎬 Demo Script - Sample Questions

### 1. Product Usage Analytics (5 minutes)

**Opening Question:**
```
What are the top 5 most used DAVE features by transaction volume?
```

**Follow-up Questions:**
```
Show me ExtraCash transaction trends by month for 2024 with a visualization

How many users are using both ExtraCash and Budgeting tools?

What's the adoption rate for Credit Builder compared to other products?

Which features have the highest user engagement by user segment?
```

**Key Insights to Highlight:**
- ExtraCash is the most popular product
- Gig Workers and Young Professionals are power users
- Cross-feature usage indicates product stickiness
- Visualizations show clear trends

---

### 2. Transaction & Revenue Analytics (5 minutes)

**Opening Question:**
```
What is our average revenue per user (ARPU) by product line?
```

**Follow-up Questions:**
```
Show me monthly revenue trends by product category for 2024

What's the average ExtraCash advance amount by user segment?

Compare revenue from ExtraCash, Subscriptions, and Tips

What percentage of users pay tips, and what's the average tip amount?
```

**Key Insights to Highlight:**
- ExtraCash drives majority of revenue
- Average advance amount is $75-$150
- Subscriptions provide recurring revenue
- Tips show user satisfaction

---

### 3. User Acquisition & Growth (5 minutes)

**Opening Question:**
```
What's our user acquisition cost (CAC) by marketing channel?
```

**Follow-up Questions:**
```
Which marketing campaigns have the best conversion rates from signup to activated user?

Show me monthly user signups by acquisition channel for 2024

What's our user activation rate from signup to first transaction?

Compare user lifetime value (LTV) by acquisition channel
```

**Key Insights to Highlight:**
- Referral program has lowest CAC
- Social media drives high volume
- Conversion rates vary significantly by channel
- LTV:CAC ratio shows profitable channels

---

### 4. User Behavior & Retention (5 minutes)

**Opening Question:**
```
Which user segments have the highest transaction frequency?
```

**Follow-up Questions:**
```
What's the average time between transactions for active users?

How many users who took an ExtraCash advance in Q1 2024 are still active?

Which features correlate with higher user retention?

Show me user churn indicators by segment
```

**Key Insights to Highlight:**
- Gig Workers have highest transaction frequency
- Multi-feature users have better retention
- Budgeting tool usage reduces churn
- Different segments have different behaviors

---

### 5. Cross-Functional Analysis (5 minutes)

**Advanced Questions:**
```
Calculate LTV to CAC ratio by user segment and acquisition channel

Show me the complete funnel from campaign impression to revenue generated

Which user segments are most profitable when considering acquisition cost?

What's the ROI of our top 5 marketing campaigns including closed revenue?
```

**Key Insights to Highlight:**
- End-to-end visibility from marketing to revenue
- Data-driven decision making
- Cross-functional insights
- Immediate answers to complex questions

---

### 6. Document Search & Policy Questions (3 minutes)

**Demo Document Search:**
```
What is our expense policy for vendor payments?

Search our marketing strategy documents for user acquisition tactics

What are the key features mentioned in our product documentation?
```

**Key Insights to Highlight:**
- Combines structured data with unstructured documents
- Retrieves relevant policies and documentation
- Provides context for data insights

---

## 💡 Key Demo Messages

### For Product Team:
- **Self-Service Analytics** - No SQL or data team required
- **Feature Insights** - Understand which features users love
- **User Behavior** - Identify patterns and opportunities
- **Data-Driven Decisions** - Make product choices based on actual usage

### For Executive Team:
- **Strategic Metrics** - ARPU, CAC, LTV, retention at your fingertips
- **ROI Visibility** - Track marketing spend to revenue
- **Growth Monitoring** - User acquisition and activation trends
- **Resource Optimization** - Identify what's working, cut what isn't

## 🏗️ What Gets Created

### Snowflake Objects:
- **Database**: `DAVE_AI_DEMO`
- **Schema**: `DAVE_PRODUCT_ANALYTICS`
- **Role**: `DAVE_Intelligence_Demo`
- **Warehouse**: `DAVE_Intelligence_demo_wh`

### Data Tables (17 Total):

**Dimension Tables (13):**
- `product_category_dim` - DAVE product lines
- `product_dim` - 100 DAVE features (ExtraCash, Banking, Budgeting, Credit Builder)
- `customer_dim` - 1,000 app users with segments
- `department_dim` - 31 DAVE departments
- `job_dim` - 61 DAVE roles with levels
- `campaign_dim` - 100 marketing campaigns
- `channel_dim` - 20 acquisition channels
- `account_dim` - Revenue & expense categories
- `region_dim` - 4 US regions
- `vendor_dim` - 1,000 fintech partners
- `employee_dim` - DAVE team members
- `location_dim` - Office locations

**Fact Tables (4):**
- `sales_fact` - 13,101 product usage transactions
- `finance_transactions` - 112,984 financial records
- `marketing_campaign_fact` - 49,316 campaign activities
- `hr_employee_fact` - Team member records

**User Journey Tables (3):**
- `sf_accounts` - 1,000 user account profiles
- `sf_opportunities` - 24,507 user activations
- `sf_contacts` - 38,389 user signups

### Semantic Views (4):
1. **Transaction Analytics** - ExtraCash, fees, tips, subscriptions
2. **Product Usage Analytics** - Feature adoption & engagement (B2C model)
3. **User Acquisition & Retention** - Campaigns, CAC, LTV, conversions
4. **Team Performance** - DAVE team composition

### AI Services (9):
- 4 Cortex Search Services (Finance, HR, Marketing, Sales docs)
- 3 Custom Tools (Web scraper, Email sender, File URL generator)
- 1 Agent: **DAVE Product Analytics Agent**
- 1 Git Repository Integration

## 📊 DAVE-Specific Data

### Products (100 DAVE Features):
- **ExtraCash Advances**: $25, $50, $75, $100, $150, $200, $250, $300, $400, $500
- **Banking Services**: Account, Debit Card, Direct Deposit, Transfers, Check Deposit
- **Budgeting Tools**: Goals, Side Hustle Tracker, Spending Insights, Bill Forecast
- **Credit Building**: Enrollment, Score Monitoring, Payment History, Auto Payment
- **Subscriptions**: Monthly, Quarterly, Annual, Premium memberships
- **Fees & Tips**: Express fees, Tips ($1-$10), Service fees

### User Segments (15 Types):
- Young Professional
- Gig Worker
- Student
- Healthcare Worker
- Retail Worker
- Service Industry
- Tech Worker
- Freelancer
- Small Business Owner
- Teacher
- Driver
- Restaurant Worker
- Administrative
- Sales Professional
- Warehouse Worker

### Marketing Campaigns (100 Campaigns):
- Product Launches (ExtraCash, Banking, Credit Builder)
- Seasonal (Back to School, Holiday, Tax Season)
- Segment-Specific (Gig Workers, Students, Healthcare Workers)
- Channel Campaigns (Social Media, Influencer, Podcast)
- Retention & Reactivation Drives

### Acquisition Channels (20 Channels):
- Organic & Paid Search
- Social Media Ads (Facebook, Instagram, TikTok, YouTube, Twitter)
- Referral Program
- App Stores (iOS & Android)
- Email & Content Marketing
- Influencer & Podcast Partnerships
- Display & Affiliate Marketing

### Transaction Amounts (Realistic for Fintech):
- **ExtraCash**: $25-$500 (most common: $75-$200)
- **Tips**: $1-$10 (most common: $3-$5)
- **Subscriptions**: $1-$10/month
- **User LTV**: $50-$500
- **Marketing Spend**: $100-$25,000 per campaign

## 🔧 Technical Architecture

### B2C Data Model
**Pure consumer model** - removed B2B concepts:
- ❌ No sales rep tracking on user transactions (self-service model)
- ❌ No vendor tracking on user transactions (direct app usage)
- ✅ Clean user → product → transaction relationships
- ✅ Payment processors tracked in finance (operational only)

### Data Volumes:
| Dataset | Records | Time Range |
|---------|---------|------------|
| App Users | 1,000 | - |
| Products/Features | 100 | - |
| Product Usage Transactions | 13,101 | 2024-2025 |
| Financial Transactions | 112,984 | 2024-2025 |
| Campaign Activities | 49,316 | 2024-2025 |
| User Activations | 24,507 | 2024-2025 |
| User Signups | 38,389 | 2024-2025 |
| DAVE Team Members | 200+ | Current |

### GitHub Integration:
- **Repository**: https://github.com/sfc-gh-jleati/Snowflake_AI_DEMO
- **Auto-Sync**: `ALTER GIT REPOSITORY DAVE_AI_DEMO_REPO FETCH;`
- **Data Files**: All CSV files in `/demo_data/`
- **Documents**: All PDFs in `/unstructured_docs/`

## 📈 Use Cases Enabled

### Product Team:
1. **Feature Adoption Analysis** - Which features are users engaging with?
2. **User Engagement Trends** - How has usage changed over time?
3. **Product Cross-Usage** - Which features are used together?
4. **Segment Analysis** - How do different user types behave?
5. **Churn Prediction** - What signals indicate at-risk users?

### Executive Team:
1. **Revenue Analytics** - ARPU, LTV, revenue by product
2. **Unit Economics** - LTV:CAC ratio, payback periods
3. **Growth Metrics** - User growth, activation, retention rates
4. **Channel Performance** - Which channels drive best users?
5. **Operational Efficiency** - Cost per transaction, team productivity

### Growth/Marketing Team:
1. **Campaign ROI** - Which campaigns drive activations?
2. **Channel Effectiveness** - Best performing acquisition sources
3. **Conversion Optimization** - Where do users drop off?
4. **Cohort Analysis** - User behavior over time
5. **Attribution** - Full funnel from impression to revenue

## 📝 Post-Setup Verification

After running the script, verify with:

```sql
USE DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS;

-- Check all tables created (17 tables)
SHOW TABLES;

-- Verify semantic views (4 views)
SHOW SEMANTIC VIEWS;

-- Check search services (4 services)
SHOW CORTEX SEARCH SERVICES;

-- Verify data loaded
SELECT 'Users' as dataset, COUNT(*) as records FROM customer_dim
UNION ALL
SELECT 'Products', COUNT(*) FROM product_dim
UNION ALL
SELECT 'Transactions', COUNT(*) FROM sales_fact
UNION ALL
SELECT 'Financial Txns', COUNT(*) FROM finance_transactions
UNION ALL
SELECT 'Campaigns', COUNT(*) FROM marketing_campaign_fact
UNION ALL
SELECT 'User Accounts', COUNT(*) FROM sf_accounts
UNION ALL
SELECT 'Activations', COUNT(*) FROM sf_opportunities
UNION ALL
SELECT 'Signups', COUNT(*) FROM sf_contacts;

-- Expected Results:
-- Users: 1,000
-- Products: 100
-- Transactions: ~13,101
-- Financial Txns: ~112,984
-- Campaigns: ~49,316
-- User Accounts: 1,000
-- Activations: ~24,507
-- Signups: ~38,389

-- Check the agent exists
SHOW AGENTS IN SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS;
```

## 🎯 Sample Questions Library

### Product Usage Questions:
```
What are the top 5 most used DAVE features?

Show me ExtraCash transaction volumes by month for 2024

How many users are using both ExtraCash and Budgeting tools?

What's the adoption rate for Credit Builder vs Banking?

Which features have declining usage trends?

What's the average transaction size for each ExtraCash product tier?
```

### User Analytics Questions:
```
Which user segments have the highest engagement?

Show me user engagement trends over the last 6 months

How many active users do we have each month?

What percentage of users become repeat ExtraCash users?

Which user segments use multiple DAVE products?

What's the distribution of users across segments?
```

### Financial Questions:
```
What is our average revenue per user (ARPU) by product?

Show me monthly revenue trends by product line

What's the revenue split between ExtraCash, Subscriptions, and Tips?

What are our top expense categories?

Calculate ARPU by user segment

What's the average tip amount and how many users tip?
```

### Growth & Marketing Questions:
```
What's our user acquisition cost (CAC) by channel?

Which marketing campaigns have the best conversion rates?

Show me monthly user signups by acquisition channel

What's our user activation rate from signup to first transaction?

Which channels have the lowest CAC?

Compare LTV to CAC ratio by acquisition channel

What's the conversion funnel from signup to activated user?

Which campaigns drove the most revenue?
```

### Retention & Churn Questions:
```
Which user segments have the highest churn rate?

What's our user retention rate at 30, 60, and 90 days?

How many users who got ExtraCash in Q1 are still active?

What features correlate with higher retention?

What's the average time between transactions for active users?

Which user cohorts have the best retention?
```

### Cross-Functional Questions:
```
Calculate LTV to CAC ratio by user segment and channel

Show me the complete funnel from campaign to revenue

Which user segments are most profitable?

What's the payback period by acquisition channel?

How does product usage affect lifetime value?
```

### Document Search Questions:
```
What is our expense policy for vendor payments?

Search our marketing strategy for user acquisition tactics

What does our financial report say about Q4 performance?

Find information about performance review guidelines
```

## 🏢 What Makes This DAVE-Specific

### B2C Fintech Model:
- **No B2B Concepts**: Removed sales reps and vendors from user transactions
- **Consumer Focus**: Individual app users, not businesses
- **Self-Service**: Users engage directly with app features
- **Realistic Amounts**: $25-$500 advances, not $50K+ B2B deals

### DAVE Products & Services:
- ExtraCash cash advances (core product)
- Dave Banking (checking accounts, debit cards)
- Budgeting tools (goals, insights, forecasts)
- Credit Builder (credit score improvement)
- Subscription tiers (Free, Basic, Premium, Premium Plus)

### DAVE User Segments:
- Gig Workers (Uber drivers, DoorDash, freelancers)
- Young Professionals (first jobs, career starters)
- Students (college, grad school)
- Essential Workers (healthcare, retail, service industry)
- Realistic demographic distribution

### DAVE Partners:
- Payment Processors: Stripe, Plaid, Dwolla, Marqeta
- Banking Infrastructure: Galileo, Unit
- Identity Verification: Alloy, Socure, Onfido
- Analytics: Segment, Amplitude, Mixpanel
- Infrastructure: AWS, Google Cloud
- Credit Bureaus: Experian, TransUnion, Equifax

## 📊 Data Architecture

### Semantic Views (Natural Language Interface):

#### 1. **Transaction Analytics** (Finance)
- Tracks: ExtraCash advances, fees, tips, subscriptions
- Dimensions: Transaction type, department, user, product, date
- Metrics: Total revenue, average transaction, transaction count
- Use: Revenue analysis, transaction patterns, ARPU

#### 2. **Product Usage Analytics** (Sales - B2C)
- Tracks: Feature usage, adoption, engagement
- Dimensions: User, product, region, date
- Metrics: Total usage, active users, average transaction
- Use: Feature adoption, product analytics, cross-usage patterns
- **B2C Model**: No sales reps or vendors

#### 3. **User Acquisition & Retention** (Marketing)
- Tracks: Campaigns, signups, activations, conversions
- Dimensions: Campaign, channel, user tier, date
- Metrics: CAC, LTV, conversion rate, activation rate
- Use: Campaign ROI, channel performance, funnel analysis

#### 4. **Team Performance** (HR)
- Tracks: DAVE team composition, staffing, roles
- Dimensions: Department, role, location, date
- Metrics: Team size, average salary, attrition rate
- Use: Organizational analytics, team composition

## 🎯 Business Value Demonstration

### Time to Insight:
- **Before**: Days/weeks for data team to build reports
- **With Snowflake Intelligence**: Seconds with natural language

### Accessibility:
- **Before**: SQL knowledge required
- **With Snowflake Intelligence**: Anyone can ask questions

### Breadth:
- **Before**: Siloed data in different systems
- **With Snowflake Intelligence**: Product + Finance + Marketing + Operations in one place

### Actionability:
- **Before**: Static reports, hard to explore
- **With Snowflake Intelligence**: Dynamic exploration, instant follow-ups

## 🔧 Technical Details

### Database Isolation:
This demo uses **separate objects** from the original demo:
- Original: `SF_AI_DEMO.DEMO_SCHEMA`
- DAVE Demo: `DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS`
- **Both can coexist** without conflicts

### Agent Configuration:
- **Name**: DAVE_Product_Analytics_Agent
- **Location**: `SNOWFLAKE_INTELLIGENCE.AGENTS.DAVE_Product_Analytics_Agent`
- **Context**: Fintech product analytics specialist
- **Tools**: 4 Cortex Analyst + 4 Cortex Search + 3 Custom tools

### Cortex Search Services:
1. **Finance Docs** - Policies, reports, vendor contracts
2. **Team Docs** - Handbooks, guidelines, org info
3. **Product Docs** - Feature specs, playbooks, success stories
4. **Marketing Docs** - Strategies, campaign reports

### Custom Functions:
1. **Web_scrape** - Analyze external web content
2. **send_mail** - Send email notifications
3. **Get_File_Presigned_URL_SP** - Generate document URLs

## 📋 Prerequisites

Before running the script:

- ✅ **ACCOUNTADMIN role** (or role with CREATE INTEGRATION privilege)
- ✅ **Anaconda Terms accepted** (for Python packages like requests, beautifulsoup4)
- ✅ **GitHub repository is public** (https://github.com/sfc-gh-jleati/Snowflake_AI_DEMO)
- ✅ **Files committed to GitHub** (demo_data/*.csv and unstructured_docs/*.pdf)

## 🎬 Demo Flow Recommendations

### 15-Minute Product Team Demo:
1. **Feature Adoption** (5 min) - "What are top features?" → "Show ExtraCash trends"
2. **User Behavior** (5 min) - "Which segments engage most?" → "Show cross-usage"
3. **Product Performance** (5 min) - "What's ARPU by product?" → "Revenue drivers"

### 15-Minute Executive Demo:
1. **Growth Metrics** (5 min) - "User growth trends?" → "CAC by channel"
2. **Financial Performance** (5 min) - "Revenue by product" → "ARPU trends"
3. **Strategic Insights** (5 min) - "Most profitable segments?" → "LTV:CAC ratio"

### 30-Minute Comprehensive Demo:
1. **Product Analytics** (7 min) - Usage patterns, adoption, engagement
2. **User Analytics** (7 min) - Segments, behavior, retention
3. **Growth Analytics** (7 min) - Campaigns, CAC, conversion funnels
4. **Financial Analytics** (5 min) - Revenue, ARPU, profitability
5. **Cross-Functional** (4 min) - End-to-end insights, LTV:CAC, ROI

## 🔍 Key Features to Highlight

### 1. Natural Language Interface
- No SQL required
- Ask questions conversationally
- Instant answers with visualizations

### 2. Cross-Functional Data
- Product + Finance + Marketing + Operations
- One source of truth
- Connected insights

### 3. Self-Service Analytics
- Product managers get insights independently
- No waiting for data team
- Explore data dynamically

### 4. Visualizations Included
- Auto-generated charts
- Trends, comparisons, distributions
- Executive-ready outputs

### 5. Document Integration
- Search policies and documentation
- Combine structured and unstructured data
- Context-aware answers

## 🚨 Troubleshooting

### If script fails at Git integration:
- Verify repository is public
- Check GitHub URL is correct
- Ensure files are committed to main branch

### If tables show 0 rows:
- Check `ON_ERROR = 'CONTINUE'` allowed script to continue
- Run verification queries to check which tables loaded
- Re-run specific COPY INTO statements if needed

### If agent doesn't appear:
- Verify you're in the correct account
- Check role has access to SNOWFLAKE_INTELLIGENCE schema
- Wait a few seconds for agent to initialize

### If queries fail:
- Ensure semantic views were created: `SHOW SEMANTIC VIEWS;`
- Check search services: `SHOW CORTEX SEARCH SERVICES;`
- Verify warehouse is running

## 📚 Additional Resources

- **Repository**: https://github.com/sfc-gh-jleati/Snowflake_AI_DEMO
- **Snowflake Docs**: https://docs.snowflake.com/en/user-guide/snowflake-intelligence
- **Cortex Analyst**: https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst
- **Semantic Views**: https://docs.snowflake.com/en/user-guide/views-semantic

## 🎉 Summary

This demo provides **DAVE's product and executive teams** with:

✅ **Immediate Relevance** - Uses DAVE's actual products and user segments
✅ **B2C Authenticity** - Pure consumer model, no B2B artifacts
✅ **Realistic Data** - Transaction amounts and volumes match fintech operations
✅ **Actionable Insights** - Answers strategic questions in seconds
✅ **Production-Ready** - Validated syntax, complete error handling
✅ **Quick Setup** - Single script, 5-minute execution
✅ **Natural Language** - No SQL skills required

**Ready to show DAVE how Snowflake Intelligence transforms product analytics!** 🚀

---

## 🔄 Refresh Data

To pull latest changes from GitHub:
```sql
USE ROLE DAVE_Intelligence_Demo;
ALTER GIT REPOSITORY DAVE_AI_DEMO_REPO FETCH;
```

## 🗑️ Cleanup (if needed)

To remove the demo:
```sql
USE ROLE ACCOUNTADMIN;
DROP AGENT IF EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS.DAVE_Product_Analytics_Agent;
DROP DATABASE IF EXISTS DAVE_AI_DEMO CASCADE;
DROP WAREHOUSE IF EXISTS DAVE_Intelligence_demo_wh;
DROP ROLE IF EXISTS DAVE_Intelligence_Demo;
```

---

**Created for DAVE Operating Co Product Analytics Demo**
*Snowflake Intelligence | AI-Powered Analytics | Natural Language Queries*
