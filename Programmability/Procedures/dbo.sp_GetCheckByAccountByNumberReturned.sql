SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCheckByAccountByNumberReturned]
(@Number  VARCHAR(50), 
 @Account VARCHAR(50),
  @Routing VARCHAR(50)
)
AS 
BEGIN
  IF NOT EXISTS (SELECT TOP 1
        *
     
         FROM Checks c
      WHERE c.Number = @Number
      AND c.Account = @Account
      AND c.Routing = @Routing)
  
    BEGIN
        SELECT TOP 1 ReturnedCheckId
        FROM [ReturnedCheck]
        WHERE Account = @Account
              AND CheckNumber =  @Number AND  Routing = @Routing
      
    END;
END;
GO