SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetInventoryElsByAgencyByInventoryCode]
(@InventoryELSCode VARCHAR(10),
 @AgencyId         INT,
 @CashierId INT = NULL
)
AS
     BEGIN
         SELECT *
         FROM InventoryELS I
              LEFT JOIN InventoryELSByAgency IA ON I.InventoryELSId = IA.InventoryELSId AND IA.AgencyId = @AgencyId AND (@CashierId IS NULL OR IA.CashierId = @CashierId)
         WHERE I.Code = @InventoryELSCode
          
     END;
GO