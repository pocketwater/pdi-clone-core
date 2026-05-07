USE [PDI_PricingLink];
GO

/*
  PDI_Customers_Clone

  Purpose : Local clone of PDI customer master records. All columns stored as
            varchar(100) to preserve raw PDI values without type coercion.
  Refresh : dbo.sp_PDI_AllClones_SYNC (registered clone)
*/

IF OBJECT_ID('dbo.PDI_Customers_Clone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PDI_Customers_Clone
    (
          Cust_Key                   varchar(100)  NOT NULL
        , Cust_ID                    varchar(100)  NULL
        , Cust_Description           varchar(100)  NULL
        , Cust_Template              varchar(100)  NULL
        , Cust_Address_1             varchar(100)  NULL
        , Cust_Address_2             varchar(100)  NULL
        , Cust_Address_3             varchar(100)  NULL
        , Cust_City                  varchar(100)  NULL
        , Cust_State_Key             varchar(100)  NULL
        , Cust_Postal_Code           varchar(100)  NULL
        , Cust_Speed_Dial            varchar(100)  NULL
        , Cust_Alias                 varchar(100)  NULL
        , Cust_Sort_Description      varchar(100)  NULL
        , Cust_Account_Type          varchar(100)  NULL
        , Cust_CustType_Key          varchar(100)  NULL
        , Cust_Account_Status        varchar(100)  NULL
        , Cust_Date_Opened           varchar(100)  NULL
        , Cust_Date_Closed           varchar(100)  NULL
        , Cust_Wholesale_Customer    varchar(100)  NULL
        , Cust_Retail_Customer       varchar(100)  NULL
        , Cust_CardLock_Customer     varchar(100)  NULL
        , Cust_CustClass_Key         varchar(100)  NULL
        , Cust_Tax_ID                varchar(100)  NULL
        , Cust_Company_Owned_Locs    varchar(100)  NULL
        , Sync_Dtm                   datetime2(3)  NOT NULL
        , CONSTRAINT PK_PDI_Customers_Clone
            PRIMARY KEY CLUSTERED (Cust_Key)
    );
END;
GO
