SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Udapted on 16-06-2025 JF/TASK 6598  Agregar columnas de creación y edición

CREATE PROCEDURE [dbo].[sp_GetAllPromotionalCodes] @Date DATETIME
AS
     BEGIN
         SET NOCOUNT ON;
         SELECT *, Code CodeOld,
		 FORMAT(pc.FromDate, 'MM-dd-yyyy', 'en-US')  FromDateFormat,
		 FORMAT(pc.ToDate, 'MM-dd-yyyy', 'en-US')  ToDateFormat,
     FORMAT(pc.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
     FORMAT(pc.LastUpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  LastUpdatedOnFormat,
     u.Name CreatedByName,
     u1.Name LastUpdatedByName ,
	      CASE
                    WHEN DATEDIFF(DAY, @Date, ToDate) > 0
                    THEN DATEDIFF(DAY, @Date, ToDate)
                    ELSE 0
                END AS DaysLeft 
         FROM PromotionalCodes pc
         INNER JOIN Users u ON pc.CreatedBy = u.UserId
         LEFT JOIN Users u1 ON pc.LastUpdatedBy = u1.UserId;
     END;

GO