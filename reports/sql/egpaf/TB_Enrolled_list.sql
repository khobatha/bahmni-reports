(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age , Gender, age_group, 'New Patient' AS 'TB_Treatment_History'
	FROM
					
		(select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			
			person.gender AS Gender,
			observed_age_group.name AS age_group,
			observed_age_group.sort_order AS sort_order

		from obs o
		-- New TB Patient
				INNER JOIN patient ON o.person_id = patient.patient_id 
				AND o.concept_id =3785 and o.value_coded=1034
				AND patient.voided = 0 AND o.voided = 0
				AND (o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))

				
				AND o.person_id not in (
				select distinct os.person_id 
					from obs os
		-- Patient must not be a tranfer in	
					where os.concept_id = 	3772 and os.value_coded =2095
				AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
				AND patient.voided = 0 AND os.voided = 0
				)
				
				INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
				INNER JOIN person_name ON person.person_id = person_name.person_id
				INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
				INNER JOIN reporting_age_group AS observed_age_group ON
				CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
				AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
			WHERE observed_age_group.report_group_name = 'Modified_Ages') AS HTSClients_HIV_STATUS
	ORDER BY HTSClients_HIV_STATUS.HIV_STATUS, HTSClients_HIV_STATUS.Age)


UNION

	(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age , Gender, age_group, 'Relapsed Patient' AS 'TB_Treatment_History'
		FROM
			(select distinct patient.patient_id AS Id,
				patient_identifier.identifier AS patientIdentifier,
				concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
				floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
				
				person.gender AS Gender,
				observed_age_group.name AS age_group,
									observed_age_group.sort_order AS sort_order

			from obs o
		-- Relapsed TB Client
				INNER JOIN patient ON o.person_id = patient.patient_id 
				AND o.concept_id =3785 and o.value_coded=1084
				AND patient.voided = 0 AND o.voided = 0
				AND (o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
				AND o.person_id not in (
					select distinct os.person_id 
					from obs os
		-- Client must not be a transfer in
					where os.concept_id = 3772 and os.value_coded =2095
				AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
				AND patient.voided = 0 AND os.voided = 0
				)
				
				INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
				INNER JOIN person_name ON person.person_id = person_name.person_id
				INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
				INNER JOIN reporting_age_group AS observed_age_group ON
				CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
				AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
			WHERE observed_age_group.report_group_name = 'Modified_Ages') AS HTSClients_HIV_STATUS
ORDER BY HTSClients_HIV_STATUS.HIV_STATUS, HTSClients_HIV_STATUS.Age)