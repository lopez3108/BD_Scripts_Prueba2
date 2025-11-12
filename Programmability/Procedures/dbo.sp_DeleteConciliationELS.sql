SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteConciliationELS] 
@ConciliationELSId INT,
@CurrentDate DATETIME
AS
     BEGIN

IF(CAST(@CurrentDate as DATE) <> (SELECT TOP 1 CAST(CreationDate as DATE) FROM ConciliationELS WHERE
ConciliationELSId = @ConciliationELSId))
BEGIN

SELECT -1

END
ELSE
BEGIN

DELETE FROM [dbo].[ConciliationELSDetails]
      WHERE ConciliationELSId = @ConciliationELSId

DELETE ConciliationELS WHERE 
ConciliationELSId = @ConciliationELSId

SELECT @ConciliationELSId

END

END
GO