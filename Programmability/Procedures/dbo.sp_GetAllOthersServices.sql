SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllOthersServices]
AS
     BEGIN
         SELECT OtherId,
                Name,
                AcceptNegative,
                AcceptDetails AS 'Disabled',
                AcceptDetails,

				CASE
                   WHEN  AcceptDetails = 1
                   THEN 'YES'
                   ELSE 'NO'
                END AS [AcceptDetailsFormat],

				Active,

				CASE
                   WHEN Active = 1
                   THEN 'ACTIVE'
                   ELSE 'INACTIVE'
                END AS [ActiveFormat],

                '0.00' AS 'moneyvalue'
         FROM OthersServices
         ORDER BY Name;
     END;
GO