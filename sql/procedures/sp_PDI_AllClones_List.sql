
CREATE PROCEDURE [dbo].[sp_PDI_AllClones_List]
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#CloneList') IS NOT NULL DROP TABLE #CloneList;
    IF OBJECT_ID('tempdb..#Results')   IS NOT NULL DROP TABLE #Results;

    CREATE TABLE #CloneList
    (
          SchemaName     sysname       NOT NULL
        , TableName      sysname       NOT NULL
        , ObjectId       int           NOT NULL
        , TimestampCol   sysname       NULL
    );

    INSERT #CloneList
    (
          SchemaName
        , TableName
        , ObjectId
        , TimestampCol
    )
    SELECT
          s.name AS SchemaName
        , t.name AS TableName
        , t.object_id AS ObjectId
        , CASE
              WHEN EXISTS
              (
                  SELECT 1
                  FROM sys.columns c
                  WHERE c.object_id = t.object_id
                    AND c.name = N'Sync_Dtm'
              ) THEN N'Sync_Dtm'
              WHEN EXISTS
              (
                  SELECT 1
                  FROM sys.columns c
                  WHERE c.object_id = t.object_id
                    AND c.name = N'Clone_LoadDtmUtc'
              ) THEN N'Clone_LoadDtmUtc'
              ELSE NULL
          END AS TimestampCol
    FROM sys.tables t
    JOIN sys.schemas s
        ON s.schema_id = t.schema_id
    WHERE t.name LIKE N'%[_]Clone';

    IF NOT EXISTS (SELECT 1 FROM #CloneList)
    BEGIN
        SELECT N'No _Clone tables found in this database.' AS Message;
        RETURN 0;
    END;

    CREATE TABLE #Results
    (
          SchemaName     sysname       NOT NULL
        , TableName      sysname       NOT NULL
        , [Rows]         bigint        NOT NULL
        , Max_Sync_Dtm   datetime2(3)  NULL
        , CreateDate     datetime      NOT NULL
        , ModifyDate     datetime      NOT NULL
    );

    DECLARE
          @Schema       sysname
        , @Table        sysname
        , @ObjId        int
        , @TimestampCol sysname
        , @Sql          nvarchar(max);

    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
        SELECT
              SchemaName
            , TableName
            , ObjectId
            , TimestampCol
        FROM #CloneList
        ORDER BY SchemaName, TableName;

    OPEN c;
    FETCH NEXT FROM c INTO @Schema, @Table, @ObjId, @TimestampCol;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @TimestampCol IS NOT NULL
        BEGIN
            SET @Sql = N'
INSERT #Results
(
      SchemaName
    , TableName
    , [Rows]
    , Max_Sync_Dtm
    , CreateDate
    , ModifyDate
)
SELECT
      @SchemaName
    , @TableName
    , ISNULL
      (
          (
              SELECT SUM(ps.row_count)
              FROM sys.dm_db_partition_stats ps
              WHERE ps.object_id = @ObjectId
                AND ps.index_id IN (0,1)
          ),
          0
      ) AS [Rows]
    , (
          SELECT MAX(' + QUOTENAME(@TimestampCol) + N')
          FROM ' + QUOTENAME(@Schema) + N'.' + QUOTENAME(@Table) + N'
      ) AS Max_Sync_Dtm
    , (
          SELECT create_date
          FROM sys.tables
          WHERE object_id = @ObjectId
      ) AS CreateDate
    , (
          SELECT modify_date
          FROM sys.tables
          WHERE object_id = @ObjectId
      ) AS ModifyDate;';
        END
        ELSE
        BEGIN
            SET @Sql = N'
INSERT #Results
(
      SchemaName
    , TableName
    , [Rows]
    , Max_Sync_Dtm
    , CreateDate
    , ModifyDate
)
SELECT
      @SchemaName
    , @TableName
    , ISNULL
      (
          (
              SELECT SUM(ps.row_count)
              FROM sys.dm_db_partition_stats ps
              WHERE ps.object_id = @ObjectId
                AND ps.index_id IN (0,1)
          ),
          0
      ) AS [Rows]
    , CAST(NULL AS datetime2(3)) AS Max_Sync_Dtm
    , (
          SELECT create_date
          FROM sys.tables
          WHERE object_id = @ObjectId
      ) AS CreateDate
    , (
          SELECT modify_date
          FROM sys.tables
          WHERE object_id = @ObjectId
      ) AS ModifyDate;';
        END;

        EXEC sys.sp_executesql
              @Sql
            , N'@SchemaName sysname, @TableName sysname, @ObjectId int'
            , @SchemaName = @Schema
            , @TableName  = @Table
            , @ObjectId   = @ObjId;

        FETCH NEXT FROM c INTO @Schema, @Table, @ObjId, @TimestampCol;
    END;

    CLOSE c;
    DEALLOCATE c;

    SELECT
          SchemaName
        , TableName
        , [Rows]
        , Max_Sync_Dtm
        , CASE
              WHEN Max_Sync_Dtm IS NOT NULL
              THEN CONVERT
                   (
                       datetime2(3),
                       (Max_Sync_Dtm AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time')
                   )
              ELSE NULL
          END AS Max_Sync_Dtm_Pacific
        , CreateDate
        , ModifyDate
    FROM #Results
    ORDER BY SchemaName, TableName;

    RETURN 0;
END


