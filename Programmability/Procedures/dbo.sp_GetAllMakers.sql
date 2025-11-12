SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllMakers]
AS
     SET NOCOUNT ON;
     BEGIN
         SELECT DISTINCT
                m.*, dbo.EntityTypes.[Description] as EntityTypeName
         FROM [dbo].[Makers] m INNER JOIN
                         dbo.EntityTypes ON m.EntityTypeId = dbo.EntityTypes.EntityTypeId
			--inner join AddressXMaker am ON m.MakerId = am.MakerId
         ORDER BY m.[Name];
     END;
GO