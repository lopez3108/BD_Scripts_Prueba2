SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllDocuments] @DocumentId INT = NULL
AS
    BEGIN
        SELECT Documents.UpdatedBy, 
               Documents.UpdatedOn, 
               userby.Name CreatedByUser, 
               Documents.CreatedBy, 
               Documents.CreatedDate, 
               Documents.DocumentId, 
               Documents.Doc1Front, 
               Documents.Doc1Back, 
               Documents.Doc1Type, 
               Documents.Doc1Number, 
               Documents.Doc1Country, 
               Documents.Doc1State, 
               Documents.Doc1Expire, 
               Countries.Name AS Doc1CountryName, 
               TypeID.Description AS Doc1TypeName,
               CASE CAST(Documents.ExpireDoc1 AS BIT)
                   WHEN 1
                   THEN 'true'
                   ELSE 'false'
               END AS ExpireDoc1, 
               Documents.DocumentStatusId1, 
               DS.Code DocumentStatusCode1, 
               ds.Description DocumentStatusDescription1, 
               Documents.DocumentByClientId
        FROM Documents
             LEFT JOIN Countries ON Documents.Doc1Country = Countries.CountryId
             LEFT JOIN TypeID ON Documents.Doc1Type = TypeID.TypeId
             LEFT JOIN DocumentStatus ds ON Documents.DocumentStatusId1 = ds.DocumentStatusId
             LEFT JOIN Users userby ON userby.UserId = Documents.CreatedBy
        WHERE Documents.DocumentId = @DocumentId
              OR @DocumentId IS NULL;
    END;
GO