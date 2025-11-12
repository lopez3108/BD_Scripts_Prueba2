SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Description:	Selecciona cheques de returnedcheck  por clientId o account
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetAccountsReturnedChecksByAccount]  @Account  VARCHAR(50) = NULL,
@ClientId  INT  = NULL
AS
     BEGIN

         SELECT DISTINCT	   
       
         C.Account,
        r.Number AS Routing,
        r.BankName,
        c.ClientId
         FROM dbo.ReturnedCheck C
             INNER JOIN Routings r ON c.Routing = r.Number
              INNER JOIN dbo.Makers ON C.MakerId = dbo.Makers.MakerId
              LEFT JOIN AddressXClient A ON A.ClientId = c.ClientId
              LEFT JOIN AddressXMaker AM ON AM.MakerId = dbo.Makers.MakerId  
         WHERE (c.Account LIKE '%'+@Account+'%'
                    OR @Account IS NULL) and (c.ClientId = @ClientId OR @ClientId is NULL)
         ORDER BY Account ASC;
     END;



GO