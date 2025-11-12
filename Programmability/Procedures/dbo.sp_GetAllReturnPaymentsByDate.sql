SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllReturnPaymentsByDate]
(@From DATE,
 @To     DATE,
 @AgencyId INT,
 @CreatedBy INT
)
AS
BEGIN 

DECLARE @result TABLE (
Date DATETIME,
USD DECIMAL(18,2),
Name VARCHAR(50)
)

	 -- Returned checks

	 INSERT INTO @result
             SELECT 
			 CAST(dbo.ReturnPayments.CreationDate AS DATE) as DATE,
			 dbo.ReturnPayments.Usd as USD,
			 'RETURNED CHECKS' as Name
             FROM dbo.ReturnPayments 
						 WHERE 
						 CAST(dbo.ReturnPayments.CreationDate as DATE) >= CAST(@From as DATE) AND
						 CAST(dbo.ReturnPayments.CreationDate as DATE) <= CAST(@To as DATE) AND
						 CreatedBy = @CreatedBy AND
						 AgencyId = CASE WHEN @AgencyId IS NULL THEN AgencyId ELSE @AgencyId END
         

		SELECT SUM(USD) as USD, Name, CAST(Date as DATE) as Date  FROM @result
		GROUP BY Name, CAST(DATE as DATE)







     END;
GO