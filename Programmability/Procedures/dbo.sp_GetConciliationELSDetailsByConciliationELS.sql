SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetConciliationELSDetailsByConciliationELS] 
@ConciliationELSId INT = NULL
AS
     BEGIN

SELECT [Usd]
  FROM [dbo].[ConciliationELSDetails]
  WHERE [ConciliationELSId] = @ConciliationELSId

END
GO