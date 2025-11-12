SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-02-22 DJ/6365: Insurance quot

CREATE PROCEDURE [dbo].[sp_GetDriverLicenseType] 

AS
     BEGIN

	 SELECT 
	 d.DriverLicenseTypeId,
	 d.Description,
	 d.[Order],
	 d.Code
	 FROM DriverLicenseType d
	 ORDER BY d.[Order] ASC

	 END
GO