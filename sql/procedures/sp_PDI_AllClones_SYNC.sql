CREATE   PROCEDURE [dbo].[sp_PDI_AllClones_SYNC]
      @Debug bit = 0
    , @RunResolveHooks bit = 0
    , @ReturnTop50 bit = 0
    , @ReturnLocalTime bit = 0 -- 1 = include Pacific local time columns (debug + top50)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
          @ProcName    sysname = OBJECT_NAME(@@PROCID)
        , @Step        sysname
        , @RunGroup_ID uniqueidentifier = NEWID()
        , @Start       datetime2(3)
        , @End         datetime2(3);

    BEGIN TRY
        /* =========================
           STEP: Products
        ========================= */
        SET @Step  = N'sp_PDI_Products_SYNC';
        SET @Start = SYSUTCDATETIME();

        IF @Debug = 1
        BEGIN
            DECLARE @Utc datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'Starting sync: dbo.PDI_Products_Clone' AS Msg
                , @Utc AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@Utc AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm;
        END;

        INSERT dbo.PDI_CloneSync_RunLog (RunGroup_ID, Proc_Name, Step_Name, Start_DtmUtc, Status)
        VALUES (@RunGroup_ID, @ProcName, @Step, @Start, 'Started');

        EXEC dbo.sp_PDI_Products_SYNC @Debug = @Debug;

        IF @Debug = 1
        BEGIN
            DECLARE @Utc2 datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'Completed sync: dbo.PDI_Products_Clone' AS Msg
                , @Utc2 AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@Utc2 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm;
        END;

        SET @End = SYSUTCDATETIME();

        UPDATE dbo.PDI_CloneSync_RunLog
           SET End_DtmUtc  = @End,
               Duration_ms = DATEDIFF(ms, @Start, @End),
               Status      = 'Success'
         WHERE RunGroup_ID = @RunGroup_ID
           AND Step_Name   = @Step
           AND End_DtmUtc IS NULL;

        /* =========================
           STEP: Terminals
        ========================= */
        SET @Step  = N'sp_PDI_Terminals_SYNC';
        SET @Start = SYSUTCDATETIME();

        IF @Debug = 1
        BEGIN
            DECLARE @Utc3 datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'Starting sync: dbo.PDI_Terminals_Clone' AS Msg
                , @Utc3 AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@Utc3 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm;
        END;

        INSERT dbo.PDI_CloneSync_RunLog (RunGroup_ID, Proc_Name, Step_Name, Start_DtmUtc, Status)
        VALUES (@RunGroup_ID, @ProcName, @Step, @Start, 'Started');

        EXEC dbo.sp_PDI_Terminals_SYNC @Debug = @Debug;

        IF @Debug = 1
        BEGIN
            DECLARE @Utc4 datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'Completed sync: dbo.PDI_Terminals_Clone' AS Msg
                , @Utc4 AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@Utc4 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm;
        END;

        SET @End = SYSUTCDATETIME();

        UPDATE dbo.PDI_CloneSync_RunLog
           SET End_DtmUtc  = @End,
               Duration_ms = DATEDIFF(ms, @Start, @End),
               Status      = 'Success'
         WHERE RunGroup_ID = @RunGroup_ID
           AND Step_Name   = @Step
           AND End_DtmUtc IS NULL;

        /* =========================
           STEP: Vendors
        ========================= */
        SET @Step  = N'sp_PDI_Vendors_Clone_SYNC';
        SET @Start = SYSUTCDATETIME();

        IF @Debug = 1
        BEGIN
            DECLARE @Utc5 datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'Starting sync: dbo.PDI_Vendors_Clone' AS Msg
                , @Utc5 AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@Utc5 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm;
        END;

        INSERT dbo.PDI_CloneSync_RunLog (RunGroup_ID, Proc_Name, Step_Name, Start_DtmUtc, Status)
        VALUES (@RunGroup_ID, @ProcName, @Step, @Start, 'Started');

        EXEC dbo.sp_PDI_Vendors_Clone_SYNC @Debug = @Debug;

        IF @Debug = 1
        BEGIN
            DECLARE @Utc6 datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'Completed sync: dbo.PDI_Vendors_Clone' AS Msg
                , @Utc6 AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@Utc6 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm;
        END;

        SET @End = SYSUTCDATETIME();

        UPDATE dbo.PDI_CloneSync_RunLog
           SET End_DtmUtc  = @End,
               Duration_ms = DATEDIFF(ms, @Start, @End),
               Status      = 'Success'
         WHERE RunGroup_ID = @RunGroup_ID
           AND Step_Name   = @Step
           AND End_DtmUtc IS NULL;

        /* =========================
           STEP: FIVC Vendor
        ========================= */
        SET @Step  = N'sp_PDI_FIVC_Vendor_Clone_SYNC';
        SET @Start = SYSUTCDATETIME();

        IF @Debug = 1
        BEGIN
            DECLARE @Utc7 datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'Starting sync: dbo.PDI_FIVC_Vendor_Clone' AS Msg
                , @Utc7 AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@Utc7 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm;
        END;

        INSERT dbo.PDI_CloneSync_RunLog (RunGroup_ID, Proc_Name, Step_Name, Start_DtmUtc, Status)
        VALUES (@RunGroup_ID, @ProcName, @Step, @Start, 'Started');

        EXEC dbo.sp_PDI_FIVC_Vendor_Clone_SYNC @Debug = @Debug;

        IF @Debug = 1
        BEGIN
            DECLARE @Utc8 datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'Completed sync: dbo.PDI_FIVC_Vendor_Clone' AS Msg
                , @Utc8 AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@Utc8 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm;
        END;

        SET @End = SYSUTCDATETIME();

        UPDATE dbo.PDI_CloneSync_RunLog
           SET End_DtmUtc  = @End,
               Duration_ms = DATEDIFF(ms, @Start, @End),
               Status      = 'Success'
         WHERE RunGroup_ID = @RunGroup_ID
           AND Step_Name   = @Step
           AND End_DtmUtc IS NULL;

        /* =========================
           STEP: CITT Vendor (FIVC)
        ========================= */
        SET @Step  = N'sp_PDI_CITT_Axxis_Grav_PDI_Vend_FIVC_SYNC';
        SET @Start = SYSUTCDATETIME();

        IF @Debug = 1
        BEGIN
            DECLARE @Utc9 datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'Starting sync: dbo.PDI_CITT_Axxis_Grav_PDI_Vend_FIVC_Clone' AS Msg
                , @Utc9 AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@Utc9 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm;
        END;

        INSERT dbo.PDI_CloneSync_RunLog (RunGroup_ID, Proc_Name, Step_Name, Start_DtmUtc, Status)
        VALUES (@RunGroup_ID, @ProcName, @Step, @Start, 'Started');

        EXEC dbo.sp_PDI_CITT_Axxis_Grav_PDI_Vend_FIVC_SYNC @Debug = @Debug;

        IF @Debug = 1
        BEGIN
            DECLARE @Utc10 datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'Completed sync: dbo.PDI_CITT_Axxis_Grav_PDI_Vend_FIVC_Clone' AS Msg
                , @Utc10 AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@Utc10 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm;
        END;

        SET @End = SYSUTCDATETIME();

        UPDATE dbo.PDI_CloneSync_RunLog
           SET End_DtmUtc  = @End,
               Duration_ms = DATEDIFF(ms, @Start, @End),
               Status      = 'Success'
         WHERE RunGroup_ID = @RunGroup_ID
           AND Step_Name   = @Step
           AND End_DtmUtc IS NULL;

        /* =========================
           STEP: CITT Terminals
        ========================= */
        SET @Step  = N'sp_PDI_CITT_Axxis_Grav_PDI_Terminals_SYNC';
        SET @Start = SYSUTCDATETIME();

        IF @Debug = 1
        BEGIN
            DECLARE @Utc11 datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'Starting sync: dbo.PDI_CITT_Axxis_Grav_PDI_Terminals_Clone' AS Msg
                , @Utc11 AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@Utc11 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm;
        END;

        INSERT dbo.PDI_CloneSync_RunLog (RunGroup_ID, Proc_Name, Step_Name, Start_DtmUtc, Status)
        VALUES (@RunGroup_ID, @ProcName, @Step, @Start, 'Started');

        EXEC dbo.sp_PDI_CITT_Axxis_Grav_PDI_Terminals_SYNC @Debug = @Debug;

        IF @Debug = 1
        BEGIN
            DECLARE @Utc12 datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'Completed sync: dbo.PDI_CITT_Axxis_Grav_PDI_Terminals_Clone' AS Msg
                , @Utc12 AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@Utc12 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm;
        END;

        SET @End = SYSUTCDATETIME();

        UPDATE dbo.PDI_CloneSync_RunLog
           SET End_DtmUtc  = @End,
               Duration_ms = DATEDIFF(ms, @Start, @End),
               Status      = 'Success'
         WHERE RunGroup_ID = @RunGroup_ID
           AND Step_Name   = @Step
           AND End_DtmUtc IS NULL;

        /* =========================
           STEP: CITT Products
        ========================= */
        SET @Step  = N'sp_PDI_CITT_Axxis_Grav_PDI_Products_SYNC';
        SET @Start = SYSUTCDATETIME();

        IF @Debug = 1
        BEGIN
            DECLARE @Utc13 datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'Starting sync: dbo.PDI_CITT_Axxis_Grav_PDI_Products_Clone' AS Msg
                , @Utc13 AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@Utc13 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm;
        END;

        INSERT dbo.PDI_CloneSync_RunLog (RunGroup_ID, Proc_Name, Step_Name, Start_DtmUtc, Status)
        VALUES (@RunGroup_ID, @ProcName, @Step, @Start, 'Started');

        EXEC dbo.sp_PDI_CITT_Axxis_Grav_PDI_Products_SYNC @Debug = @Debug;

        IF @Debug = 1
        BEGIN
            DECLARE @Utc14 datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'Completed sync: dbo.PDI_CITT_Axxis_Grav_PDI_Products_Clone' AS Msg
                , @Utc14 AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@Utc14 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm;
        END;

        SET @End = SYSUTCDATETIME();

        UPDATE dbo.PDI_CloneSync_RunLog
           SET End_DtmUtc  = @End,
               Duration_ms = DATEDIFF(ms, @Start, @End),
               Status      = 'Success'
         WHERE RunGroup_ID = @RunGroup_ID
           AND Step_Name   = @Step
           AND End_DtmUtc IS NULL;

        /* =========================
           STEP: Drivers
        ========================= */
        SET @Step  = N'sp_PDI_Drivers_SYNC';
        SET @Start = SYSUTCDATETIME();

        IF @Debug = 1
        BEGIN
            DECLARE @UtcDrivers1 datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'Starting sync: dbo.PDI_Drivers_Clone' AS Msg
                , @UtcDrivers1 AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@UtcDrivers1 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm;
        END;

        INSERT dbo.PDI_CloneSync_RunLog (RunGroup_ID, Proc_Name, Step_Name, Start_DtmUtc, Status)
        VALUES (@RunGroup_ID, @ProcName, @Step, @Start, 'Started');

        EXEC dbo.sp_PDI_Drivers_SYNC @Debug = @Debug;

        IF @Debug = 1
        BEGIN
            DECLARE @UtcDrivers2 datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'Completed sync: dbo.PDI_Drivers_Clone' AS Msg
                , @UtcDrivers2 AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@UtcDrivers2 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm;
        END;

        SET @End = SYSUTCDATETIME();

        UPDATE dbo.PDI_CloneSync_RunLog
           SET End_DtmUtc  = @End,
               Duration_ms = DATEDIFF(ms, @Start, @End),
               Status      = 'Success'
         WHERE RunGroup_ID = @RunGroup_ID
           AND Step_Name   = @Step
           AND End_DtmUtc IS NULL;

        /* =========================
           STEP: Trucks (Vehicles)
        ========================= */
        SET @Step  = N'sp_PDI_Vehicles_SYNC';
        SET @Start = SYSUTCDATETIME();

        IF @Debug = 1
        BEGIN
            DECLARE @UtcTrucks1 datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'Starting sync: dbo.PDI_Trucks_Clone' AS Msg
                , @UtcTrucks1 AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@UtcTrucks1 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm;
        END;

        INSERT dbo.PDI_CloneSync_RunLog (RunGroup_ID, Proc_Name, Step_Name, Start_DtmUtc, Status)
        VALUES (@RunGroup_ID, @ProcName, @Step, @Start, 'Started');

        EXEC dbo.sp_PDI_Vehicles_SYNC @Debug = @Debug;

        IF @Debug = 1
        BEGIN
            DECLARE @UtcTrucks2 datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'Completed sync: dbo.PDI_Trucks_Clone' AS Msg
                , @UtcTrucks2 AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@UtcTrucks2 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm;
        END;

        SET @End = SYSUTCDATETIME();

        UPDATE dbo.PDI_CloneSync_RunLog
           SET End_DtmUtc  = @End,
               Duration_ms = DATEDIFF(ms, @Start, @End),
               Status      = 'Success'
         WHERE RunGroup_ID = @RunGroup_ID
           AND Step_Name   = @Step
           AND End_DtmUtc IS NULL;

        /* =========================
           STEP: Sites
        ========================= */
        SET @Step  = N'sp_PDI_Sites_SYNC';
        SET @Start = SYSUTCDATETIME();
        INSERT dbo.PDI_CloneSync_RunLog (RunGroup_ID, Proc_Name, Step_Name, Start_DtmUtc, Status)
        VALUES (@RunGroup_ID, @ProcName, @Step, @Start, 'Started');
        EXEC dbo.sp_PDI_Sites_SYNC @Debug = @Debug;
        SET @End = SYSUTCDATETIME();
        UPDATE dbo.PDI_CloneSync_RunLog
           SET End_DtmUtc  = @End,
               Duration_ms = DATEDIFF(ms, @Start, @End),
               Status      = 'Success'
         WHERE RunGroup_ID = @RunGroup_ID
           AND Step_Name   = @Step
           AND End_DtmUtc IS NULL;

        /* =========================
           STEP: Orders
        ========================= */
        SET @Step  = N'sp_PDI_Orders_SYNC';
        SET @Start = SYSUTCDATETIME();
        INSERT dbo.PDI_CloneSync_RunLog (RunGroup_ID, Proc_Name, Step_Name, Start_DtmUtc, Status)
        VALUES (@RunGroup_ID, @ProcName, @Step, @Start, 'Started');
        EXEC dbo.sp_PDI_Orders_SYNC @Debug = @Debug;
        SET @End = SYSUTCDATETIME();
        UPDATE dbo.PDI_CloneSync_RunLog
           SET End_DtmUtc  = @End,
               Duration_ms = DATEDIFF(ms, @Start, @End),
               Status      = 'Success'
         WHERE RunGroup_ID = @RunGroup_ID
           AND Step_Name   = @Step
           AND End_DtmUtc IS NULL;

        /* =========================
           STEP: Order Details Fuel
        ========================= */
        SET @Step  = N'sp_PDI_Order_Details_Fuel_Clone_SYNC';
        SET @Start = SYSUTCDATETIME();
        INSERT dbo.PDI_CloneSync_RunLog (RunGroup_ID, Proc_Name, Step_Name, Start_DtmUtc, Status)
        VALUES (@RunGroup_ID, @ProcName, @Step, @Start, 'Started');
        EXEC dbo.sp_PDI_Order_Details_Fuel_Clone_SYNC @Debug = @Debug;
        SET @End = SYSUTCDATETIME();
        UPDATE dbo.PDI_CloneSync_RunLog
           SET End_DtmUtc  = @End,
               Duration_ms = DATEDIFF(ms, @Start, @End),
               Status      = 'Success'
         WHERE RunGroup_ID = @RunGroup_ID
           AND Step_Name   = @Step
           AND End_DtmUtc IS NULL;

        /* =========================
           STEP: SI Users
        ========================= */
        SET @Step  = N'sp_PDI_SI_Users_SYNC';
        SET @Start = SYSUTCDATETIME();
        INSERT dbo.PDI_CloneSync_RunLog (RunGroup_ID, Proc_Name, Step_Name, Start_DtmUtc, Status)
        VALUES (@RunGroup_ID, @ProcName, @Step, @Start, 'Started');
        EXEC dbo.sp_PDI_SI_Users_SYNC @Debug = @Debug;
        SET @End = SYSUTCDATETIME();
        UPDATE dbo.PDI_CloneSync_RunLog
           SET End_DtmUtc  = @End,
               Duration_ms = DATEDIFF(ms, @Start, @End),
               Status      = 'Success'
         WHERE RunGroup_ID = @RunGroup_ID
           AND Step_Name   = @Step
           AND End_DtmUtc IS NULL;

        /* =========================
           STEP: Customer Locations
        ========================= */
        SET @Step  = N'sp_PDI_Customer_Locations_SYNC';
        SET @Start = SYSUTCDATETIME();
        INSERT dbo.PDI_CloneSync_RunLog (RunGroup_ID, Proc_Name, Step_Name, Start_DtmUtc, Status)
        VALUES (@RunGroup_ID, @ProcName, @Step, @Start, 'Started');
        DECLARE @StepRows int = NULL;
        EXEC dbo.sp_PDI_Customer_Locations_SYNC @Debug = @Debug, @RowsAffected = @StepRows OUTPUT;
        SET @End = SYSUTCDATETIME();
        UPDATE dbo.PDI_CloneSync_RunLog
           SET End_DtmUtc    = @End,
               Duration_ms   = DATEDIFF(ms, @Start, @End),
               Status        = 'Success',
               Rows_Affected = @StepRows
         WHERE RunGroup_ID = @RunGroup_ID
           AND Step_Name   = @Step
           AND End_DtmUtc IS NULL;

        /* =========================
           STEP: Customers
        ========================= */
        SET @Step  = N'sp_PDI_Customers_SYNC';
        SET @Start = SYSUTCDATETIME();
        INSERT dbo.PDI_CloneSync_RunLog (RunGroup_ID, Proc_Name, Step_Name, Start_DtmUtc, Status)
        VALUES (@RunGroup_ID, @ProcName, @Step, @Start, 'Started');
        DECLARE @StepRows2 int = NULL;
        EXEC dbo.sp_PDI_Customers_SYNC @Debug = @Debug, @RowsAffected = @StepRows2 OUTPUT;
        SET @End = SYSUTCDATETIME();
        UPDATE dbo.PDI_CloneSync_RunLog
           SET End_DtmUtc    = @End,
               Duration_ms   = DATEDIFF(ms, @Start, @End),
               Status        = 'Success',
               Rows_Affected = @StepRows2
         WHERE RunGroup_ID = @RunGroup_ID
           AND Step_Name   = @Step
           AND End_DtmUtc IS NULL;

        /* =========================
           OPTIONAL: Resolve Hooks
        ========================= */
        IF @RunResolveHooks = 1
        BEGIN
            SET @Step  = N'ResolveHooks';
            SET @Start = SYSUTCDATETIME();

            IF @Debug = 1
            BEGIN
                DECLARE @Utc15 datetime2(7) = SYSUTCDATETIME();
                SELECT
                      N'Starting sync: ResolveHooks' AS Msg
                    , @Utc15 AS UtcDtm
                    , CASE WHEN @ReturnLocalTime = 1
                           THEN CONVERT(datetime2(7), (@Utc15 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                           ELSE NULL
                      END AS PacificDtm;
            END;

            INSERT dbo.PDI_CloneSync_RunLog (RunGroup_ID, Proc_Name, Step_Name, Start_DtmUtc, Status)
            VALUES (@RunGroup_ID, @ProcName, @Step, @Start, 'Started');

            /* TODO: wire real resolve sprocs here */

            IF @Debug = 1
            BEGIN
                DECLARE @Utc16 datetime2(7) = SYSUTCDATETIME();
                SELECT
                      N'Completed sync: ResolveHooks' AS Msg
                    , @Utc16 AS UtcDtm
                    , CASE WHEN @ReturnLocalTime = 1
                           THEN CONVERT(datetime2(7), (@Utc16 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                           ELSE NULL
                      END AS PacificDtm;
            END;

            SET @End = SYSUTCDATETIME();

            UPDATE dbo.PDI_CloneSync_RunLog
               SET End_DtmUtc  = @End,
                   Duration_ms = DATEDIFF(ms, @Start, @End),
                   Status      = 'Success'
             WHERE RunGroup_ID = @RunGroup_ID
               AND Step_Name   = @Step
               AND End_DtmUtc IS NULL;
        END;

        IF @Debug = 1
        BEGIN
            DECLARE @Utc17 datetime2(7) = SYSUTCDATETIME();
            SELECT
                  N'All clone sync steps completed' AS Msg
                , @RunGroup_ID AS RunGroup_ID
                , @Utc17 AS CompletedUtc
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@Utc17 AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS CompletedPacific;
        END;

        IF @ReturnTop50 = 1
        BEGIN
            IF @ReturnLocalTime = 1
            BEGIN
                SELECT TOP (50)
                      RunLog_ID
                    , RunGroup_ID
                    , Proc_Name
                    , Step_Name
                    , Status
                    , Start_DtmUtc
                    , Start_DtmUtc AT TIME ZONE 'UTC'
                        AT TIME ZONE 'Pacific Standard Time' AS Start_DtmPacific
                    , End_DtmUtc
                    , End_DtmUtc AT TIME ZONE 'UTC'
                        AT TIME ZONE 'Pacific Standard Time' AS End_DtmPacific
                    , Duration_ms
                    , ErrorNumber
                    , ErrorLine
                    , ErrorMessage
                FROM dbo.PDI_CloneSync_RunLog
                WHERE RunGroup_ID = @RunGroup_ID
                ORDER BY RunLog_ID DESC;
            END
            ELSE
            BEGIN
                SELECT TOP (50) *
                FROM dbo.PDI_CloneSync_RunLog
                WHERE RunGroup_ID = @RunGroup_ID
                ORDER BY RunLog_ID DESC;
            END;
        END;

        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE
              @ErrNum int = ERROR_NUMBER()
            , @ErrLine int = ERROR_LINE()
            , @ErrMsg nvarchar(4000) = ERROR_MESSAGE();

        SET @End = SYSUTCDATETIME();

        UPDATE dbo.PDI_CloneSync_RunLog
           SET End_DtmUtc   = @End,
               Duration_ms  = DATEDIFF(ms, @Start, @End),
               Status       = 'Failed',
               ErrorNumber  = @ErrNum,
               ErrorLine    = @ErrLine,
               ErrorMessage = @ErrMsg
         WHERE RunGroup_ID = @RunGroup_ID
           AND Step_Name   = @Step
           AND End_DtmUtc IS NULL;

        IF @Debug = 1
        BEGIN
            DECLARE @UtcErr datetime2(7) = SYSUTCDATETIME();
            SELECT
                  @Step AS FailedStep
                , @UtcErr AS UtcDtm
                , CASE WHEN @ReturnLocalTime = 1
                       THEN CONVERT(datetime2(7), (@UtcErr AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'))
                       ELSE NULL
                  END AS PacificDtm
                , @ErrNum AS ErrorNumber
                , @ErrLine AS ErrorLine
                , @ErrMsg AS ErrorMessage
                , @RunGroup_ID AS RunGroup_ID;
        END;

        THROW;
    END CATCH;
END;

