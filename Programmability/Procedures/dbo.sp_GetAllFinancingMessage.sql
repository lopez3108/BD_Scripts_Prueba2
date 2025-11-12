SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllFinancingMessage](@SMSCategoryId INT = NULL, @SMSCategoryCode VARCHAR(10) = NULL)
AS
     BEGIN
         SELECT FinancingMessageId,
                Title,
                Message,
			 s.Description Category, S.SMSCategoryId
         FROM FinancingMessages F INNER JOIN SMSCategories S ON S.SMSCategoryId = F.SMSCategoryId
	    INNER JOIN SMSCategories sc ON F.SMSCategoryId = SC.SMSCategoryId
         WHERE (S.SMSCategoryId = @SMSCategoryId
               OR @SMSCategoryId IS NULL) 
			AND (SC.Code = @SMSCategoryCode
               OR( @SMSCategoryCode IS NULL OR @SMSCategoryCode = '') ) 
         ORDER BY s.Description;
     END;
GO