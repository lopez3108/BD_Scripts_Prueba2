SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- Create Felipe
-- Date 28-febrero-2024
-- Task 5655 -- Pendiente de preguntar unas dudas a Jorge 

CREATE PROCEDURE [dbo].[sp_GetMoneyTransferxAgencyNumbers](@ProviderId INT,  @AgencyId INT)
AS

-- DECLARE @ProviderId INT ;
--  SET @ProviderId = (SELECT p.ProviderId FROM Providers p  WHERE p.Name = @ProviderName)

     BEGIN
         SELECT *
         FROM MoneyTransferxAgencyNumbers mt
             
         WHERE mt.AgencyId = @AgencyId AND mt.ProviderId = @ProviderId ;
     END;


GO