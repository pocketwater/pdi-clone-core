USE [PDI_PricingLink];
GO

/*
  PDI_Terminals_Clone

  Purpose : Local clone of PDI terminal (rack/bulk plant) records with group,
            report group, and address attributes. Used by pricing and OD import
            views for terminal name resolution.
  Refresh : dbo.sp_PDI_AllClones_SYNC (registered clone)
*/

IF OBJECT_ID('dbo.PDI_Terminals_Clone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PDI_Terminals_Clone
    (
          Trmnl_ID                varchar(50)   NOT NULL
        , Trmnl_Description       varchar(255)  NULL
        , TrmnlGrp_Description    varchar(255)  NULL
        , TrmnlRptGrp_Description varchar(255)  NULL
        , Trmnl_DTN_Trmnl_Owner   varchar(255)  NULL
        , Trmnl_Key               int           NOT NULL
        , Trmnl_Active            bit           NOT NULL
        , Sync_Dtm                datetime2(0)  NOT NULL
        , Trmnl_Address_1         varchar(255)  NULL
        , Trmnl_Address_2         varchar(255)  NULL
        , Trmnl_Address_3         varchar(255)  NULL
        , Trmnl_City              varchar(100)  NULL
        , Trmnl_State_Code        varchar(10)   NULL
        , Trmnl_Postal_Code       varchar(20)   NULL
        , Trmnl_Mailing_Address   varchar(800)  NULL
        , CONSTRAINT PK_PDI_Terminals_Clone
            PRIMARY KEY CLUSTERED (Trmnl_Key)
    );
END;
GO
