SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
		-- ===================================================
-- Author:		Juan Felipe Oquendo López 
-- Create date: 2021-12-28
-- Description:	Delete DeleteAgenciesXOrdersSupplies by id
-- ===================================================
CREATE   PROCEDURE [dbo].[sp_DeleteAgenciesXOrdersSuppliesById](@AgenciesXOrdersSuppliesId INT)
AS
    BEGIN
        DELETE FROM AgenciesXOrdersSupplies
        WHERE AgenciesXOrdersSuppliesId = @AgenciesXOrdersSuppliesId;
    END;
GO