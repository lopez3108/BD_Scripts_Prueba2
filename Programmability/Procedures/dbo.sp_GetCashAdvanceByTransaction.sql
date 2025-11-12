SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Create Felipe
--Creation date: 16-01-2024 
--Task : 5550
CREATE PROCEDURE [dbo].[sp_GetCashAdvanceByTransaction]
(
 @TransactionId		VARCHAR(15),
 @AgencyId			INT,
 @ProviderId		INT  = NULL
)
AS
     BEGIN
         SELECT  A.CashAdvanceOrBackId
				,A.ProviderId
				,A.TransactionId
				,A.Usd
				,A.Voucher
				,A.CreatedBy UserId
				,A.AgencyId
				,A.CreationDate
         FROM CashAdvanceOrBack A
		  LEFT JOIN Users usu ON A.CreatedBy = usu.UserId
         WHERE A.AgencyId = @AgencyId
               AND (A.ProviderId = @ProviderId)
			   AND A.TransactionId = @TransactionId
     END;
GO