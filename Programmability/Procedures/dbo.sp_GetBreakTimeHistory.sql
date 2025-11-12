SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetBreakTimeHistory] (@ListUsersId VARCHAR(1000) = NULL,
@DateFrom DATE = NULL,
@DateTo DATE = NULL,
@AgencyId INT = NULL)
AS
  DECLARE @NumberOfSeconds INT
  BEGIN
    SELECT
      *
     ,RIGHT('0' + CAST(FLOOR(COALESCE(TotalTime * 60, 0) / 60) AS VARCHAR(8)), 2) + ':' +
      RIGHT('0' + CAST(FLOOR(COALESCE(TotalTime * 60, 0) % 60) AS VARCHAR(2)), 2) + ':' +
      RIGHT('0' + CAST(FLOOR(((TotalTime * 60) * 60) % 60) AS VARCHAR(2)), 2) TotalFormatTime


    FROM (SELECT
        u.Name AS Name
       ,
        --       a.Name AS AgencyCodeName,
        a.Code + ' - ' + a.Name AS AgencyCodeName
       ,ut.Desciption AS Description
       ,CAST(bt.DateFrom AS DATE) AS Date
       ,FORMAT(bt.DateFrom, 'MM-dd-yyyy', 'en-US') DateFromFormat
       ,bt.DateFrom
       ,FORMAT(bt.DateFrom, 'h:mm:ss tt', 'en-US') DateFrom_Format
       ,bt.DateTo
       ,FORMAT(bt.DateTo, 'h:mm:ss tt', 'en-US') DateToFormat
       ,
        --CONVERT(varchar, DATEADD(SECOND, DATEDIFF(second,bt.DateFrom,  bt.DateTo),0), 108) TotalTime,
        CAST(ISNULL(DATEDIFF(SECOND, bt.DateFrom, bt.DateTo) / 3600.0, 0) AS DECIMAL(18, 4)) TotalTime
      FROM BreakTimeHistory bt
      INNER JOIN dbo.Users u
        ON bt.UserId = u.UserId
      LEFT JOIN dbo.Agencies a
        ON bt.AgencyId = a.AgencyId
      INNER JOIN UserTypes ut
        ON bt.Rol = ut.UsertTypeId

      WHERE (u.UserId IN (SELECT
          item
        FROM dbo.FN_ListToTableInt(@ListUsersId))
      OR @ListUsersId IS NULL)

AND (bt.AgencyId = @AgencyId OR @AgencyId IS NULL  )

      AND ((CAST(DateFrom AS DATE) >= CAST(@DateFrom AS DATE)
      OR @DateFrom IS NULL)
      AND ((CAST(DateFrom AS DATE) <= CAST(@DateTo AS DATE))
      OR @DateTo IS NULL))) AS QUERY
    ORDER BY DateFrom ASC -- changen by Sergio from desc to asc

  END;









GO