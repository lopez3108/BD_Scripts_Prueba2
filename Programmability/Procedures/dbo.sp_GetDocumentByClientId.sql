SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_GetDocumentByClientId] @DocumentId INT
AS
    BEGIN
        SELECT userby.Name CreatedByUser, 
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
			   Documents.DocumentByClientId
        FROM Documents
             LEFT JOIN Countries ON Documents.Doc1Country = Countries.CountryId
             LEFT JOIN TypeID ON Documents.Doc1Type = TypeID.TypeId
             LEFT JOIN Users userby ON userby.UserId = Documents.CreatedBy
        WHERE Documents.DocumentByClientId = @DocumentId;
    END;
GO