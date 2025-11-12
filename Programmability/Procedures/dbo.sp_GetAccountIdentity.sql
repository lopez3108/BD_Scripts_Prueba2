SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAccountIdentity] ( @MakerId  INT = NULL ,@Account VARCHAR(50), @Routing  VARCHAR(50)
 )
AS


  IF (EXISTS (SELECT
        1
      FROM dbo.Checks c
      WHERE c.Account = @Account)
    )
  BEGIN
    SELECT
      c.Routing
     ,r.BankName
     ,m.Name
     ,c.Account
    FROM dbo.Checks c
    INNER JOIN dbo.Makers m
      ON c.Maker = m.MakerId
    INNER JOIN dbo.Routings r
      ON r.Number = c.Routing
    WHERE c.Account = @Account AND c.Routing = @Routing AND (c.Maker = @MakerId OR @MakerId is NULL) 
  END;
  ELSE
  BEGIN
    SELECT
      c.Routing
     ,r.BankName
     ,m.Name
     ,c.Account
    FROM ReturnedCheck c
    INNER JOIN dbo.Makers m
      ON c.MakerId = m.MakerId
    INNER JOIN dbo.Routings r
      ON r.Number = c.Routing
    WHERE c.Account = @Account AND c.Routing = @Routing AND  (c.MakerId = @MakerId OR @MakerId is NULL) 
  END





GO