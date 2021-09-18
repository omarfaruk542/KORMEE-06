SELECT A.ESID,A.PresentGeoCodeID,C.Division,DivisionLocal,D.District,DistrictLocal,E.Upazila,UpazilaLocal,
F.UN_WRD,UN_WRDLocal,G.MZA_MOH,MZA_MOHLocal,H.Village,VillageLocal,A.PresentPostCode,A.PresentAddress 
FROM Employee.ActiveEmployeeAddress A
JOIN SysInfo.GeoCode B ON A.PresentGeoCodeID = B.SystemID
LEFT JOIN (
	SELECT Name as Division,LocalName as DivisionLocal,DIVN  AS DivCode,RMO  FROM [SysInfo].[GeoCode]
	WHERE ZILA = -1
) C ON B.DIVN = C.DivCode
LEFT JOIN 
(
	SELECT DISTINCT NAME AS District,LocalName as DistrictLocal, Zila AS DistCode,DIVN as DivCode FROM [SysInfo].[GeoCode]
	WHERE Zila<> -1 AND UPZA=-1
) D ON B.DIVN = D.DivCode AND B.ZILA = D.DistCode
LEFT JOIN 
(
	SELECT NAME AS Upazila,LocalName as UpazilaLocal, UPZA AS UpzilaCode,DIVN as DivCode,Zila AS DistCode FROM [SysInfo].[GeoCode] 	
	WHERE UPZA<> -1 AND PSA=-1 AND UN_WRD_CB=-1	
) E ON B.DIVN = E.DivCode AND B.ZILA = E.DistCode AND B.UPZA = E.UpzilaCode
LEFT JOIN 
(
	SELECT NAME AS UN_WRD,LocalName as UN_WRDLocal, UN_WRD_CB AS UNCode,DIVN as DivCode,ZILA as DistCode,UPZA as UpzilaCode 
	FROM [SysInfo].[GeoCode] 	 	
	WHERE UN_WRD_CB<> -1 AND MZA_MOH=-1
) F ON B.DIVN = F.DivCode AND B.ZILA = F.DistCode AND B.UPZA = F.UpzilaCode AND B.UN_WRD_CB = F.UNCode
LEFT JOIN 
(
	SELECT NAME AS MZA_MOH,LocalName as MZA_MOHLocal, MZA_MOH AS MZA_MOHCode,UN_WRD_CB AS UNCode,DIVN as DivCode,
	ZILA as DistCode,	UPZA as UpzilaCode FROM [SysInfo].[GeoCode] 	 	
	WHERE MZA_MOH<> -1 AND Vill = -1
) G ON B.DIVN = G.DivCode AND B.ZILA = G.DistCode AND B.UPZA = G.UpzilaCode AND B.UN_WRD_CB = G.UNCode 
AND B.MZA_MOH = G.MZA_MOHCode
LEFT JOIN 
(
	SELECT NAME AS Village,LocalName as VillageLocal, Vill AS VillCode,MZA_MOH AS MZA_MOHCode,UN_WRD_CB AS UNCode,
	DIVN as DivCode,ZILA as DistCode,UPZA as UpzilaCode FROM [SysInfo].[GeoCode]  	
	WHERE Vill <> -1
) H ON B.DIVN = H.DivCode AND B.ZILA = H.DistCode AND B.UPZA = H.UpzilaCode AND B.UN_WRD_CB = H.UNCode 
AND B.MZA_MOH = H.MZA_MOHCode AND B.VILL = H.VillCode