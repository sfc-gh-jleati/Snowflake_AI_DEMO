


    -- ========================================================================
    -- DAVE Product Analytics Demo - Complete Setup Script
    -- Snowflake Intelligence Demo for DAVE Operating Co Product Team
    -- Focus: Customer app usage, product adoption, and engagement analytics
    -- Repository: https://github.com/sfc-gh-jleati/Snowflake_AI_DEMO.git
    -- ========================================================================
    
    /*
    =============================================================================
    ABOUT THIS DEMO
    =============================================================================
    
    This demo is customized for DAVE Operating Co's Product Team to showcase
    how Snowflake Intelligence can provide actionable insights about:
    
    1. PRODUCT USAGE ANALYTICS
       - Track how customers use DAVE app features (ExtraCash, Banking, Budgeting, Credit Builder)
       - Monitor feature adoption rates and usage patterns
       - Identify most/least used features
       - Analyze user engagement trends over time
       
    2. TRANSACTION ANALYTICS
       - Track ExtraCash advances, subscription fees, tips, and other revenue
       - Analyze transaction volumes and patterns
       - Monitor average revenue per user (ARPU)
       - Identify revenue trends by product and user segment
       
    3. USER ACQUISITION & RETENTION
       - Track marketing campaign performance
       - Analyze user acquisition channels (social, paid ads, referrals, organic)
       - Monitor user activation and onboarding completion
       - Calculate customer acquisition cost (CAC) and lifetime value (LTV)
       - Identify churn patterns and retention opportunities
       
    4. TEAM PERFORMANCE
       - Monitor team composition and staffing levels
       - Track customer success team performance
       - Analyze organizational metrics
    
    DATA MODEL CONTEXT FOR DAVE:
    - "Customers" = DAVE app users/members
    - "Products" = DAVE features/services (ExtraCash, Banking, Budgeting, Credit Builder)
    - "Sales" = Product usage transactions (when users engage with features)
    - "Marketing Campaigns" = User acquisition and retention initiatives
    - "Opportunities" = User activations (signup to active user conversion)
    - "Finance Transactions" = ExtraCash advances, fees, tips, subscriptions
    
    SAMPLE QUESTIONS YOU CAN ASK:
    - "What are the top 5 most used features by active users?"
    - "Show me user engagement trends over the last 6 months"
    - "What is our average revenue per user (ARPU) by product?"
    - "Which customer segments have the highest churn rate?"
    - "How is ExtraCash product adoption trending?"
    - "What's our user acquisition cost by channel?"
    - "Which campaigns have the best conversion rates?"
    
    =============================================================================
    */

    

    -- Switch to accountadmin role to create warehouse
    USE ROLE accountadmin;

    -- Enable Snowflake Intelligence by creating the Config DB & Schema
    -- CREATE DATABASE IF NOT EXISTS snowflake_intelligence;
    -- CREATE SCHEMA IF NOT EXISTS snowflake_intelligence.agents;
    
    -- Allow anyone to see the agents in this schema
    GRANT USAGE ON DATABASE snowflake_intelligence TO ROLE PUBLIC;
    GRANT USAGE ON SCHEMA snowflake_intelligence.agents TO ROLE PUBLIC;


CREATE OR REPLACE ROLE DAVE_Intelligence_Demo;


SET current_user_name = CURRENT_USER();
    
    -- Step 2: Use the variable to grant the role
    GRANT ROLE DAVE_Intelligence_Demo TO USER IDENTIFIER($current_user_name);
    GRANT CREATE DATABASE ON ACCOUNT TO ROLE DAVE_Intelligence_Demo;
    
    -- Create a dedicated warehouse for the DAVE demo with auto-suspend/resume
    CREATE OR REPLACE WAREHOUSE DAVE_Intelligence_demo_wh 
        WITH WAREHOUSE_SIZE = 'XSMALL'
        AUTO_SUSPEND = 300
        AUTO_RESUME = TRUE;


    -- Grant usage on warehouse to DAVE demo role
    GRANT USAGE ON WAREHOUSE DAVE_INTELLIGENCE_DEMO_WH TO ROLE DAVE_Intelligence_Demo;


   -- Alter current user's default role and warehouse to the ones used here
    ALTER USER IDENTIFIER($current_user_name) SET DEFAULT_ROLE = DAVE_Intelligence_Demo;
    ALTER USER IDENTIFIER($current_user_name) SET DEFAULT_WAREHOUSE = DAVE_Intelligence_demo_wh;
    

    -- Switch to DAVE_Intelligence_Demo role to create demo objects
    use role DAVE_Intelligence_Demo;
   
    -- Create database and schema for DAVE demo
    CREATE OR REPLACE DATABASE DAVE_AI_DEMO;
    USE DATABASE DAVE_AI_DEMO;

    CREATE SCHEMA IF NOT EXISTS DAVE_PRODUCT_ANALYTICS;
    USE SCHEMA DAVE_PRODUCT_ANALYTICS;

    -- Create file format for CSV files
    CREATE OR REPLACE FILE FORMAT CSV_FORMAT
        TYPE = 'CSV'
        FIELD_DELIMITER = ','
        RECORD_DELIMITER = '\n'
        SKIP_HEADER = 1
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        TRIM_SPACE = TRUE
        ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
        ESCAPE = 'NONE'
        ESCAPE_UNENCLOSED_FIELD = '\134'
        DATE_FORMAT = 'YYYY-MM-DD'
        TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS'
        NULL_IF = ('NULL', 'null', '', 'N/A', 'n/a');


USE ROLE accountadmin;
    -- Create API Integration for GitHub (public repository access)
    CREATE OR REPLACE API INTEGRATION git_api_integration
        API_PROVIDER = git_https_api
        API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-jleati/')
        ENABLED = TRUE;


GRANT USAGE ON INTEGRATION GIT_API_INTEGRATION TO ROLE DAVE_Intelligence_Demo;


USE ROLE DAVE_Intelligence_Demo;
    -- Create Git repository integration for the public demo repository
    CREATE OR REPLACE GIT REPOSITORY DAVE_AI_DEMO_REPO
        API_INTEGRATION = git_api_integration
        ORIGIN = 'https://github.com/sfc-gh-jleati/Snowflake_AI_DEMO.git';

    -- Create internal stage for copied data files
    CREATE OR REPLACE STAGE INTERNAL_DATA_STAGE
        FILE_FORMAT = CSV_FORMAT
        COMMENT = 'Internal stage for copied demo data files'
        DIRECTORY = ( ENABLE = TRUE)
        ENCRYPTION = (   TYPE = 'SNOWFLAKE_SSE');

    ALTER GIT REPOSITORY DAVE_AI_DEMO_REPO FETCH;

    -- ========================================================================
    -- COPY DATA FROM GIT TO INTERNAL STAGE
    -- ========================================================================

    -- Copy all CSV files from Git repository demo_data folder to internal stage
    COPY FILES
    INTO @INTERNAL_DATA_STAGE/demo_data/
    FROM @DAVE_AI_DEMO_REPO/branches/main/demo_data/;


    COPY FILES
    INTO @INTERNAL_DATA_STAGE/unstructured_docs/
    FROM @DAVE_AI_DEMO_REPO/branches/main/unstructured_docs/;

    -- Verify files were copied
    LS @INTERNAL_DATA_STAGE;

    ALTER STAGE INTERNAL_DATA_STAGE refresh;

  

    -- ========================================================================
    -- DIMENSION TABLES
    -- ========================================================================

    -- Product Category Dimension
    CREATE OR REPLACE TABLE product_category_dim (
        category_key INT PRIMARY KEY,
        category_name VARCHAR(100) NOT NULL,
        vertical VARCHAR(50) NOT NULL
    );

    -- Product Dimension
    CREATE OR REPLACE TABLE product_dim (
        product_key INT PRIMARY KEY,
        product_name VARCHAR(200) NOT NULL,
        category_key INT NOT NULL,
        category_name VARCHAR(100),
        vertical VARCHAR(50)
    );

    -- Partner/Service Provider Dimension (B2C context - payment processors, service providers)
    CREATE OR REPLACE TABLE vendor_dim (
        vendor_key INT PRIMARY KEY,
        vendor_name VARCHAR(200) NOT NULL,
        vertical VARCHAR(50) NOT NULL,  -- Partner type (Payment Processing, Banking Infrastructure, etc.)
        address VARCHAR(200),
        city VARCHAR(100),
        state VARCHAR(10),
        zip VARCHAR(20)
    ) COMMENT = 'Service partners and payment processors (Stripe, Plaid, Dwolla, etc.) - used for operational tracking, not customer-facing';

    -- App User Dimension (B2C - individual DAVE app users)
    CREATE OR REPLACE TABLE customer_dim (
        customer_key INT PRIMARY KEY,
        customer_name VARCHAR(200) NOT NULL,  -- User ID
        industry VARCHAR(100),  -- User segment (Young Professional, Gig Worker, etc.)
        vertical VARCHAR(50),  -- User vertical category
        address VARCHAR(200),
        city VARCHAR(100),
        state VARCHAR(10),
        zip VARCHAR(20)
    ) COMMENT = 'DAVE app users - individual consumers who use the app (not businesses)';

    -- Account Dimension (Finance)
    CREATE OR REPLACE TABLE account_dim (
        account_key INT PRIMARY KEY,
        account_name VARCHAR(100) NOT NULL,
        account_type VARCHAR(50)
    );

    -- Department Dimension
    CREATE OR REPLACE TABLE department_dim (
        department_key INT PRIMARY KEY,
        department_name VARCHAR(100) NOT NULL
    );

    -- Region Dimension
    CREATE OR REPLACE TABLE region_dim (
        region_key INT PRIMARY KEY,
        region_name VARCHAR(100) NOT NULL
    );

    -- Campaign Dimension (Marketing)
    CREATE OR REPLACE TABLE campaign_dim (
        campaign_key INT PRIMARY KEY,
        campaign_name VARCHAR(300) NOT NULL,
        objective VARCHAR(100)
    );

    -- Channel Dimension (Marketing)
    CREATE OR REPLACE TABLE channel_dim (
        channel_key INT PRIMARY KEY,
        channel_name VARCHAR(100) NOT NULL
    );

    -- Employee Dimension (HR)
    CREATE OR REPLACE TABLE employee_dim (
        employee_key INT PRIMARY KEY,
        employee_name VARCHAR(200) NOT NULL,
        gender VARCHAR(1),
        hire_date DATE
    );

    -- Job Dimension (HR)
    CREATE OR REPLACE TABLE job_dim (
        job_key INT PRIMARY KEY,
        job_title VARCHAR(100) NOT NULL,
        job_level INT
    );

    -- Location Dimension (HR)
    CREATE OR REPLACE TABLE location_dim (
        location_key INT PRIMARY KEY,
        location_name VARCHAR(200) NOT NULL
    );

    -- ========================================================================
    -- FACT TABLES
    -- ========================================================================

    -- Product Usage Fact Table (B2C - no sales reps or vendors)
    CREATE OR REPLACE TABLE sales_fact (
        sale_id INT PRIMARY KEY,
        date DATE NOT NULL,
        customer_key INT NOT NULL,
        product_key INT NOT NULL,
        region_key INT NOT NULL,
        amount DECIMAL(10,2) NOT NULL,
        units INT NOT NULL
    );

    -- Finance Transactions Fact Table
    CREATE OR REPLACE TABLE finance_transactions (
        transaction_id INT PRIMARY KEY,
        date DATE NOT NULL,
        account_key INT NOT NULL,
        department_key INT NOT NULL,
        vendor_key INT NOT NULL,
        product_key INT NOT NULL,
        customer_key INT NOT NULL,
        amount DECIMAL(12,2) NOT NULL
    );

    -- Marketing Campaign Fact Table
    CREATE OR REPLACE TABLE marketing_campaign_fact (
        campaign_fact_id INT PRIMARY KEY,
        date DATE NOT NULL,
        campaign_key INT NOT NULL,
        product_key INT NOT NULL,
        channel_key INT NOT NULL,
        region_key INT NOT NULL,
        spend DECIMAL(10,2) NOT NULL,
        leads_generated INT NOT NULL,
        impressions INT NOT NULL
    );

    -- HR Employee Fact Table
    CREATE OR REPLACE TABLE hr_employee_fact (
        hr_fact_id INT PRIMARY KEY,
        date DATE NOT NULL,
        employee_key INT NOT NULL,
        department_key INT NOT NULL,
        job_key INT NOT NULL,
        location_key INT NOT NULL,
        salary DECIMAL(10,2) NOT NULL,
        attrition_flag INT NOT NULL
    );

    -- ========================================================================
    -- USER JOURNEY TABLES (B2C)
    -- Tracks user signups, activations, and account management
    -- Note: Field names follow CRM convention but data represents B2C user journey
    -- ========================================================================

    -- User Accounts Table (B2C - individual app users with acquisition attribution)
    CREATE OR REPLACE TABLE sf_accounts (
        account_id VARCHAR(20) PRIMARY KEY,
        account_name VARCHAR(200) NOT NULL,
        customer_key INT NOT NULL,
        industry VARCHAR(100),  -- User segment
        vertical VARCHAR(50),  -- User vertical
        acquisition_channel VARCHAR(100),  -- Channel user was acquired from (Instagram, Referral, TikTok, etc.)
        billing_street VARCHAR(200),
        billing_city VARCHAR(100),
        billing_state VARCHAR(10),
        billing_postal_code VARCHAR(20),
        account_type VARCHAR(50),  -- Free, Basic, Premium, Premium Plus
        annual_revenue DECIMAL(15,2),  -- Lifetime value (LTV)
        employees INT,  -- Household size
        created_date DATE  -- Account creation date
    ) COMMENT = 'User account records - tracks DAVE app user profiles, account tiers, and acquisition channel for CAC attribution';

    -- User Activation Opportunities Table (B2C - signup to active user journey)
    CREATE OR REPLACE TABLE sf_opportunities (
        opportunity_id VARCHAR(20) PRIMARY KEY,
        sale_id INT,  -- Links to first transaction if activated
        account_id VARCHAR(20) NOT NULL,
        opportunity_name VARCHAR(200) NOT NULL,
        stage_name VARCHAR(100) NOT NULL,  -- Lead, Signup, Verification, Activated, Closed Won
        amount DECIMAL(15,2) NOT NULL,  -- Predicted LTV
        probability DECIMAL(5,2),  -- Activation probability
        close_date DATE,  -- Activation completion date
        created_date DATE,  -- Signup date
        lead_source VARCHAR(100),  -- Acquisition channel
        type VARCHAR(100),  -- New User, Returning User, Premium Upgrade
        campaign_id INT  -- Attribution to campaign
    ) COMMENT = 'User activation tracking - monitors journey from signup to active user';

    -- User Signups/Leads Table (B2C - individual user signups)
    CREATE OR REPLACE TABLE sf_contacts (
        contact_id VARCHAR(20) PRIMARY KEY,
        opportunity_id VARCHAR(20) NOT NULL,
        account_id VARCHAR(20) NOT NULL,
        first_name VARCHAR(100),
        last_name VARCHAR(100),
        email VARCHAR(200),
        phone VARCHAR(50),
        title VARCHAR(100),  -- User status (Active, New Signup, Premium, Trial)
        department VARCHAR(100),  -- Interest area (Personal Finance, Savings, etc.)
        lead_source VARCHAR(100),  -- How they heard about DAVE
        campaign_no INT,  -- Attribution to campaign
        created_date DATE  -- Signup date
    ) COMMENT = 'User signup records - tracks leads and signups from acquisition campaigns';

    -- ========================================================================
    -- LOAD DIMENSION DATA FROM INTERNAL STAGE
    -- ========================================================================

    -- Load Product Category Dimension
    COPY INTO product_category_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/product_category_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Product Dimension
    COPY INTO product_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/product_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Vendor Dimension
    COPY INTO vendor_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/vendor_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Customer Dimension
    COPY INTO customer_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/customer_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Account Dimension
    COPY INTO account_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/account_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Department Dimension
    COPY INTO department_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/department_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Region Dimension
    COPY INTO region_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/region_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Campaign Dimension
    COPY INTO campaign_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/campaign_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Channel Dimension
    COPY INTO channel_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/channel_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Employee Dimension
    COPY INTO employee_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/employee_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Job Dimension
    COPY INTO job_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/job_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Location Dimension
    COPY INTO location_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/location_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- ========================================================================
    -- LOAD FACT DATA FROM INTERNAL STAGE
    -- ========================================================================

    -- Load Sales Fact
    COPY INTO sales_fact
    FROM @INTERNAL_DATA_STAGE/demo_data/sales_fact.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Finance Transactions
    COPY INTO finance_transactions
    FROM @INTERNAL_DATA_STAGE/demo_data/finance_transactions.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Marketing Campaign Fact
    COPY INTO marketing_campaign_fact
    FROM @INTERNAL_DATA_STAGE/demo_data/marketing_campaign_fact.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load HR Employee Fact
    COPY INTO hr_employee_fact
    FROM @INTERNAL_DATA_STAGE/demo_data/hr_employee_fact.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- ========================================================================
    -- LOAD USER JOURNEY DATA FROM INTERNAL STAGE
    -- ========================================================================

    -- Load User Accounts
    COPY INTO sf_accounts
    FROM @INTERNAL_DATA_STAGE/demo_data/sf_accounts.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load User Activations
    COPY INTO sf_opportunities
    FROM @INTERNAL_DATA_STAGE/demo_data/sf_opportunities.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load User Signups
    COPY INTO sf_contacts
    FROM @INTERNAL_DATA_STAGE/demo_data/sf_contacts.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- ========================================================================
    -- VERIFICATION
    -- ========================================================================

    -- Verify Git integration and file copy
    SHOW GIT REPOSITORIES;
   -- SELECT 'Internal Stage Files' as stage_type, COUNT(*) as file_count FROM (LS @INTERNAL_DATA_STAGE);

    -- Verify data loads
    SELECT 'DIMENSION TABLES' as category, '' as table_name, NULL as row_count
    UNION ALL
    SELECT '', 'product_category_dim', COUNT(*) FROM product_category_dim
    UNION ALL
    SELECT '', 'product_dim', COUNT(*) FROM product_dim
    UNION ALL
    SELECT '', 'vendor_dim', COUNT(*) FROM vendor_dim
    UNION ALL
    SELECT '', 'customer_dim', COUNT(*) FROM customer_dim
    UNION ALL
    SELECT '', 'account_dim', COUNT(*) FROM account_dim
    UNION ALL
    SELECT '', 'department_dim', COUNT(*) FROM department_dim
    UNION ALL
    SELECT '', 'region_dim', COUNT(*) FROM region_dim
    UNION ALL
    SELECT '', 'campaign_dim', COUNT(*) FROM campaign_dim
    UNION ALL
    SELECT '', 'channel_dim', COUNT(*) FROM channel_dim
    UNION ALL
    SELECT '', 'employee_dim', COUNT(*) FROM employee_dim
    UNION ALL
    SELECT '', 'job_dim', COUNT(*) FROM job_dim
    UNION ALL
    SELECT '', 'location_dim', COUNT(*) FROM location_dim
    UNION ALL
    SELECT '', '', NULL
    UNION ALL
    SELECT 'FACT TABLES', '', NULL
    UNION ALL
    SELECT '', 'sales_fact', COUNT(*) FROM sales_fact
    UNION ALL
    SELECT '', 'finance_transactions', COUNT(*) FROM finance_transactions
    UNION ALL
    SELECT '', 'marketing_campaign_fact', COUNT(*) FROM marketing_campaign_fact
    UNION ALL
    SELECT '', 'hr_employee_fact', COUNT(*) FROM hr_employee_fact
    UNION ALL
    SELECT '', '', NULL
    UNION ALL
    SELECT 'USER JOURNEY TABLES', '', NULL
    UNION ALL
    SELECT '', 'sf_accounts (User Accounts)', COUNT(*) FROM sf_accounts
    UNION ALL
    SELECT '', 'sf_opportunities (Activations)', COUNT(*) FROM sf_opportunities
    UNION ALL
    SELECT '', 'sf_contacts (Signups)', COUNT(*) FROM sf_contacts;

    -- Show all tables
    SHOW TABLES IN SCHEMA DAVE_PRODUCT_ANALYTICS; 




  -- ========================================================================
  -- DAVE Product Analytics - Semantic Views for Cortex Analyst
  -- Creates product analytics semantic views for natural language queries
  -- Based on: https://docs.snowflake.com/en/user-guide/views-semantic/sql
  -- ========================================================================
  USE ROLE DAVE_Intelligence_Demo;
  USE DATABASE DAVE_AI_DEMO;
  USE SCHEMA DAVE_PRODUCT_ANALYTICS;

  -- ========================================================================
  -- TRANSACTION ANALYTICS SEMANTIC VIEW (for DAVE)
  -- Tracks financial transactions, fees, and revenue
  -- ========================================================================

CREATE OR REPLACE SEMANTIC VIEW DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.FINANCE_SEMANTIC_VIEW
    tables (
        TRANSACTIONS as FINANCE_TRANSACTIONS primary key (TRANSACTION_ID) with synonyms=('transactions','financial transactions','payments','advances') comment='All DAVE financial transactions: ExtraCash advances, subscription fees, tips, transfers',
        ACCOUNTS as ACCOUNT_DIM primary key (ACCOUNT_KEY) with synonyms=('account types','transaction types','revenue categories') comment='Transaction categorization: ExtraCash, Subscriptions, Tips, Fees',
        DEPARTMENTS as DEPARTMENT_DIM primary key (DEPARTMENT_KEY) with synonyms=('business units','departments','product lines') comment='Business unit or department that owns the transaction type',
        VENDORS as VENDOR_DIM primary key (VENDOR_KEY) with synonyms=('partners','payment processors','vendors') comment='Payment processors and partner information',
        PRODUCTS as PRODUCT_DIM primary key (PRODUCT_KEY) with synonyms=('products','features','services') comment='DAVE products associated with transactions',
        CUSTOMERS as CUSTOMER_DIM primary key (CUSTOMER_KEY) with synonyms=('users','members','customers','app users') comment='DAVE app users who made the transactions'
    )
    relationships (
        TRANSACTIONS_TO_ACCOUNTS as TRANSACTIONS(ACCOUNT_KEY) references ACCOUNTS(ACCOUNT_KEY),
        TRANSACTIONS_TO_DEPARTMENTS as TRANSACTIONS(DEPARTMENT_KEY) references DEPARTMENTS(DEPARTMENT_KEY),
        TRANSACTIONS_TO_VENDORS as TRANSACTIONS(VENDOR_KEY) references VENDORS(VENDOR_KEY),
        TRANSACTIONS_TO_PRODUCTS as TRANSACTIONS(PRODUCT_KEY) references PRODUCTS(PRODUCT_KEY),
        TRANSACTIONS_TO_CUSTOMERS as TRANSACTIONS(CUSTOMER_KEY) references CUSTOMERS(CUSTOMER_KEY)
    )
    facts (
        TRANSACTIONS.AMOUNT as amount comment='Transaction amount in dollars (ExtraCash advances, fees, tips, subscriptions)',
        TRANSACTIONS.TRANSACTION_RECORD as 1 comment='Count of transactions'
    )
    dimensions (
        TRANSACTIONS.DATE as date with synonyms=('date','transaction date','payment date') comment='Date of the financial transaction',
        TRANSACTIONS.TRANSACTION_MONTH as MONTH(date) comment='Month of the transaction',
        TRANSACTIONS.TRANSACTION_YEAR as YEAR(date) comment='Year of the transaction',
        ACCOUNTS.ACCOUNT_NAME as account_name with synonyms=('transaction category','account type','revenue type') comment='Transaction category (ExtraCash, Subscription, Tip, Express Fee, etc.)',
        ACCOUNTS.ACCOUNT_TYPE as account_type with synonyms=('type','category','revenue category') comment='Type of transaction (Revenue/Income, Fee, Transfer)',
        DEPARTMENTS.DEPARTMENT_NAME as department_name with synonyms=('department','business unit','product line') comment='Department or product line (Lending, Banking, Subscriptions)',
        VENDORS.VENDOR_NAME as vendor_name with synonyms=('partner','processor','payment processor') comment='Payment processor or partner name',
        PRODUCTS.PRODUCT_NAME as product_name with synonyms=('product','feature','service') comment='DAVE product name (ExtraCash, Banking, etc.)',
        CUSTOMERS.CUSTOMER_NAME as customer_name with synonyms=('user','member','customer','app user') comment='DAVE app user who made the transaction'
    )
    metrics (
        TRANSACTIONS.AVERAGE_AMOUNT as AVG(transactions.amount) comment='Average transaction value',
        TRANSACTIONS.TOTAL_AMOUNT as SUM(transactions.amount) comment='Total transaction volume/revenue',
        TRANSACTIONS.TOTAL_TRANSACTIONS as COUNT(transactions.transaction_record) comment='Total number of transactions'
    )
    comment='Semantic view for DAVE transaction analytics - tracks ExtraCash advances, fees, tips, subscriptions, and all financial transactions';



  -- ========================================================================
  -- PRODUCT USAGE ANALYTICS SEMANTIC VIEW (for DAVE)
  -- Tracks app user engagement, feature adoption, and product usage metrics
  -- ========================================================================

CREATE OR REPLACE SEMANTIC VIEW DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.SALES_SEMANTIC_VIEW
	tables (
		CUSTOMERS as CUSTOMER_DIM primary key (CUSTOMER_KEY) with synonyms=('app users','users','members','customers','accounts') comment='DAVE app users - people who have downloaded and use the DAVE app',
		PRODUCTS as PRODUCT_DIM primary key (PRODUCT_KEY) with synonyms=('products','features','services','offerings','product lines') comment='DAVE products and features: ExtraCash advances, Banking, Budgeting tools, Credit Builder',
		PRODUCT_CATEGORY_DIM primary key (CATEGORY_KEY),
		REGIONS as REGION_DIM primary key (REGION_KEY) with synonyms=('territories','regions','areas','markets','geographic areas') comment='Geographic regions where DAVE users are located',
		SALES as SALES_FACT primary key (SALE_ID) with synonyms=('product usage','transactions','user activities','feature usage') comment='Product usage transactions - when users engage with DAVE features like taking an ExtraCash advance, using budgeting tools, etc.'
	)
	relationships (
		PRODUCT_TO_CATEGORY as PRODUCTS(CATEGORY_KEY) references PRODUCT_CATEGORY_DIM(CATEGORY_KEY),
		SALES_TO_CUSTOMERS as SALES(CUSTOMER_KEY) references CUSTOMERS(CUSTOMER_KEY),
		SALES_TO_PRODUCTS as SALES(PRODUCT_KEY) references PRODUCTS(PRODUCT_KEY),
		SALES_TO_REGIONS as SALES(REGION_KEY) references REGIONS(REGION_KEY)
	)
	facts (
		SALES.AMOUNT as amount comment='Transaction amount in dollars - includes ExtraCash advances, subscription fees, tips, and other revenue',
		SALES.SALE_RECORD as 1 comment='Count of product usage transactions',
		SALES.UNITS as units comment='Number of transaction units or feature usages'
	)
	dimensions (
		CUSTOMERS.INDUSTRY as INDUSTRY with synonyms=('user segment','customer type','user category','customer industry') comment='User demographic segment or type',
		CUSTOMERS.CUSTOMER_KEY as CUSTOMER_KEY,
		CUSTOMERS.CUSTOMER_NAME as customer_name with synonyms=('user','member','customer','app user') comment='App user identifier or name',
		PRODUCTS.CATEGORY_KEY as CATEGORY_KEY with synonyms=('category_id','product_category','feature_category','service_category','product_line_id') comment='Unique identifier for the product/feature category.',
		PRODUCTS.PRODUCT_KEY as PRODUCT_KEY,
		PRODUCTS.PRODUCT_NAME as product_name with synonyms=('product','feature','service','offering') comment='Name of the DAVE product or feature (e.g., ExtraCash, Banking, Budgeting, Credit Builder)',
		PRODUCT_CATEGORY_DIM.CATEGORY_KEY as CATEGORY_KEY with synonyms=('category_id','category_code','product_line_id','category_identifier','classification_key') comment='Unique identifier for a product category.',
		PRODUCT_CATEGORY_DIM.CATEGORY_NAME as CATEGORY_NAME with synonyms=('category_title','product_line','feature_group','service_type','product_family') comment='The category to which a DAVE product belongs, such as Financial Services, Banking Services, or Budgeting Tools.',
		PRODUCT_CATEGORY_DIM.VERTICAL as VERTICAL with synonyms=('business_line','product_vertical','service_area','product_domain') comment='The business vertical or product line, such as Lending, Banking, or Financial Tools.',
		REGIONS.REGION_KEY as REGION_KEY,
		REGIONS.REGION_NAME as region_name with synonyms=('region','market','area','geography') comment='Geographic region where user is located',
		SALES.CUSTOMER_KEY as CUSTOMER_KEY,
		SALES.PRODUCT_KEY as PRODUCT_KEY,
		SALES.REGION_KEY as REGION_KEY,
		SALES.DATE as date with synonyms=('date','transaction date','usage date','activity date','sale date') comment='Date when user engaged with the product/feature',
		SALES.SALE_ID as SALE_ID,
		SALES.SALE_MONTH as MONTH(date) comment='Month of the product usage',
		SALES.SALE_YEAR as YEAR(date) comment='Year of the product usage'
	)
	metrics (
		SALES.AVERAGE_DEAL_SIZE as AVG(sales.amount) comment='Average transaction value or revenue per user',
		SALES.AVERAGE_UNITS_PER_SALE as AVG(sales.units) comment='Average usage frequency per transaction',
		SALES.TOTAL_DEALS as COUNT(sales.sale_record) comment='Total number of product usage transactions',
		SALES.TOTAL_REVENUE as SUM(sales.amount) comment='Total revenue from all transactions',
		SALES.TOTAL_UNITS as SUM(sales.units) comment='Total usage volume across all transactions'
	)
	comment='Semantic view for DAVE product usage analytics - tracks app user engagement, feature adoption, and transaction patterns (B2C model - no sales reps or vendors)'
	with extension (CA='{"tables":[{"name":"CUSTOMERS","dimensions":[{"name":"CUSTOMER_KEY"},{"name":"CUSTOMER_NAME","sample_values":["User_000001","User_000002","User_000003"]},{"name":"INDUSTRY","sample_values":["Young Professional","Gig Worker","Student"]}]},{"name":"PRODUCTS","dimensions":[{"name":"CATEGORY_KEY","unique":false},{"name":"PRODUCT_KEY"},{"name":"PRODUCT_NAME","sample_values":["ExtraCash Advance $75","Dave Banking Account","Budgeting - Goals"]}]},{"name":"PRODUCT_CATEGORY_DIM","dimensions":[{"name":"CATEGORY_KEY","sample_values":["1","2","3"]},{"name":"CATEGORY_NAME","sample_values":["Cash Advances","Banking Services","Budgeting Tools"]},{"name":"VERTICAL","sample_values":["Financial Services","Financial Services","Financial Tools"]}]},{"name":"REGIONS","dimensions":[{"name":"REGION_KEY"},{"name":"REGION_NAME","sample_values":["North","South","West"]}]},{"name":"SALES","dimensions":[{"name":"CUSTOMER_KEY"},{"name":"PRODUCT_KEY"},{"name":"REGION_KEY"},{"name":"DATE","sample_values":["2024-01-01","2024-01-02","2024-01-03"]},{"name":"SALE_ID"},{"name":"SALE_MONTH"},{"name":"SALE_YEAR"}],"facts":[{"name":"AMOUNT"},{"name":"SALE_RECORD"},{"name":"UNITS"}],"metrics":[{"name":"AVERAGE_DEAL_SIZE"},{"name":"AVERAGE_UNITS_PER_SALE"},{"name":"TOTAL_DEALS"},{"name":"TOTAL_REVENUE"},{"name":"TOTAL_UNITS"}]}],"relationships":[{"name":"PRODUCT_TO_CATEGORY"},{"name":"SALES_TO_CUSTOMERS","relationship_type":"many_to_one"},{"name":"SALES_TO_PRODUCTS","relationship_type":"many_to_one"},{"name":"SALES_TO_REGIONS","relationship_type":"many_to_one"}]}');


-- ========================================================================
  -- USER ACQUISITION & RETENTION SEMANTIC VIEW (for DAVE)
  -- Tracks user acquisition campaigns, retention efforts, and engagement
  -- ========================================================================
CREATE OR REPLACE SEMANTIC VIEW DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.MARKETING_SEMANTIC_VIEW
	tables (
		ACCOUNTS as SF_ACCOUNTS primary key (ACCOUNT_ID) with synonyms=('users','app users','member accounts','customers') comment='DAVE app user account information for engagement and retention analysis',
		CAMPAIGNS as MARKETING_CAMPAIGN_FACT primary key (CAMPAIGN_FACT_ID) with synonyms=('acquisition campaigns','user campaigns','growth campaigns','marketing initiatives') comment='User acquisition and retention campaign performance data',
		CAMPAIGN_DETAILS as CAMPAIGN_DIM primary key (CAMPAIGN_KEY) with synonyms=('campaign info','campaign details','campaign metadata') comment='Campaign details including objectives (user acquisition, retention, engagement)',
		CHANNELS as CHANNEL_DIM primary key (CHANNEL_KEY) with synonyms=('acquisition channels','marketing channels','user sources') comment='Acquisition channels: social media, paid ads, referrals, organic, partnerships',
		CONTACTS as SF_CONTACTS primary key (CONTACT_ID) with synonyms=('leads','prospects','potential users','signups') comment='User signups and leads generated from acquisition campaigns',
		CONTACTS_FOR_OPPORTUNITIES as SF_CONTACTS primary key (CONTACT_ID) with synonyms=('converted users','activated users') comment='Users who converted from leads to active app users',
		OPPORTUNITIES as SF_OPPORTUNITIES primary key (OPPORTUNITY_ID) with synonyms=('conversions','user activations','new users','activated accounts') comment='User conversion opportunities - tracking from signup to active user',
		PRODUCTS as PRODUCT_DIM primary key (PRODUCT_KEY) with synonyms=('products','features','offerings') comment='DAVE products featured in acquisition campaigns',
		REGIONS as REGION_DIM primary key (REGION_KEY) with synonyms=('territories','markets','geographic areas') comment='Geographic regions targeted by acquisition campaigns'
	)
	relationships (
		CAMPAIGNS_TO_CHANNELS as CAMPAIGNS(CHANNEL_KEY) references CHANNELS(CHANNEL_KEY),
		CAMPAIGNS_TO_DETAILS as CAMPAIGNS(CAMPAIGN_KEY) references CAMPAIGN_DETAILS(CAMPAIGN_KEY),
		CAMPAIGNS_TO_PRODUCTS as CAMPAIGNS(PRODUCT_KEY) references PRODUCTS(PRODUCT_KEY),
		CAMPAIGNS_TO_REGIONS as CAMPAIGNS(REGION_KEY) references REGIONS(REGION_KEY),
		CONTACTS_TO_ACCOUNTS as CONTACTS(ACCOUNT_ID) references ACCOUNTS(ACCOUNT_ID),
		CONTACTS_TO_CAMPAIGNS as CONTACTS(CAMPAIGN_NO) references CAMPAIGNS(CAMPAIGN_FACT_ID),
		CONTACTS_TO_OPPORTUNITIES as CONTACTS_FOR_OPPORTUNITIES(OPPORTUNITY_ID) references OPPORTUNITIES(OPPORTUNITY_ID),
		OPPORTUNITIES_TO_ACCOUNTS as OPPORTUNITIES(ACCOUNT_ID) references ACCOUNTS(ACCOUNT_ID),
		OPPORTUNITIES_TO_CAMPAIGNS as OPPORTUNITIES(CAMPAIGN_ID) references CAMPAIGNS(CAMPAIGN_FACT_ID)
	)
	facts (
		PUBLIC CAMPAIGNS.CAMPAIGN_RECORD as 1 comment='Count of campaign activities',
		PUBLIC CAMPAIGNS.SPEND as spend comment='User acquisition and retention spend in dollars (CAC - Customer Acquisition Cost)',
		PUBLIC CAMPAIGNS.IMPRESSIONS as IMPRESSIONS comment='Number of ad impressions or campaign reach',
		PUBLIC CAMPAIGNS.LEADS_GENERATED as LEADS_GENERATED comment='Number of app downloads or signups generated',
		PUBLIC CONTACTS.CONTACT_RECORD as 1 comment='Count of user signups generated',
		PUBLIC OPPORTUNITIES.OPPORTUNITY_RECORD as 1 comment='Count of user activations (users who completed onboarding)',
		PUBLIC OPPORTUNITIES.AMOUNT as AMOUNT comment='Revenue generated from activated users'
	)
	dimensions (
		PUBLIC ACCOUNTS.ACCOUNT_ID as ACCOUNT_ID,
		PUBLIC ACCOUNTS.ACCOUNT_NAME as ACCOUNT_NAME with synonyms=('user name','member name','account name','user id') comment='User identifier or account name',
		PUBLIC ACCOUNTS.ACCOUNT_TYPE as ACCOUNT_TYPE with synonyms=('user type','account tier','membership level','subscription tier') comment='User account tier: Free, Basic, Premium, Premium Plus',
		PUBLIC ACCOUNTS.ANNUAL_REVENUE as ANNUAL_REVENUE with synonyms=('user ltv','lifetime value','user revenue','total value','LTV') comment='Lifetime value (LTV) - total revenue generated from this user',
		PUBLIC ACCOUNTS.EMPLOYEES as EMPLOYEES with synonyms=('household size','family members','dependents') comment='Number of people in user household',
		PUBLIC ACCOUNTS.INDUSTRY as INDUSTRY with synonyms=('user segment','demographic segment','user category','user type') comment='User demographic segment (Young Professional, Gig Worker, Student, etc.)',
		PUBLIC ACCOUNTS.ACQUISITION_CHANNEL as ACQUISITION_CHANNEL with synonyms=('signup channel','acquisition source','how user signed up','user source','channel') comment='Channel through which the user was acquired (Instagram Ads, Referral Program, TikTok Ads, Paid Search, Organic Search, etc.)',
		PUBLIC ACCOUNTS.CUSTOMER_KEY as CUSTOMER_KEY with synonyms=('User ID','Member ID','Customer Key') comment='User key that links to the app users table.',
		PUBLIC CAMPAIGNS.DATE as date with synonyms=('date','campaign date','activity date') comment='Date of the acquisition or retention campaign activity',
		PUBLIC CAMPAIGNS.CAMPAIGN_FACT_ID as CAMPAIGN_FACT_ID,
		PUBLIC CAMPAIGNS.CAMPAIGN_KEY as CAMPAIGN_KEY,
		PUBLIC CAMPAIGNS.CAMPAIGN_MONTH as MONTH(date) comment='Month of the campaign',
		PUBLIC CAMPAIGNS.CAMPAIGN_YEAR as YEAR(date) comment='Year of the campaign',
		PUBLIC CAMPAIGNS.CHANNEL_KEY as CHANNEL_KEY,
		PUBLIC CAMPAIGNS.PRODUCT_KEY as PRODUCT_KEY with synonyms=('product_id','product identifier') comment='Product identifier for campaign targeting',
		PUBLIC CAMPAIGNS.REGION_KEY as REGION_KEY,
		PUBLIC CAMPAIGN_DETAILS.CAMPAIGN_KEY as CAMPAIGN_KEY,
		PUBLIC CAMPAIGN_DETAILS.CAMPAIGN_NAME as CAMPAIGN_NAME with synonyms=('campaign','campaign title','marketing initiative') comment='Name of the user acquisition or retention campaign',
		PUBLIC CAMPAIGN_DETAILS.CAMPAIGN_OBJECTIVE as OBJECTIVE with synonyms=('objective','goal','purpose','campaign type') comment='Campaign objective (user acquisition, retention, engagement, reactivation)',
		PUBLIC CHANNELS.CHANNEL_KEY as CHANNEL_KEY,
		PUBLIC CHANNELS.CHANNEL_NAME as CHANNEL_NAME with synonyms=('channel','acquisition channel','marketing channel','user source') comment='Acquisition channel (social media, paid ads, referrals, organic, partnerships)',
		PUBLIC CONTACTS.ACCOUNT_ID as ACCOUNT_ID,
		PUBLIC CONTACTS.CAMPAIGN_NO as CAMPAIGN_NO,
		PUBLIC CONTACTS.CONTACT_ID as CONTACT_ID,
		PUBLIC CONTACTS.DEPARTMENT as DEPARTMENT with synonyms=('user category','user group') comment='User category or grouping',
		PUBLIC CONTACTS.EMAIL as EMAIL with synonyms=('email','email address','user email') comment='User email address',
		PUBLIC CONTACTS.FIRST_NAME as FIRST_NAME with synonyms=('first name','user first name') comment='User first name',
		PUBLIC CONTACTS.LAST_NAME as LAST_NAME with synonyms=('last name','surname','user last name') comment='User last name',
		PUBLIC CONTACTS.LEAD_SOURCE as LEAD_SOURCE with synonyms=('signup source','acquisition source','referral source') comment='How the user signed up (social media, referral, ads, organic)',
		PUBLIC CONTACTS.OPPORTUNITY_ID as OPPORTUNITY_ID,
		PUBLIC CONTACTS.TITLE as TITLE with synonyms=('user status','account status') comment='User account status',
		PUBLIC OPPORTUNITIES.ACCOUNT_ID as ACCOUNT_ID,
		PUBLIC OPPORTUNITIES.CAMPAIGN_ID as CAMPAIGN_ID with synonyms=('campaign id','acquisition campaign id') comment='Campaign ID that links user activation to acquisition campaign',
		PUBLIC OPPORTUNITIES.CLOSE_DATE as CLOSE_DATE with synonyms=('activation date','onboarding date','conversion date') comment='Date when user completed activation/onboarding',
		PUBLIC OPPORTUNITIES.OPPORTUNITY_ID as OPPORTUNITY_ID,
		PUBLIC OPPORTUNITIES.OPPORTUNITY_LEAD_SOURCE as lead_source with synonyms=('activation source','signup source') comment='Source that led to user activation',
		PUBLIC OPPORTUNITIES.OPPORTUNITY_NAME as OPPORTUNITY_NAME with synonyms=('user activation','conversion event','onboarding completion') comment='User activation or conversion event',
		PUBLIC OPPORTUNITIES.OPPORTUNITY_STAGE as STAGE_NAME comment='User activation stage. Closed Won indicates a fully activated user who has completed onboarding',
		PUBLIC OPPORTUNITIES.OPPORTUNITY_TYPE as TYPE with synonyms=('activation type','user type','conversion type') comment='Type of user activation or conversion',
		PUBLIC OPPORTUNITIES.SALE_ID as SALE_ID with synonyms=('transaction id','usage id') comment='Transaction ID linking user activation to first product usage',
		PUBLIC PRODUCTS.CATEGORY_NAME as CATEGORY_NAME with synonyms=('category','product category') comment='Category of the product',
		PUBLIC PRODUCTS.PRODUCT_KEY as PRODUCT_KEY,
		PUBLIC PRODUCTS.PRODUCT_NAME as PRODUCT_NAME with synonyms=('product','item','product title') comment='Name of the product being promoted',
		PUBLIC PRODUCTS.VERTICAL as VERTICAL with synonyms=('vertical','industry','product vertical') comment='Business vertical of the product',
		PUBLIC REGIONS.REGION_KEY as REGION_KEY,
		PUBLIC REGIONS.REGION_NAME as REGION_NAME with synonyms=('region','market','territory') comment='Name of the region'
	)
	metrics (
		PUBLIC CAMPAIGNS.AVERAGE_SPEND as AVG(CAMPAIGNS.spend) comment='Average spend per acquisition/retention campaign (CAC per campaign)',
		PUBLIC CAMPAIGNS.TOTAL_CAMPAIGNS as COUNT(CAMPAIGNS.campaign_record) comment='Total number of acquisition and retention campaign activities',
		PUBLIC CAMPAIGNS.TOTAL_IMPRESSIONS as SUM(CAMPAIGNS.impressions) comment='Total impressions or reach across all campaigns',
		PUBLIC CAMPAIGNS.TOTAL_LEADS as SUM(CAMPAIGNS.leads_generated) comment='Total app downloads and signups generated from campaigns',
		PUBLIC CAMPAIGNS.TOTAL_SPEND as SUM(CAMPAIGNS.spend) comment='Total user acquisition and retention spend',
		PUBLIC CONTACTS.TOTAL_CONTACTS as COUNT(CONTACTS.contact_record) comment='Total user signups generated from campaigns',
		PUBLIC OPPORTUNITIES.AVERAGE_DEAL_SIZE as AVG(OPPORTUNITIES.amount) comment='Average revenue per activated user (ARPU)',
		PUBLIC OPPORTUNITIES.CLOSED_WON_REVENUE as SUM(CASE WHEN OPPORTUNITIES.stage_name = 'Closed Won' THEN OPPORTUNITIES.amount ELSE 0 END) comment='Revenue from fully activated users',
		PUBLIC OPPORTUNITIES.TOTAL_OPPORTUNITIES as COUNT(OPPORTUNITIES.opportunity_record) comment='Total user activations from acquisition campaigns',
		PUBLIC OPPORTUNITIES.TOTAL_REVENUE as SUM(OPPORTUNITIES.amount) comment='Total revenue from campaign-acquired users'
	)
	comment='Semantic view for DAVE user acquisition & retention analytics - tracks campaign performance, user signups, activations, and conversion to revenue'
	with extension (CA='{"tables":[{"name":"ACCOUNTS","dimensions":[{"name":"ACCOUNT_ID"},{"name":"ACCOUNT_NAME"},{"name":"ACCOUNT_TYPE"},{"name":"ANNUAL_REVENUE"},{"name":"EMPLOYEES"},{"name":"INDUSTRY"},{"name":"ACQUISITION_CHANNEL"},{"name":"CUSTOMER_KEY"}]},{"name":"CAMPAIGNS","dimensions":[{"name":"DATE"},{"name":"CAMPAIGN_FACT_ID"},{"name":"CAMPAIGN_KEY"},{"name":"CAMPAIGN_MONTH"},{"name":"CAMPAIGN_YEAR"},{"name":"CHANNEL_KEY"},{"name":"PRODUCT_KEY"},{"name":"REGION_KEY"}],"facts":[{"name":"CAMPAIGN_RECORD"},{"name":"SPEND"},{"name":"IMPRESSIONS"},{"name":"LEADS_GENERATED"}],"metrics":[{"name":"AVERAGE_SPEND"},{"name":"TOTAL_CAMPAIGNS"},{"name":"TOTAL_IMPRESSIONS"},{"name":"TOTAL_LEADS"},{"name":"TOTAL_SPEND"}]},{"name":"CAMPAIGN_DETAILS","dimensions":[{"name":"CAMPAIGN_KEY"},{"name":"CAMPAIGN_NAME"},{"name":"CAMPAIGN_OBJECTIVE"}]},{"name":"CHANNELS","dimensions":[{"name":"CHANNEL_KEY"},{"name":"CHANNEL_NAME"}]},{"name":"CONTACTS","dimensions":[{"name":"ACCOUNT_ID"},{"name":"CAMPAIGN_NO"},{"name":"CONTACT_ID"},{"name":"DEPARTMENT"},{"name":"EMAIL"},{"name":"FIRST_NAME"},{"name":"LAST_NAME"},{"name":"LEAD_SOURCE"},{"name":"OPPORTUNITY_ID"},{"name":"TITLE"}],"facts":[{"name":"CONTACT_RECORD"}],"metrics":[{"name":"TOTAL_CONTACTS"}]},{"name":"CONTACTS_FOR_OPPORTUNITIES"},{"name":"OPPORTUNITIES","dimensions":[{"name":"ACCOUNT_ID"},{"name":"CAMPAIGN_ID"},{"name":"CLOSE_DATE"},{"name":"OPPORTUNITY_ID"},{"name":"OPPORTUNITY_LEAD_SOURCE"},{"name":"OPPORTUNITY_NAME"},{"name":"OPPORTUNITY_STAGE","sample_values":["Closed Won","Perception Analysis","Qualification"]},{"name":"OPPORTUNITY_TYPE"},{"name":"SALE_ID"}],"facts":[{"name":"OPPORTUNITY_RECORD"},{"name":"AMOUNT"}],"metrics":[{"name":"AVERAGE_DEAL_SIZE"},{"name":"CLOSED_WON_REVENUE"},{"name":"TOTAL_OPPORTUNITIES"},{"name":"TOTAL_REVENUE"}]},{"name":"PRODUCTS","dimensions":[{"name":"CATEGORY_NAME"},{"name":"PRODUCT_KEY"},{"name":"PRODUCT_NAME"},{"name":"VERTICAL"}]},{"name":"REGIONS","dimensions":[{"name":"REGION_KEY"},{"name":"REGION_NAME"}]}],"relationships":[{"name":"CAMPAIGNS_TO_CHANNELS","relationship_type":"many_to_one"},{"name":"CAMPAIGNS_TO_DETAILS","relationship_type":"many_to_one"},{"name":"CAMPAIGNS_TO_PRODUCTS","relationship_type":"many_to_one"},{"name":"CAMPAIGNS_TO_REGIONS","relationship_type":"many_to_one"},{"name":"CONTACTS_TO_ACCOUNTS","relationship_type":"many_to_one"},{"name":"CONTACTS_TO_CAMPAIGNS","relationship_type":"many_to_one"},{"name":"CONTACTS_TO_OPPORTUNITIES","relationship_type":"many_to_one"},{"name":"OPPORTUNITIES_TO_ACCOUNTS","relationship_type":"many_to_one"},{"name":"OPPORTUNITIES_TO_CAMPAIGNS"}],"custom_instructions":"IMPORTANT: There is a helper view called segment_metrics_view in DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS that pre-calculates LTV and CAC by user segment.\\n\\nFor questions about LTV and CAC by segment, use:\\nSELECT * FROM DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.segment_metrics_view WHERE user_segment IN ('desired segments')\\n\\nThis view contains:\\n- user_segment (Gig Worker, Young Professional, Student, etc.)\\n- avg_lifetime_value (average LTV)\\n- total_users (count of users)\\n- weighted_avg_cac (CAC weighted by channel mix)\\n- ltv_to_cac_ratio\\n\\nFor simple LTV only: Query accounts table directly.\\nFor simple CAC by channel: Query campaigns + channels.","verified_queries":[{"name":"LTV and CAC by segment using helper view","question":"which user segments have the highest lifetime value and lowest acquisition cost","sql":"SELECT user_segment, avg_lifetime_value, total_users, weighted_avg_cac, ltv_to_cac_ratio FROM DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.segment_metrics_view WHERE user_segment IN (''Gig Worker'',''Young Professional'',''Student'') ORDER BY avg_lifetime_value DESC","use_as_onboarding_question":true,"verified_by":"DAVE","verified_at":1728401234},{"name":"LTV by segment","question":"show me lifetime value by user segment","sql":"SELECT industry, AVG(annual_revenue) as avg_ltv, COUNT(*) as users FROM accounts WHERE industry IN (''Gig Worker'',''Young Professional'',''Student'') GROUP BY industry ORDER BY avg_ltv DESC","use_as_onboarding_question":false,"verified_by":"DAVE","verified_at":1728401234}]}');



  -- ========================================================================
  -- TEAM PERFORMANCE SEMANTIC VIEW (for DAVE)
  -- Tracks team metrics, staffing, and organizational structure
  -- ========================================================================
CREATE OR REPLACE SEMANTIC VIEW DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.HR_SEMANTIC_VIEW
	tables (
		DEPARTMENTS as DEPARTMENT_DIM primary key (DEPARTMENT_KEY) with synonyms=('departments','teams','business units') comment='DAVE departments and teams: Product, Engineering, Customer Success, Operations',
		EMPLOYEES as EMPLOYEE_DIM primary key (EMPLOYEE_KEY) with synonyms=('employees','team members','staff','workforce') comment='DAVE team members including product, engineering, customer success, and operations staff',
		HR_RECORDS as HR_EMPLOYEE_FACT primary key (HR_FACT_ID) with synonyms=('team data','employee records','staffing data') comment='Team member records for workforce analysis and performance tracking',
		JOBS as JOB_DIM primary key (JOB_KEY) with synonyms=('roles','positions','job titles') comment='Job roles: Product Manager, Engineer, Customer Success Rep, Operations Analyst, etc.',
		LOCATIONS as LOCATION_DIM primary key (LOCATION_KEY) with synonyms=('locations','offices','work locations','sites') comment='Work locations for team members (headquarters, remote, regional offices)'
	)
	relationships (
		HR_TO_DEPARTMENTS as HR_RECORDS(DEPARTMENT_KEY) references DEPARTMENTS(DEPARTMENT_KEY),
		HR_TO_EMPLOYEES as HR_RECORDS(EMPLOYEE_KEY) references EMPLOYEES(EMPLOYEE_KEY),
		HR_TO_JOBS as HR_RECORDS(JOB_KEY) references JOBS(JOB_KEY),
		HR_TO_LOCATIONS as HR_RECORDS(LOCATION_KEY) references LOCATIONS(LOCATION_KEY)
	)
	facts (
		HR_RECORDS.ATTRITION_FLAG as attrition_flag with synonyms=('turnover_indicator','departure_flag','separation_flag','retention_status','churn_status','exit_indicator') comment='Attrition flag. value is 0 if team member is currently active. 1 if team member has left DAVE. Always filter by 0 to show active team members unless specified otherwise',
		HR_RECORDS.EMPLOYEE_RECORD as 1 comment='Count of team member records',
		HR_RECORDS.EMPLOYEE_SALARY as salary comment='Team member salary/compensation in dollars'
	)
	dimensions (
		DEPARTMENTS.DEPARTMENT_KEY as DEPARTMENT_KEY,
		DEPARTMENTS.DEPARTMENT_NAME as department_name with synonyms=('department','team','business unit','division') comment='Department or team name (Product, Engineering, Customer Success, Operations, Marketing)',
		EMPLOYEES.EMPLOYEE_KEY as EMPLOYEE_KEY,
		EMPLOYEES.EMPLOYEE_NAME as employee_name with synonyms=('employee','team member','staff member','person','cs rep','engineer','product manager') comment='Name of the team member',
		EMPLOYEES.GENDER as gender with synonyms=('gender','sex') comment='Team member gender',
		EMPLOYEES.HIRE_DATE as hire_date with synonyms=('hire date','start date','join date') comment='Date when team member joined DAVE',
		HR_RECORDS.DEPARTMENT_KEY as DEPARTMENT_KEY,
		HR_RECORDS.EMPLOYEE_KEY as EMPLOYEE_KEY,
		HR_RECORDS.HR_FACT_ID as HR_FACT_ID,
		HR_RECORDS.JOB_KEY as JOB_KEY,
		HR_RECORDS.LOCATION_KEY as LOCATION_KEY,
		HR_RECORDS.RECORD_DATE as date with synonyms=('date','record date','snapshot date') comment='Date of the team record snapshot',
		HR_RECORDS.RECORD_MONTH as MONTH(date) comment='Month of the team record',
		HR_RECORDS.RECORD_YEAR as YEAR(date) comment='Year of the team record',
		JOBS.JOB_KEY as JOB_KEY,
		JOBS.JOB_LEVEL as job_level with synonyms=('level','grade','seniority','career level') comment='Job level (IC, Senior, Lead, Manager, Director)',
		JOBS.JOB_TITLE as job_title with synonyms=('job title','position','role','job function') comment='Team member job title (Product Manager, Software Engineer, CS Rep, etc.)',
		LOCATIONS.LOCATION_KEY as LOCATION_KEY,
		LOCATIONS.LOCATION_NAME as location_name with synonyms=('location','office','work location','site') comment='Work location (HQ, Remote, Regional Office)'
	)
	metrics (
		HR_RECORDS.ATTRITION_COUNT as SUM(hr_records.attrition_flag) comment='Number of team members who left',
		HR_RECORDS.AVG_SALARY as AVG(hr_records.employee_salary) comment='Average team member salary',
		HR_RECORDS.TOTAL_EMPLOYEES as COUNT(hr_records.employee_record) comment='Total number of team members',
		HR_RECORDS.TOTAL_SALARY_COST as SUM(hr_records.EMPLOYEE_SALARY) comment='Total team compensation cost'
	)
	comment='Semantic view for DAVE team performance analytics - tracks team composition, staffing levels, and organizational metrics'
	with extension (CA='{"tables":[{"name":"DEPARTMENTS","dimensions":[{"name":"DEPARTMENT_KEY"},{"name":"DEPARTMENT_NAME","sample_values":["Finance","Accounting","Treasury"]}]},{"name":"EMPLOYEES","dimensions":[{"name":"EMPLOYEE_KEY"},{"name":"EMPLOYEE_NAME","sample_values":["Grant Frey","Elizabeth George","Olivia Mcdaniel"]},{"name":"GENDER"},{"name":"HIRE_DATE"}]},{"name":"HR_RECORDS","dimensions":[{"name":"DEPARTMENT_KEY"},{"name":"EMPLOYEE_KEY"},{"name":"HR_FACT_ID"},{"name":"JOB_KEY"},{"name":"LOCATION_KEY"},{"name":"RECORD_DATE"},{"name":"RECORD_MONTH"},{"name":"RECORD_YEAR"}],"facts":[{"name":"ATTRITION_FLAG","sample_values":["0","1"]},{"name":"EMPLOYEE_RECORD"},{"name":"EMPLOYEE_SALARY"}],"metrics":[{"name":"ATTRITION_COUNT"},{"name":"AVG_SALARY"},{"name":"TOTAL_EMPLOYEES"},{"name":"TOTAL_SALARY_COST"}]},{"name":"JOBS","dimensions":[{"name":"JOB_KEY"},{"name":"JOB_LEVEL"},{"name":"JOB_TITLE"}]},{"name":"LOCATIONS","dimensions":[{"name":"LOCATION_KEY"},{"name":"LOCATION_NAME"}]}],"relationships":[{"name":"HR_TO_DEPARTMENTS","relationship_type":"many_to_one"},{"name":"HR_TO_EMPLOYEES","relationship_type":"many_to_one"},{"name":"HR_TO_JOBS","relationship_type":"many_to_one"},{"name":"HR_TO_LOCATIONS","relationship_type":"many_to_one"}],"verified_queries":[{"name":"List of all active employees","question":"List of all active employees","sql":"select\\n  h.employee_key,\\n  e.employee_name,\\nfrom\\n  employees e\\n  left join hr_records h on e.employee_key = h.employee_key\\ngroup by\\n  all\\nhaving\\n  sum(h.attrition_flag) = 0;","use_as_onboarding_question":false,"verified_by":"Nick Akincilar","verified_at":1753846263},{"name":"List of all inactive employees","question":"List of all inactive employees","sql":"SELECT\\n  h.employee_key,\\n  e.employee_name\\nFROM\\n  employees AS e\\n  LEFT JOIN hr_records AS h ON e.employee_key = h.employee_key\\nGROUP BY\\n  ALL\\nHAVING\\n  SUM(h.attrition_flag) > 0","use_as_onboarding_question":false,"verified_by":"Nick Akincilar","verified_at":1753846300}],"custom_instructions":"- Each employee can have multiple hr_employee_fact records. \\n- Only one hr_employee_fact record per employee is valid and that is the one which has the highest date value."}');
  -- ========================================================================
  -- VERIFICATION
  -- ========================================================================

  -- Show all semantic views
  SHOW SEMANTIC VIEWS;

  -- Show dimensions for each semantic view
  SHOW SEMANTIC DIMENSIONS;

  -- Show metrics for each semantic view
  SHOW SEMANTIC METRICS; 


    -- ========================================================================
    -- HELPER VIEWS FOR COMMON ANALYTICS
    -- Pre-calculated views to avoid complex joins and improve agent performance
    -- ========================================================================

    -- User Segment Metrics View - Pre-calculates LTV and CAC by segment
    CREATE OR REPLACE VIEW segment_metrics_view AS
    WITH channel_cac AS (
        SELECT 
            ch.channel_name,
            SUM(c.spend) / NULLIF(SUM(c.leads_generated), 0) as cac_per_user
        FROM marketing_campaign_fact c
        JOIN channel_dim ch ON c.channel_key = ch.channel_key
        WHERE YEAR(c.date) = 2025
        GROUP BY ch.channel_name
    ),
    segment_channel_distribution AS (
        SELECT 
            a.industry,
            a.acquisition_channel,
            COUNT(*) as user_count,
            AVG(a.annual_revenue) as avg_ltv_this_channel
        FROM sf_accounts a
        GROUP BY a.industry, a.acquisition_channel
    )
    SELECT 
        scd.industry as user_segment,
        AVG(scd.avg_ltv_this_channel) as avg_lifetime_value,
        SUM(scd.user_count) as total_users,
        SUM(scd.user_count * COALESCE(cc.cac_per_user, 0)) / NULLIF(SUM(scd.user_count), 0) as weighted_avg_cac,
        AVG(scd.avg_ltv_this_channel) / NULLIF(SUM(scd.user_count * COALESCE(cc.cac_per_user, 0)) / NULLIF(SUM(scd.user_count), 0), 0) as ltv_to_cac_ratio
    FROM segment_channel_distribution scd
    LEFT JOIN channel_cac cc ON scd.acquisition_channel = cc.channel_name
    GROUP BY scd.industry;

    -- Verify the helper view works
    SELECT * FROM segment_metrics_view WHERE user_segment IN ('Gig Worker', 'Young Professional', 'Student') ORDER BY avg_lifetime_value DESC;





    -- ========================================================================
    -- UNSTRUCTURED DATA
    -- ========================================================================
CREATE OR REPLACE TABLE parsed_content AS 
SELECT 
    relative_path, 
    BUILD_STAGE_FILE_URL('@DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.INTERNAL_DATA_STAGE', relative_path) AS file_url,
    TO_File(BUILD_STAGE_FILE_URL('@DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.INTERNAL_DATA_STAGE', relative_path)) AS file_object,
    SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
        @DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.INTERNAL_DATA_STAGE,
        relative_path,
        {'mode':'LAYOUT'}
    ):content::string AS Content
FROM directory(@DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.INTERNAL_DATA_STAGE) 
WHERE relative_path ILIKE 'unstructured_docs/%.pdf';

--select *, GET_PATH(PARSE_JSON(content), 'content')::string as extracted_content from parsed_content;


    -- Switch to DAVE demo role for remaining operations
    USE ROLE DAVE_Intelligence_Demo;

    -- Create search service for finance documents
    -- This enables semantic search over finance-related content
    CREATE OR REPLACE CORTEX SEARCH SERVICE Search_finance_docs
        ON content
        ATTRIBUTES relative_path, file_url, title
        WAREHOUSE = DAVE_INTELLIGENCE_DEMO_WH
        TARGET_LAG = '30 day'
        EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
        AS (
            SELECT
                relative_path,
                file_url,
                REGEXP_SUBSTR(relative_path, '[^/]+$') as title, -- Extract filename as title
                content
            FROM parsed_content
            WHERE relative_path ilike '%/finance/%'
        );
    
    -- Create search service for HR documents
    -- This enables semantic search over HR-related content
    CREATE OR REPLACE CORTEX SEARCH SERVICE Search_hr_docs
        ON content
        ATTRIBUTES relative_path, file_url, title
        WAREHOUSE = DAVE_INTELLIGENCE_DEMO_WH
        TARGET_LAG = '30 day'
        EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
        AS (
            SELECT
                relative_path,
                file_url,
                REGEXP_SUBSTR(relative_path, '[^/]+$') as title,
                content
            FROM parsed_content
            WHERE relative_path ilike '%/hr/%'
        );

    -- Create search service for marketing documents
    -- This enables semantic search over marketing-related content
    CREATE OR REPLACE CORTEX SEARCH SERVICE Search_marketing_docs
        ON content
        ATTRIBUTES relative_path, file_url, title
        WAREHOUSE = DAVE_INTELLIGENCE_DEMO_WH
        TARGET_LAG = '30 day'
        EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
        AS (
            SELECT
                relative_path,
                file_url,
                REGEXP_SUBSTR(relative_path, '[^/]+$') as title,
                content
            FROM parsed_content
            WHERE relative_path ilike '%/marketing/%'
        );

    -- Create search service for sales documents
    -- This enables semantic search over sales-related content
    CREATE OR REPLACE CORTEX SEARCH SERVICE Search_sales_docs
        ON content
        ATTRIBUTES relative_path, file_url, title
        WAREHOUSE = DAVE_INTELLIGENCE_DEMO_WH
        TARGET_LAG = '30 day'
        EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
        AS (
            SELECT
                relative_path,
                file_url,
                REGEXP_SUBSTR(relative_path, '[^/]+$') as title,
                content
            FROM parsed_content
            WHERE relative_path ilike '%/sales/%'
        );


USE ROLE DAVE_intelligence_demo;


  -- NETWORK rule is part of db schema
CREATE OR REPLACE NETWORK RULE DAVE_intelligence_WebAccessRule
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('0.0.0.0:80', '0.0.0.0:443');


USE ROLE accountadmin;

GRANT ALL PRIVILEGES ON DATABASE DAVE_AI_DEMO TO ROLE ACCOUNTADMIN;
GRANT ALL PRIVILEGES ON SCHEMA DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS TO ROLE ACCOUNTADMIN;
GRANT USAGE ON NETWORK RULE DAVE_intelligence_webaccessrule TO ROLE accountadmin;

USE SCHEMA DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS;

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION DAVE_intelligence_ExternalAccess_Integration
ALLOWED_NETWORK_RULES = (DAVE_intelligence_WebAccessRule)
ENABLED = true;

CREATE NOTIFICATION INTEGRATION ai_email_int
  TYPE=EMAIL
  ENABLED=TRUE;

GRANT USAGE ON DATABASE snowflake_intelligence TO ROLE DAVE_Intelligence_Demo;
GRANT USAGE ON SCHEMA snowflake_intelligence.agents TO ROLE DAVE_Intelligence_Demo;
GRANT CREATE AGENT ON SCHEMA snowflake_intelligence.agents TO ROLE DAVE_Intelligence_Demo;

GRANT USAGE ON INTEGRATION DAVE_intelligence_ExternalAccess_Integration TO ROLE DAVE_Intelligence_Demo;

GRANT USAGE ON INTEGRATION AI_EMAIL_INT TO ROLE DAVE_INTELLIGENCE_DEMO;


USE ROLE DAVE_Intelligence_Demo;
-- CREATES A SNOWFLAKE INTELLIGENCE AGENT WITH MULTIPLE TOOLS

-- Create stored procedure to generate presigned URLs for files in internal stages
CREATE OR REPLACE PROCEDURE Get_File_Presigned_URL_SP(
    RELATIVE_FILE_PATH STRING, 
    EXPIRATION_MINS INTEGER DEFAULT 60
)
RETURNS STRING
LANGUAGE SQL
COMMENT = 'Generates a presigned URL for a file in the static @INTERNAL_DATA_STAGE. Input is the relative file path.'
EXECUTE AS CALLER
AS
$$
DECLARE
    presigned_url STRING;
    sql_stmt STRING;
    expiration_seconds INTEGER;
    stage_name STRING DEFAULT '@DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.INTERNAL_DATA_STAGE';
BEGIN
    expiration_seconds := EXPIRATION_MINS * 60;

    sql_stmt := 'SELECT GET_PRESIGNED_URL(' || stage_name || ', ' || '''' || RELATIVE_FILE_PATH || '''' || ', ' || expiration_seconds || ') AS url';
    
    EXECUTE IMMEDIATE :sql_stmt;
    
    
    SELECT "URL"
    INTO :presigned_url
    FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));
    
    RETURN :presigned_url;
END;
$$;

-- Create stored procedure to send emails to verified recipients in Snowflake

CREATE OR REPLACE PROCEDURE send_mail(recipient TEXT, subject TEXT, text TEXT)
RETURNS TEXT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'send_mail'
AS
$$
def send_mail(session, recipient, subject, text):
    session.call(
        'SYSTEM$SEND_EMAIL',
        'ai_email_int',
        recipient,
        subject,
        text,
        'text/html'
    )
    return f'Email was sent to {recipient} with subject: "{subject}".'
$$;

CREATE OR REPLACE FUNCTION Web_scrape(weburl STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = 3.11
HANDLER = 'get_page'
EXTERNAL_ACCESS_INTEGRATIONS = (DAVE_intelligence_ExternalAccess_Integration)
PACKAGES = ('requests', 'beautifulsoup4')
--SECRETS = ('cred' = oauth_token )
AS
$$
import _snowflake
import requests
from bs4 import BeautifulSoup

def get_page(weburl):
  url = f"{weburl}"
  response = requests.get(url)
  soup = BeautifulSoup(response.text)
  return soup.get_text()
$$;


CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.DAVE_Product_Analytics_Agent
WITH PROFILE='{ "display_name": "DAVE Product Analytics Agent" }'
    COMMENT=$$ This is a product analytics agent for DAVE Operating Co that can answer questions about customer app usage, product adoption, user engagement, and financial transactions. $$
FROM SPECIFICATION $$
{
  "models": {
    "orchestration": ""
  },
  "instructions": {
    "response": "You are a product analytics specialist for DAVE, a financial technology company. You have access to customer app usage, product adoption, user engagement, transaction data, and customer support analytics. If user does not specify a date range, assume it for year 2025. Leverage data from all domains to analyze & answer user questions about how customers are using DAVE's app and products. Provide visualizations when possible. Trendlines should default to linecharts, categorical data to barcharts. Focus on actionable insights for the product team.",
    "orchestration": "Use cortex search for known entities and pass the results to cortex analyst for detailed analysis.\n\nKey Context for DAVE:\n- Sales data represents product transactions (ExtraCash advances, subscription fees, tips)\n- Customers are app users\n- Products represent DAVE services and features (ExtraCash, Banking, Budgeting, Credit Builder)\n- Marketing campaigns represent user acquisition and retention campaigns\n- Finance data includes transaction processing, fees, and revenue\n\nWhen analyzing product metrics:\n- Focus on user engagement, feature adoption, and transaction patterns\n- Consider cohort analysis for user behavior\n- Look for churn indicators and product stickiness\n- Analyze revenue per user and lifetime value\n\n",
    "sample_questions": [
      {
        "question": "What are the top 5 most used features by active users?"
      },
      {
        "question": "Show me user engagement trends over the last 6 months"
      },
      {
        "question": "What is our average revenue per user (ARPU) by product?"
      },
      {
        "question": "Which customer segments have the highest churn rate?"
      },
      {
        "question": "How is ExtraCash product adoption trending?"
      },
      {
        "question": "What are the most common user support issues?"
      }
    ]
  },
  "tools": [
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query Transaction Analytics",
        "description": "Analyze DAVE financial transactions including ExtraCash advances, subscription fees, tips, and revenue. Provides insights into transaction volumes, amounts, and patterns by product type, customer segment, and time period."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query Product Usage Analytics",
        "description": "Analyze DAVE app product usage and adoption metrics. Track which features (ExtraCash, Banking, Budgeting, Credit Builder) are being used, by which users, how frequently, and transaction volumes. Includes data on active users, feature adoption rates, and product engagement."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query Team Performance",
        "description": "Query team and employee data including customer success teams, support staff, and product teams. Analyze team performance metrics and staffing levels. employee_name column also contains names of customer success representatives."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query User Acquisition & Retention",
        "description": "Analyze user acquisition campaigns, retention efforts, channel performance (social media, referrals, paid ads), and user engagement metrics. Track campaign effectiveness, user acquisition costs, and retention rates."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search Financial Policies & Reports",
        "description": "Search DAVE's financial policies, transaction processing guidelines, expense policies, vendor contracts, and financial reports. Useful for understanding fee structures, revenue models, and financial operations."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search Team & Operations Docs",
        "description": "Search internal documents related to team operations, employee handbooks, performance guidelines, and organizational structure. Useful for understanding team processes and operational procedures."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search Product Documentation",
        "description": "Search product documentation, feature specifications, user guides, product playbooks, and customer success materials. Essential for understanding product functionality, feature rollouts, and customer-facing materials."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search User Acquisition Materials",
        "description": "Search documents related to user acquisition strategies, marketing campaigns, channel performance reports, and growth initiatives. Any reference docs in ID columns should be passed to Dynamic URL tool to generate a downloadable URL for users in the response"
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "Web_scraper",
        "description": "This tool should be used if the user wants to analyse contents of a given web page. This tool will use a web url (https or https) as input and will return the text content of that web page for further analysis",
        "input_schema": {
          "type": "object",
          "properties": {
            "weburl": {
              "description": "Agent should ask web url ( that includes http:// or https:// ). It will scrape text from the given url and return as a result.",
              "type": "string"
            }
          },
          "required": [
            "weburl"
          ]
        }
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "Send_Emails",
        "description": "This tool is used to send emails to a email recipient. It can take an email, subject & content as input to send the email. Always use HTML formatted content for the emails.",
        "input_schema": {
          "type": "object",
          "properties": {
            "recipient": {
              "description": "recipient of email",
              "type": "string"
            },
            "subject": {
              "description": "subject of email",
              "type": "string"
            },
            "text": {
              "description": "content of email",
              "type": "string"
            }
          },
          "required": [
            "text",
            "recipient",
            "subject"
          ]
        }
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "Dynamic_Doc_URL_Tool",
        "description": "This tools uses the ID Column coming from Cortex Search tools for reference docs and returns a temp URL for users to view & download the docs.\n\nReturned URL should be presented as a HTML Hyperlink where doc title should be the text and out of this tool should be the url.\n\nURL format for PDF docs that are are like this which has no PDF in the url. Create the Hyperlink format so the PDF doc opens up in a browser instead of downloading the file.\nhttps://domain/path/unique_guid",
        "input_schema": {
          "type": "object",
          "properties": {
            "expiration_mins": {
              "description": "default should be 5",
              "type": "number"
            },
            "relative_file_path": {
              "description": "This is the ID Column value Coming from Cortex Search tool.",
              "type": "string"
            }
          },
          "required": [
            "expiration_mins",
            "relative_file_path"
          ]
        }
      }
    }
  ],
  "tool_resources": {
    "Dynamic_Doc_URL_Tool": {
      "execution_environment": {
        "query_timeout": 0,
        "type": "warehouse",
        "warehouse": "DAVE_INTELLIGENCE_DEMO_WH"
      },
      "identifier": "DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.GET_FILE_PRESIGNED_URL_SP",
      "name": "GET_FILE_PRESIGNED_URL_SP(VARCHAR, DEFAULT NUMBER)",
      "type": "procedure"
    },
    "Query Transaction Analytics": {
      "semantic_view": "DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.FINANCE_SEMANTIC_VIEW"
    },
    "Query Team Performance": {
      "semantic_view": "DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.HR_SEMANTIC_VIEW"
    },
    "Query User Acquisition & Retention": {
      "semantic_view": "DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.MARKETING_SEMANTIC_VIEW"
    },
    "Query Product Usage Analytics": {
      "semantic_view": "DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.SALES_SEMANTIC_VIEW"
    },
    "Search Financial Policies & Reports": {
      "id_column": "FILE_URL",
      "max_results": 5,
      "name": "DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.SEARCH_FINANCE_DOCS",
      "title_column": "TITLE"
    },
    "Search Team & Operations Docs": {
      "id_column": "FILE_URL",
      "max_results": 5,
      "name": "DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.SEARCH_HR_DOCS",
      "title_column": "TITLE"
    },
    "Search User Acquisition Materials": {
      "id_column": "RELATIVE_PATH",
      "max_results": 5,
      "name": "DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.SEARCH_MARKETING_DOCS",
      "title_column": "TITLE"
    },
    "Search Product Documentation": {
      "id_column": "FILE_URL",
      "max_results": 5,
      "name": "DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.SEARCH_SALES_DOCS",
      "title_column": "TITLE"
    },
    "Send_Emails": {
      "execution_environment": {
        "query_timeout": 0,
        "type": "warehouse",
        "warehouse": "DAVE_INTELLIGENCE_DEMO_WH"
      },
      "identifier": "DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.SEND_MAIL",
      "name": "SEND_MAIL(VARCHAR, VARCHAR, VARCHAR)",
      "type": "procedure"
    },
    "Web_scraper": {
      "execution_environment": {
        "query_timeout": 0,
        "type": "warehouse",
        "warehouse": "DAVE_INTELLIGENCE_DEMO_WH"
      },
      "identifier": "DAVE_AI_DEMO.DAVE_PRODUCT_ANALYTICS.WEB_SCRAPE",
      "name": "WEB_SCRAPE(VARCHAR)",
      "type": "function"
    }
  }
}
$$;