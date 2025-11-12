SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetMakerInfoFraudAlert] @Maker VARCHAR (50) = NULL, @Account VARCHAR(50) = NULL
AS
  SET NOCOUNT ON;


  BEGIN




    SELECT DISTINCT TOP 1
  m.name AS maker,ck.Account,ax.Address,m.FileNumber,ck.Routing,r.BankName
    FROM Makers m
    left JOIN Checks ck ON m.MakerId = ck.Maker
    left JOIN AddressXMaker ax ON m.MakerId = ax.MakerId
    LEFT JOIN Clientes c ON ck.ClientId = c.ClienteId
    LEFT JOIN Routings r ON ck.Routing = r.Number
    WHERE (ck.Account = @Account AND (m.Name = @Maker OR @Maker is null)) 

  END
   




GO