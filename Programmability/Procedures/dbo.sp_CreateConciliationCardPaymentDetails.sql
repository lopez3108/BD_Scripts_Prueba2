SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateConciliationCardPaymentDetails] 
@ConciliationCardPaymentId INT,
@Usd DECIMAL(18,2)
AS
     BEGIN

INSERT INTO [dbo].[ConciliationCardPaymentsDetails]
           ([ConciliationCardPaymentId]
           ,[Usd])
     VALUES
           (@ConciliationCardPaymentId
           ,@Usd)

		   SELECT @@IDENTITY

END
GO