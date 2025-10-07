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
- Database: `DAVE_AI_DEMO`
- 17 tables with 244K+ records of DAVE-specific sample data
- 4 semantic views for natural language queries
- 4 document search services
- 1 AI agent: **DAVE Product Analytics Agent**

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
- ExtraCash advances dominate (65% of all transactions)
- $75-$100 advances are the most popular amounts
- ExtraCash is THE killer feature

**Why This Matters**: Validates product-market fit and shows where to focus development

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
- **ExtraCash = #1 Product**: 65% of transactions, 65% of revenue
- **Most Popular Amounts**: $75-$100 (the sweet spot for users)
- **Budgeting Growing**: 15% adoption, drives 40% higher retention
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

**Sample Data:**
- 1,000 DAVE app users (Gig Workers, Young Professionals, Students, etc.)
- 100 DAVE products (ExtraCash, Banking, Budgeting, Credit Builder)
- 14,600+ product usage transactions
- 109,600+ financial transactions
- 49,300+ marketing campaign activities
- Realistic amounts: $25-$500 ExtraCash, $1-$10 tips

**AI Services:**
- 4 Semantic Views (for natural language queries)
- 4 Document Search Services (finance, HR, marketing, sales docs)
- 1 AI Agent with multi-tool capabilities

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
USE DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS;

-- Check tables loaded
SELECT 'users' as dataset, COUNT(*) FROM customer_dim
UNION ALL SELECT 'products', COUNT(*) FROM product_dim
UNION ALL SELECT 'transactions', COUNT(*) FROM sales_fact;

-- Expected: 1000 users, 100 products, ~14600 transactions

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