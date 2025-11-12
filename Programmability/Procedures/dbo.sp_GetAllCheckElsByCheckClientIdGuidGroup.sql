SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllCheckElsByCheckClientIdGuidGroup] @CheckClientIdGuidGroup VARCHAR(100)
AS
  SET NOCOUNT ON;
  BEGIN
    SELECT
      E.CheckNumber
     ,ISNULL(E.Amount, 0) AS Amount
     ,ISNULL(E.Amount, 0) * (ISNULL(E.Fee, 0)/100) AS Fee
     ,ISNULL(PC.Usd, 0) AS Discount
     ,(ISNULL(E.Amount, 0) - (ISNULL(E.Amount, 0) * (ISNULL(E.Fee, 0)/100)) ) + ISNULL(PC.Usd, 0) AS Total -- falta sumarle el discount
    FROM ChecksEls E
	 LEFT JOIN PromotionalCodesStatus P ON E.CheckElsId = p.CheckId
              LEFT JOIN PromotionalCodes pc ON pc.PromotionalCodeId = p.PromotionalCodeId
    WHERE E.CheckClientIdGuidGroup = @CheckClientIdGuidGroup
  END

GO