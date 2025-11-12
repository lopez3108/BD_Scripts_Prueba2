SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCashierFileOwnerByFileName] (@Name VARCHAR(50))
AS
BEGIN
  SELECT top 1
   u.Name,
   u.UserId

  FROM PathsByUsers p
  INNER JOIN [dbo].[Users] u
    ON p.CreatedBy = u.UserId
  WHERE p.PathResource = @Name
END


GO