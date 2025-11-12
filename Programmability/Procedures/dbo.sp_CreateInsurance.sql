SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Creates a new insurance company
-- =============================================

-- 2025-05-22 DJ/6522: Crear seccion Insurance companies en el modulo Settings de los Properties

CREATE PROCEDURE [dbo].[sp_CreateInsurance] 
@InsuranceId INT = NULL,
@Name VARCHAR(40),
@Telephone VARCHAR(10),
@Url VARCHAR(400) = NULL
AS
     BEGIN

	 IF(@InsuranceId IS NULL)
	 BEGIN

	 IF(EXISTS(SELECT 1 FROM Insurance WHERE Name = @Name))
	 BEGIN

	 SELECT -1

	 END
	 ELSE
	 BEGIN
         
		INSERT INTO [dbo].[Insurance]
           ([Name]
           ,[Telephone]
		   ,[URL])
     VALUES
           (@Name
           ,@Telephone
		   ,@Url)

		   SELECT @@IDENTITY

		   END

		   END
		   ELSE
		   BEGIN

		   UPDATE [dbo].[Insurance]
   SET [Name] = @Name
      ,[Telephone] = @Telephone
	  ,[URL] = @Url
 WHERE InsuranceId = @InsuranceId

 SELECT @InsuranceId

		   END



		 END
GO