SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCheckElsById] @CheckElsId INT
AS
     BEGIN
         SELECT 
			C.PaymentChecksAgentToAgentId
			,c.Account
			,c.Routing,		
		dbo.[fn_GetReturnedCheckByCheckElsId](C.CheckElsId) HasReturnedCheck
         FROM [dbo].[ChecksEls] C 

         WHERE C.CheckElsId = @CheckElsId;
     END;
GO