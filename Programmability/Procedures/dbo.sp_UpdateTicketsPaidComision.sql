SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- task 6632 09-junio de 2025 Comisiones tickets JF
CREATE PROCEDURE [dbo].[sp_UpdateTicketsPaidComision]  
    @TicketIds NVARCHAR(MAX), @ProviderCommissionPaymentId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Tickets
    SET  ProviderCommissionPaymentId = @ProviderCommissionPaymentId
    WHERE TicketId IN (
        SELECT CAST(value AS INT)
        FROM STRING_SPLIT(@TicketIds, ',')
    )
  
    IF @@ROWCOUNT > 0
        RETURN 1; -- éxito
    ELSE
        RETURN 0; -- nada actualizado

END
GO