SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Según investigacion de JT el 17-12-24 Ese sp ya no se usa mas 
CREATE PROCEDURE [dbo].[sp_GetChecksByClient] @ClientId INT
AS
    BEGIN
        SELECT c.CheckId, 
               c.CheckTypeId, 
               UPPER(dbo.CheckTypes.Description) AS CheckType, 
               dbo.Users.Name AS Client, 
               ce1.CheckNumber AS CheckNumber, 
               c.Account, 
               c.Routing, 
               CAST(ce1.CheckDate AS DATE) CheckDate,        
			     FORMAT(ce1.CheckDate, 'MM-dd-yyyy', 'en-US')  CheckDateFormat,		
			    FORMAT(ce1.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
               --c.IsBounced
               dbo.Makers.Name AS Maker, 
               dbo.Makers.MakerId, 
               c.DateCashed AS CashedDate, 
               c.ClientId, 
               dbo.Routings.BankName AS Bank, 
               [dbo].[fn_IsCheckReturned](c.Number) AS Returned,
        -------------------------------------------------------------------
               CASE
                   WHEN EXISTS
        (
            SELECT *
            FROM ReturnedCheck re
            WHERE re.CheckNumber = c.Number
        )
                   THEN
        (
            SELECT TOP 1 dbo.ReturnReason.Description
            FROM dbo.ReturnedCheck r
                 INNER JOIN dbo.ReturnReason ON r.ReturnReasonId = dbo.ReturnReason.ReturnReasonId
            WHERE r.CheckNumber = c.Number
        )
                   ELSE NULL
               END AS ReturnReason,
                                                       -------------------------------------------------------------------------------
               CASE
                   WHEN EXISTS
        (
            SELECT *
            FROM ReturnedCheck re
            WHERE re.CheckNumber = c.Number
        )
                   THEN
        (
            SELECT TOP 1 re.ReturnDate
            FROM dbo.ReturnedCheck re
            WHERE re.CheckNumber = c.Number
        )
                   ELSE NULL
               END AS ReturnDate,
                                                       -----------------------------------------------------------------------------
                                                       --SUBSTRING(c.CheckFront, LEN(c.CheckFront)-CHARINDEX('\', REVERSE(c.CheckFront))+2, LEN(c.CheckFront)) AS CheckFront,
               c.CheckFront, 
               c.CheckBack, 
                                                       --SUBSTRING(c.CheckBack, LEN(c.CheckBack)-CHARINDEX('\', REVERSE(c.CheckFront))+2, LEN(c.CheckBack)) AS CheckBack,
               a.Code + ' - ' + a.Name AS Agency,
                                                       --c.Amount,
                                                       --CONVERT(DECIMAL(10,2),c.Amount) as Amount,
               CAST(CONVERT(DECIMAL(18, 2), ce1.Amount) AS VARCHAR) AS Amount, 
               uscash.Name CashierName
        FROM ChecksEls ce1
         inner JOIN dbo.Checks c ON c.CheckId = ce1.CheckId 
       
             INNER JOIN dbo.CheckTypes ON c.CheckTypeId = dbo.CheckTypes.CheckTypeId
             INNER JOIN dbo.Clientes ON c.ClientId = dbo.Clientes.ClienteId
             INNER JOIN dbo.Users ON dbo.Clientes.UsuarioId = dbo.Users.UserId
             INNER JOIN dbo.Routings ON c.Routing = dbo.Routings.Number
             INNER JOIN dbo.Makers ON c.Maker = dbo.Makers.MakerId
             INNER JOIN dbo.Agencies A ON A.AgencyId = ce1.AgencyId
             INNER JOIN dbo.Cashiers cash ON cash.CashierId = c.CashierId
             INNER JOIN dbo.Users uscash ON cash.UserId = uscash.UserId
        WHERE c.ClientId = @ClientId
        UNION ALL
        SELECT dbo.ReturnedCheck.ReturnedCheckId AS CheckId, 
        (
            SELECT TOP 1 CheckTypeId
            FROM checktypes
            WHERE Description = 'PAYROLL'
        ) AS ChecTypeId, 
        (
            SELECT TOP 1 [Description]
            FROM checktypes
            WHERE Description = 'PAYROLL'
        ) AS CheckType, 
               dbo.Users.Name AS Client, 
               dbo.ReturnedCheck.CheckNumber, 
               dbo.ReturnedCheck.Account, 
               dbo.ReturnedCheck.Routing, 
               CAST(dbo.ReturnedCheck.CheckDate AS DATE) CheckDate, 
			   FORMAT(dbo.ReturnedCheck.CheckDate, 'MM-dd-yyyy', 'en-US')  CheckDateFormat,
			   --CAST(ReturnedCheck.CreationDate AS DATETIME) CreationDate,
			   FORMAT(ReturnedCheck.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
               dbo.Makers.Name AS Maker, 
               dbo.Makers.MakerId,			
               dbo.ReturnedCheck.CreationDate AS CashedDate, 
               dbo.ReturnedCheck.ClientId, 
               dbo.Routings.BankName AS Bank, 
               [dbo].[fn_IsCheckReturned](dbo.ReturnedCheck.CheckNumber) AS Returned, 
               dbo.ReturnReason.Description AS ReturnReason, 
               dbo.ReturnedCheck.ReturnDate AS ReturnDate,
               CASE
                   WHEN EXISTS
        (
            SELECT *
            FROM dbo.Checks
            WHERE dbo.Checks.Number = dbo.ReturnedCheck.CheckNumber
        )
                   THEN
        (
            SELECT SUBSTRING(c.CheckFront, LEN(c.CheckFront) - CHARINDEX('\', REVERSE(c.CheckFront)) + 2, LEN(c.CheckFront))
            FROM Checks c
            WHERE c.Number = dbo.ReturnedCheck.CheckNumber
        )
                   ELSE NULL
               END AS CheckFront,
               CASE
                   WHEN EXISTS
        (
            SELECT *
            FROM dbo.Checks cb
            WHERE cb.Number = dbo.ReturnedCheck.CheckNumber
        )
                   THEN
        (
            SELECT SUBSTRING(cb.CheckFront, LEN(cb.CheckFront) - CHARINDEX('\', REVERSE(cb.CheckFront)) + 2, LEN(cb.CheckFront))
            FROM Checks cb
            WHERE cb.Number = dbo.ReturnedCheck.CheckNumber
        )
                   ELSE NULL
               END AS CheckBack, 
               a.Code + ' - ' + a.Name AS Agency, 
               CAST(CONVERT(DECIMAL(18, 2), ReturnedCheck.USD) AS VARCHAR) AS Amount,
        --CONVERT(DECIMAL(10,2),ReturnedCheck.USD) as Amount,
               '' CashierName
        FROM dbo.Routings
             INNER JOIN dbo.ReturnedCheck
             INNER JOIN dbo.Clientes ON dbo.ReturnedCheck.ClientId = dbo.Clientes.ClienteId
             INNER JOIN dbo.Users ON dbo.Clientes.UsuarioId = dbo.Users.UserId
             INNER JOIN dbo.Makers ON dbo.ReturnedCheck.MakerId = dbo.Makers.MakerId ON dbo.Routings.Number = dbo.ReturnedCheck.Routing
             INNER JOIN dbo.ReturnReason ON dbo.ReturnedCheck.ReturnReasonId = dbo.ReturnReason.ReturnReasonId
             INNER JOIN dbo.Agencies a ON A.AgencyId = dbo.ReturnedCheck.BelongAgencyId
        WHERE dbo.ReturnedCheck.ClientId = @ClientId
              AND dbo.ReturnedCheck.CheckNumber NOT IN
        (
            SELECT Number
            FROM Checks
            WHERE ClientId = @ClientId
        )
        ORDER BY Returned DESC, 
                 CashedDate ASC, 
                 CheckType ASC;
    END;



GO