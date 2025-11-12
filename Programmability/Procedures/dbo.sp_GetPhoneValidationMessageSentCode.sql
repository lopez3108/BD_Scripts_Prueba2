SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPhoneValidationMessageSentCode] 
AS
     BEGIN

	 
		SELECT        dbo.FinancingMessages.Message
FROM            dbo.FinancingMessages INNER JOIN
                         dbo.SMSCategories ON dbo.FinancingMessages.SMSCategoryId = dbo.SMSCategories.SMSCategoryId				 

						 WHERE dbo.SMSCategories.Code = 'C25'
     END;
GO