SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateConciliationELSDetail] 
@ConciliationELSId INT,
@Usd DECIMAL(18,2)
AS
     BEGIN

INSERT INTO [dbo].[ConciliationELSDetails]
           ([ConciliationELSId]
           ,[Usd])
     VALUES
           (@ConciliationELSId
           ,@Usd)

		   SELECT @@IDENTITY

END
GO