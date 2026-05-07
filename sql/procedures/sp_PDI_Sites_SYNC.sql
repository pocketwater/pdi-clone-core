USE [PDI_PricingLink];
GO

/*
  sp_PDI_Sites_SYNC

  Purpose : Full-replace sync of dbo.PDI_Sites_Clone from
            [PDI-SQL-01].PDICompany_2386_01.dbo.Sites.

  Called by : dbo.sp_PDI_AllClones_SYNC
  Frequency : Each AllClones_SYNC run.
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_Sites_SYNC
    @Debug bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;
    DECLARE @LoadDtm datetime2(3) = SYSUTCDATETIME();

    BEGIN TRY
        IF @Debug = 1
            SELECT 'Starting sync: dbo.PDI_Sites_Clone' AS Msg, @LoadDtm AS UtcDtm;

        TRUNCATE TABLE dbo.PDI_Sites_Clone;

        INSERT dbo.PDI_Sites_Clone
        (
              Site_Key
            , Site_ID
            , Site_Description
            , Clone_LoadDtmUtc
        )
        SELECT
              CONVERT(int, S.Site_Key)
            , CONVERT(varchar(10), S.Site_ID)
            , CONVERT(varchar(100), S.Site_Description)
            , @LoadDtm
        FROM [PDI-SQL-01].PDICompany_2386_01.dbo.Sites AS S
        WHERE S.Site_Key IS NOT NULL;

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT 'Completed sync: dbo.PDI_Sites_Clone' AS Msg, @Rows AS [Rows], @LoadDtm AS UtcDtm;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @Debug = 1
            SELECT CONCAT('sp_PDI_Sites_SYNC failed. Error ', ERROR_NUMBER(), ', Line ', ERROR_LINE(), ': ', ERROR_MESSAGE()) AS ErrorMessage;

        THROW;
    END CATCH
END;
GO
