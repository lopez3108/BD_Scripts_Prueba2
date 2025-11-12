SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--CREATEDBY: JOHAN
--CREATEDON: 8-03-23
--USO: RETORNA LOS DETALLES PARA FEESERVICE
CREATE PROCEDURE [dbo].[sp_GetAllFeeServiceDetailsById]
                                           @TicketFeeServiceId INT
                                        
                                         
AS
    BEGIN

      SELECT *
     
      FROM TicketFeeServiceDetails
      WHERE TicketFeeServiceId = @TicketFeeServiceId
             
    END;

GO