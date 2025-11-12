SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPermitTypeById](@PermitTypeId INT)
AS
     BEGIN
         SELECT *
         FROM PermitTypes
         WHERE PermitTypeId = @PermitTypeId;
     END;

GO