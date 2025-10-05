SELECT
    'VisitDate', 
    'PatientID', 
    'PrincipalICD10', 
    'DrugCode', 
    'DrugName', 
    'DrugUsage', 
    'DrugQuantity', 
    'AppointmentDate', 
    'HospCode'
UNION ALL
SELECT
    V.visitdate AS VisitDate,
    V.pid AS PatientID,
    VD.diagcode AS PrincipalICD10,
    DR.drugcode AS DrugCode,
    CD.drugname AS DrugName,
    DR.dose AS DrugUsage,
    DR.unit AS DrugQuantity,
    A.appodate AS AppointmentDate,
    V.pcucode AS HospCode
FROM
    visit V
LEFT JOIN
    visitdiag VD
    ON V.pcucode = VD.pcucode
    AND V.visitno = VD.visitno
    AND VD.dxtype = '01'
LEFT JOIN
    visitdrug DR
    ON V.pcucode = DR.pcucode
    AND V.visitno = DR.visitno
LEFT JOIN
    cdrug CD
    ON DR.drugcode = CD.drugcode
    AND CD.drugtype = '01'
    AND CD.drugflag = '1'
LEFT JOIN
    visitdiagappoint A
    ON V.pcucode = A.pcucode
    AND V.visitno = A.visitno
WHERE
    -- เริ่มต้นวันแรกของเดือนที่แล้ว
    V.visitdate >= DATE_SUB(LAST_DAY(DATE_SUB(NOW(), INTERVAL 1 MONTH)), INTERVAL DAY(LAST_DAY(DATE_SUB(NOW(), INTERVAL 1 MONTH))) - 1 DAY)
    -- สิ้นสุดวันสุดท้ายของเดือนที่แล้ว
    AND V.visitdate <= LAST_DAY(DATE_SUB(NOW(), INTERVAL 1 MONTH))
    AND CD.drugcode IS NOT NULL;