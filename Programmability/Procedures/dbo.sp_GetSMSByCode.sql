SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSMSByCode]
(@Code   VARCHAR(4)
)
AS
     BEGIN

SELECT     TOP 1   dbo.FinancingMessages.FinancingMessageId, dbo.FinancingMessages.Title, dbo.FinancingMessages.Message, dbo.FinancingMessages.SMSCategoryId, dbo.SMSCategories.Code
FROM            dbo.FinancingMessages INNER JOIN
                         dbo.SMSCategories ON dbo.FinancingMessages.SMSCategoryId = dbo.SMSCategories.SMSCategoryId
    WHERE dbo.SMSCategories.Code = @Code
	 
	      END;
GO