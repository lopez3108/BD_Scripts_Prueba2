SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateReturnedChecksxAgencyInitialBalance] 
@AgencyId INT,
@InitialBalance DECIMAL(18,2)
AS
     BEGIN

	 INSERT INTO [dbo].[ReturnedChecksxAgencyInitialBalances]
           ([AgencyId]
           ,[InitialBalance])
     VALUES
           (@AgencyId
           ,@InitialBalance)

		   SELECT @@IDENTITY

END
GO