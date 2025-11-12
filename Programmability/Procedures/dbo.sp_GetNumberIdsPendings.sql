SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetNumberIdsPendings]
(@UserId AS   INT, 
 @AgencyId AS INT,
 @CurrentDate AS DATE
)
AS
    BEGIN
        DECLARE @StatusId INT;
        SET @StatusId =
        (
            SELECT DocumentStatus.DocumentStatusId
            FROM DocumentStatus
            WHERE Code = 'C02'
        );
	 SELECT COUNT(*) Pendings FROM (
          SELECT DISTINCT 
               di.DocumentId, 
               di.Name, 
               di.Telephone, 
               di.Note, 
               di.CreatedDate, 
               di.CreatedBy, 
               di.AgencyId, 
               userby.Name CreatedByUser, 
               a.Name AgencyName, 
               a.Code + ' - ' + a.Name AS CodeName, 
               di.UpdatedBy, 
               di.UpdatedOn, 
               di.Doc1Birth, 
               userupdateby.Name UpdatedByUser
			    FROM documentinformation di
             LEFT JOIN Documents d ON d.DocumentId = di.DocumentId
             LEFT JOIN Users userby ON userby.UserId = di.CreatedBy
             LEFT JOIN Agencies a ON a.AgencyId = di.AgencyId
             LEFT JOIN DocumentStatus ds ON d.DocumentStatusId1 = ds.DocumentStatusId
             LEFT JOIN Users userupdateby ON userupdateby.UserId = di.UpdatedBy


			 WHERE (di.CreatedBy = @UserId
                  OR @UserId IS NULL)
            AND
           -- PREDIENTES Y NO EXPIRADOS  
			  ((
			  
			  EXISTS
			 (
            SELECT 1
            FROM
            (
                SELECT TOP 1 *
                FROM Documents DOC
                     JOIN DocumentStatus docs ON DOC.DocumentStatusId1 = docs.DocumentStatusId
                WHERE DOC.DocumentId = di.DocumentId 
                ORDER BY DOC.CreatedDate DESC, DocumentByClientId DESC
				 ) AS QUERY
				 WHERE QUERY.Code = 'C02' AND CAST(@CurrentDate AS DATE) <= CAST(QUERY.Doc1Expire AS DATE)
           AND (CAST(QUERY.CreatedDate AS DATE) <= CAST(@CurrentDate AS DATE) OR @CurrentDate IS NULL )
			 )
			  ))
			
			 
			 --AND ((@StatusCode = 'C03'
    --               AND ((ds.Code = 'C01'
    --                     OR ds.Code = 'C02')
    --                    AND (CAST(d.Doc1Expire AS DATE) < CAST(@Date AS DATE))
				--		AND D.DocumentId = di.DocumentId ))
    --              OR (d.DocumentStatusId1 = @DocumentStatusId
    --                  OR @DocumentStatusId IS NULL))

             AND (a.AgencyId = @AgencyId OR  @AgencyId IS NULL)
        GROUP BY di.DocumentId, 
                 di.Name, 
                 di.Telephone, 
                 di.Note, 
                 di.CreatedDate, 
                 di.CreatedBy, 
                 di.AgencyId, 
                 userby.Name, 
                 a.Name, 
                 a.Code, 
                 di.UpdatedBy, 
                 di.UpdatedOn, 
                 di.Doc1Birth, 
                 userupdateby.Name
				 )  QUERYFINAL
   --     SELECT COUNT(*) Pendings
   --     FROM
   --     (
   --         SELECT di.*
   --         FROM DocumentInformation di
   --              INNER JOIN Documents doc ON di.DocumentId = DOC.DocumentId
   --         WHERE(doc.AgencyId = 1
   --             )
   --              AND (doc.CreatedBy = 178
   --                   )
   --              AND (doc.DocumentStatusId1 = 2)
			--AND	 (
			--  EXISTS
			-- (
   --         SELECT 1
   --         FROM
   --         (
   --             SELECT TOP 1 *
   --             FROM Documents DOC
   --                  JOIN DocumentStatus docs ON DOC.DocumentStatusId1 = docs.DocumentStatusId
   --             WHERE DOC.DocumentId = di.DocumentId
   --             ORDER BY DOC.CreatedDate DESC
			--	 ) AS QUERY
			--	 --WHERE CAST(@Date AS DATE) > CAST(QUERY.Doc1Expire AS DATE)
			-- )
			--  )
   --         --GROUP BY DI.DocumentId
   --     ) query;
    END;
GO