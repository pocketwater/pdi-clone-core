USE [PDI_PricingLink];
GO

/*
  PDI_Site_Tank_Details_Clone

  Purpose : Minimal clone of PDI Site_Tank_Details records. Provides the
            tank-to-product mapping needed by the PE-021 pre-export site
            tank validation check in the Gravitate export pipeline.

  Columns : Only the columns required for pipeline join resolution are included.
            SiteTankDtl_Key     → IS NULL check (missing tank detail = exclusion trigger)
            SiteTankDtl_Date_Key → joins to PDI_Site_Tank_Dates_Clone (SiteTankDate_Key)
            SiteTankDtl_Tank_No → matches Destination_Tank_No from export scope
            SiteTankDtl_Prod_Key → joins to PDI_Products_Clone (Prod_Key)

  Refresh : dbo.sp_PDI_Site_Tank_Details_Clone_SYNC (called by sp_PDI_AllClones_SYNC,
            after Site_Tank_Dates step)
  Consumer: Invoke-PDI_ODE_Gravitate_Export.ps1 PE-021 pre-export blocker query
*/

IF OBJECT_ID('dbo.PDI_Site_Tank_Details_Clone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PDI_Site_Tank_Details_Clone
    (
          SiteTankDtl_Key      decimal(15, 0)  NOT NULL
        , SiteTankDtl_Date_Key decimal(15, 0)  NOT NULL
        , SiteTankDtl_Tank_No  smallint        NOT NULL
        , SiteTankDtl_Prod_Key decimal(15, 0)  NOT NULL
        , Sync_Dtm             datetime2(3)    NOT NULL
        , CONSTRAINT PK_PDI_Site_Tank_Details_Clone
            PRIMARY KEY CLUSTERED (SiteTankDtl_Key)
    );

    CREATE NONCLUSTERED INDEX IX_PDI_Site_Tank_Details_Clone_Date_Tank
        ON dbo.PDI_Site_Tank_Details_Clone (SiteTankDtl_Date_Key, SiteTankDtl_Tank_No)
        INCLUDE (SiteTankDtl_Prod_Key);
END;
GO
