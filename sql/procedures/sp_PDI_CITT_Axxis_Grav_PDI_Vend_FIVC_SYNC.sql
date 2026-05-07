USE [PDI_PricingLink];
GO

/*
  sp_PDI_CITT_Axxis_Grav_PDI_Vend_FIVC_SYNC

  Purpose : Full-replace sync of dbo.PDI_CITT_Axxis_Grav_PDI_Vend_FIVC_Clone from
            CitySV CITT Axxis FIVC vendor integration source.

  Called by : dbo.sp_PDI_AllClones_SYNC
  Frequency : Each AllClones_SYNC run.
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_CITT_Axxis_Grav_PDI_Vend_FIVC_SYNC
    @Debug bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;
    DECLARE @SyncDtm datetime2(3) = SYSUTCDATETIME();

    BEGIN TRY
        IF @Debug = 1
            SELECT 'Starting sync: dbo.PDI_CITT_Axxis_Grav_PDI_Vend_FIVC_Clone' AS Msg, @SyncDtm AS UtcDtm;

        TRUNCATE TABLE dbo.PDI_CITT_Axxis_Grav_PDI_Vend_FIVC_Clone;

        INSERT dbo.PDI_CITT_Axxis_Grav_PDI_Vend_FIVC_Clone
        (
              Vend_Key
            , Vend_ID
            , Vend_Description
            , Sync_Dtm
        )
        SELECT
              CONVERT(int, V.Vend_Key)
            , CONVERT(varchar(10), V.Vend_ID)
            , CONVERT(varchar(100), V.Vend_Description)
            , @SyncDtm
        FROM [PDI-SQL-01].PDICompany_2386_01.dbo.Vendors AS V
        WHERE V.Vend_Key IS NOT NULL;

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT 'Completed sync: dbo.PDI_CITT_Axxis_Grav_PDI_Vend_FIVC_Clone' AS Msg, @Rows AS [Rows], @SyncDtm AS UtcDtm;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @Debug = 1
            SELECT CONCAT('sp_PDI_CITT_Axxis_Grav_PDI_Vend_FIVC_SYNC failed. Error ', ERROR_NUMBER(), ', Line ', ERROR_LINE(), ': ', ERROR_MESSAGE()) AS ErrorMessage;

        THROW;
    END CATCH
END;
GO
