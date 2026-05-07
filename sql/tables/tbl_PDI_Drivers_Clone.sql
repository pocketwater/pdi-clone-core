USE [PDI_PricingLink];
GO

/*
  PDI_Drivers_Clone

  Purpose : Local clone of PDI driver records. Loaded via bulk insert pattern
            (Clone_Load_Dtm / Clone_Source columns, no Sync_Dtm).
  Refresh : dbo.sp_PDI_AllClones_SYNC (registered clone)
*/

IF OBJECT_ID('dbo.PDI_Drivers_Clone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PDI_Drivers_Clone
    (
          Driver_Key       decimal(15, 0)  NOT NULL
        , Driver_ID        varchar(10)     NOT NULL
        , Driver_Name      varchar(40)     NOT NULL
        , Driver_Vend_Key  decimal(15, 0)  NOT NULL
        , ts               rowversion      NULL
        , Clone_Load_Dtm   datetime2(3)    NOT NULL
        , Clone_Source     varchar(128)    NOT NULL
        , Sync_Dtm         datetime2(3)    NOT NULL
            CONSTRAINT DF_PDI_Drivers_Clone_Sync DEFAULT (SYSUTCDATETIME())
        , CONSTRAINT PK_PDI_Drivers_Clone
            PRIMARY KEY CLUSTERED (Driver_Key)
    );
END;
GO
