SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSystemToolsValues] @BillId INT = NULL
AS
     BEGIN
         SELECT *,
		 s.Value AS usd,
		 	 s.Fee 
		 FROM SystemToolsValues s
         WHERE s.BillId = @BillId;
     END;
GO