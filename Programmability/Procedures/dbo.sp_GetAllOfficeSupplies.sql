SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- ===================================================
-- Author:		Diego León Acevedo Arenas
-- Create date: 2021-12-09
-- Description:	Consulta los datos de OfficeSupplies.
-- ===================================================
-- exec [dbo].[sp_GetAllOfficeSupplies] @Name = 'SILLA'

CREATE PROCEDURE [dbo].[sp_GetAllOfficeSupplies] @Name VARCHAR(100) = NULL,
                                                @Active   BIT = NULL
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT a.OfficeSupplieId, 
               a.Name, 
               a.CreatedBy, 
               a.CreationDate,
			   FORMAT(a.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
               UPPER(b.Name) UserCreated, 
               a.LastUpdatedBy, 
               a.LastUpdatedOn, 
               a.FileOfficeSupplies, 
			       a.FileOfficeSupplies FileOfficeSupplieSaved, 
               UPPER(c.Name) UserUpdated,
			   cast (a.IsActive as BIT) as IsActive ,

			    CASE
                   WHEN a.IsActive  = 1
                   THEN 'ACTIVE'
                   ELSE 'INACTIVE'
                END AS [IsActiveFormat],

        (
            SELECT [dbo].[fn_GetPrividerSupplyNames](a.OfficeSupplieId)
        ) Providers
        FROM OfficeSupplies a WITH(NOLOCK)
             INNER JOIN Users b WITH(NOLOCK) ON a.CreatedBy = b.UserId
             LEFT JOIN Users c WITH(NOLOCK) ON a.LastUpdatedBy = c.UserId
        WHERE(a.Name LIKE '%' + @Name + '%'
              OR @Name IS NULL) 
			  AND (a.IsActive = @Active
               OR @Active IS NULL);
    END;
GO