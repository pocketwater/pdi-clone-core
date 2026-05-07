USE [PDI_PricingLink];
GO

/*
  sp_PDI_Fuel_Costs_Clone_SYNC_Upsert

  Purpose : Upsert-based incremental sync for Fuel_Costs_Clone.
            Merges all current records from source, inserting new and updating changed ones.
            Standard idempotent pattern for operational recovery.

  Called by : Manual execution (diagnostic), maintenance routines
  Frequency : On-demand per operational runbook.
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_Fuel_Costs_Clone_SYNC_Upsert
    @Debug bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;
    DECLARE @SyncDtm datetime2(3) = SYSUTCDATETIME();

    BEGIN TRY
        IF @Debug = 1
            SELECT 'Starting upsert sync: dbo.PDI_Fuel_Costs_Clone' AS Msg, @SyncDtm AS UtcDtm;

        -- Upsert all current records from source
        MERGE dbo.PDI_Fuel_Costs_Clone AS target
        USING (
            SELECT
                  CONVERT(int, FC.Fuel_Cost_Key) AS Fuel_Cost_Key
                , CONVERT(int, FC.Fuel_Trmnl_Key) AS Fuel_Trmnl_Key
                , CONVERT(datetime2(3), FC.Fuel_Cost_EffectiveDate) AS Fuel_Cost_EffectiveDate
                , CONVERT(decimal(10, 4), FC.Fuel_Cost_Amount) AS Fuel_Cost_Amount
            FROM [PDI-SQL-01].PDICompany_2386_01.dbo.Fuel_Costs AS FC
            WHERE FC.Fuel_Cost_Key IS NOT NULL
        ) AS source
        ON target.Fuel_Cost_Key = source.Fuel_Cost_Key
        WHEN MATCHED THEN
            UPDATE SET
                  Fuel_Trmnl_Key = source.Fuel_Trmnl_Key
                , Fuel_Cost_EffectiveDate = source.Fuel_Cost_EffectiveDate
                , Fuel_Cost_Amount = source.Fuel_Cost_Amount
                , Sync_Dtm = @SyncDtm
        WHEN NOT MATCHED THEN
            INSERT (Fuel_Cost_Key, Fuel_Trmnl_Key, Fuel_Cost_EffectiveDate, Fuel_Cost_Amount, Sync_Dtm)
            VALUES (source.Fuel_Cost_Key, source.Fuel_Trmnl_Key, source.Fuel_Cost_EffectiveDate, source.Fuel_Cost_Amount, @SyncDtm);

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT 'Completed upsert sync: dbo.PDI_Fuel_Costs_Clone' AS Msg, @Rows AS [RowsAffected], @SyncDtm AS UtcDtm;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @Debug = 1
            SELECT CONCAT('sp_PDI_Fuel_Costs_Clone_SYNC_Upsert failed. Error ', ERROR_NUMBER(), ', Line ', ERROR_LINE(), ': ', ERROR_MESSAGE()) AS ErrorMessage;

        THROW;
    END CATCH
END;
GO
