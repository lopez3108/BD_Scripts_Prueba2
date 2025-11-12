SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllRegisteredMac] @Mac           VARCHAR(30) = NULL, 
                                               @Description   VARCHAR(30) = NULL, 
                                               @ComputerBrand VARCHAR(30) = NULL, 
                                               @AgencyId      INT         = NULL
AS
    BEGIN
        SELECT r.RegisteredMacId, 
               r.Mac, 
               r.Description, 
               r.ComputerBrand, 
               r.CreatedBy, 
               r.CreationDate, 
			   FORMAT(r.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
               UPPER(u.Name) UserCreated, 
               a.AgencyId, 
               a.Code + ' - ' + a.Name AS Agency
        FROM RegisteredMacs r
             INNER JOIN Users u ON r.CreatedBy = u.UserId
             LEFT JOIN Agencies a ON a.AgencyId = r.AgencyId
        WHERE(REPLACE(r.Mac, '-', '') = REPLACE(@Mac, '-', '')
              OR r.Mac LIKE '%' + @Mac + '%'
              OR @Mac IS NULL
              OR @Mac = '')
             AND (r.Description = @Description
                  OR r.Description LIKE '%' + @Description + '%'
                  OR @Description IS NULL
                  OR @Description = '')
             AND (r.ComputerBrand = @ComputerBrand
                  OR r.ComputerBrand LIKE '%' + @ComputerBrand + '%'
                  OR @ComputerBrand IS NULL
                  OR @ComputerBrand = '')
             AND (r.AgencyId = @AgencyId
                  OR @AgencyId IS NULL)                  
               

           ORDER BY r.CreationDate ASC;
    END;

GO