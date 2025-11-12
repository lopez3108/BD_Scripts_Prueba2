SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllDocumentsInformation] @Name             VARCHAR(50)  = NULL, 
                                                      @Telephone        VARCHAR(50)  = NULL, 
                                                      @DOB              DATETIME     = NULL, 
                                                      @DocumentStatusId INT          = NULL, 
                                                      @Date             DATETIME, 
                                                       @CashiersId       VARCHAR(500) = NULL, 
                                                      @AgenciesId       VARCHAR(500) = NULL
AS
    BEGIN
        IF(@Telephone IS NOT NULL)
            BEGIN
                DECLARE @tel VARCHAR(50);
                SET @tel = REPLACE(@Telephone, ' ', '');
            END;
        DECLARE @StatusCode VARCHAR(10)= NULL;
        IF(@DocumentStatusId IS NOT NULL)
            BEGIN
                SET @StatusCode =
                (
                    SELECT Code
                    FROM DocumentStatus
                    WHERE DocumentStatusId = @DocumentStatusId
                );
            END;
        SELECT DISTINCT 
               di.DocumentId, 
               di.Name, 
               di.Telephone, 
               di.Note, 
               di.CreatedDate, 
			   FORMAT(di.CreatedDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
               di.CreatedBy, 
               di.AgencyId, 
               userby.Name CreatedByUser, 
               a.Name AgencyName, 
               a.Code + ' - ' + a.Name AS CodeName, 
               di.UpdatedBy, 
               di.UpdatedOn, 
               di.Doc1Birth,
			   FORMAT(di.Doc1Birth, 'MM-dd-yyyy', 'en-US')  Doc1BirthFormat,
               userupdateby.Name UpdatedByUser, 
               (CASE
                    WHEN EXISTS
        (
            SELECT 1
            FROM
            (
                SELECT TOP 1 *
                FROM Documents DOC
                     JOIN DocumentStatus docs ON DOC.DocumentStatusId1 = docs.DocumentStatusId
                WHERE DOC.DocumentId = di.DocumentId
                ORDER BY DOC.CreatedDate DESC, 
                         DocumentByClientId DESC
            ) AS QUERY
            WHERE CAST(@Date AS DATE) > CAST(QUERY.Doc1Expire AS DATE)
        )
                    THEN CAST(1 AS BIT)
                    ELSE CAST(0 AS BIT)
                END) AS HasExpires,
				( SELECT top 1 docs.Description
                FROM Documents DOC
                     JOIN DocumentStatus docs ON DOC.DocumentStatusId1 = docs.DocumentStatusId
                WHERE DOC.DocumentId = di.DocumentId) AS Status,
				( SELECT top 1 docs.Code
                FROM Documents DOC
                     JOIN DocumentStatus docs ON DOC.DocumentStatusId1 = docs.DocumentStatusId
                WHERE DOC.DocumentId = di.DocumentId) AS StatusCode,
				v.Name as ValidatedByName,
				di.ValidatedOn
     FROM documentinformation di
             LEFT JOIN Documents d ON d.DocumentId = di.DocumentId
			 LEFT JOIN Users v ON v.UserId = di.ValidatedBy
             LEFT JOIN Users userby ON userby.UserId = di.CreatedBy
             LEFT JOIN Agencies a ON a.AgencyId = di.AgencyId
             LEFT JOIN DocumentStatus ds ON d.DocumentStatusId1 = ds.DocumentStatusId
             LEFT JOIN Users userupdateby ON userupdateby.UserId = di.UpdatedBy
        WHERE(di.Name LIKE '%' + @Name + '%'
              OR @Name IS NULL)
--             AND (di.CreatedBy = @UserId
--                  OR @UserId IS NULL)
             AND REPLACE(di.Telephone, ' ', '') LIKE CASE
                                                         WHEN @Telephone IS NULL
                                                         THEN REPLACE(di.Telephone, ' ', '')
                                                         ELSE '%' + @tel + '%'
                                                     END
             AND (@DOB IS NULL
                  OR CAST(di.Doc1Birth AS DATE) = CAST(@DOB AS DATE))
             AND ((@StatusCode IS NULL
                   AND EXISTS
        (
            SELECT 1
            FROM
            (
                SELECT TOP 1 *
                FROM Documents DOC
                     LEFT JOIN DocumentStatus docs ON DOC.DocumentStatusId1 = docs.DocumentStatusId
                WHERE DOC.DocumentId = di.DocumentId
                ORDER BY DOC.CreatedDate DESC, 
                         DOC.DocumentByClientId DESC
            ) AS QUERY
        ))
                   OR (EXISTS
        (
            SELECT 1
            FROM
            (
                SELECT TOP 1 *
                FROM Documents DOC
                     JOIN DocumentStatus docs ON DOC.DocumentStatusId1 = docs.DocumentStatusId
                WHERE DOC.DocumentId = di.DocumentId
                ORDER BY DOC.CreatedDate DESC, 
                         DocumentByClientId DESC
            ) AS QUERY
            WHERE CAST(@Date AS DATE) <= CAST(QUERY.Doc1Expire AS DATE)
                  AND QUERY.Code = @StatusCode
        )))
                   AND (a.AgencyId IN
        (
            SELECT item
            FROM dbo.FN_ListToTableInt(@AgenciesId)
        )
                  OR (@AgenciesId = ''
                      OR @AgenciesId IS NULL))

      AND (di.CreatedBy IN
        (
            SELECT item
            FROM dbo.FN_ListToTableInt(@CashiersId)
        )
                  OR (@CashiersId = ''
                      OR @CashiersId IS NULL))
        GROUP BY di.DocumentId, 
                 di.Name, 
                 di.Telephone, 
                 di.Note, 
                 di.CreatedDate, 
                 di.CreatedBy, 
                 di.AgencyId, 
                 userby.Name, 
                 a.Name,
				 v.Name,
				 di.validatedOn,
                 a.Code, 
                 di.UpdatedBy, 
                 di.UpdatedOn, 
                 di.Doc1Birth, 
                 userupdateby.Name;
    END;

GO