CREATE   PROCEDURE dbo.sp_PDI_Vendors_Clone_SYNC
    @Debug bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;

    BEGIN TRY

        IF @Debug = 1
            SELECT
                  Msg    = 'Starting sync: dbo.PDI_Vendors_Clone'
                , UtcDtm = SYSUTCDATETIME();

        TRUNCATE TABLE dbo.PDI_Vendors_Clone;

        INSERT dbo.PDI_Vendors_Clone
        (
              Vend_Key
            , Vend_ID
            , Vend_Description
            , Vend_Alt_Description
            , Sync_Dtm
        )
        SELECT
              V.Vend_Key
            , V.Vend_ID
            , V.Vend_Description
            , V.Vend_Alt_Description
            , SYSUTCDATETIME() AS Sync_Dtm
        FROM [PDI-SQL-01].[PDICompany_2386_01].[dbo].[Vendors] AS V;

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT
                  Msg    = 'Completed sync: dbo.PDI_Vendors_Clone'
                , [Rows] = @Rows
                , UtcDtm = SYSUTCDATETIME();

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END


