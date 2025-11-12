SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		John Terry García 
-- Description:	Selecciona cheques de returnedcheck y checks por clientId
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetAccountsRegisteredChecksByAccount]   @Account  VARCHAR(50) = NULL
AS
     BEGIN
         SELECT DISTINCT
	   
                c.Account
           
 
                --c.DateCheck
         FROM dbo.Checks c
              INNER JOIN Routings r ON c.Routing = r.Number
              INNER JOIN dbo.Makers ON C.Maker = dbo.Makers.MakerId
              LEFT JOIN AddressXClient A ON A.ClientId = c.ClientId
              LEFT JOIN AddressXMaker AM ON AM.MakerId = dbo.Makers.MakerId
         WHERE 
           
             (c.Account LIKE '%'+@Account+'%'
                    OR @Account IS NULL)
         UNION ALL
         SELECT DISTINCT

         C.Account
      

         FROM dbo.ReturnedCheck C
              INNER JOIN Routings r ON c.Routing = r.Number
              INNER JOIN dbo.Makers ON C.MakerId = dbo.Makers.MakerId
              LEFT JOIN AddressXClient A ON A.ClientId = c.ClientId
              LEFT  JOIN AddressXMaker AM ON AM.AddressXMakerId = C.AddressXMakerId
         WHERE 
               (c.Account LIKE '%'+@Account+'%'
                    OR @Account IS NULL)
         ORDER BY Account ASC;
     END;



GO