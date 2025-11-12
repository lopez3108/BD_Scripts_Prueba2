SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
		-- ===================================================
-- Author:		Juan Felipe Oquendo López 
-- Create date: 2021-12-29
-- Description:	Trae los estados de la orden.
-- ===================================================
CREATE   PROCEDURE [dbo].[sp_GetVinPermitStatus]
AS
     SET NOCOUNT ON;
    BEGIN
        SELECT *
        FROM VinPertmitStatus;
    END;
GO