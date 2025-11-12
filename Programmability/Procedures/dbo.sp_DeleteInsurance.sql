SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-05-22 DJ/6522: Crear seccion Insurance companies en el modulo Settings de los Properties

CREATE PROCEDURE [dbo].[sp_DeleteInsurance] 
@InsuranceId INT = NULL
AS
     BEGIN

	

	 IF(EXISTS(SELECT 1 FROM Properties WHERE InsuranceId = @InsuranceId))
	 BEGIN

	 SELECT -1

	 END
	 ELSE
	 BEGIN

	 DELETE dbo.Insurance WHERE InsuranceId = @InsuranceId

	 SELECT @InsuranceId


	 END
	


		 END
GO