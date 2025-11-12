SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateConciliationOtherDistribution] 
@ConciliationOtherId INT,
@AgencyId INT = NULL,
@Usd DECIMAL(18,2)
AS
     BEGIN

INSERT INTO [dbo].[ConciliationOthersDistributions]
           ([ConciliationOtherId]
           ,[AgencyId]
           ,[Usd])
     VALUES
           (@ConciliationOtherId
           ,@AgencyId
           ,@Usd)

		   SELECT @@IDENTITY

END
GO