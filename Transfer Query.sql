SELECT 
P.ESID,P.EffectiveDate,
MAX(CASE WHEN POST.TransferType = 'Unit' THEN Pre.PreTransfer END) as PreTransferUnit,
MAX(CASE WHEN POST.TransferType = 'Unit' THEN Pre.PreTransferLocal END) as PreTransferUnitLocal,
MAX(CASE WHEN POST.TransferType = 'Unit' THEN PREN.EntityName END) as PreTransferEntity,
MAX(CASE WHEN POST.TransferType = 'Unit' THEN PREN.EntityNameLocal END) as PreTransferEntityLocal,
MAX(CASE WHEN POST.TransferType = 'Unit' THEN PreEmployeeCode END) as PreTransferEmployeeCode,
MAX(CASE WHEN POST.TransferType = 'Unit' THEN POST.PostTransfer END) as PostTransferUnit,
MAX(CASE WHEN POST.TransferType = 'Unit' THEN POST.PostTransferLocal END) as PostTransferUnitLocal,
MAX(CASE WHEN POST.TransferType = 'Unit' THEN POEN.EntityName END) as PostTransferEntity,
MAX(CASE WHEN POST.TransferType = 'Unit' THEN POEN.EntityNameLocal END) as PostTransferEntityLocal,
MAX(CASE WHEN POST.TransferType = 'Unit' THEN PostEmployeeCode END) as PostTransferEmployeeCode,
----------------- Section Transfer
MAX(CASE WHEN POST.TransferType = 'Section Info' THEN Pre.PreTransfer END) as PreTransferSection,
MAX(CASE WHEN POST.TransferType = 'Section Info' THEN Pre.PreTransferLocal END) as PreTransferSectionLocal,
MAX(CASE WHEN POST.TransferType = 'Section Info' THEN PREN.EntityName END) as PreTransferEntitySection,
MAX(CASE WHEN POST.TransferType = 'Section Info' THEN PREN.EntityNameLocal END) as PreTransferEntitySectionLocal,
MAX(CASE WHEN POST.TransferType = 'Section Info' THEN PreEmployeeCode END) as PreTransferEmployeeCodeSection,
MAX(CASE WHEN POST.TransferType = 'Section Info' THEN POST.PostTransfer END) as PostTransferSection,
MAX(CASE WHEN POST.TransferType = 'Section Info' THEN POST.PostTransferLocal END) as PostTransferSectionLocal,
MAX(CASE WHEN POST.TransferType = 'Section Info' THEN POEN.EntityName END) as PostTransferEntitySection,
MAX(CASE WHEN POST.TransferType = 'Section Info' THEN POEN.EntityNameLocal END) as PostTransferEntitySectionLocal,
MAX(CASE WHEN POST.TransferType = 'Section Info' THEN PostEmployeeCode END) as PostTransferEmployeeCodeSection

FROM Employee.TransferInformation P
JOIN Reports.EmployeePIMSInfo E ON E.ESID = P.ESID
JOIN 
(
	SELECT P.PositionID AS PrePositionID,M.HKMasterName AS TransferType,M.HKMasterID,C.HKEntryID,
	C.HKEntryName PreTransfer,CL.HKLocalName PreTransferLocal
	FROM Organization.HKMaster M
	INNER JOIN Organization.HKChild C ON C.HKMasterID = M.HKMasterID
	INNER JOIN Organization.PositionChild P ON P.HKEntryID = C.HKEntryID AND P.HKMasterID = C.HKMasterID
	LEFT JOIN Organization.HKChildLocal CL ON P.HKEntryID = CL.HKChildID
) Pre ON Pre.PrePositionID = P.PrePositionID 
JOIN
(
	SELECT P.PositionID AS PostPositionID,M.HKMasterName AS TransferType,M.HKMasterID,C.HKEntryID,
	C.HKEntryName PostTransfer,CL.HKLocalName PostTransferLocal
	FROM Organization.HKMaster M
	INNER JOIN Organization.HKChild C ON C.HKMasterID = M.HKMasterID
	INNER JOIN Organization.PositionChild P ON P.HKEntryID = C.HKEntryID AND P.HKMasterID = C.HKMasterID
	LEFT JOIN Organization.HKChildLocal CL ON P.HKEntryID = CL.HKChildID	 
) POST ON POST.PostPositionID = P.PostPositionID AND POST.HKMasterID = Pre.HKMasterID  
LEFT JOIN Organization.EntityAddressInfo PREN ON P.PreEntityID = PREN.EntityID
LEFT JOIN Organization.EntityAddressInfo POEN ON P.PostEntityID = POEN.EntityID
WHERE Pre.PreTransfer <> POST.PostTransfer	
GROUP BY P.ESID,P.EffectiveDate

