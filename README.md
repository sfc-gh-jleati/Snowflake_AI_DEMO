# DAVE Product Analytics Demo - Snowflake Intelligence

A complete Snowflake Intelligence demonstration customized for **DAVE Operating Co**, showcasing AI-powered product analytics for a B2C fintech company.

**🚀 Quick Start**: Run `sql_scripts/demo_setup.sql` → Access agent at **https://ai.snowflake.com** → Ask the [5 demo questions](#-5-minute-demo-script-multi-tool-showcase) below!

## 🎯 Overview

This demo is specifically designed for **DAVE's Product and Executive Teams** to demonstrate how Snowflake Intelligence enables natural language analytics across:
- **Product Usage** - How customers use DAVE app features
- **Transaction Analytics** - ExtraCash advances, fees, tips, subscriptions
- **User Acquisition** - Campaign performance, CAC, conversion funnels
- **Team Performance** - Organizational metrics and staffing
- **Competitive Intelligence** - Web scraping and external data analysis
- **Document Search** - Policy and documentation retrieval

## ⚡ Quick Start

### Execute the Setup (5 Minutes)

1. **Open Snowsight** (https://app.snowflake.com) with **ACCOUNTADMIN** role
2. **Create New Worksheet**
3. **Copy & Paste** entire `sql_scripts/demo_setup.sql` file
4. **Click "Run All"** (Ctrl/Cmd + Shift + Enter)
5. **Wait 3-5 minutes** for completion

### Access the Agent

1. Open **https://ai.snowflake.com** (or click **"AI & ML"** → **"Intelligence"** in Snowsight)
2. Select **"DAVE Product Analytics Agent"**
3. Follow the 5-question demo script below!

---

## 🎯 **5-Minute Demo Script** (Multi-Tool Showcase)

Copy and paste these questions into the agent **one at a time**:

### **Question 1: Product Usage** (Cortex Analyst - Product Usage Analytics)
```
What are the top 5 most used DAVE features by transaction volume? Show me the breakdown.
```
**Expected Insight**: ExtraCash products dominate (65% of transactions), with $75-$100 advances being most popular.

---

### **Question 2: User Segments & Value** (Cortex Analyst - Multi-Domain)
```
Show me the average lifetime value for Gig Workers, Young Professionals, and Students. Then show me which acquisition channels have the lowest cost per user.
```
**Expected Insight**: Young Professionals highest LTV ($250-450), Gig Workers $150-300 (high volume), Students $80-180. Referral Program has lowest CAC ($15-30), Instagram medium ($40-60).

---

### **Question 3: Competitive Analysis** (Web Scraping Tool)
```
How do our products compare against https://www.albert.com? Analyze their website and compare their feature offerings to our DAVE products.
```
**Expected Insight**: Agent will scrape Albert's website and compare their cash advance, budgeting, and banking features to DAVE's offerings.

---

### **Question 4: Policy Search** (Cortex Search - Document Search)
```
What does our financial policy say about expense management and vendor payments?
```
**Expected Insight**: Agent searches finance documents and returns relevant policy information from expense policies and vendor management docs.

---

### **Question 5: Email Summary** (Email Tool)
```
Send me an email summary of this chat to [your.email@company.com]
```
**Expected Insight**: Agent compiles the conversation and sends an HTML-formatted email summary of all insights discussed.

---

**Demo Time**: ~5 minutes | **Tools Used**: All 4 tool types (Cortex Analyst, Cortex Search, Web Scraping, Email)

**Agent URL**: https://ai.snowflake.com

---

## 💡 What Insights the Data Reveals

The sample data has been crafted to reveal **compelling, realistic insights** that will resonate with DAVE's teams:

### 🏆 **ExtraCash Dominates** (65% of transactions)
- Most popular amounts: $75-$100 (the sweet spot)
- Clear product-market fit with gig economy
- Drives 65% of all revenue

### 👥 **Gig Workers Are Core Users** (40% of users, 50%+ of transactions)
- Highest transaction frequency
- Weekend activity spikes (payday patterns)
- Prefer $50-$150 ExtraCash range

### 💎 **Young Professionals = Highest Value** ($250-450 LTV)
- 25% of user base
- Most likely to be Premium tier
- Growing segment with best unit economics

### 🎯 **Referral Program = Best ROI** ($15-30 CAC, 70% activation)
- 10:1 LTV:CAC ratio (clear winner)
- Instagram high volume but medium CAC ($40-60)
- Paid Search scalable but expensive ($60-85 CAC)

### 🛠️ **Budgeting Tools Drive Retention**
- 15% overall adoption
- Students love it (30%+ usage rate)
- Multi-product users have 40% higher LTV

### 💰 **Tips Show Satisfaction** (60%+ adoption, $3.50 average)
- 15% of total revenue
- Premium users tip more
- Validates user satisfaction

## 📚 Additional Sample Questions

**See the [5-Minute Demo Script](#-5-minute-demo-script-multi-tool-showcase) above for the recommended demo flow.**

Below are additional questions you can explore:

### Product Usage:
```
Show me ExtraCash transaction trends by month for 2024
How many users are using both ExtraCash and Budgeting tools?
What's the adoption rate for Credit Builder?
Which features have declining usage trends?
```

### User & Revenue Analytics:
```
What is our average revenue per user (ARPU) by segment?
Show me monthly revenue trends by product line
What percentage of users pay tips?
Which user segments have the highest transaction frequency?
```

### Growth & Marketing:
```
Which campaigns have the best conversion rates?
Show me user signups by channel over time
What's our overall user activation rate?
Compare LTV to CAC ratio by channel
```

### Retention & Behavior:
```
Which segments have the highest churn rate?
What's our retention rate at 30, 60, and 90 days?
Do multi-product users have better retention?
Show me transaction patterns by day of week
```

### Cross-Functional:
```
Calculate ROI of our top 5 campaigns
Which user segments are most profitable?
Show me the complete funnel from signup to revenue
What's the payback period by acquisition channel?
```

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

## 💬 More Questions to Try

Explore these additional questions after the 5-minute demo:

```
Show me ExtraCash transaction trends by month for 2024
Compare revenue from ExtraCash vs Subscriptions vs Tips
Which user segments have the highest engagement?
What's our user activation rate from signup to first transaction?
How many users are using both ExtraCash and Budgeting tools?
Which campaigns have the best conversion rates?
What's the average tip amount and how many users tip?
Show me transaction patterns by day of week
Which user cohorts have the best retention?
Search our marketing strategy for user acquisition tactics
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

## 🎯 Key Value Propositions

**For Product Teams:**
- ✅ Self-service analytics (no SQL required)
- ✅ Instant feature adoption insights
- ✅ Multi-tool capabilities (data + docs + web scraping + email)

**For Executives:**
- ✅ Strategic metrics at fingertips (ARPU, CAC, LTV, ROI)
- ✅ Cross-functional visibility
- ✅ Data-driven decision making in seconds

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
