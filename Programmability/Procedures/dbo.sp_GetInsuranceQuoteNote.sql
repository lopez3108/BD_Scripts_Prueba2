SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-02-24 CB/6365: Insurance quot

CREATE PROCEDURE [dbo].[sp_GetInsuranceQuoteNote] 
@InsuranceQuoteId INT
AS

BEGIN

SELECT i.InsuranceQuoteNoteId
,i.InsuranceQuoteId
,i.Note
,i.CreationDate
,i.CreatedBy
      ,u.Name CreatedByName
  FROM [dbo].[InsuranceQuoteNote] i INNER JOIN
  dbo.Users u ON u.UserId = i.createdBy
  WHERE 
  (i.InsuranceQuoteId = @InsuranceQuoteId) 
  

END
GO