SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:22-09-2023
--CAMBIOS EN 5398, Registros del modulo Concilliation deben hacer la operacion inversa en reportes

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:09-10-2023
--CAMBIOS EN 5425 (NO DEBE DE MOSTRAR EL VALOR CONTABLE INVERSO SOLO PARA ESTE REPORTE)

-- 5514: INITAL BALANCE Added to the report

CREATE FUNCTION [dbo].[fn_GetReportExpenseBankDetail]
(@AgencyId INT, 
 @FromDate DATETIME = NULL, 
 @ToDate   DATETIME = NULL, 
 @Date     DATETIME
)RETURNS @result TABLE (
  RowNumber     INT, 
         Date          DATETIME, 
         Type          VARCHAR(1000), 
         Description   VARCHAR(1000), 
         Account       VARCHAR(15), 
         Employee      VARCHAR(50), 
         TypeId        INT, 
         Debit         DECIMAL(18, 2), 
         Credit        DECIMAL(18, 2), 
         BalanceDetail DECIMAL(18, 2)
)
AS
    BEGIN
      
	  
	   DECLARE @TempTableExpenseDetail TABLE
        (RowNumber     INT, 
         Date          DATETIME, 
         Type          VARCHAR(1000), 
         Description   VARCHAR(1000), 
         Account       VARCHAR(15), 
         Employee      VARCHAR(50), 
         TypeId        INT, 
         Debit         DECIMAL(18, 2), 
         Credit        DECIMAL(18, 2), 
         BalanceDetail DECIMAL(18, 2)
        );

	  INSERT INTO @TempTableExpenseDetail
        (
		RowNumber,
         Date, 
         Type, 
         Description, 
         Account, 
         Employee, 
         TypeId, 
         Debit, 
         Credit, 
         BalanceDetail)
         SELECT
      *
    FROM (SELECT
        ROW_NUMBER() OVER (
        ORDER BY q.TypeId ASC,
        CAST(q.Date AS Date) ASC) RowNumberDetail
       ,*
      FROM (
                   
                       SELECT CAST(E.CreationDate AS DATE) AS Date, 
                              c.Description AS Type, 
                          CASE c.Code
                                  WHEN 'C15'
                                  THEN   A.Code +'-'+ E.Description
                                  ELSE   A.Code +'-'+  c.Description
                              END AS Description,  
                              '**** ' + b.AccountNumber AS Account, 
                              U.name AS Employee, 
                              1 TypeId, 
                               0 Debit, 
                               ABS(SUM(E.Usd)) AS Credit, 
                              -ABS(SUM(E.Usd)) AS BalanceDetail
                       FROM dbo.[ConciliationOthers] E
                            INNER JOIN ConciliationOtherTypes c ON E.ConciliationOtherTypeId = c.ConciliationOtherTypeId
                            INNER JOIN BankAccounts b ON E.BankAccountId = B.BankAccountId
                            INNER JOIN Users U ON u.UserId = E.CreatedBy
							        INNER JOIN Agencies A ON A.AgencyId = E.AgencyId
                       WHERE E.AgencyId = @AgencyId
                             AND E.Iscredit = 1
                             AND (CAST(E.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                  OR @FromDate IS NULL)
                             AND (CAST(E.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                                  OR @ToDate IS NULL)
                       GROUP BY CAST(E.CreationDate AS DATE), 
                                U.Name, 
                                c.Description, 
								E.Description,
                                E.ConciliationOtherId,
								c.Code,
								b.AccountNumber,
								 A.Code
                       UNION ALL
                       SELECT CAST(E.CreationDate AS DATE) AS Date, 
                              c.Description AS Type,
                              CASE c.Code
                                  WHEN 'C15'
                                  THEN  A.Code +'-'+ E.Description
                                  ELSE  A.Code +'-'+ c.Description
                              END AS Description, 
                             '**** ' +  b.AccountNumber AS Account, 
                              U.name AS Employee, 
                              2 TypeId, 
                              ABS(SUM(E.Usd))  AS Debit, 
                             0 Credit, 
                              ABS(SUM(E.Usd)) AS BalanceDetail
                       FROM dbo.[ConciliationOthers] E
                            INNER JOIN ConciliationOtherTypes c ON E.ConciliationOtherTypeId = c.ConciliationOtherTypeId
                            INNER JOIN BankAccounts b ON E.BankAccountId = B.BankAccountId
                            INNER JOIN Users U ON u.UserId = E.CreatedBy
							 INNER JOIN Agencies A ON A.AgencyId = E.AgencyId
                       WHERE E.AgencyId = @AgencyId
                             AND E.Iscredit = 0
                             AND (CAST(E.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                  OR @FromDate IS NULL)
                             AND (CAST(E.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                                  OR @ToDate IS NULL)
                       GROUP BY CAST(E.CreationDate AS DATE), 
                                U.Name, 
                                c.Description, 
								E.Description,
                                E.ConciliationOtherId,
								c.Code,
									b.AccountNumber,
									 A.Code

                   ) q ) qf
				    ORDER BY RowNumberDetail ASC;

	
	INSERT INTO	@result
	SELECT * FROM @TempTableExpenseDetail

	RETURN
    END;

GO