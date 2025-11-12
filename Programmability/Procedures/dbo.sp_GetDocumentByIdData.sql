SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetDocumentByIdData] @DocumentId INT, 
                                               @Date       DATETIME
AS
    BEGIN
        SELECT userby.Name CreatedByUser, 
               Documents.CreatedBy, 
               Documents.CreatedDate, 
               Documents.DocumentId, 
               Documents.DocumentByClientId, 
               --Documents.Name, 
               --Documents.Telephone, 
               Documents.Doc1Front, 
               Documents.Doc1Back, 
               Documents.Doc1Type, 
               Documents.Doc1Number, 
               Documents.Doc1Country, 
               Documents.Doc1State, 
               Documents.Doc1Expire, 
               --Documents.Doc1Birth, 
               Countries.Name AS Doc1CountryName, 
               TypeID.Description AS Doc1TypeName, 
               --Documents.Note,
               CASE
                   WHEN(CAST(Documents.Doc1Expire AS DATE) < CAST(@Date AS DATE))
                   THEN CAST(1 AS BIT)
                   ELSE CAST(0 AS BIT)
               END AS DocExpired, 
               Documents.DocumentStatusId1, 
               DS.Code DocumentStatusCode1, 
               ds.Description DocumentStatusDescription1, 
               Documents.UpdatedBy, 
               Documents.UpdatedOn
        FROM Documents
             LEFT JOIN Countries ON Documents.Doc1Country = Countries.CountryId
             LEFT JOIN TypeID ON Documents.Doc1Type = TypeID.TypeId
             LEFT JOIN Users userby ON userby.UserId = Documents.CreatedBy
             LEFT JOIN DocumentStatus ds ON Documents.DocumentStatusId1 = ds.DocumentStatusId
        WHERE Documents.DocumentId = @DocumentId;
    END;
GO