SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreatePaymentAdjustment]

@AgencyFromId INT,
@AgencyToId INT,
@ProviderId INT,
@Usd DECIMAL(18,2),
@CreationDate DATETIME,
@CreatedBy INT,
@Date DATETIME

AS
     BEGIN


INSERT INTO [dbo].[PaymentAdjustment]
           ([AgencyFromId]
		   ,[AgencyToId]
           ,[ProviderId]
           ,[USD]
           ,[CreationDate]
		   ,[CreatedBy]
		   ,[Date])
     VALUES
           (@AgencyFromId
		   ,@AgencyToId
           ,@ProviderId
           ,@Usd
           ,@CreationDate
		   ,@CreatedBy
		   ,@Date)

		   SELECT @@IDENTITY




     END;
GO