SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllPermitType]
AS
     BEGIN
         SELECT *
         FROM  PermitTypes
     END;

GO