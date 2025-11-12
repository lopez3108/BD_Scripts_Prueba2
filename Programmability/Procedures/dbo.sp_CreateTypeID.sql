SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateTypeID]
(@TypeID      INT         = NULL,
 @Description VARCHAR(30)
)
AS
     BEGIN
         --IF(EXISTS
         --  (
         --      SELECT *
         --      FROM [dbo].[TypeID]
         --      WHERE Description = @Description
         --            AND @TypeID IS NULL
         --  ))
         --    BEGIN
         --        SELECT-1;
         --END;
             --ELSE
             BEGIN
                 IF(@TypeID IS NULL)
                     BEGIN
                         INSERT INTO [dbo].[TypeID]([Description])
                     VALUES(@Description);
                         SELECT @@IDENTITY;
                 END;
                     ELSE
                     BEGIN
                         UPDATE [dbo].[TypeID]
                           SET
                               [Description] = @Description
                         WHERE TypeId = @TypeID;
                         SELECT @TypeID;
                 END;
         END;
     END;
GO