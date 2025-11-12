SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllNotesxCancellations]
AS
     BEGIN
         SELECT nc. *,   
         FORMAT(nc.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat ,
         u.Name AS CreatedByName,
         FORMAT(nc.UpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') UpdatedOnFormat ,
         u1.Name AS UpdatedByName       
                      
         FROM NotesxCancellations nc
         LEFT JOIN Users u ON u.UserId = nc.CreatedBy
         LEFT JOIN Users u1 ON u1.UserId = nc.UpdatedBy
         ORDER BY Description;
     END;



GO