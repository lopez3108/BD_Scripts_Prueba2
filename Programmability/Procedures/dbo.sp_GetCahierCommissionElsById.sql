SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- Create By:      Felipe
-- Creation Date:  24-Marzo-2024
-- Task:           5751 Save commission values ​​for city stickers

CREATE PROCEDURE [dbo].[sp_GetCahierCommissionElsById](@CreatedBy INT, @Code VARCHAR(4), @DateApplyComissions DATE)
AS    
      

   BEGIN  
   
    DECLARE @valor DECIMAL(18, 2);
    -- Llamando a la función dentro del procedimiento
    SET @valor = dbo.fn_GetCahierCommissionElsById(@CreatedBy,@Code,@DateApplyComissions); 
   
    SELECT @valor AS CommissionResult;
      
  
    END;
    


GO