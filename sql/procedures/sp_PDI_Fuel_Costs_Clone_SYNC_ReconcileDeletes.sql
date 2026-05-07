USE [PDI_PricingLink];
GO

/*
  sp_PDI_Fuel_Costs_Clone_SYNC_ReconcileDeletes

  Purpose : Reconciliation sync to remove Fuel_Costs_Clone records
            that no longer exist in source PDI system.
            Compares keys and removes orphaned rows.

  Called by : Manual execution (diagnostic), maintenance routines
  Frequency : Periodic reconciliation per operational runbook.
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_Fuel_Costs_Clone_SYNC_ReconcileDeletes
    @Debug bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;

    BEGIN TRY
        IF @Debug = 1
            SELECT 'Starting reconcile-deletes sync: dbo.PDI_Fuel_Costs_Clone' AS Msg, SYSUTCDATETIME() AS UtcDtm;

        -- Remove orphaned records: keys in clone but not in source
        DELETE FROM dbo.PDI_Fuel_Costs_Clone
        WHERE NOT EXISTS (
            SELECT 1 FROM [PDI-SQL-01].PDICompany_2386_01.dbo.Fuel_Costs AS FC
            WHERE FC.Fuel_Cost_Key = dbo.PDI_Fuel_Costs_Clone.Fuel_Cost_Key
        );

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT 'Completed reconcile-deletes sync: dbo.PDI_Fuel_Costs_Clone' AS Msg, @Rows AS [RowsDeleted], SYSUTCDATETIME() AS UtcDtm;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @Debug = 1
            SELECT CONCAT('sp_PDI_Fuel_Costs_Clone_SYNC_ReconcileDeletes failed. Error ', ERROR_NUMBER(), ', Line ', ERROR_LINE(), ': ', ERROR_MESSAGE()) AS ErrorMessage;

        THROW;
    END CATCH
END;
GO
