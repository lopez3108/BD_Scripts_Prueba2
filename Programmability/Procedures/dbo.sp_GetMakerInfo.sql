SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetMakerInfo] @Account VARCHAR(50) = NULL, @Routing VARCHAR (50) = NULL
AS
  SET NOCOUNT ON;


--  IF (EXISTS (SELECT
--        1
--      FROM dbo.Checks c
--      WHERE c.Account = @Account)
--    )
  BEGIN

--    SELECT DISTINCT
----      c.Routing
----     ,r.BankName,
--      m.Name
--     ,c.Maker AS MakerId
--     ,c.Account
--  FROM dbo.Checks c
--    INNER JOIN dbo.Makers m
--      ON c.Maker = m.MakerId
----    INNER JOIN dbo.Routings r
----      ON r.Number = c.Routing
--    WHERE c.Account =@Account
----  END;
----  ELSE
----  BEGIN
--union ALL
--    SELECT DISTINCT
----      c.Routing
----     ,r.BankName,
--     m.Name,
--     c.MakerId
--     ,c.Account
--    FROM ReturnedCheck c
--    INNER JOIN dbo.Makers m
--      ON c.MakerId = m.MakerId
----    INNER JOIN dbo.Routings r
----      ON r.Number = c.Routing
--    WHERE c.Account = @Account


    SELECT DISTINCT
  m.*
 
    FROM Makers m
    left JOIN dbo.returnedCheck c ON c.MakerId = m.MakerId
    left JOIN Checks ck ON m.MakerId = ck.Maker
--    left JOIN ChecksEls ce ON ce.MakerId = m.MakerId
    WHERE (c.Account = @Account AND (c.Routing = @Routing OR @Routing is null)) 
    OR (ck.Account =@Account AND (ck.Routing = @Routing OR @Routing is null))
--    OR (ce.Account = @Account AND ce.Routing = @Routing)

  END
   




GO