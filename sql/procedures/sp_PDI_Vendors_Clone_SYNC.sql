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
                        , Vend_Class_Key
                        , Vend_Class_ID
                        , Vend_VendType_Key
                        , Vend_Type_Description
                        , Vend_On_Hold
                        , Vend_Deactivated
            , Sync_Dtm
        )
        SELECT
                            TRY_CONVERT(int, V.Vend_Key) AS Vend_Key
            , V.Vend_ID
            , V.Vend_Description
            , V.Vend_Alt_Description
                        , V.Vend_Class AS Vend_Class_Key
                        , VC.VendClass_ID AS Vend_Class_ID
                        , V.Vend_VendType_Key
                        , VT.VendType_Description AS Vend_Type_Description
                        , V.Vend_On_Hold
                        , V.Vend_Deactivated
            , SYSUTCDATETIME() AS Sync_Dtm
                FROM [PDI-SQL-01].[PDICompany_2386_01].[dbo].[Vendors] AS V
                LEFT JOIN [PDI-SQL-01].[PDICompany_2386_01].[dbo].[Vendor_Classes] AS VC
                        ON VC.VendClass_Key = TRY_CONVERT(decimal(15, 0), V.Vend_Class)
                LEFT JOIN [PDI-SQL-01].[PDICompany_2386_01].[dbo].[Vendor_Types] AS VT
                        ON VT.VendType_Key = TRY_CONVERT(decimal(15, 0), V.Vend_VendType_Key);

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


