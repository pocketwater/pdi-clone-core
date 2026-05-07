USE [PDI_PricingLink];
GO

/*
  sp_PDI_Terminals_SYNC

  Purpose : Full-replace sync of dbo.PDI_Terminals_Clone from
            [PDI-SQL-01].PDICompany_2386_01.dbo.Terminals.

  Called by : dbo.sp_PDI_AllClones_SYNC
  Frequency : Each AllClones_SYNC run.
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_Terminals_SYNC
    @Debug bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;
    DECLARE @SyncDtm datetime2(3) = SYSUTCDATETIME();

    BEGIN TRY
        IF @Debug = 1
            SELECT 'Starting sync: dbo.PDI_Terminals_Clone' AS Msg, @SyncDtm AS UtcDtm;

        TRUNCATE TABLE dbo.PDI_Terminals_Clone;

        INSERT dbo.PDI_Terminals_Clone
        (
              Trmnl_Key
            , Trmnl_ID
            , Trmnl_Description
            , Sync_Dtm
        )
        SELECT
              CONVERT(int, T.Trmnl_Key)
            , CONVERT(varchar(10), T.Trmnl_ID)
            , CONVERT(varchar(100), T.Trmnl_Description)
            , @SyncDtm
        FROM [PDI-SQL-01].PDICompany_2386_01.dbo.Terminals AS T
        WHERE T.Trmnl_Key IS NOT NULL;

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT 'Completed sync: dbo.PDI_Terminals_Clone' AS Msg, @Rows AS [Rows], @SyncDtm AS UtcDtm;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @Debug = 1
            SELECT CONCAT('sp_PDI_Terminals_SYNC failed. Error ', ERROR_NUMBER(), ', Line ', ERROR_LINE(), ': ', ERROR_MESSAGE()) AS ErrorMessage;

        THROW;
    END CATCH
END;
GO
