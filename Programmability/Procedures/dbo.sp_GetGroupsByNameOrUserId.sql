SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetGroupsByNameOrUserId] @Name   VARCHAR(100) = NULL,
                                                   @UserId INT          = NULL
AS
     BEGIN
         SELECT DISTINCT
                GR.GroupId,
                U.Name AS NameUser,
                U.UserId,
                GR.Name,
                GR.CreatedBy,
                Gr.CreatedOn,
				FORMAT(Gr.CreatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreatedOnFormat,
                UC.Name AS CreatedByName,
                CASE
                    WHEN @UserId IS NOT NULL
                    THEN 1
                    ELSE 0
                END AS TE,
                CAST(
                    (
                        SELECT COUNT(*)
                        FROM UsersXGroup GX
                        WHERE GX.GroupId = GR.GroupId
                    ) AS VARCHAR(100)) AS Members,
                LOWER(STUFF(
                           (
                               SELECT DISTINCT
                                      ', '+Users.Name
                               FROM UsersXGroup uxg
                                    LEFT JOIN Users ON Users.UserId = uxg.UserId
                               WHERE uxg.GroupId = gr.GroupId FOR XML PATH(''), TYPE
                           ).value('.', 'NVARCHAR(MAX)'), 1, 2, '')) MembersNames,
                LOWER(STUFF(
                           (
                               SELECT DISTINCT
                                      ', '+ CAST(Users.UserId AS VARCHAR(max))
                               FROM UsersXGroup uxg
                                    LEFT JOIN Users ON Users.UserId = uxg.UserId
                               WHERE uxg.GroupId = gr.GroupId FOR XML PATH(''), TYPE
                           ).value('.', 'VARCHAR(MAX)'), 1, 2, '')) MembersIds,
                ISNULL(
                      (
                          SELECT SUM(CASE
                                         WHEN r.ReadUserId = @UserId
                                         THEN 0
                                         ELSE 1
                                     END) AS WhioutRead
                          FROM ChatMessages c
                               LEFT JOIN ReadsByChat r ON C.ChatMessageId = r.ChatMessageId
                                                          AND r.ReadUserId = @UserId
                          WHERE c.ToGroupId = GR.GroupId
                                AND c.FromUserId <> @UserId
                      ), 0) numNewMsg
         FROM Groups GR
              INNER JOIN Users UC ON UC.UserId = GR.CreatedBy
              LEFT JOIN UsersXGroup GX ON GX.GroupId = GR.GroupId
                                          AND @UserId IS NOT NULL
              LEFT JOIN Users U ON U.UserId = GX.UserId
         WHERE(GR.Name LIKE '%'+@Name+'%'
               OR @Name IS NULL
               OR @Name = '')
              AND (GX.UserId = @UserId
                   OR @UserId IS NULL)
         GROUP BY GR.GroupId,
                  GR.Name,
                  GR.CreatedBy,
                  U.UserId,
                  Gr.CreatedOn,
                  U.Name,
                  UC.Name;
     END;
GO