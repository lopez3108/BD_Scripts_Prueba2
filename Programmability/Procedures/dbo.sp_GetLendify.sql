SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--EXEC sp_GetLendify 1,null,null,1
CREATE PROCEDURE [dbo].[sp_GetLendify] @LendifyStatusId INT         = NULL,
                                      @Name            VARCHAR(60) = NULL,
                                      @Telephone       VARCHAR(10) = NULL,
                                      @AgencyId        INT         = NULL
AS
     BEGIN
         IF(@Name = '')
             SET @Name = NULL;
         IF(@Telephone = '')
             SET @Telephone = NULL;
         SELECT l.LendifyId,
                l.Name,
                l.Telephone,
                l.LendifyStatusId,
                l.CreationDate,
                l.AprovedDate as ApprovalDate ,
				l.CreatedBy CreatedByUserId,
                u.Name AS CreatedBy,
                ls.[Description] AS [Status],
				ls.Code AS statusSaved,
                UPPER(u1.Name) AS AprovedBy,
				ag.Code+' - '+ag.Name AS AgencyName ,
                ag.AgencyId,
			 c.CashierId CashierCreatedId,
                    FORMAT(l.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat 
            , FORMAT(l.AprovedDate, 'MM-dd-yyyy', 'en-US') AprovedDateFormat 

         FROM Lendify l
              INNER JOIN dbo.LendifyStatus ls ON l.LendifyStatusId = ls.LendifyStatusId
              INNER JOIN dbo.Agencies ag ON ag.AgencyId = l.AgencyId
              INNER JOIN dbo.Users u ON l.CreatedBy = u.UserId
		    INNER JOIN dbo.Cashiers c ON C.UserId = u.UserId
              LEFT OUTER JOIN dbo.Users u1 ON l.AprovedBy = u1.UserId
         WHERE(@LendifyStatusId IS NULL
               OR l.[LendifyStatusId] = @LendifyStatusId)
              AND (@Name IS NULL
                   OR l.[Name] LIKE '%'+@Name+'%')
              AND (@Telephone IS NULL
                   OR l.[Telephone] LIKE '%'+@Telephone+'%')
              AND (@AgencyId IS NULL
                   OR l.[AgencyId] = @AgencyId);
     END;
GO