SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllOthersDetailByOtherServiceId](@CreationDate DATE,
                                                               @OtherServiceId INT,
                                                               @AgencyId INT,
                                                               @CreatedBy INT
)
AS
BEGIN
    SELECT OtherId,
           os.Name,
           od.UpdatedOn,
           od.UpdatedBy,
           usu.Name              UpdatedByName,
           AcceptNegative,
           AcceptNegative        AcceptZero,
           AcceptDetails,
           od.Usd             AS 'moneyvalue',
           od.Usd             AS Value,
           CAST(1 AS BIT)        'Set',
           CAST(1 AS BIT)        Valid,
           ISNULL(od.Cash, 0) as 'Cash',
           *
    FROM OthersDetails od
             INNER JOIN OthersServices os ON od.OtherServiceId = os.OtherId
             LEFT JOIN Users usu ON od.UpdatedBy = usu.UserId
    WHERE (CAST(od.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
      AND od.CreatedBy = @CreatedBy
      AND od.OtherServiceId = @OtherServiceId
      AND od.AgencyId = @AgencyId;
END;
GO