SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, App_Status

FROM
        (
			SELECT distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   'Defaulted' AS App_Status
			FROM obs o
									INNER JOIN patient ON o.person_id = patient.patient_id and o.concept_id = 3752 
									
									and o.value_datetime in
									(				
										select latestFU
										from
											(
												select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
												from obs os
												inner join person_name pn on os.person_id = pn.person_id
												inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
												inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
												where os.concept_id = 3752 
												group by os.person_id
												having Num_Days > 0 and Num_Days <= 28
											) AS Defauled
									)
									
									and o.person_id in
									(				
										select person_id
										from
											(
												select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
												from obs os
												inner join person_name pn on os.person_id = pn.person_id
												inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
												inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
												where os.concept_id = 3752 
												group by os.person_id
												having Num_Days > 0 and Num_Days <= 28
											) AS Defauled
									)
									
									 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
									 INNER JOIN person_name ON person.person_id = person_name.person_id
									 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1			
		) AS Patient_MissedAppointments

ORDER BY Patient_MissedAppointments.Gender, Patient_MissedAppointments.App_Status;
