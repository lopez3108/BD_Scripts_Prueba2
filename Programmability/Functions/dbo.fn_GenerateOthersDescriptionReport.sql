SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:      JF
-- Create date: 23/06/2024 7:30 p. m.
-- Database:    devtest
-- Description: task: 5896  Ajustes reporte OTHER SERVICES
-- =============================================

-- =============================================
-- Author:      JF
-- Create date: 12/09/2024 1:25 p. m.
-- Database:    developing
-- Description: task 6051 Agregar un nuevo filtro al reporte others services
-- =============================================




CREATE FUNCTION [dbo].[fn_GenerateOthersDescriptionReport] 
    (
        @AgencyId INT,
        @FromDate DATETIME = NULL,
        @ToDate DATETIME = NULL, 
        @OthersIds VARCHAR(100) = NULL,
        @CashiersIds VARCHAR(100) = NULL
    )

RETURNS @result TABLE (
  [Index] INT
 ,Date DATETIME
 ,Type VARCHAR(1000)
 ,Description VARCHAR(1000)
 ,Transactions INT
 ,NameEmployee VARCHAR(80)
 ,TypeId INT
 ,Usd DECIMAL(18, 2)
 ,Commission DECIMAL(18, 2)
 ,Balance DECIMAL(18, 2)
)
AS
BEGIN



  INSERT INTO @result
    SELECT
      1 [Index]
     ,CAST(O.CreationDate AS Date) AS Date
     ,'DAILY' AS Type
     ,OS.Name AS Description
     ,COUNT(O.CreationDate) AS Transactions
     ,U.Name NameEmployee
     ,2 TypeId
     ,SUM(O.Usd) AS Usd
     ,0 Commission
     ,SUM(O.Usd) AS Balance
    FROM dbo.OthersDetails O
    INNER JOIN OthersServices OS   ON O.OtherServiceId = OS.OtherId
    INNER JOIN dbo.Users U ON U.UserId = O.CreatedBy
    INNER JOIN Cashiers C ON U.UserId = C.UserId

    WHERE O.AgencyId = @AgencyId AND
    (O.OtherServiceId IN
         (
             SELECT item
             FROM dbo.FN_ListToTableInt(@OthersIds)
         ) OR @OthersIds IS NULL ) AND

           (C.CashierId IN
         (
             SELECT item
             FROM dbo.FN_ListToTableInt(@CashiersIds)
         ) OR @CashiersIds IS NULL )

    AND (CAST(O.CreationDate AS Date) >= CAST(@FromDate AS Date)
    OR @FromDate IS NULL)
    AND (CAST(O.CreationDate AS Date) <= CAST(@ToDate AS Date)
    OR @ToDate IS NULL)
    GROUP BY CAST(O.CreationDate AS Date),OS.Name ,U.Name









  RETURN

END
GO