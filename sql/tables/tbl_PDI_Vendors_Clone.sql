USE [PDI_PricingLink];
GO

/*
  PDI_Vendors_Clone

  Purpose : Local clone of PDICompany Vendors with class/type attributes
            needed by carrier-name translation and OD import rendering.
  Refresh : dbo.sp_PDI_Vendors_Clone_SYNC
*/

IF OBJECT_ID('dbo.PDI_Vendors_Clone','U') IS NULL
BEGIN
    CREATE TABLE dbo.PDI_Vendors_Clone
    (
          Vend_Key               int             NOT NULL
        , Vend_ID                varchar(50)     NULL
        , Vend_Description       varchar(200)    NULL
        , Vend_Alt_Description   varchar(200)    NULL
        , Vend_Class_Key         tinyint         NULL
        , Vend_Class_ID          varchar(15)     NULL
        , Vend_VendType_Key      decimal(15, 0)  NULL
        , Vend_Type_Description  varchar(20)     NULL
        , Vend_On_Hold           smallint        NULL
        , Vend_Deactivated       smallint        NULL
        , Sync_Dtm               datetime2(3)    NOT NULL
        , CONSTRAINT PK_PDI_Vendors_Clone PRIMARY KEY CLUSTERED (Vend_Key)
    );
END;
GO

IF COL_LENGTH('dbo.PDI_Vendors_Clone', 'Vend_Class_Key') IS NULL
    ALTER TABLE dbo.PDI_Vendors_Clone ADD Vend_Class_Key tinyint NULL;
GO

IF COL_LENGTH('dbo.PDI_Vendors_Clone', 'Vend_Class_ID') IS NULL
    ALTER TABLE dbo.PDI_Vendors_Clone ADD Vend_Class_ID varchar(15) NULL;
GO

IF COL_LENGTH('dbo.PDI_Vendors_Clone', 'Vend_VendType_Key') IS NULL
    ALTER TABLE dbo.PDI_Vendors_Clone ADD Vend_VendType_Key decimal(15, 0) NULL;
GO

IF COL_LENGTH('dbo.PDI_Vendors_Clone', 'Vend_Type_Description') IS NULL
    ALTER TABLE dbo.PDI_Vendors_Clone ADD Vend_Type_Description varchar(20) NULL;
GO

IF COL_LENGTH('dbo.PDI_Vendors_Clone', 'Vend_On_Hold') IS NULL
    ALTER TABLE dbo.PDI_Vendors_Clone ADD Vend_On_Hold smallint NULL;
GO

IF COL_LENGTH('dbo.PDI_Vendors_Clone', 'Vend_Deactivated') IS NULL
    ALTER TABLE dbo.PDI_Vendors_Clone ADD Vend_Deactivated smallint NULL;
GO
