SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Last update by Juan Felipe Oquendo task 5269

--makers
CREATE PROCEDURE [dbo].[sp_GetMakerAccountChecks] @MakerId INT
AS
BEGIN
 SELECT DISTINCT
    *
    FROM (
  SELECT DISTINCT
--    Checks.CheckId
   NULL CheckTypeId,
--   (SELECT TOP 1 Checks.CheckFront
--     FROM Checks
--  WHERE Maker = @MakerId AND Checks.CheckFront IS NOT NULL  )  CheckFront
--   , 
--    (SELECT TOP 1 Checks.CheckBack
--     FROM Checks
--  WHERE Maker = @MakerId AND Checks.CheckBack IS NOT NULL )  CheckBack

    
   Checks.Account
   ,Checks.Routing
   ,'+' AS showLabel
--     'CHECK' AS Section
  FROM Checks
  WHERE Maker = @MakerId
--  INNER JOIN (SELECT
--      MAX(CheckId) AS maxID
--     ,Account FROM Checks
--    WHERE Maker = 341
--    GROUP BY Account) ChecksJoin
--    ON ChecksJoin.maxID = Checks.CheckId

  UNION ALL 

  SELECT DISTINCT

--    NULL CheckId
   NULL CheckTypeId
--   ,NULL CheckFront
--   ,NULL CheckBack
   ,rc.Account
   ,rc.Routing
   ,'+' AS showLabel
--'RETURNCHECK' AS Section
  FROM dbo.ReturnedCheck rc

  INNER JOIN dbo.Makers
    ON rc.MakerId = Makers.MakerId
  WHERE rc.MakerId = @MakerId
  AND rc.Account NOT IN (SELECT TOP 1
      c.Account
    FROM Checks c
    WHERE c.Maker = @MakerId)
    ) AS Account
END;





GO