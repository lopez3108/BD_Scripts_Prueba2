SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created: FELIPE
--CReated: 2-01-2024
--Task 5550

CREATE PROCEDURE [dbo].[sp_GetAllCashAdvanceByProvider]
(@Creationdate DATE = NULL,
 @AgencyId     INT,
 @CreatedBy    INT,
 @ProviderId   INT  = NULL
)
AS
     BEGIN
         SELECT  C.CashAdvanceOrBackId
				,C.ProviderId
				,C.TransactionId
				,C.Usd
				,C.Voucher 
				,C.CreatedBy AS UserId
				,C.AgencyId
				,C.CreationDate
				,C.LastUpdatedOn
				,C.LastUpdatedBy
				,u.Name LastUpdatedByName
         FROM CashAdvanceOrBack C

		 LEFT JOIN Users usu ON C.CreatedBy = usu.UserId
      LEFT JOIN Users u ON C.LastUpdatedBy = u.UserId
         WHERE C.AgencyId = @AgencyId
               AND (CAST(C.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
               AND C.CreatedBy = @CreatedBy
               AND (C.ProviderId = @ProviderId
                    OR @ProviderId IS NULL);
     END;



GO