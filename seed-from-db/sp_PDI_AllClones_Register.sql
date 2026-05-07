CREATE   PROCEDURE dbo.sp_PDI_AllClones_Register
      @SourceServer         sysname
    , @SourceDatabase       sysname
    , @SourceSchema         sysname         = N'dbo'
    , @SourceTable          sysname
    , @RebuildIfExists      bit             = 0
    , @UseChangeTracking    bit             = 1
    , @Debug                bit             = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
          @CloneTableName   sysname
        , @CloneFullName    nvarchar(256)
        , @RunGroupId       uniqueidentifier = NEWID()
        , @StepStart        datetime2(3)     = SYSUTCDATETIME()
        , @StepEnd          datetime2(3)
        , @Sql              nvarchar(max)
        , @ColDef           nvarchar(max)    = N''
        , @ColName          sysname
        , @DataType         sysname
        , @MaxLen           int
        , @Precision        tinyint
        , @Scale            tinyint
        , @IsNullable       varchar(3)
        , @Fragment         nvarchar(512)
        , @IsFirst          bit             = 1
        , @ErrNum           int
        , @ErrLine          int
        , @ErrMsg           nvarchar(4000);

    IF NULLIF(LTRIM(RTRIM(@SourceServer)),   N'') IS NULL
        RAISERROR(N'@SourceServer is required and cannot be empty.',   16, 1);

    IF NULLIF(LTRIM(RTRIM(@SourceDatabase)), N'') IS NULL
        RAISERROR(N'@SourceDatabase is required and cannot be empty.', 16, 1);

    IF NULLIF(LTRIM(RTRIM(@SourceTable)),    N'') IS NULL
        RAISERROR(N'@SourceTable is required and cannot be empty.',    16, 1);

    SET @CloneTableName = @SourceTable + N'_Clone';
    SET @CloneFullName  = N'[dbo].' + QUOTENAME(@SourceTable + N'_Clone');

    BEGIN TRY

        IF OBJECT_ID(N'dbo.' + QUOTENAME(@SourceTable + N'_Clone'), N'U') IS NOT NULL
        BEGIN
            IF @RebuildIfExists = 0
            BEGIN
                SET @StepEnd = SYSUTCDATETIME();

                INSERT dbo.PDI_CloneSync_RunLog
                (
                      RunGroup_ID
                    , Proc_Name
                    , Step_Name
                    , Start_DtmUtc
                    , End_DtmUtc
                    , Duration_ms
                    , Status
                    , Rows_Affected
                    , ErrorNumber
                    , ErrorLine
                    , ErrorMessage
                )
                VALUES
                (
                      @RunGroupId
                    , N'sp_PDI_AllClones_Register'
                    , N'SKIPPED_EXISTS'
                    , @StepStart
                    , @StepEnd
                    , DATEDIFF(millisecond, @StepStart, @StepEnd)
                    , N'SKIPPED'
                    , 0
                    , NULL
                    , NULL
                    , NULL
                );

                RETURN 0;
            END;

            SET @Sql = N'DROP TABLE ' + @CloneFullName + N';';

            IF @Debug = 1
                PRINT N'-- [DEBUG] ' + @Sql;
            ELSE
                EXEC sp_executesql @Sql;
        END;

        IF OBJECT_ID('tempdb..#SourceCols') IS NOT NULL DROP TABLE #SourceCols;

        CREATE TABLE #SourceCols
        (
              ColName         sysname         NOT NULL
            , DataType        sysname         NOT NULL
            , MaxLength       int             NULL
            , NumPrecision    tinyint         NULL
            , NumScale        tinyint         NULL
            , IsNullable      varchar(3)      NOT NULL
            , OrdinalPosition int             NOT NULL
        );

        SET @Sql =
              N'SELECT'
            + N'      c.COLUMN_NAME'
            + N'    , c.DATA_TYPE'
            + N'    , c.CHARACTER_MAXIMUM_LENGTH'
            + N'    , c.NUMERIC_PRECISION'
            + N'    , c.NUMERIC_SCALE'
            + N'    , c.IS_NULLABLE'
            + N'    , c.ORDINAL_POSITION'
            + N' FROM ' + QUOTENAME(@SourceServer)
            + N'.'      + QUOTENAME(@SourceDatabase)
            + N'.INFORMATION_SCHEMA.COLUMNS AS c'
            + N' WHERE c.TABLE_SCHEMA = N''' + REPLACE(@SourceSchema, N'''', N'''''') + N''''
            + N'   AND c.TABLE_NAME   = N''' + REPLACE(@SourceTable,  N'''', N'''''') + N''''
            + N' ORDER BY c.ORDINAL_POSITION;';

        INSERT INTO #SourceCols
        (
              ColName
            , DataType
            , MaxLength
            , NumPrecision
            , NumScale
            , IsNullable
            , OrdinalPosition
        )
        EXEC sp_executesql @Sql;

        IF NOT EXISTS (SELECT 1 FROM #SourceCols)
            RAISERROR(
                N'Source table [%s].[%s].[%s].[%s] returned 0 columns. Verify the linked server, database, schema, and table name.',
                16, 1,
                @SourceServer, @SourceDatabase, @SourceSchema, @SourceTable
            );

        DECLARE cur_cols CURSOR LOCAL FAST_FORWARD FOR
            SELECT
                  ColName
                , DataType
                , MaxLength
                , NumPrecision
                , NumScale
                , IsNullable
            FROM #SourceCols
            ORDER BY OrdinalPosition;

        OPEN cur_cols;

        FETCH NEXT FROM cur_cols INTO
              @ColName
            , @DataType
            , @MaxLen
            , @Precision
            , @Scale
            , @IsNullable;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @Fragment =
                CASE
                    WHEN @DataType IN (N'varchar', N'nvarchar', N'char', N'nchar')
                        THEN @DataType +
                             CASE WHEN @MaxLen = -1
                                  THEN N'(MAX)'
                                  ELSE N'(' + CAST(@MaxLen AS nvarchar(10)) + N')'
                             END

                    WHEN @DataType IN (N'decimal', N'numeric')
                        THEN @DataType +
                             N'(' + CAST(ISNULL(@Precision, 18) AS nvarchar(5))
                           + N',' + CAST(ISNULL(@Scale,     0)  AS nvarchar(5)) + N')'

                    WHEN @DataType IN (N'datetime2', N'time')
                        THEN @DataType +
                             N'(' + CAST(ISNULL(@Scale, 7) AS nvarchar(2)) + N')'

                    ELSE @DataType
                END;

            SET @ColDef = @ColDef
                + CASE WHEN @IsFirst = 1 THEN N'      ' ELSE N'    , ' END
                + QUOTENAME(@ColName)
                + N' ' + @Fragment
                + CASE WHEN @IsNullable = 'YES' THEN N' NULL' ELSE N' NOT NULL' END
                + NCHAR(13) + NCHAR(10);

            SET @IsFirst = 0;

            FETCH NEXT FROM cur_cols INTO
                  @ColName
                , @DataType
                , @MaxLen
                , @Precision
                , @Scale
                , @IsNullable;
        END;

        CLOSE cur_cols;
        DEALLOCATE cur_cols;

        IF @UseChangeTracking = 1
            SET @ColDef = @ColDef
                + N'    , [Clone_LoadDtmUtc] datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME()'
                + NCHAR(13) + NCHAR(10);

        SET @Sql =
              N'CREATE TABLE ' + @CloneFullName + NCHAR(13) + NCHAR(10)
            + N'(' + NCHAR(13) + NCHAR(10)
            + @ColDef
            + N');';

        IF @Debug = 1
            PRINT N'-- [DEBUG] CREATE TABLE DDL:' + NCHAR(13) + NCHAR(10) + @Sql;
        ELSE
            EXEC sp_executesql @Sql;

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Clone_Sync_Watermark
            WHERE ObjectName = @SourceTable
        )
        BEGIN
            INSERT dbo.Clone_Sync_Watermark
            (
                  ObjectName
                , LastRowVersion
                , LastSyncDtmUtc
                , LastUpsertRows
                , LastDeleteRows
            )
            VALUES
            (
                  @SourceTable
                , 0x0000000000000000
                , NULL
                , NULL
                , NULL
            );
        END;

        SET @StepEnd = SYSUTCDATETIME();

        INSERT dbo.PDI_CloneSync_RunLog
        (
              RunGroup_ID
            , Proc_Name
            , Step_Name
            , Start_DtmUtc
            , End_DtmUtc
            , Duration_ms
            , Status
            , Rows_Affected
            , ErrorNumber
            , ErrorLine
            , ErrorMessage
        )
        VALUES
        (
              @RunGroupId
            , N'sp_PDI_AllClones_Register'
            , N'REGISTER'
            , @StepStart
            , @StepEnd
            , DATEDIFF(millisecond, @StepStart, @StepEnd)
            , N'SUCCESS'
            , 0
            , NULL
            , NULL
            , NULL
        );

    END TRY
    BEGIN CATCH

        SET @ErrNum  = ERROR_NUMBER();
        SET @ErrLine = ERROR_LINE();
        SET @ErrMsg  = ERROR_MESSAGE();
        SET @StepEnd = SYSUTCDATETIME();

        INSERT dbo.PDI_CloneSync_RunLog
        (
              RunGroup_ID
            , Proc_Name
            , Step_Name
            , Start_DtmUtc
            , End_DtmUtc
            , Duration_ms
            , Status
            , Rows_Affected
            , ErrorNumber
            , ErrorLine
            , ErrorMessage
        )
        VALUES
        (
              @RunGroupId
            , N'sp_PDI_AllClones_Register'
            , N'REGISTER'
            , @StepStart
            , @StepEnd
            , DATEDIFF(millisecond, @StepStart, @StepEnd)
            , N'FAILED'
            , 0
            , @ErrNum
            , @ErrLine
            , @ErrMsg
        );

        THROW;

    END CATCH;

END;

