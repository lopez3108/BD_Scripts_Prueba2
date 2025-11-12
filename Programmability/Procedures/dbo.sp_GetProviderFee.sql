SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      JF
-- Create date: 14/07/2024 2:10 p. m.
-- Database:    copiaDevtest
-- Description: task 5916 Aplicar fee a los para los VEHICLE SERVICES RETURNED
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetProviderFee] ( @InventoryELSId int )

AS 

BEGIN
 DECLARE @ProvidersElsId INT  

IF ( @InventoryELSId = 1) BEGIN  --City sticker

 SET @ProvidersElsId = (SELECT pe.ProviderElsId ReturnsELSStatusId FROM ProvidersEls pe WHERE Code = 'C03')

SELECT pe.FeeELS FROM ProvidersEls pe
WHERE pe.ProviderElsId = @ProvidersElsId
	
END  ELSE 
IF ( @InventoryELSId = 3 OR @InventoryELSId = 4 OR @InventoryELSId = 16 OR @InventoryELSId = 17 OR @InventoryELSId = 18) BEGIN  --B-truk plate 

 SET @ProvidersElsId = (SELECT pe.ProviderElsId ReturnsELSStatusId FROM ProvidersEls pe WHERE Code = 'C01')

SELECT pe.FeeELS FROM ProvidersEls pe
WHERE pe.ProviderElsId = @ProvidersElsId
	
END ELSE 
IF ( @InventoryELSId = 5 ) BEGIN  --Registration renewal

 SET @ProvidersElsId = (SELECT pe.ProviderElsId ReturnsELSStatusId FROM ProvidersEls pe WHERE Code = 'C04')

SELECT pe.FeeELS FROM ProvidersEls pe
WHERE pe.ProviderElsId = @ProvidersElsId
	
END ELSE 
IF ( @InventoryELSId = 6 OR @InventoryELSId = 14 OR @InventoryELSId = 15) BEGIN  --TRP

 SET @ProvidersElsId = (SELECT pe.ProviderElsId ReturnsELSStatusId FROM ProvidersEls pe WHERE Code = 'C02')

SELECT pe.FeeELS FROM ProvidersEls pe
WHERE pe.ProviderElsId = @ProvidersElsId
	
END

	END
GO