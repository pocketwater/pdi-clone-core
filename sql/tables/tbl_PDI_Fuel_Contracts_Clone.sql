USE [PDI_PricingLink];
GO

/*
  PDI_Fuel_Contracts_Clone

  Purpose : Local clone of PDI fuel contract headers.
            Supports contract lineage and join paths that should not
            query SQL-01 directly from SQL-02 pipeline objects.
  Refresh : dbo.sp_PDI_Fuel_Contracts_Clone_SYNC (called by sp_PDI_AllClones_SYNC)
*/

IF OBJECT_ID('dbo.PDI_Fuel_Contracts_Clone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PDI_Fuel_Contracts_Clone
    (
          FuelCont_Key          decimal(15, 0) NOT NULL
        , FuelCont_ID           varchar(15)    NOT NULL
        , FuelCont_Type         tinyint        NOT NULL
        , FuelCont_Description  varchar(40)    NOT NULL
        , FuelCont_Inactive     smallint       NOT NULL
        , ts                    rowversion     NULL
        , Sync_Dtm              datetime2(3)   NOT NULL
        , CONSTRAINT PK_PDI_Fuel_Contracts_Clone
            PRIMARY KEY CLUSTERED (FuelCont_Key)
    );
END;
GO
