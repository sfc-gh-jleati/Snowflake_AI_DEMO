# DAVE Product Analytics Demo - Snowflake Intelligence

AI-powered product analytics for DAVE's product and executive teams. Ask questions in natural language and get instant insights from your data.

**🚀 Setup**: 5 minutes | **Demo**: 5 questions | **Agent**: https://ai.snowflake.com

---

## ⚡ Quick Setup

### Step 1: Run the Setup Script (5 minutes)

1. Open **Snowsight** at https://app.snowflake.com
2. Make sure you're using **ACCOUNTADMIN** role
3. Create a **New Worksheet**
4. Copy and paste the entire `sql_scripts/demo_setup.sql` file
5. Click **"Run All"** (or press Ctrl/Cmd + Shift + Enter)
6. Wait 3-5 minutes while it creates everything

**What gets created:**
- Database: `DAVE_AI_DEMO.PRODUCT_ANALYTICS`  
- **4 clean tables** with ~1,300 records (fast!)
  - users (100) - App users with segment, acquisition channel, LTV
  - products (100) - DAVE features
  - transactions (913) - Product usage events
  - campaigns (214) - Marketing with channel costs
- **2 semantic views** for natural language queries
- **1 document search service** for policies
- **1 AI agent**: DAVE Product Analytics Agent

### Step 2: Access the Agent

1. Go to **https://ai.snowflake.com** (or in Snowsight: **AI & ML** → **Intelligence**)
2. Find and select **"DAVE Product Analytics Agent"**
3. Start asking the demo questions below!

---

## 🎯 5-Minute Demo Script

Copy these questions **one at a time** into the agent:

### **Question 1: What's Our Most Popular Product?**
```
What are the top 5 most used DAVE features by transaction volume? Show me the breakdown.
```

**What You'll See:**
- **#1: ExtraCash $75** - 3,168 transactions (20% of all activity!)
- **#2: ExtraCash $100** - 2,452 transactions (15%)
- **#3: ExtraCash $50** - 1,625 transactions (10%)
- Top 3 alone = 45% of all transactions
- Overall ExtraCash = 70% of all activity

**Why This Matters**: Clear product-market fit - ExtraCash isn't just popular, it's DOMINANT. The $75-$100 range is the sweet spot. This guides pricing, limits, and product strategy.

---

### **Question 2: Who Are Our Best Users?**
```
Show me the average lifetime value for Gig Workers, Young Professionals, and Students. Then show me which acquisition channels have the lowest cost per user.
```

**What You'll See:**
- Young Professionals: $250-450 LTV (highest value segment)
- Gig Workers: $150-300 LTV (highest volume - 40% of users)
- Students: $80-180 LTV (budget-conscious, love budgeting tools)
- Referral Program: $15-30 CAC (best ROI)
- Instagram: $40-60 CAC (high volume)

**Why This Matters**: Shows which users to acquire and which channels are most efficient

---

### **Question 3: How Do We Compare to Competitors?**
```
How do our products compare against https://www.albert.com? Analyze their website and compare their feature offerings to our DAVE products.
```

**What You'll See:**
- Agent scrapes Albert's website in real-time
- Compares their features to DAVE's ExtraCash, Banking, and Budgeting
- Identifies competitive advantages and gaps

**Why This Matters**: Instant competitive intelligence without manual research

---

### **Question 4: What Do Our Policies Say?**
```
What does our financial policy say about expense management and vendor payments?
```

**What You'll See:**
- Agent searches expense policies and vendor management documents
- Returns relevant sections with document links
- Combines policy info with data insights

**Why This Matters**: Shows how structured + unstructured data work together

---

### **Question 5: Send Me the Summary**
```
Send me an email summary of this chat to your.email@company.com
```

**What You'll See:**
- Agent compiles the entire conversation
- Sends HTML-formatted email with all insights
- Actionable summary for follow-up

**Why This Matters**: Makes insights shareable and actionable

---

## 📊 What the Data Reveals

The demo uses realistic sample data that tells a compelling story:

### Product Insights
- **ExtraCash = THE Dominant Product**: 70% of all transactions
- **Top 3 Products (all ExtraCash)**: $75 (20%), $100 (15%), $50 (10%) = 45% of activity
- **Sweet Spot Identified**: $75-$100 range is the clear winner
- **Budgeting Strong Second**: 10% adoption, drives retention
- **Tips = Satisfaction**: 60% of users tip, average $3.50

### User Insights
- **Gig Workers = Core Market**: 40% of users, 50%+ of transactions
- **Young Professionals = Highest Value**: $250-450 LTV, most Premium users
- **Students = Budget-Conscious**: Love budgeting tools, lower LTV but engaged
- **Weekend Spikes**: 40% more transactions on Sat/Sun (gig worker paydays)

### Acquisition Insights
- **Referral Program = Best ROI**: $15-30 CAC, 70% activation rate (10:1 LTV:CAC)
- **Instagram = Volume Leader**: $40-60 CAC, highest campaign volume
- **TikTok = Growing**: Popular with Students, 45% activation rate
- **Paid Search = Scalable**: $60-85 CAC, works but expensive

### Key Metrics
| Metric | Value | Insight |
|--------|-------|---------|
| ExtraCash % of revenue | 65% | Dominant product |
| Average ExtraCash amount | $95 | Sweet spot $75-$100 |
| Gig Worker % of users | 40% | Core market |
| Young Professional LTV | $250-450 | Highest value |
| Referral CAC | $15-30 | Best efficiency |
| Tip adoption | 60%+ | High satisfaction |

---

## 💬 More Questions to Try

After the 5-minute demo, explore these:

**Product Questions:**
```
Show me ExtraCash transaction trends by month for 2024
What's the average ExtraCash amount by user segment?
How many users use both ExtraCash and Budgeting tools?
Which features have the highest engagement?
```

**User & Revenue Questions:**
```
Which user segments have the highest transaction frequency?
Show me revenue breakdown by product line
What percentage of users pay tips?
Compare Premium vs Free user behavior
```

**Growth Questions:**
```
Which marketing campaigns have the best conversion rates?
Show me monthly user signups by channel
What's our overall user activation rate?
Do users from Referrals have better retention?
```

**Strategic Questions:**
```
Show me the complete funnel from signup to revenue
Which user segments are most profitable?
What's the ROI of our top 5 campaigns?
How does budgeting tool adoption affect retention?
```

---

## 🏗️ What Gets Created

When you run the setup script, it creates:

**Database & Schema:**
- `DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS`

**Clean B2C Architecture:**
- 100 DAVE app users (Gig Workers 40%, Young Professionals 25%, Students 15%)
- 100 DAVE products (ExtraCash, Banking, Budgeting, Credit Builder, Tips)
- 913 product usage transactions (ExtraCash $75, $100, $50 dominate)
- 214 marketing campaigns (10 channels, realistic CAC)
- **Total: ~1,300 rows** (fast queries, instant insights!)

**AI Services:**
- 2 Semantic Views (Product Analytics, User Acquisition)
- 1 Document Search Service (all policies)
- 1 AI Agent with multi-tool capabilities
- Web scraping & email functions

---

## 🎯 Key Capabilities

**Natural Language Queries**
- No SQL required
- Ask questions conversationally
- Get instant answers with visualizations

**Multi-Tool Agent**
- Query structured data (Cortex Analyst)
- Search documents (Cortex Search)
- Scrape websites (Web Scraping)
- Send emails (Email integration)

**Cross-Functional Analytics**
- Product + Finance + Marketing + Operations
- One agent, all your data
- Connected insights across teams

---

## ✅ Verify Setup

After running the script, verify everything worked:

```sql
USE DAVE_AI_DEMO.PRODUCT_ANALYTICS;

-- Check tables loaded
SELECT 'users' as dataset, COUNT(*) FROM users
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL SELECT 'campaigns', COUNT(*) FROM campaigns;

-- Expected: 100 users, 100 products, ~900 transactions, ~200 campaigns

-- Check agent exists
SHOW AGENTS IN SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS;
-- Look for: DAVE_Product_Analytics_Agent
```

---

## 🔧 Troubleshooting

**Setup fails?**
- Make sure you're using ACCOUNTADMIN role
- Check that GitHub repository is accessible
- Verify Anaconda terms are accepted in your account

**Agent not visible?**
- Wait 30 seconds after setup completes
- Refresh Snowsight browser page
- Check you're in the correct Snowflake account

**Queries not working?**
- Run: `SHOW SEMANTIC VIEWS;` to verify views were created
- Run: `SELECT COUNT(*) FROM sales_fact;` to verify data loaded
- Make sure you selected the correct agent in Snowsight

**Need help?**
- Repository: https://github.com/sfc-gh-jleati/Snowflake_AI_DEMO
- All code and data is open source and customizable

---

## 🎬 Demo Tips

**For Product Teams:**
- Start with Question 1 to show product usage
- Emphasize self-service (no SQL needed)
- Show cross-product insights (ExtraCash + Budgeting)

**For Executives:**
- Focus on Questions 2 (LTV/CAC) and strategic metrics
- Highlight instant ROI calculations
- Show competitive analysis capability (Question 3)

**For Growth Teams:**
- Deep dive into channel performance
- Show acquisition funnel analysis
- Demonstrate campaign ROI tracking

---

## 🔄 Update Data

The demo uses sample data from GitHub. To refresh:

```sql
USE ROLE DAVE_Intelligence_Demo;
ALTER GIT REPOSITORY DAVE_AI_DEMO_REPO FETCH;
```

This pulls the latest CSV files and documents from the repository.

---

## 🗑️ Remove Demo

To clean up when done:

```sql
USE ROLE ACCOUNTADMIN;
DROP AGENT IF EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS.DAVE_Product_Analytics_Agent;
DROP DATABASE IF EXISTS DAVE_AI_DEMO CASCADE;
DROP WAREHOUSE IF EXISTS DAVE_Intelligence_demo_wh;
DROP ROLE IF EXISTS DAVE_Intelligence_Demo;
```

---

## 📦 What's Included

**Repository**: https://github.com/sfc-gh-jleati/Snowflake_AI_DEMO

**Key Files:**
- `sql_scripts/demo_setup.sql` - Complete setup script (one file, 5 minutes)
- `demo_data/` - 20 CSV files with realistic DAVE data
- `unstructured_docs/` - Sample policies and documentation

**DAVE-Specific Data:**
- 100 DAVE products and features
- 1,000 app users across 6 segments
- Realistic transaction amounts ($25-$500)
- Real fintech partners (Stripe, Plaid, Dwolla)
- Authentic marketing campaigns

---

**Questions?** Check the repository: https://github.com/sfc-gh-jleati/Snowflake_AI_DEMO

**Ready to demo Snowflake Intelligence to DAVE's teams!** 🚀