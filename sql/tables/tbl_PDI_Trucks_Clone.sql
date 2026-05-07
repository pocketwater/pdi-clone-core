USE [PDI_PricingLink];
GO

/*
  PDI_Trucks_Clone

  Purpose : Local clone of PDI vehicle/truck master records. Loaded via bulk
            insert pattern (Clone_Load_Dtm / Clone_Source columns).
  Refresh : dbo.sp_PDI_AllClones_SYNC (registered clone)
*/

IF OBJECT_ID('dbo.PDI_Trucks_Clone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PDI_Trucks_Clone
    (
          Vehicle_Key              decimal(15, 0)  NOT NULL
        , Vehicle_ID               varchar(15)     NOT NULL
        , Vehicle_Description      varchar(30)     NOT NULL
        , Vehicle_Vend_Key         decimal(15, 0)  NOT NULL
        , Vehicle_VehicleType_Key  decimal(15, 0)  NULL
        , Vehicle_EquipmentType_Key decimal(15, 0) NULL
        , Vehicle_ProfitSite_Key   decimal(15, 0)  NULL
        , ts                       rowversion      NULL
        , Clone_Load_Dtm           datetime2(3)    NOT NULL
        , Clone_Source             varchar(128)    NOT NULL
        , Sync_Dtm                 datetime2(3)    NOT NULL
            CONSTRAINT DF_PDI_Trucks_Clone_Sync DEFAULT (SYSUTCDATETIME())
        , CONSTRAINT PK_PDI_Trucks_Clone
            PRIMARY KEY CLUSTERED (Vehicle_Key)
    );
END;
GO
