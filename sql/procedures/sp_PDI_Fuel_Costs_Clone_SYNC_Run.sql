USE [PDI_PricingLink];
GO

/*
  sp_PDI_Fuel_Costs_Clone_SYNC_Run

  Purpose : Standard full-replace sync of dbo.PDI_Fuel_Costs_Clone from
            [PDI-SQL-01].PDICompany_2386_01.dbo.Fuel_Costs.
            Entry point for scheduled AllClones_SYNC runs.

  Called by : dbo.sp_PDI_AllClones_SYNC (primary), manual execution (diagnostic)
  Frequency : Each AllClones_SYNC run.
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_Fuel_Costs_Clone_SYNC_Run
    @Debug bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;
    DECLARE @SyncDtm datetime2(3) = SYSUTCDATETIME();

    BEGIN TRY
        IF @Debug = 1
            SELECT 'Starting full sync: dbo.PDI_Fuel_Costs_Clone' AS Msg, @SyncDtm AS UtcDtm;

        TRUNCATE TABLE dbo.PDI_Fuel_Costs_Clone;

        INSERT dbo.PDI_Fuel_Costs_Clone
        (
              Fuel_Cost_Key
            , Fuel_Trmnl_Key
            , Fuel_Cost_EffectiveDate
            , Fuel_Cost_Amount
            , Sync_Dtm
        )
        SELECT
              CONVERT(int, FC.Fuel_Cost_Key)
            , CONVERT(int, FC.Fuel_Trmnl_Key)
            , CONVERT(datetime2(3), FC.Fuel_Cost_EffectiveDate)
            , CONVERT(decimal(10, 4), FC.Fuel_Cost_Amount)
            , @SyncDtm
        FROM [PDI-SQL-01].PDICompany_2386_01.dbo.Fuel_Costs AS FC
        WHERE FC.Fuel_Cost_Key IS NOT NULL;

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT 'Completed full sync: dbo.PDI_Fuel_Costs_Clone' AS Msg, @Rows AS [Rows], @SyncDtm AS UtcDtm;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @Debug = 1
            SELECT CONCAT('sp_PDI_Fuel_Costs_Clone_SYNC_Run failed. Error ', ERROR_NUMBER(), ', Line ', ERROR_LINE(), ': ', ERROR_MESSAGE()) AS ErrorMessage;

        THROW;
    END CATCH
END;
GO
