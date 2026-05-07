USE [PDI_PricingLink];
GO

/*
  sp_PDI_Fuel_Costs_Clone_SYNC_CatchUp

  Purpose : Incremental catch-up sync for Fuel_Costs_Clone.
            Syncs only records modified after the last full sync run.
            Used for operational recovery between scheduled runs.

  Called by : Manual execution (diagnostic), maintenance routines
  Frequency : On-demand or per operational runbook.
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_Fuel_Costs_Clone_SYNC_CatchUp
    @Debug bit = 0,
    @WindowDays int = 7
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;
    DECLARE @SyncDtm datetime2(3) = SYSUTCDATETIME();
    DECLARE @WindowStart datetime2 = DATEADD(day, -@WindowDays, CAST(@SyncDtm AS date));

    BEGIN TRY
        IF @Debug = 1
            SELECT 'Starting catch-up sync: dbo.PDI_Fuel_Costs_Clone' AS Msg, @SyncDtm AS UtcDtm, @WindowStart AS WindowStart;

        -- Upsert logic: insert new or update modified records within window
        MERGE dbo.PDI_Fuel_Costs_Clone AS target
        USING (
            SELECT
                  CONVERT(int, FC.Fuel_Cost_Key) AS Fuel_Cost_Key
                , CONVERT(int, FC.Fuel_Trmnl_Key) AS Fuel_Trmnl_Key
                , CONVERT(datetime2(3), FC.Fuel_Cost_EffectiveDate) AS Fuel_Cost_EffectiveDate
                , CONVERT(decimal(10, 4), FC.Fuel_Cost_Amount) AS Fuel_Cost_Amount
                , @SyncDtm AS Sync_Dtm
            FROM [PDI-SQL-01].PDICompany_2386_01.dbo.Fuel_Costs AS FC
            WHERE FC.Fuel_Cost_Key IS NOT NULL
              AND FC.Fuel_Cost_EffectiveDate >= @WindowStart
        ) AS source
        ON target.Fuel_Cost_Key = source.Fuel_Cost_Key
        WHEN MATCHED THEN
            UPDATE SET
                  Fuel_Trmnl_Key = source.Fuel_Trmnl_Key
                , Fuel_Cost_EffectiveDate = source.Fuel_Cost_EffectiveDate
                , Fuel_Cost_Amount = source.Fuel_Cost_Amount
                , Sync_Dtm = source.Sync_Dtm
        WHEN NOT MATCHED THEN
            INSERT (Fuel_Cost_Key, Fuel_Trmnl_Key, Fuel_Cost_EffectiveDate, Fuel_Cost_Amount, Sync_Dtm)
            VALUES (source.Fuel_Cost_Key, source.Fuel_Trmnl_Key, source.Fuel_Cost_EffectiveDate, source.Fuel_Cost_Amount, source.Sync_Dtm);

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT 'Completed catch-up sync: dbo.PDI_Fuel_Costs_Clone' AS Msg, @Rows AS [RowsAffected], @SyncDtm AS UtcDtm;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @Debug = 1
            SELECT CONCAT('sp_PDI_Fuel_Costs_Clone_SYNC_CatchUp failed. Error ', ERROR_NUMBER(), ', Line ', ERROR_LINE(), ': ', ERROR_MESSAGE()) AS ErrorMessage;

        THROW;
    END CATCH
END;
GO
