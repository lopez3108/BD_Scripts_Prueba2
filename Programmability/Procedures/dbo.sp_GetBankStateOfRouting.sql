SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*
	exec [sp_GetBankStateOfRouting]
*/
CREATE PROCEDURE [dbo].[sp_GetBankStateOfRouting]

AS
--     BEGIN
--         SELECT DISTINCT           // estaba así  el día 01/14/21 att wilmar  al hacer el compare 
--                BankState as Name
--         FROM [dbo].routings 
--		 WHERE BankState IS NOT NULL
--         ORDER BY BankState;
--     END;

  BEGIN
         SELECT * 
         FROM [dbo].routings 
--		 WHERE BankState IS NOT NULL
--         ORDER BY BankState;
     END;
GO