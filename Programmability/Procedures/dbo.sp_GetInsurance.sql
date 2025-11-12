SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Returns insurance list
-- =============================================

-- 2025-05-22 DJ/6522: Crear seccion Insurance companies en el modulo Settings de los Properties

CREATE PROCEDURE [dbo].[sp_GetInsurance] 
AS
     BEGIN
         
		SELECT        InsuranceId, UPPER([Name]) as [Name], Telephone, URL
FROM            dbo.Insurance
ORDER BY Name ASC



		 END
GO