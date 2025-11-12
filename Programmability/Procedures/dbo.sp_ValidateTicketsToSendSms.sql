SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 8-01-2025 Pinzon/6188: Validate existing tickets
CREATE PROCEDURE [dbo].[sp_ValidateTicketsToSendSms]    
    @TicketToSendTableType TicketToSendTableType READONLY
AS
BEGIN  
        
 -- Crear tabla temporal para errores y registros ok
   SELECT 
    O.TicketNumber,     
    CASE     
        WHEN T.TicketNumber IS NOT NULL THEN 'ticket_already_exist_error'                
    END AS errorMessage
INTO #TicketsTemp
FROM @TicketToSendTableType O
INNER JOIN dbo.Tickets T ON UPPER(O.TicketNumber COLLATE SQL_Latin1_General_CP1_CI_AS) = UPPER(T.TicketNumber)
 WHERE T.TicketNumber IS NOT NULL

   -- Mostrar registros con errores osea diferentes a ok
SELECT * FROM #TicketsTemp 

-- al final limpiamos tablas temporales
DROP TABLE #TicketsTemp;


END
GO