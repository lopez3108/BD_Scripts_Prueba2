SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllDeliveryTypes]
AS
     BEGIN
         SELECT *
         FROM DeliveryTypes
         ORDER BY Description;
     END;


GO