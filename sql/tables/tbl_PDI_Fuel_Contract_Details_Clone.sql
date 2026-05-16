USE [PDI_PricingLink];
GO

/*
  PDI_Fuel_Contract_Details_Clone

  Purpose : Local clone of PDI fuel contract detail rows.
            Includes detail-level attributes used by downstream
            pricing lineage and contract resolution diagnostics.
  Refresh : dbo.sp_PDI_Fuel_Contract_Details_Clone_SYNC (called by sp_PDI_AllClones_SYNC)
*/

IF OBJECT_ID('dbo.PDI_Fuel_Contract_Details_Clone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PDI_Fuel_Contract_Details_Clone
    (
          FuelContDtl_Key                     decimal(15, 0) NOT NULL
        , FuelContDtl_FuelCont_Key            decimal(15, 0) NOT NULL
        , FuelContDtl_Eff_Datetime            smalldatetime  NOT NULL
        , FuelContDtl_Expires                 smallint       NOT NULL
        , FuelContDtl_Exp_Datetime            smalldatetime  NULL
        , FuelContDtl_Loading_No              varchar(20)    NULL
        , FuelContDtl_Status                  tinyint        NOT NULL
        , FuelContDtl_Closed_Datetime         smalldatetime  NULL
        , FuelContDtl_Default_Cost            smallint       NOT NULL
        , FuelContDtl_Preferred               tinyint        NOT NULL
        , FuelContDtl_Apply_To_Alloc          smallint       NOT NULL
        , FuelContDtl_Def_To_Rack_Cost        smallint       NOT NULL
        , FuelContDtl_All_Terminals           smallint       NOT NULL
        , FuelContDtl_All_Products            smallint       NOT NULL
        , FuelContDtl_All_Sites               smallint       NOT NULL
        , FuelContDtl_All_CustLocs            smallint       NOT NULL
        , FuelContDtl_Based_On_Units          tinyint        NOT NULL
        , FuelContDtl_AutoCalc_Costs          smallint       NOT NULL
        , FuelContDtl_AutoCalc_Method         tinyint        NOT NULL
        , FuelContDtl_AutoCalc_Based_On       tinyint        NOT NULL
        , FuelContDtl_AutoCalc_VaryByProd     smallint       NOT NULL
        , FuelContDtl_AutoCalc_Amt            decimal(15, 7) NOT NULL
        , FuelContDtl_AutoCalc_Vend_Key       decimal(15, 0) NULL
        , FuelContDtl_AutoCalc_Trmnl_Key      decimal(15, 0) NULL
        , FuelContDtl_AutoCalc_FuelFormula_Key decimal(15, 0) NULL
        , FuelContDtl_AutoCalc_FormulaGrp_Key decimal(15, 0) NULL
        , FuelContDtl_AutoCalc_FormulaProd_Key decimal(15, 0) NULL
        , FuelContDtl_Notes                   varchar(4000)  NULL
        , FuelContDtl_UseFuelGroups           smallint       NOT NULL
        , FuelContDtl_FormulaGrp_Key          decimal(15, 0) NULL
        , ts                                  rowversion     NULL
        , Sync_Dtm                            datetime2(3)   NOT NULL
        , CONSTRAINT PK_PDI_Fuel_Contract_Details_Clone
            PRIMARY KEY CLUSTERED (FuelContDtl_Key)
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_PDI_Fuel_Contract_Details_Clone_FuelCont_Key'
      AND object_id = OBJECT_ID('dbo.PDI_Fuel_Contract_Details_Clone')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_PDI_Fuel_Contract_Details_Clone_FuelCont_Key
        ON dbo.PDI_Fuel_Contract_Details_Clone (FuelContDtl_FuelCont_Key);
END;
GO
