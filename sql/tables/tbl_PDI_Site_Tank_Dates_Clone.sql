USE [PDI_PricingLink];
GO

/*
  PDI_Site_Tank_Dates_Clone

  Purpose : Minimal clone of PDI Site_Tank_Dates records. Provides the
            site-to-tank-date mapping key needed by the PE-021 pre-export
            site tank validation check in the Gravitate export pipeline.

  Columns : Only the columns required for pipeline join resolution are included.
            SiteTankDate_Key → joins to Site_Tank_Details (SiteTankDtl_Date_Key).
            SiteTankDate_Site_Key → joins to PDI_Sites_Clone (Site_Key).

  Refresh : dbo.sp_PDI_Site_Tank_Dates_Clone_SYNC (called by sp_PDI_AllClones_SYNC)
  Consumer: Invoke-PDI_ODE_Gravitate_Export.ps1 PE-021 pre-export blocker query
*/

IF OBJECT_ID('dbo.PDI_Site_Tank_Dates_Clone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PDI_Site_Tank_Dates_Clone
    (
          SiteTankDate_Key      decimal(15, 0)  NOT NULL
        , SiteTankDate_Site_Key decimal(15, 0)  NOT NULL
        , Sync_Dtm              datetime2(3)    NOT NULL
        , CONSTRAINT PK_PDI_Site_Tank_Dates_Clone
            PRIMARY KEY CLUSTERED (SiteTankDate_Key)
    );

    CREATE NONCLUSTERED INDEX IX_PDI_Site_Tank_Dates_Clone_Site_Key
        ON dbo.PDI_Site_Tank_Dates_Clone (SiteTankDate_Site_Key);
END;
GO
