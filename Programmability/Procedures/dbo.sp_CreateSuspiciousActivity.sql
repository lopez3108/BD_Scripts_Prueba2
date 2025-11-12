SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateSuspiciousActivity]
 (
	  @SuspiciousActivityId int = null
	  ,@ProviderId INT
           ,@TransactionNumber VARCHAR(20)
           ,@USD DECIMAL(18,2)
           ,@Description VARCHAR(1000) = null
           ,@SAR BIT
           ,@AgencyId INT = NULL
           ,@CreationDate DATETIME = NULL
           ,@CreatedBy INT = NULL
		    ,@SuspiciousActivityStatusId INT = NULL

    )
AS 

BEGIN


IF(@SuspiciousActivityId IS NULL)
BEGIN

declare @statusId INT
set @statusId = (SELECT TOP 1 SuspiciousActivityStatusId FROM SuspiciousActivityStatus WHERE Description = 'PENDING')

INSERT INTO [dbo].[SuspiciousActivity]
           ([ProviderId]
           ,[TransactionNumber]
           ,[USD]
           ,[Note]
           ,[SAR]
           ,[AgencyId]
           ,[CreationDate]
           ,[CreatedBy]
		   ,[SuspiciousActivityStatusId])
     VALUES
           (@ProviderId
           ,@TransactionNumber
           ,@USD
           ,@Description
           ,@SAR
           ,@AgencyId
           ,@CreationDate
           ,@CreatedBy
		   ,@statusId)

		   END
		   ELSE
		   BEGIN


UPDATE [dbo].[SuspiciousActivity]
   SET [ProviderId] = @ProviderId
      ,[TransactionNumber] = @TransactionNumber
      ,[USD] = @USD
      ,[SAR] = @SAR
	  ,[SuspiciousActivityStatusId] = @SuspiciousActivityStatusId
 WHERE SuspiciousActivityId = @SuspiciousActivityId

		   END

	END
GO