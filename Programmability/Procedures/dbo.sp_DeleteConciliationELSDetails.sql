SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteConciliationELSDetails] 
@ConciliationELSId INT
AS
     BEGIN

DELETE [dbo].[ConciliationELSDetails] WHERE [ConciliationELSId] = @ConciliationELSId

		   SELECT @ConciliationELSId

END
GO