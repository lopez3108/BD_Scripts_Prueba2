SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- Create: Felipe
-- Date: 29-Enero-2024
-- Task 5550  CASH ADVANCE OR BACK SENT 11-28-2023
CREATE PROCEDURE [dbo].[sp_GetAllProviderscashAdvanceByState] @State    BIT = NULL, 
                                                                @AgencyId INT = NULL
AS
    BEGIN
        SELECT p.ProviderId, 
               p.Name +' (C.A.B)' Name ,
               p.Active, 
               p.ProviderTypeId, 
               p.AcceptNegative, 
               0 AS 'Disabled', 
               0 Comision, 
               pt.Code AS ProviderTypeCode, 
               pt.Description AS ProviderType, 
               0 transactions, 
               p.CheckCommission AS 'moneyvalue', 
               p.MoneyOrderCommission, 
               P.ReturnedCheckCommission, 
               'true' AS 'Set'
        FROM Providers p
             INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
			 
        WHERE pt.Code = 'C02'
              AND (p.Active = 1) and p.UseCashAdvanceOrBack= 1
        ORDER BY Name;
    END;

GO