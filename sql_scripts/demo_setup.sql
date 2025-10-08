-- ========================================================================
-- DAVE Product Analytics Demo - CLEAN B2C DATA MODEL
-- Built from scratch for B2C fintech - Not adapted from B2B!
-- Repository: https://github.com/sfc-gh-jleati/Snowflake_AI_DEMO.git
-- ========================================================================

/*
=============================================================================
CLEAN B2C ARCHITECTURE FOR DAVE
=============================================================================

4 CORE TABLES (vs 20 in old model):
1. users (100 rows) - DAVE app users with segment, acquisition, LTV
2. products (100 rows) - DAVE features  
3. transactions (913 rows) - Product usage events
4. campaigns (214 rows) - Marketing with channel costs

2 SEMANTIC VIEWS (vs 4 in old model):
1. Product Analytics - Usage patterns, revenue, top features
2. User Acquisition - Segments, LTV, CAC by channel

TOTAL DATA: ~1,300 rows (vs 244K!) - Loads in seconds, still tells full story

=============================================================================
*/

-- ========================================================================
-- SETUP: ROLE, WAREHOUSE, DATABASE
-- ========================================================================

USE ROLE accountadmin;

GRANT USAGE ON DATABASE snowflake_intelligence TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA snowflake_intelligence.agents TO ROLE PUBLIC;

CREATE OR REPLACE ROLE DAVE_Intelligence_Demo;

SET current_user_name = CURRENT_USER();
GRANT ROLE DAVE_Intelligence_Demo TO USER IDENTIFIER($current_user_name);
GRANT CREATE DATABASE ON ACCOUNT TO ROLE DAVE_Intelligence_Demo;

CREATE OR REPLACE WAREHOUSE DAVE_Intelligence_demo_wh 
    WITH WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE;

GRANT USAGE ON WAREHOUSE DAVE_INTELLIGENCE_DEMO_WH TO ROLE DAVE_Intelligence_Demo;

ALTER USER IDENTIFIER($current_user_name) SET DEFAULT_ROLE = DAVE_Intelligence_Demo;
ALTER USER IDENTIFIER($current_user_name) SET DEFAULT_WAREHOUSE = DAVE_Intelligence_demo_wh;

USE ROLE DAVE_Intelligence_Demo;

CREATE OR REPLACE DATABASE DAVE_AI_DEMO;
USE DATABASE DAVE_AI_DEMO;

CREATE SCHEMA IF NOT EXISTS PRODUCT_ANALYTICS;
USE SCHEMA PRODUCT_ANALYTICS;

CREATE OR REPLACE FILE FORMAT CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    NULL_IF = ('NULL', 'null', '', 'N/A');

-- ========================================================================
-- GIT INTEGRATION
-- ========================================================================

USE ROLE accountadmin;

CREATE OR REPLACE API INTEGRATION git_api_integration
    API_PROVIDER = git_https_api
    API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-jleati/')
    ENABLED = TRUE;

GRANT USAGE ON INTEGRATION GIT_API_INTEGRATION TO ROLE DAVE_Intelligence_Demo;

USE ROLE DAVE_Intelligence_Demo;

CREATE OR REPLACE GIT REPOSITORY DAVE_AI_DEMO_REPO
    API_INTEGRATION = git_api_integration
    ORIGIN = 'https://github.com/sfc-gh-jleati/Snowflake_AI_DEMO.git';

CREATE OR REPLACE STAGE INTERNAL_DATA_STAGE
    FILE_FORMAT = CSV_FORMAT
    DIRECTORY = (ENABLE = TRUE)
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');

ALTER GIT REPOSITORY DAVE_AI_DEMO_REPO FETCH;

COPY FILES INTO @INTERNAL_DATA_STAGE/demo_data_new/
FROM @DAVE_AI_DEMO_REPO/branches/main/demo_data_new/;

COPY FILES INTO @INTERNAL_DATA_STAGE/unstructured_docs/
FROM @DAVE_AI_DEMO_REPO/branches/main/unstructured_docs/;

ALTER STAGE INTERNAL_DATA_STAGE REFRESH;

-- ========================================================================
-- CLEAN B2C TABLE SCHEMAS
-- ========================================================================

-- 1. USERS - DAVE app users
CREATE OR REPLACE TABLE users (
    user_id INT PRIMARY KEY,
    user_segment VARCHAR(50) NOT NULL,
    acquisition_channel VARCHAR(100),
    signup_date DATE NOT NULL,
    account_tier VARCHAR(20) NOT NULL,
    lifetime_value DECIMAL(10,2) NOT NULL,
    region VARCHAR(50) NOT NULL,
    city VARCHAR(100),
    state VARCHAR(10)
);

-- 2. PRODUCTS - DAVE features
CREATE OR REPLACE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    product_category VARCHAR(50) NOT NULL,
    price_point DECIMAL(10,2)
);

-- 3. TRANSACTIONS - Product usage
CREATE OR REPLACE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    transaction_date DATE NOT NULL,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    region VARCHAR(50) NOT NULL
);

-- 4. CAMPAIGNS - Marketing
CREATE OR REPLACE TABLE campaigns (
    campaign_id INT PRIMARY KEY,
    campaign_name VARCHAR(200) NOT NULL,
    channel VARCHAR(100) NOT NULL,
    campaign_date DATE NOT NULL,
    spend DECIMAL(10,2) NOT NULL,
    leads_generated INT NOT NULL,
    impressions INT NOT NULL
);

-- ========================================================================
-- LOAD DATA FROM GIT
-- ========================================================================

COPY INTO users FROM @INTERNAL_DATA_STAGE/demo_data_new/users.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO products FROM @INTERNAL_DATA_STAGE/demo_data_new/products.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO transactions FROM @INTERNAL_DATA_STAGE/demo_data_new/transactions.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO campaigns FROM @INTERNAL_DATA_STAGE/demo_data_new/campaigns.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';

-- Verify
SELECT 'users' as table_name, COUNT(*) FROM users
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL SELECT 'campaigns', COUNT(*) FROM campaigns;

-- ========================================================================
-- SEMANTIC VIEW 1: PRODUCT ANALYTICS
-- ========================================================================

CREATE OR REPLACE SEMANTIC VIEW DAVE_AI_DEMO.PRODUCT_ANALYTICS.product_analytics_view
    tables (
        USERS as users primary key (USER_ID) comment='DAVE app users',
        PRODUCTS as products primary key (PRODUCT_ID) comment='DAVE products and features',
        TRANSACTIONS as transactions primary key (TRANSACTION_ID) comment='Product usage transactions'
    )
    relationships (
        TXN_TO_USERS as TRANSACTIONS(USER_ID) references USERS(USER_ID),
        TXN_TO_PRODUCTS as TRANSACTIONS(PRODUCT_ID) references PRODUCTS(PRODUCT_ID)
    )
    facts (
        TRANSACTIONS.AMOUNT as amount comment='Transaction amount',
        TRANSACTIONS.TXN_COUNT as 1 comment='Count of transactions'
    )
    dimensions (
        TRANSACTIONS.TRANSACTION_DATE as transaction_date comment='Date of transaction',
        TRANSACTIONS.TXN_MONTH as MONTH(transaction_date) comment='Month',
        TRANSACTIONS.TXN_YEAR as YEAR(transaction_date) comment='Year',
        TRANSACTIONS.REGION as region comment='Geographic region',
        PRODUCTS.PRODUCT_NAME as product_name comment='Product name',
        PRODUCTS.PRODUCT_CATEGORY as product_category comment='Product category',
        PRODUCTS.PRICE_POINT as price_point comment='Typical price',
        USERS.USER_SEGMENT as user_segment comment='User segment (Gig Worker, Young Professional, Student)',
        USERS.ACCOUNT_TIER as account_tier comment='Account tier (Free, Basic, Premium, Premium Plus)'
    )
    metrics (
        TRANSACTIONS.TOTAL_TRANSACTIONS as COUNT(transactions.txn_count) comment='Total transactions',
        TRANSACTIONS.TOTAL_REVENUE as SUM(transactions.amount) comment='Total revenue',
        TRANSACTIONS.AVERAGE_AMOUNT as AVG(transactions.amount) comment='Average transaction amount'
    )
    comment='Product usage analytics - feature adoption, revenue, user behavior';

-- ========================================================================
-- SEMANTIC VIEW 2: USER ACQUISITION
-- ========================================================================

CREATE OR REPLACE SEMANTIC VIEW DAVE_AI_DEMO.PRODUCT_ANALYTICS.user_acquisition_view
    tables (
        USERS as users primary key (USER_ID) comment='DAVE app users with LTV and acquisition channel',
        CAMPAIGNS as campaigns primary key (CAMPAIGN_ID) comment='Marketing campaigns with spend and leads'
    )
    facts (
        CAMPAIGNS.SPEND as spend comment='Campaign spend',
        CAMPAIGNS.LEADS_GENERATED as leads_generated comment='Leads generated',
        CAMPAIGNS.IMPRESSIONS as impressions comment='Ad impressions',
        CAMPAIGNS.CAMP_COUNT as 1 comment='Count of campaigns'
    )
    dimensions (
        USERS.USER_SEGMENT as user_segment comment='User segment',
        USERS.ACQUISITION_CHANNEL as acquisition_channel comment='Channel user was acquired from',
        USERS.LIFETIME_VALUE as lifetime_value comment='User lifetime value',
        USERS.ACCOUNT_TIER as account_tier comment='Account tier',
        USERS.SIGNUP_DATE as signup_date comment='User signup date',
        USERS.REGION as region comment='User region',
        CAMPAIGNS.CHANNEL as channel comment='Campaign channel',
        CAMPAIGNS.CAMPAIGN_NAME as campaign_name comment='Campaign name',
        CAMPAIGNS.CAMPAIGN_DATE as campaign_date comment='Campaign date'
    )
    metrics (
        USERS.AVERAGE_LTV as AVG(users.lifetime_value) comment='Average lifetime value',
        CAMPAIGNS.TOTAL_SPEND as SUM(campaigns.spend) comment='Total campaign spend',
        CAMPAIGNS.TOTAL_LEADS as SUM(campaigns.leads_generated) comment='Total leads generated',
        CAMPAIGNS.CAC as SUM(campaigns.spend) / SUM(campaigns.leads_generated) comment='Customer acquisition cost'
    )
    comment='User acquisition analytics - LTV by segment, CAC by channel';

-- Show semantic views
SHOW SEMANTIC VIEWS;

-- ========================================================================
-- DOCUMENT PARSING & SEARCH
-- ========================================================================

CREATE OR REPLACE TABLE parsed_content AS 
SELECT 
    relative_path, 
    BUILD_STAGE_FILE_URL('@DAVE_AI_DEMO.PRODUCT_ANALYTICS.INTERNAL_DATA_STAGE', relative_path) AS file_url,
    SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
        @DAVE_AI_DEMO.PRODUCT_ANALYTICS.INTERNAL_DATA_STAGE,
        relative_path,
        {'mode':'LAYOUT'}
    ):content::string AS content
FROM directory(@DAVE_AI_DEMO.PRODUCT_ANALYTICS.INTERNAL_DATA_STAGE) 
WHERE relative_path ILIKE 'unstructured_docs/%.pdf';

CREATE OR REPLACE CORTEX SEARCH SERVICE Search_docs
    ON content
    ATTRIBUTES relative_path, file_url
    WAREHOUSE = DAVE_INTELLIGENCE_DEMO_WH
    TARGET_LAG = '30 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (SELECT relative_path, file_url, content FROM parsed_content);

-- ========================================================================
-- EXTERNAL ACCESS & FUNCTIONS
-- ========================================================================

CREATE OR REPLACE NETWORK RULE web_access_rule
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('0.0.0.0:80', '0.0.0.0:443');

USE ROLE accountadmin;

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION external_access_integration
    ALLOWED_NETWORK_RULES = (web_access_rule)
    ENABLED = true;

CREATE NOTIFICATION INTEGRATION email_integration
  TYPE=EMAIL
  ENABLED=TRUE;

GRANT USAGE ON INTEGRATION external_access_integration TO ROLE DAVE_Intelligence_Demo;
GRANT USAGE ON INTEGRATION EMAIL_INTEGRATION TO ROLE DAVE_Intelligence_Demo;

USE ROLE DAVE_Intelligence_Demo;

-- Web scraping function
CREATE OR REPLACE FUNCTION web_scrape(url STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = 3.11
HANDLER = 'scrape'
EXTERNAL_ACCESS_INTEGRATIONS = (external_access_integration)
PACKAGES = ('requests', 'beautifulsoup4')
AS $$
import requests
from bs4 import BeautifulSoup
def scrape(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    return soup.get_text()
$$;

-- Email function
CREATE OR REPLACE PROCEDURE send_email(recipient TEXT, subject TEXT, content TEXT)
RETURNS TEXT
LANGUAGE PYTHON
RUNTIME_VERSION = 3.11
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'send'
AS $$
def send(session, recipient, subject, content):
    session.call('SYSTEM$SEND_EMAIL', 'email_integration', recipient, subject, content, 'text/html')
    return f'Email sent to {recipient}'
$$;

-- ========================================================================
-- SNOWFLAKE INTELLIGENCE AGENT
-- ========================================================================

USE ROLE accountadmin;
GRANT USAGE ON DATABASE snowflake_intelligence TO ROLE DAVE_Intelligence_Demo;
GRANT USAGE ON SCHEMA snowflake_intelligence.agents TO ROLE DAVE_Intelligence_Demo;
GRANT CREATE AGENT ON SCHEMA snowflake_intelligence.agents TO ROLE DAVE_Intelligence_Demo;

USE ROLE DAVE_Intelligence_Demo;

CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.DAVE_Product_Analytics_Agent
WITH PROFILE='{"display_name": "DAVE Product Analytics Agent"}'
COMMENT='Product analytics agent for DAVE - answers questions about users, products, transactions, and campaigns'
FROM SPECIFICATION $$
{
  "instructions": {
    "response": "You are a product analytics specialist for DAVE, a fintech company. Answer questions about product usage, user segments, revenue, and acquisition channels using the available data.",
    "sample_questions": [
      {"question": "What are the top 5 most used DAVE features?"},
      {"question": "Which user segments have the highest lifetime value?"},
      {"question": "What's the customer acquisition cost by channel?"}
    ]
  },
  "tools": [
    {"tool_spec": {"type": "cortex_analyst_text_to_sql", "name": "Query_Product_Analytics", "description": "Query product usage, transactions, revenue, and user behavior"}},
    {"tool_spec": {"type": "cortex_analyst_text_to_sql", "name": "Query_User_Acquisition", "description": "Query user segments, LTV, acquisition channels, and CAC"}},
    {"tool_spec": {"type": "cortex_search", "name": "Search_Documents", "description": "Search product documentation and policies"}},
    {"tool_spec": {"type": "generic", "name": "Web_Scraper", "description": "Scrape and analyze external websites", "input_schema": {"type": "object", "properties": {"url": {"type": "string", "description": "Website URL to scrape"}}, "required": ["url"]}}},
    {"tool_spec": {"type": "generic", "name": "Send_Email", "description": "Send email summaries", "input_schema": {"type": "object", "properties": {"recipient": {"type": "string"}, "subject": {"type": "string"}, "content": {"type": "string"}}, "required": ["recipient", "subject", "content"]}}}
  ],
  "tool_resources": {
    "Query_Product_Analytics": {"semantic_view": "DAVE_AI_DEMO.PRODUCT_ANALYTICS.product_analytics_view"},
    "Query_User_Acquisition": {"semantic_view": "DAVE_AI_DEMO.PRODUCT_ANALYTICS.user_acquisition_view"},
    "Search_Documents": {"name": "DAVE_AI_DEMO.PRODUCT_ANALYTICS.SEARCH_DOCS", "max_results": 5},
    "Web_Scraper": {"identifier": "DAVE_AI_DEMO.PRODUCT_ANALYTICS.WEB_SCRAPE", "type": "function", "execution_environment": {"type": "warehouse", "warehouse": "DAVE_INTELLIGENCE_DEMO_WH"}},
    "Send_Email": {"identifier": "DAVE_AI_DEMO.PRODUCT_ANALYTICS.SEND_EMAIL", "type": "procedure", "execution_environment": {"type": "warehouse", "warehouse": "DAVE_INTELLIGENCE_DEMO_WH"}}
  }
}
$$;

-- ========================================================================
-- VERIFICATION
-- ========================================================================

SHOW TABLES;
SHOW SEMANTIC VIEWS;
SHOW AGENTS IN SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS;

SELECT 'Setup Complete!' as status, 
       'Tables: 4' as tables_created,
       'Semantic Views: 2' as views_created,
       'Total Rows: ~1,300' as data_volume,
       'Agent: DAVE_Product_Analytics_Agent' as agent_created;