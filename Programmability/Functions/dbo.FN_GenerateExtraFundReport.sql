SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:18-10-2023
--CAMBIOS EN 5418, Refactoring reporte de extra fund

CREATE FUNCTION [dbo].[FN_GenerateExtraFundReport](
@AgencyId   INT, 
@FromDate   DATETIME = NULL, 
@ToDate     DATETIME = NULL)
RETURNS @result TABLE
(    [Index] INT,
    
          [Type]        VARCHAR(30),
          CreationDate  DATETIME,
          [Description] VARCHAR(100),
          Debit         DECIMAL(18, 2) NULL,
          Credit        DECIMAL(18, 2) NULL,
         BalanceDetail DECIMAL(18, 2)
)


AS
     BEGIN
       

           -- Cashiers from Admin

         INSERT INTO @result
                SELECT 2,
                       t.Type,
                       t.CreationDate,
                       t.Description,
                       SUM(t.Usd),--Debit
					             NULL, --Credit

                       SUM(t.Usd) AS BalanceDetail
                FROM
                (
                    SELECT 'CASHIER FROM ADMIN' AS Type,
                           CAST(dbo.ExtraFund.CreationDate AS DATE) AS CreationDate,
                           ISNULL(dbo.ExtraFund.Usd, 0) AS Usd,
                           'CLOSING DAILY' AS Description
                    FROM dbo.ExtraFund
                         INNER JOIN dbo.Users ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
                         INNER JOIN dbo.UserTypes ON dbo.Users.UserType = dbo.UserTypes.UsertTypeId
                    WHERE CashAdmin = 0
                          AND IsCashier = 0
                          AND dbo.ExtraFund.AgencyId = @AgencyId
                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                ) t
                GROUP BY t.CreationDate,
                         t.Type,
                         t.Description;

						 -- Admin to cashiers

         INSERT INTO @result
                SELECT 3,
                       t.Type,
                       t.CreationDate,
                       t.Description,
                       NULL, --Debit
                       SUM(t.Usd), --Credit
                       -SUM(t.Usd) AS BalanceDetail
                FROM
                (
                    SELECT 'ADMIN TO CASHIER' AS Type,
                           CAST(dbo.ExtraFund.CreationDate AS DATE) AS CreationDate,
                           ISNULL(dbo.ExtraFund.Usd, 0) AS Usd,
                           'CLOSING DAILY' AS Description
                    FROM dbo.ExtraFund
                         INNER JOIN dbo.Users ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
                         INNER JOIN dbo.UserTypes ON dbo.Users.UserType = dbo.UserTypes.UsertTypeId
                    WHERE CashAdmin = 0
                          AND IsCashier = 0
                          AND dbo.ExtraFund.AgencyId = @AgencyId
                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                ) t
                GROUP BY t.CreationDate,
                         t.Type,
                         t.Description;

         -- Cashiers from Cashiers

         INSERT INTO @result
                SELECT 4,
                       t.Type,
                       t.CreationDate,
                       t.Description,
                       SUM(t.Usd),--Debit
                       NULL,--Credit
                         SUM(t.Usd) AS BalanceDetail
                FROM
                (
                    SELECT 'CASHIER FROM CASHIER' AS Type,
                           CAST(dbo.ExtraFund.CreationDate AS DATE) AS CreationDate,
                           ISNULL(dbo.ExtraFund.Usd, 0) AS Usd,
                           'CLOSING DAILY' AS Description
                    FROM dbo.Users AS Users_1
                         INNER JOIN dbo.ExtraFund ON Users_1.UserId = dbo.ExtraFund.AssignedTo
                         INNER JOIN Users U ON U.UserId = ExtraFund.AssignedTo
                         LEFT JOIN Cashiers c ON U.UserId = c.UserId
                    WHERE IsCashier = 1
                          AND dbo.ExtraFund.AgencyId = @AgencyId
                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                ) t
                GROUP BY t.CreationDate,
                         t.Type,
                         t.Description;
 -- Cashiers to Cashiers

         INSERT INTO @result
                SELECT 5,
                       t.Type,
                       t.CreationDate,
                       t.Description,
                       NULL,--Debit
                       SUM(t.Usd),--Credit
                      -SUM(t.Usd) AS BalanceDetail
                FROM
                (
                    SELECT 'CASHIER TO CASHIER' AS Type,
                           CAST(dbo.ExtraFund.CreationDate AS DATE) AS CreationDate,
                           ISNULL(dbo.ExtraFund.Usd, 0) AS Usd,
                           'CLOSING DAILY' AS Description
                    FROM dbo.ExtraFund
                         INNER JOIN dbo.Users ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
                         INNER JOIN dbo.UserTypes ON dbo.Users.UserType = dbo.UserTypes.UsertTypeId
                    WHERE IsCashier = 1
                          AND dbo.ExtraFund.AgencyId = @AgencyId
                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                ) t
                GROUP BY t.CreationDate,
                         t.Type,
                         t.Description;
						         
						 -- ADMIN FROM CASHIER
         INSERT INTO @result
                SELECT 6,
                       t.Type,
                       t.CreationDate,
                       t.Description,
                       SUM(t.Usd),--Debit
                       NULL,--Credit
                        SUM(t.Usd) AS BalanceDetail
                FROM
                (
                    SELECT 'ADMIN FROM CASHIER' AS Type,
                           CAST(dbo.ExtraFund.CreationDate AS DATE) AS CreationDate,
                           ISNULL(dbo.ExtraFund.Usd, 0) AS Usd,
                           'CLOSING DAILY' AS Description
                    FROM dbo.ExtraFund
                         INNER JOIN dbo.Users ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
                         LEFT JOIN Cashiers c ON Users.UserId = c.UserId
                    WHERE CashAdmin = 1
                          AND dbo.ExtraFund.CashAdmin = 1
                          AND dbo.ExtraFund.AgencyId = @AgencyId
                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                ) t
                GROUP BY t.CreationDate,
                         t.Type,
                         t.Description;

-- Cashiers TO ADMIN

         INSERT INTO @result
                SELECT 7,
                       t.Type,
                       t.CreationDate,
                       t.Description,
                       NULL,--Debit
                       SUM(t.Usd), --Credit
                       -SUM(t.Usd) AS BalanceDetail
                FROM
                (
                    SELECT 'CASHIER TO ADMIN' AS Type,
                           CAST(dbo.ExtraFund.CreationDate AS DATE) AS CreationDate,
                           ISNULL(dbo.ExtraFund.Usd, 0) AS Usd,
                           'CLOSING DAILY' AS Description
                    FROM dbo.ExtraFund
                         INNER JOIN dbo.Users ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
                         LEFT JOIN Cashiers c ON Users.UserId = c.UserId
                    WHERE CashAdmin = 1
                          AND dbo.ExtraFund.AgencyId = @AgencyId
                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                          AND CAST(dbo.ExtraFund.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                ) t
                GROUP BY t.CreationDate,
                         t.Type,
                         t.Description;
            

         RETURN;
     END;






GO