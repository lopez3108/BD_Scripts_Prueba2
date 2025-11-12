SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteConciliationSalesTaxes](@ConciliationSalesTaxId INT,@CurrentDate DATETIME)
AS

BEGIN

  IF (CAST(@CurrentDate AS DATE) <> (SELECT TOP 1
        CAST(CreationDate AS DATE)
      FROM ConciliationSalesTaxes
      WHERE ConciliationSalesTaxId = @ConciliationSalesTaxId)
    )
  BEGIN
    SELECT
      -1
  END
  ELSE
     BEGIN
         DELETE FROM ConciliationSalesTaxes
         WHERE ConciliationSalesTaxId = @ConciliationSalesTaxId;
     END;

END;

GO