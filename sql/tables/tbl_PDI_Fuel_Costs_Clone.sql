USE [PDI_PricingLink];
GO

/*
  PDI_Fuel_Costs_Clone

  Purpose : Local clone of PDI fuel cost records (rack prices, contract costs).
            Core input for pricing pipeline calculations. Loaded via batch
            pattern (Clone_LoadDtmUtc / Clone_LoadBatchId columns).
  Refresh : dbo.sp_PDI_AllClones_SYNC (registered clone)
*/

IF OBJECT_ID('dbo.PDI_Fuel_Costs_Clone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PDI_Fuel_Costs_Clone
    (
          FuelCost_Key                decimal(15, 0)     NOT NULL
        , FuelCost_FuelCostBatch_Key  decimal(15, 0)     NULL
        , FuelCost_FormulaDtl_Key     decimal(15, 0)     NULL
        , FuelCost_Vend_Key           decimal(15, 0)     NOT NULL
        , FuelCost_Trmnl_Key          decimal(15, 0)     NOT NULL
        , FuelCost_Prod_Key           decimal(15, 0)     NOT NULL
        , FuelCost_FuelContDtl_Key    decimal(15, 0)     NULL
        , FuelCost_Eff_Datetime       smalldatetime      NOT NULL
        , FuelCost_Expires            smallint           NOT NULL
        , FuelCost_Exp_Datetime       smalldatetime      NULL
        , FuelCost_Cost               decimal(15, 7)     NOT NULL
        , FuelCost_Billing_Units      tinyint            NOT NULL
        , FuelCost_Source_FuelCost_Key decimal(15, 0)   NULL
        , FuelCost_Used_By_Formula    smallint           NOT NULL
        , ts                          rowversion         NOT NULL
        , Clone_LoadDtmUtc            datetime2(3)       NOT NULL
        , Clone_LoadBatchId           uniqueidentifier   NOT NULL
        , CONSTRAINT PK_Fuel_Costs_Clone
            PRIMARY KEY CLUSTERED (FuelCost_Key)
    );
END;
GO
