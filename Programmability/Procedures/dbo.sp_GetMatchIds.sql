SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetMatchIds] @Name       VARCHAR(80) = NULL, 
                                       @Telephone  VARCHAR(10) = NULL, 
                                       @DocumentId INT         = NULL, 
                                       @DOB        DATETIME    = NULL
AS
    BEGIN
        IF EXISTS
        (
            SELECT di.DocumentId AS DocumentId
            FROM DocumentInformation di
            WHERE di.Name = @Name
                  AND di.Telephone = @Telephone
                  AND CAST(di.Doc1Birth AS DATE) = CAST(@DOB AS DATE)
                  AND (di.DocumentId != @DocumentId
                       OR @DocumentId IS NULL)
        )
            SELECT 1 TypeSearch, --Cliente existente con mismo nombre y tel
                   di.Name, 
                   di.Telephone, 
                   di.DocumentId AS DocumentId, 
                   di.Doc1Birth, 
                   di.Note
            FROM DocumentInformation di
            WHERE di.Name = @Name
                  AND di.Telephone = @Telephone
                  AND (di.DocumentId != @DocumentId
                       OR @DocumentId IS NULL);
            ELSE
            BEGIN
                SELECT 2 TypeSearch, --Cliente 'like' por nombre y tel
                       di.Name, 
                       di.Telephone, 
                       di.DocumentId AS DocumentId, 
                       di.Doc1Birth, 
                       di.Note
                FROM DocumentInformation di
                WHERE(FREETEXT(di.Name, @Name)
                      AND (di.Telephone = @Telephone))
                     OR (FREETEXT(di.Name, @Name)
                         AND (CAST(di.Doc1Birth AS DATE) = CAST(@DOB AS DATE)))
                     OR ((di.Telephone = @Telephone)
                         AND (CAST(di.Doc1Birth AS DATE) = CAST(@DOB AS DATE)))
                     AND (di.DocumentId <> @DocumentId
                          OR @DocumentId IS NULL);

                --(FREETEXT(di.Name, @Name)
                --                  AND (di.Telephone = @Telephone  OR @Telephone IS NULL)
                --                 AND (CAST(di.Doc1Birth AS DATE) = CAST(@DOB AS DATE)
                --                     ))
                --                 AND (di.DocumentId <> @DocumentId
                --                      OR @DocumentId IS NULL);

            END;
    END;
GO