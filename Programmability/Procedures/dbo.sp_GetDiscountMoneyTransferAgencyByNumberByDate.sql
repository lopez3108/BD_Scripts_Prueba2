SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetDiscountMoneyTransferAgencyByNumberByDate]
(@Number                  VARCHAR(10),
 @DiscountMoneyTransferId INT         = NULL,
 @AgencyId                INT,
 @CreationDate            DATE
)
AS
     BEGIN
         SELECT *
         FROM DiscountMoneyTransfers
         WHERE(CAST(CreationDate AS DATE) = CAST(@CreationDate AS DATE))
              AND AgencyId = @AgencyId
              AND Number = @Number
              AND (DiscountMoneyTransferId <> @DiscountMoneyTransferId
                   OR @DiscountMoneyTransferId IS NULL);
     END;
GO