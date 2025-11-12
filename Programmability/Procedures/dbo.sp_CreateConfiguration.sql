SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateConfiguration]

@ConfigurationId int = null,
@MinimumFee decimal(18,2),
@MaximumFee decimal(18,2)
 

AS 

BEGIN

IF(@ConfigurationId IS NULL)
BEGIN
INSERT INTO [dbo].[Configuration]
           ([MinimumFee]
           ,[MaximumFee]
		  )

     VALUES
           (@MinimumFee
           ,@MaximumFee
		 )

		   SELECT @@IDENTITY

		   END
		   ELSE
		   BEGIN

		   UPDATE [dbo].[Configuration] SET MinimumFee = @MinimumFee, MaximumFee = @MaximumFee
		   WHERE ConfigurationId = @ConfigurationId

		   SELECT @ConfigurationId

		   END
		  

	END
GO