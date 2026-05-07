USE [PDI_PricingLink];
GO

/*
  sp_PDI_SI_Users_SYNC

  Purpose : Full-replace sync of dbo.PDI_SI_Users_Clone from
            [PDI-SQL-01].PDICompany_2386_01.dbo.SI_Users_GVW.

  Called by : dbo.sp_PDI_AllClones_SYNC
  Frequency : Each AllClones_SYNC run (i.e. at the top of every import pipeline).
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_SI_Users_SYNC
    @Debug bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;
    DECLARE @SyncDtm datetime2(3) = SYSUTCDATETIME();

    BEGIN TRY
        IF @Debug = 1
            SELECT 'Starting sync: dbo.PDI_SI_Users_Clone' AS Msg, @SyncDtm AS UtcDtm;

        TRUNCATE TABLE dbo.PDI_SI_Users_Clone;

        INSERT dbo.PDI_SI_Users_Clone
        (
              User_Key
            , User_ID
            , Clone_Load_Dtm
            , Clone_Source
            , Sync_Dtm
        )
        SELECT
              CONVERT(decimal(15, 0), U.User_Key)
            , NULLIF(LTRIM(RTRIM(CONVERT(varchar(50), U.User_ID))), '')
            , @SyncDtm
            , '[PDI-SQL-01].PDICompany_2386_01.dbo.SI_Users_GVW'
            , @SyncDtm
        FROM [PDI-SQL-01].PDICompany_2386_01.dbo.SI_Users_GVW AS U
        WHERE U.User_Key IS NOT NULL;

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT 'Completed sync: dbo.PDI_SI_Users_Clone' AS Msg, @Rows AS [Rows], @SyncDtm AS UtcDtm;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @Debug = 1
            SELECT CONCAT('sp_PDI_SI_Users_SYNC failed. Error ', ERROR_NUMBER(), ', Line ', ERROR_LINE(), ': ', ERROR_MESSAGE()) AS ErrorMessage;

        THROW;
    END CATCH
END;
GO
