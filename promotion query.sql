SELECT 
P.ESID,P.EffectiveDate,
POST.PromotionType AS PromotionTypeName, Pre.PrePromotion PrePositionName, POST.PostPromotion PostPositionName, P.Remarks,
PrePromotionLocal
FROM Employee.PromotionInformation P	
	JOIN 
	(
	 SELECT P.PositionID AS PrePositionID,M.HKMasterName AS PrePromotionType,M.HKMasterID,
	 C.HKEntryID,C.HKEntryName PrePromotion,CL.HKLocalName as PrePromotionLocal
	 FROM Organization.HKMaster M
	 INNER JOIN Organization.HKChild C ON C.HKMasterID = M.HKMasterID
	 INNER JOIN Organization.PositionChild P ON P.HKEntryID = C.HKEntryID AND P.HKMasterID = C.HKMasterID
	 LEFT JOIN Organization.HKChildLocal CL ON P.HKEntryID = CL.HKChildID	 	
	) Pre ON Pre.PrePositionID = P.PrePositionID 
	 JOIN
	(
	 SELECT P.PositionID AS PostPositionID,M.HKMasterName AS PromotionType,M.HKMasterID,C.HKEntryID,
	 C.HKEntryName PostPromotion,CL.HKLocalName as PostPromotionLocal
	 FROM Organization.HKMaster M
	 INNER JOIN Organization.HKChild C ON C.HKMasterID = M.HKMasterID
	 INNER JOIN Organization.PositionChild P ON P.HKEntryID = C.HKEntryID AND P.HKMasterID = C.HKMasterID
	 LEFT JOIN Organization.HKChildLocal CL ON P.HKEntryID = CL.HKChildID	
	) POST ON POST.PostPositionID = P.PostPositionID AND POST.HKMasterID = Pre.HKMasterID
	AND Pre.PrePromotionType = POST.PromotionType 

	WHERE Pre.PrePromotion <> POST.POSTPromotion