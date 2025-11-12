SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReasonsCheckFraudExceptions]
@CheckFraudExceptionId INT
         
		 AS
		  
BEGIN

SELECT r.[ReasonCheckFraudExceptionId]
      ,r.[CheckFraudExceptionId]
      ,r.[Reason]
      ,r.[CreatedBy]
      ,r.[CreationDate]
	  ,u.Name
  FROM [dbo].[ReasonsCheckFraudExceptions] r INNER JOIN
  Users u ON u.UserId = r.CreatedBy
  WHERE r.CheckFraudExceptionId = @CheckFraudExceptionId

END




GO