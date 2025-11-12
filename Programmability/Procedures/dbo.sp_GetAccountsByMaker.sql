SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAccountsByMaker] @MakerId INT = NULL,
@Account VARCHAR(30) = NULL
AS
BEGIN
  IF (@MakerId IS NOT NULL)
  BEGIN
  SELECT  
  DISTINCT
      Account
     ,Routing
     ,Bank
     ,MakerId
     ,Name
     ,CheckNoRegistered FROM (
    SELECT DISTINCT
      dbo.Checks.Account
     ,dbo.Checks.Routing
     ,dbo.Routings.BankName AS Bank
     ,dbo.Makers.MakerId
     ,dbo.Makers.Name
     ,dbo.Makers.NoRegistered AS CheckNoRegistered
    FROM dbo.Checks
    INNER JOIN dbo.Routings
      ON dbo.Checks.Routing = dbo.Routings.Number
    INNER JOIN dbo.Makers
      ON dbo.Checks.Maker = dbo.Makers.MakerId
    WHERE Maker = @MakerId

    union ALL

   SELECT DISTINCT
      rc.Account
     ,rc.Routing
     ,dbo.Routings.BankName AS Bank
     ,dbo.Makers.MakerId
     ,dbo.Makers.Name
     ,dbo.Makers.NoRegistered AS CheckNoRegistered
    FROM dbo.ReturnedCheck rc
    INNER JOIN dbo.Routings
      ON rc.Routing = dbo.Routings.Number
    INNER JOIN dbo.Makers
      ON rc.MakerId = Makers.MakerId
    WHERE rc.MakerId = @MakerId AND rc.Account NOT IN (SELECT TOP 1 c.Account FROM Checks c where c.Maker = @MakerId)
	) AS QUERY 
  END;


  IF (@Account IS NOT NULL)
  BEGIN
    SELECT DISTINCT TOP 1
      dbo.Checks.Account
     ,dbo.Checks.Routing
     ,dbo.Routings.BankName AS Bank
     ,dbo.Makers.MakerId
     ,dbo.Makers.Name
    FROM dbo.Checks
    INNER JOIN dbo.Routings
      ON dbo.Checks.Routing = dbo.Routings.Number
    INNER JOIN dbo.Makers
      ON dbo.Checks.Maker = dbo.Makers.MakerId
    WHERE Account = @Account;
  END;
END;
GO