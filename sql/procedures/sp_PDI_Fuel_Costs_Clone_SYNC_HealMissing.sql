USE [PDI_PricingLink];
GO

/*
  sp_PDI_Fuel_Costs_Clone_SYNC_HealMissing

  Purpose : Healing sync to backfill any missing Fuel_Costs records
            within a recent window. Used to recover from sync failures
            or operational gaps.

  Called by : Manual execution (diagnostic), maintenance routines
  Frequency : On-demand per operational runbook.
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_Fuel_Costs_Clone_SYNC_HealMissing
    @Debug bit = 0,
    @WindowDays int = 30
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;
    DECLARE @SyncDtm datetime2(3) = SYSUTCDATETIME();
    DECLARE @WindowStart datetime2 = DATEADD(day, -@WindowDays, CAST(@SyncDtm AS date));

    BEGIN TRY
        IF @Debug = 1
            SELECT 'Starting heal-missing sync: dbo.PDI_Fuel_Costs_Clone' AS Msg, @SyncDtm AS UtcDtm, @WindowStart AS WindowStart;

        -- Insert any records from source not yet in clone within window
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
        WHERE FC.Fuel_Cost_Key IS NOT NULL
          AND FC.Fuel_Cost_EffectiveDate >= @WindowStart
          AND NOT EXISTS (
              SELECT 1 FROM dbo.PDI_Fuel_Costs_Clone AS target
              WHERE target.Fuel_Cost_Key = FC.Fuel_Cost_Key
          );

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT 'Completed heal-missing sync: dbo.PDI_Fuel_Costs_Clone' AS Msg, @Rows AS [RowsInserted], @SyncDtm AS UtcDtm;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @Debug = 1
            SELECT CONCAT('sp_PDI_Fuel_Costs_Clone_SYNC_HealMissing failed. Error ', ERROR_NUMBER(), ', Line ', ERROR_LINE(), ': ', ERROR_MESSAGE()) AS ErrorMessage;

        THROW;
    END CATCH
END;
GO
