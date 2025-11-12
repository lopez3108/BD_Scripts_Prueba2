SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Create  Felipe
--Date: 24-Enero-2024
CREATE PROCEDURE [dbo].[sp_DeletedForex] ( @ForexId int, @IsDebit BIT)
AS 

BEGIN

IF(CAST(@IsDebit as BIT) = CAST(0 as BIT))
BEGIN

DELETE Forex WHERE ForexId =  @ForexId
SELECT @ForexId

END
ELSE
BEGIN

IF (EXISTS(SELECT TOP 1 * FROM dbo.Expenses e WHERE e.ExpenseId = @ForexId AND e.ValidatedOn IS NOT NULL))
BEGIN

SELECT -6


END
ELSE
BEGIN
DELETE dbo.Expenses WHERE ExpenseId =  @ForexId
SELECT @ForexId
END

END

	END
GO