SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPaymentInstructionStatus]
AS
     SET NOCOUNT ON;
    BEGIN
        SELECT *
        FROM InstructionPaymentStatus;
    END;
GO