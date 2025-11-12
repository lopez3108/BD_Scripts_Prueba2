SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteExtraFund](@ExtraFundId INT)
AS
     BEGIN
         DELETE ExtraFund
         WHERE ExtraFundId = @ExtraFundId;
         SELECT 1;
     END;
GO