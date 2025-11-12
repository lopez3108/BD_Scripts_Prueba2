SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSumTitlesDaily]
(@CreationDate DATE,
 @AgencyId     INT,
 @UserId       INT  = NULL,
 @ProcessAuto  BIT
)
AS
     BEGIN
         SELECT SUM(T.USD) SumaUsd,
                ISNULL((((SUM(T.USD) + SUM(ISNULL(T.Fee1, 0)) + SUM(ABS(ISNULL(t.PlateTypePersonalizedFee, 0)))) - ABS(SUM(ABS(ISNULL(t.MOILDOR, 0))) + SUM(ABS(ISNULL(t.FeeILDOR, 0))) + SUM(ABS(ISNULL(t.FeeILSOS, 0))) + SUM(ABS(ISNULL(t.MOLSOS, 0))) + SUM(ABS(ISNULL(t.FeeOther, 0))) + SUM(ABS(ISNULL(t.MOOther, 0))) + SUM(ABS(ISNULL(t.RunnerService, 0)))))), 0) AS Suma
         FROM TITLES t
              INNER JOIN ProcessTypes pt ON t.ProcessTypeId = pt.ProcessTypeId
              LEFT JOIN DeliveryTypes dt ON t.DeliveryTypeId = dt.DeliveryTypeId
              INNER JOIN Users us ON t.CreatedBy = us.UserId
              LEFT JOIN PlateTypes pts ON t.PlateTypeId = pts.PlateTypeId
              LEFT JOIN PlateTypesPersonalized ptp ON t.PlateTypePersonalizedId = ptp.PlateTypePersonalizedId
              LEFT JOIN Users usu ON t.UpdatedBy = usu.UserId
              LEFT JOIN ProcessStatus ps ON t.ProcessStatusId = ps.ProcessStatusId
         WHERE(CAST(CreationDate AS DATE) = CAST(@CreationDate AS DATE)
               OR @CreationDate IS NULL)
              AND t.AgencyId = @AgencyId
              AND (t.ProcessAuto = @ProcessAuto
                   OR @ProcessAuto IS NULL)
              AND (t.CreatedBy = @UserId
                   OR @UserId IS NULL);
			    --GROUP BY T.USD,T.Fee1,t.PlateTypePersonalizedFee
     END;
GO