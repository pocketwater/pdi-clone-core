USE [PDI_PricingLink];
GO

/*
  sp_PDI_Fuel_Contract_Details_Clone_SYNC

  Purpose : Full-replace sync of dbo.PDI_Fuel_Contract_Details_Clone from
            [PDI-SQL-01].PDICompany_2386_01.dbo.Fuel_Contract_Details.

  Called by : dbo.sp_PDI_AllClones_SYNC
  Frequency : Each AllClones_SYNC run.
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_Fuel_Contract_Details_Clone_SYNC
    @Debug bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;
    DECLARE @SyncDtm datetime2(3) = SYSUTCDATETIME();

    BEGIN TRY
        IF @Debug = 1
            SELECT 'Starting sync: dbo.PDI_Fuel_Contract_Details_Clone' AS Msg, @SyncDtm AS UtcDtm;

        TRUNCATE TABLE dbo.PDI_Fuel_Contract_Details_Clone;

        INSERT dbo.PDI_Fuel_Contract_Details_Clone
        (
              FuelContDtl_Key
            , FuelContDtl_FuelCont_Key
            , FuelContDtl_Eff_Datetime
            , FuelContDtl_Expires
            , FuelContDtl_Exp_Datetime
            , FuelContDtl_Loading_No
            , FuelContDtl_Status
            , FuelContDtl_Closed_Datetime
            , FuelContDtl_Default_Cost
            , FuelContDtl_Preferred
            , FuelContDtl_Apply_To_Alloc
            , FuelContDtl_Def_To_Rack_Cost
            , FuelContDtl_All_Terminals
            , FuelContDtl_All_Products
            , FuelContDtl_All_Sites
            , FuelContDtl_All_CustLocs
            , FuelContDtl_Based_On_Units
            , FuelContDtl_AutoCalc_Costs
            , FuelContDtl_AutoCalc_Method
            , FuelContDtl_AutoCalc_Based_On
            , FuelContDtl_AutoCalc_VaryByProd
            , FuelContDtl_AutoCalc_Amt
            , FuelContDtl_AutoCalc_Vend_Key
            , FuelContDtl_AutoCalc_Trmnl_Key
            , FuelContDtl_AutoCalc_FuelFormula_Key
            , FuelContDtl_AutoCalc_FormulaGrp_Key
            , FuelContDtl_AutoCalc_FormulaProd_Key
            , FuelContDtl_Notes
            , FuelContDtl_UseFuelGroups
            , FuelContDtl_FormulaGrp_Key
            , Sync_Dtm
        )
        SELECT
              CONVERT(decimal(15, 0), FCD.FuelContDtl_Key)
            , CONVERT(decimal(15, 0), FCD.FuelContDtl_FuelCont_Key)
            , FCD.FuelContDtl_Eff_Datetime
            , CONVERT(smallint, FCD.FuelContDtl_Expires)
            , FCD.FuelContDtl_Exp_Datetime
            , CONVERT(varchar(20), FCD.FuelContDtl_Loading_No)
            , CONVERT(tinyint, FCD.FuelContDtl_Status)
            , FCD.FuelContDtl_Closed_Datetime
            , CONVERT(smallint, FCD.FuelContDtl_Default_Cost)
            , CONVERT(tinyint, FCD.FuelContDtl_Preferred)
            , CONVERT(smallint, FCD.FuelContDtl_Apply_To_Alloc)
            , CONVERT(smallint, FCD.FuelContDtl_Def_To_Rack_Cost)
            , CONVERT(smallint, FCD.FuelContDtl_All_Terminals)
            , CONVERT(smallint, FCD.FuelContDtl_All_Products)
            , CONVERT(smallint, FCD.FuelContDtl_All_Sites)
            , CONVERT(smallint, FCD.FuelContDtl_All_CustLocs)
            , CONVERT(tinyint, FCD.FuelContDtl_Based_On_Units)
            , CONVERT(smallint, FCD.FuelContDtl_AutoCalc_Costs)
            , CONVERT(tinyint, FCD.FuelContDtl_AutoCalc_Method)
            , CONVERT(tinyint, FCD.FuelContDtl_AutoCalc_Based_On)
            , CONVERT(smallint, FCD.FuelContDtl_AutoCalc_VaryByProd)
            , CONVERT(decimal(15, 7), FCD.FuelContDtl_AutoCalc_Amt)
            , CONVERT(decimal(15, 0), FCD.FuelContDtl_AutoCalc_Vend_Key)
            , CONVERT(decimal(15, 0), FCD.FuelContDtl_AutoCalc_Trmnl_Key)
            , CONVERT(decimal(15, 0), FCD.FuelContDtl_AutoCalc_FuelFormula_Key)
            , CONVERT(decimal(15, 0), FCD.FuelContDtl_AutoCalc_FormulaGrp_Key)
            , CONVERT(decimal(15, 0), FCD.FuelContDtl_AutoCalc_FormulaProd_Key)
            , CONVERT(varchar(4000), FCD.FuelContDtl_Notes)
            , CONVERT(smallint, FCD.FuelContDtl_UseFuelGroups)
            , CONVERT(decimal(15, 0), FCD.FuelContDtl_FormulaGrp_Key)
            , @SyncDtm
        FROM [PDI-SQL-01].PDICompany_2386_01.dbo.Fuel_Contract_Details AS FCD
        WHERE FCD.FuelContDtl_Key IS NOT NULL;

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT 'Completed sync: dbo.PDI_Fuel_Contract_Details_Clone' AS Msg, @Rows AS [Rows], @SyncDtm AS UtcDtm;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @Debug = 1
            SELECT CONCAT('sp_PDI_Fuel_Contract_Details_Clone_SYNC failed. Error ', ERROR_NUMBER(), ', Line ', ERROR_LINE(), ': ', ERROR_MESSAGE()) AS ErrorMessage;

        THROW;
    END CATCH
END;
GO
