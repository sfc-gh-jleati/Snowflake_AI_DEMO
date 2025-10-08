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

COPY FILES INTO @INTERNAL_DATA_STAGE/demo_data/
FROM @DAVE_AI_DEMO_REPO/branches/main/demo_data/;

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

-- 5. EVENTS - App/Web clickstream events
CREATE OR REPLACE TABLE events (
    event_id INT PRIMARY KEY,
    event_timestamp TIMESTAMP NOT NULL,
    user_id INT NOT NULL,
    event_name VARCHAR(100) NOT NULL,           -- app_open, screen_view, button_click, etc.
    event_type VARCHAR(50) NOT NULL,            -- session_start, navigation, interaction, conversion
    platform VARCHAR(20) NOT NULL,              -- iOS, Android, Web
    device_type VARCHAR(20) NOT NULL,           -- mobile, desktop, tablet
    screen_name VARCHAR(100),                   -- home, extracash_tab, banking_tab, etc.
    session_id VARCHAR(50) NOT NULL
) COMMENT = 'App and web clickstream events - user behavior, navigation, interactions';

    -- ========================================================================
-- LOAD DATA FROM GIT
    -- ========================================================================

COPY INTO users FROM @INTERNAL_DATA_STAGE/demo_data/users.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO products FROM @INTERNAL_DATA_STAGE/demo_data/products.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO transactions FROM @INTERNAL_DATA_STAGE/demo_data/transactions.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO campaigns FROM @INTERNAL_DATA_STAGE/demo_data/campaigns.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO events FROM @INTERNAL_DATA_STAGE/demo_data/events.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';

-- Verify
SELECT 'users' as table_name, COUNT(*) FROM users
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL SELECT 'campaigns', COUNT(*) FROM campaigns
UNION ALL SELECT 'events', COUNT(*) FROM events;

    -- ========================================================================
-- SEMANTIC VIEW 1: PRODUCT ANALYTICS
    -- ========================================================================

CREATE OR REPLACE SEMANTIC VIEW DAVE_AI_DEMO.PRODUCT_ANALYTICS.product_analytics_view
    tables (
        USERS as users primary key (USER_ID) with synonyms=('app users','members') comment='DAVE app users',
        PRODUCTS as products primary key (PRODUCT_ID) with synonyms=('features','offerings','services') comment='DAVE products and features - ExtraCash, Banking, Budgeting, etc.',
        TRANSACTIONS as transactions primary key (TRANSACTION_ID) with synonyms=('usage events','product usage') comment='Product usage transactions - when users engage with features'
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
        TRANSACTIONS.TRANSACTION_DATE as transaction_date with synonyms=('date','usage date') comment='Date of transaction',
        TRANSACTIONS.TXN_MONTH as MONTH(transaction_date) comment='Month',
        TRANSACTIONS.TXN_YEAR as YEAR(transaction_date) comment='Year',
        TRANSACTIONS.REGION as region comment='Geographic region',
        PRODUCTS.PRODUCT_NAME as product_name with synonyms=('feature','feature name','product','offering') comment='Product/feature name (ExtraCash Advance $75, Dave Banking Account, etc.)',
        PRODUCTS.PRODUCT_CATEGORY as product_category with synonyms=('category','feature type','product type') comment='Product category (Cash Advance, Banking, Budgeting, Tip, Subscription)',
        PRODUCTS.PRICE_POINT as price_point comment='Typical price',
        USERS.USER_SEGMENT as user_segment with synonyms=('segment','user type') comment='User segment (Gig Worker, Young Professional, Student)',
        USERS.ACCOUNT_TIER as account_tier with synonyms=('tier','subscription level') comment='Account tier (Free, Basic, Premium, Premium Plus)'
    )
    metrics (
        TRANSACTIONS.TOTAL_TRANSACTIONS as COUNT(transactions.txn_count) comment='Total transactions',
        TRANSACTIONS.TOTAL_REVENUE as SUM(transactions.amount) comment='Total revenue',
        TRANSACTIONS.AVERAGE_AMOUNT as AVG(transactions.amount) comment='Average transaction amount'
    )
    comment='Product usage analytics - feature adoption, revenue, user behavior'
    with extension (CA='{"tables":[{"name":"PRODUCTS","dimensions":[{"name":"PRODUCT_NAME","sample_values":["ExtraCash Advance $75","ExtraCash Advance $100","ExtraCash Advance $50"]},{"name":"PRODUCT_CATEGORY","sample_values":["Cash Advance","Banking","Budgeting","Tip"]},{"name":"PRICE_POINT"}]},{"name":"TRANSACTIONS","dimensions":[{"name":"TRANSACTION_DATE"},{"name":"TXN_MONTH"},{"name":"TXN_YEAR"},{"name":"REGION","sample_values":["South","West","East","North"]}],"facts":[{"name":"AMOUNT"},{"name":"TXN_COUNT"}],"metrics":[{"name":"TOTAL_TRANSACTIONS"},{"name":"TOTAL_REVENUE"},{"name":"AVERAGE_AMOUNT"}]},{"name":"USERS","dimensions":[{"name":"USER_SEGMENT","sample_values":["Gig Worker","Young Professional","Student"]},{"name":"ACCOUNT_TIER","sample_values":["Free","Basic","Premium","Premium Plus"]}]}],"relationships":[{"name":"TXN_TO_USERS","relationship_type":"many_to_one"},{"name":"TXN_TO_PRODUCTS","relationship_type":"many_to_one"}]}');

  -- ========================================================================
-- SEMANTIC VIEW 2: USER ACQUISITION
  -- ========================================================================

CREATE OR REPLACE SEMANTIC VIEW DAVE_AI_DEMO.PRODUCT_ANALYTICS.user_acquisition_view
	tables (
        USERS as users primary key (USER_ID) comment='DAVE app users with LTV and acquisition channel. Query this table for LTV by user_segment.',
        CAMPAIGNS as campaigns primary key (CAMPAIGN_ID) comment='Marketing campaigns with spend and leads. Query this table for CAC by channel. Note: USERS and CAMPAIGNS are independent tables - query them separately for LTV and CAC questions.'
	)
	facts (
        CAMPAIGNS.SPEND as spend comment='Campaign spend',
        CAMPAIGNS.LEADS_GENERATED as leads_generated comment='Leads generated',
        CAMPAIGNS.IMPRESSIONS as impressions comment='Ad impressions',
        CAMPAIGNS.CAMP_COUNT as 1 comment='Count of campaigns'
	)
	dimensions (
        USERS.USER_SEGMENT as user_segment with synonyms=('segment','user type') comment='User segment (Gig Worker, Young Professional, Student)',
        USERS.ACQUISITION_CHANNEL as acquisition_channel with synonyms=('channel','signup channel') comment='Channel user was acquired from (Instagram Ads, Referral Program, TikTok Ads, etc.)',
        USERS.LIFETIME_VALUE as lifetime_value with synonyms=('LTV','user value') comment='User lifetime value in dollars',
        USERS.ACCOUNT_TIER as account_tier comment='Account tier (Free, Basic, Premium, Premium Plus)',
        USERS.SIGNUP_DATE as signup_date comment='User signup date',
        USERS.REGION as region comment='User region (South, West, East, North)',
        CAMPAIGNS.CHANNEL as channel with synonyms=('campaign channel','marketing channel') comment='Campaign channel (Instagram Ads, Referral Program, etc.)',
        CAMPAIGNS.CAMPAIGN_NAME as campaign_name comment='Campaign name',
        CAMPAIGNS.CAMPAIGN_DATE as campaign_date comment='Campaign date'
	)
	metrics (
        USERS.AVERAGE_LTV as AVG(users.lifetime_value) comment='Average lifetime value',
        CAMPAIGNS.TOTAL_SPEND as SUM(campaigns.spend) comment='Total campaign spend',
        CAMPAIGNS.TOTAL_LEADS as SUM(campaigns.leads_generated) comment='Total leads generated',
        CAMPAIGNS.CAC as SUM(campaigns.spend) / SUM(campaigns.leads_generated) comment='Customer acquisition cost (cost per user acquired)'
    )
    comment='User acquisition analytics - LTV by segment, CAC by channel'
    with extension (CA='{"tables":[{"name":"USERS","dimensions":[{"name":"USER_SEGMENT","sample_values":["Gig Worker","Young Professional","Student"]},{"name":"ACQUISITION_CHANNEL","sample_values":["Instagram Ads","Referral Program","TikTok Ads"]},{"name":"LIFETIME_VALUE"},{"name":"ACCOUNT_TIER","sample_values":["Free","Basic","Premium","Premium Plus"]},{"name":"SIGNUP_DATE"},{"name":"REGION","sample_values":["South","West","East","North"]}],"facts":[{"name":"LIFETIME_VALUE"}],"metrics":[{"name":"AVERAGE_LTV"}]},{"name":"CAMPAIGNS","dimensions":[{"name":"CHANNEL","sample_values":["Instagram Ads","Referral Program","TikTok Ads","Paid Search (Google)","Organic Search"]},{"name":"CAMPAIGN_NAME"},{"name":"CAMPAIGN_DATE"}],"facts":[{"name":"SPEND"},{"name":"LEADS_GENERATED"},{"name":"IMPRESSIONS"},{"name":"CAMP_COUNT"}],"metrics":[{"name":"TOTAL_SPEND"},{"name":"TOTAL_LEADS"},{"name":"CAC"}]}],"custom_instructions":"For questions about LTV by user segment: Query USERS table only, GROUP BY user_segment. For questions about CAC by channel: Query CAMPAIGNS table only, GROUP BY channel. These are separate tables with no join relationship - query them independently."}');

-- ========================================================================
-- SEMANTIC VIEW 3: APP & WEB EVENTS
  -- ========================================================================

CREATE OR REPLACE SEMANTIC VIEW DAVE_AI_DEMO.PRODUCT_ANALYTICS.event_analytics_view
    tables (
        USERS as users primary key (USER_ID) with synonyms=('app users') comment='DAVE app users',
        EVENTS as events primary key (EVENT_ID) with synonyms=('clickstream','app events','web events','user events') comment='App and web clickstream events - every user interaction, screen view, button click'
    )
    relationships (
        EVENTS_TO_USERS as EVENTS(USER_ID) references USERS(USER_ID)
    )
    facts (
        EVENTS.EVENT_COUNT as 1 comment='Count of events - use this for event volume, activity, usage metrics'
    )
    dimensions (
        EVENTS.EVENT_TIMESTAMP as event_timestamp with synonyms=('timestamp','event time') comment='Event timestamp',
        EVENTS.EVENT_DATE as DATE(event_timestamp) comment='Event date',
        EVENTS.EVENT_HOUR as HOUR(event_timestamp) comment='Hour of day',
        EVENTS.EVENT_NAME as event_name with synonyms=('event','action') comment='Event name (app_open, screen_view, button_click, etc.)',
        EVENTS.EVENT_TYPE as event_type comment='Event type (session_start, navigation, interaction, conversion)',
        EVENTS.PLATFORM as platform with synonyms=('os','operating system') comment='Platform - iOS, Android, or Web',
        EVENTS.DEVICE_TYPE as device_type with synonyms=('device') comment='Device type - mobile, desktop, or tablet',
        EVENTS.SCREEN_NAME as screen_name with synonyms=('screen','page') comment='Screen or page name (home, extracash_tab, banking_tab, etc.)',
        EVENTS.SESSION_ID as session_id comment='Session identifier',
        USERS.USER_SEGMENT as user_segment comment='User segment'
    )
    metrics (
        EVENTS.TOTAL_EVENTS as COUNT(events.event_count) comment='Total events - use this for platform usage, screen views, overall activity',
        EVENTS.UNIQUE_USERS as COUNT(DISTINCT events.user_id) comment='Unique users - use only when specifically asked for user counts',
        EVENTS.UNIQUE_SESSIONS as COUNT(DISTINCT events.session_id) comment='Unique sessions'
    )
    comment='App and web event analytics - user behavior, platform usage, engagement patterns'
    with extension (CA='{"tables":[{"name":"EVENTS","dimensions":[{"name":"PLATFORM","sample_values":["iOS","Android","Web"]},{"name":"DEVICE_TYPE","sample_values":["mobile","desktop","tablet"]},{"name":"EVENT_NAME","sample_values":["app_open","screen_view","button_click","transaction_complete"]},{"name":"EVENT_TYPE","sample_values":["session_start","navigation","interaction","conversion"]},{"name":"SCREEN_NAME","sample_values":["home","extracash_tab","banking_tab","budgeting_tab","request_advance"]}],"facts":[{"name":"EVENT_COUNT"}],"metrics":[{"name":"TOTAL_EVENTS"},{"name":"UNIQUE_USERS"},{"name":"UNIQUE_SESSIONS"}]},{"name":"USERS","dimensions":[{"name":"USER_SEGMENT","sample_values":["Gig Worker","Young Professional","Student"]}]}],"relationships":[{"name":"EVENTS_TO_USERS","relationship_type":"many_to_one"}],"custom_instructions":"For platform/device usage questions: Use COUNT(events.event_count) to show total event volume by platform. For questions about users: Use COUNT(DISTINCT user_id) only when explicitly asking for user counts. Default to event counts for usage/activity questions."}');

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
HANDLER = 'send_email_handler'
AS $$
def send_email_handler(session, recipient, subject, content):
    session.call(
        'SYSTEM$SEND_EMAIL',
        'email_integration',
        recipient,
        subject,
        content,
        'text/html'
    )
    return f'Email sent to {recipient} with subject: {subject}'
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
    "response": "You are a product analytics specialist for DAVE, a fintech company. Answer questions about product usage, user segments, revenue, acquisition channels, and app/web behavior using the available data.",
    "sample_questions": [
      {"question": "What are the top 5 most used DAVE features?"},
      {"question": "Which user segments have the highest lifetime value?"},
      {"question": "What platforms do users access DAVE on?"},
      {"question": "Show me app usage by device type"}
    ]
  },
  "tools": [
    {"tool_spec": {"type": "cortex_analyst_text_to_sql", "name": "Query_Product_Analytics", "description": "Query product usage, transactions, revenue, and user behavior"}},
    {"tool_spec": {"type": "cortex_analyst_text_to_sql", "name": "Query_User_Acquisition", "description": "Query user segments, LTV, acquisition channels, and CAC"}},
    {"tool_spec": {"type": "cortex_analyst_text_to_sql", "name": "Query_App_Events", "description": "Query app and web clickstream events - user behavior across iOS, Android, and Web platforms, device types, screen navigation, and engagement patterns"}},
    {"tool_spec": {"type": "cortex_search", "name": "Search_Documents", "description": "Search product documentation and policies"}},
    {"tool_spec": {"type": "generic", "name": "Web_Scraper", "description": "Scrape and analyze external websites", "input_schema": {"type": "object", "properties": {"url": {"type": "string", "description": "Website URL to scrape"}}, "required": ["url"]}}},
    {"tool_spec": {"type": "generic", "name": "Send_Email", "description": "Send HTML-formatted email summaries. IMPORTANT: Format the content parameter as HTML using tags like <h2>, <p>, <ul>, <li>, <strong>, <br>. Create a professional executive summary with headers, bullet points, and emphasis. Example: '<h2>DAVE Analytics Summary</h2><p>Key insights from our conversation:</p><ul><li><strong>Top Product:</strong> ExtraCash $75 (20% of transactions)</li></ul>'", "input_schema": {"type": "object", "properties": {"recipient": {"type": "string", "description": "Email address"}, "subject": {"type": "string", "description": "Email subject line"}, "content": {"type": "string", "description": "HTML-formatted email content with <h2>, <p>, <ul>, <li>, <strong> tags"}}, "required": ["recipient", "subject", "content"]}}}
  ],
  "tool_resources": {
    "Query_Product_Analytics": {"semantic_view": "DAVE_AI_DEMO.PRODUCT_ANALYTICS.product_analytics_view"},
    "Query_User_Acquisition": {"semantic_view": "DAVE_AI_DEMO.PRODUCT_ANALYTICS.user_acquisition_view"},
    "Query_App_Events": {"semantic_view": "DAVE_AI_DEMO.PRODUCT_ANALYTICS.event_analytics_view"},
    "Search_Documents": {"name": "DAVE_AI_DEMO.PRODUCT_ANALYTICS.SEARCH_DOCS", "max_results": 5},
    "Web_Scraper": {"identifier": "DAVE_AI_DEMO.PRODUCT_ANALYTICS.WEB_SCRAPE", "type": "function", "execution_environment": {"type": "warehouse", "warehouse": "DAVE_INTELLIGENCE_DEMO_WH"}},
    "Send_Email": {"identifier": "DAVE_AI_DEMO.PRODUCT_ANALYTICS.SEND_EMAIL", "name": "SEND_EMAIL(VARCHAR, VARCHAR, VARCHAR)", "type": "procedure", "execution_environment": {"type": "warehouse", "warehouse": "DAVE_INTELLIGENCE_DEMO_WH"}}
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
       'Tables: 5' as tables_created,
       'Semantic Views: 3' as views_created,
       'Total Rows: ~1,500' as data_volume,
       'Agent: DAVE_Product_Analytics_Agent' as agent_created;