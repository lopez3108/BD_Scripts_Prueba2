SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteElsAgencyInitialBalance] @ProviderId INT
AS
     BEGIN
         DELETE  FROM [dbo].ElsxAgencyInitialBalances
         WHERE ProviderId = @ProviderId;
     END;
GO