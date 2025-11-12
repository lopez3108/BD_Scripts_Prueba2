SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*
	exec [sp_GetBanksRoutingByName]
	@Name = 'HARB'
*/
CREATE PROCEDURE [dbo].[sp_GetBanksRoutingByNameDistinct](@Name VARCHAR(50) = NULL)
AS
     BEGIN
         SELECT DISTINCT
                BankName Name
         FROM [dbo].routings 
			--inner join AddressXBank ab ON b.BankId = ab.BankId
         WHERE BankName LIKE '%'+@Name+'%'
               OR @Name IS NULL
         ORDER BY BankName;
     END;
GO