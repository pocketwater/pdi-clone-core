USE [PDI_PricingLink];
GO

/*
  PDI_Products_Clone

  Purpose : Local clone of PDI product master records including critical
            description and report group classifications.
  Refresh : dbo.sp_PDI_AllClones_SYNC (registered clone)
*/

IF OBJECT_ID('dbo.PDI_Products_Clone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PDI_Products_Clone
    (
          Prod_ID               varchar(50)   NOT NULL
        , Prod_Description      varchar(255)  NULL
        , CritDesc_ID           varchar(50)   NULL
        , CritDesc_Description  varchar(255)  NULL
        , Prod_Key              int           NOT NULL
        , ProdRptGrp_Description varchar(255) NULL
        , ProdRptGrp_Key        int           NULL
        , ProdRptGrp_Type       int           NULL
        , Prod_Sort_Description varchar(255)  NULL
        , Prod_Blended          bit           NULL
        , Prod_CritDesc_Key     int           NULL
        , Sync_Dtm              datetime2(0)  NOT NULL
        , CONSTRAINT PK_PDI_Products_Clone
            PRIMARY KEY CLUSTERED (Prod_Key)
    );
END;
GO
