USE [PDI_PricingLink];
GO

/*
  PDI_CITT_Axxis_Grav_PDI_Terminals_Clone

  Purpose : Cross-reference clone mapping Axxis terminal names to PDI and
            Gravitate terminal identifiers via the CITT translation table.
  Refresh : dbo.sp_PDI_AllClones_SYNC (registered clone)
*/

IF OBJECT_ID('dbo.PDI_CITT_Axxis_Grav_PDI_Terminals_Clone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PDI_CITT_Axxis_Grav_PDI_Terminals_Clone
    (
          Axxis_Trmnl_Name     varchar(255)  NOT NULL
        , PDI_Trmnl_ID         varchar(50)   NULL
        , Gravitate_Trmnl_ID   varchar(255)  NULL
        , TransTable_Key       int           NOT NULL
        , TransTableDetail_Key int           NOT NULL
        , Sync_Dtm             datetime2(0)  NOT NULL
        , CONSTRAINT PK_PDI_CITT_Axxis_Grav_PDI_Terminals_Clone
            PRIMARY KEY CLUSTERED (TransTableDetail_Key)
    );
END;
GO
