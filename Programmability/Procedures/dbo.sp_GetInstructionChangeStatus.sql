SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetInstructionChangeStatus]
AS
     SET NOCOUNT ON;
    BEGIN
        SELECT *
        FROM InstructionChangeStatus;
    END;
GO