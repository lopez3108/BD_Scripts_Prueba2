SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created: FELIPE
--CReated: 21-12-2023

-- =============================================
-- Author:      JF
-- Create date: 11/06/2024 11:37 p. m.
-- Database:    devtest
-- Description: 5895 Nueva alerta QA OTHER PAYMENTS (PENDING)
-- =============================================




CREATE PROCEDURE [dbo].[sp_GetDateOtherPaymentById]
@Id INT = null
AS
    
     BEGIN
        SELECT
        DailyId,
        FORMAT(CreationDate, 'MM-dd-yyyy', 'en-US') CreationDate ,
        completed  AS  Completed     
        FROM OtherPayments
        WHERE OtherPaymentId = @Id;		
     END;



GO