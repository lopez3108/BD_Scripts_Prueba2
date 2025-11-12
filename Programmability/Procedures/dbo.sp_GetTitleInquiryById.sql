SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetTitleInquiryById]
(@TitleInquiryId    INT  )
AS
     BEGIN
         SELECT  t.TitleInquiryId,
                 t.Usd,
				 t.Fee1,
				 t.CreationDate
				                        
         FROM  TitleInquiry t 
         WHERE t.TitleInquiryId = @TitleInquiryId
     END;
GO