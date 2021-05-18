
-- updated
SELECT Patient_Identifier, Patient_Name, Age, Gender, age_group,VL_Results_Status,Date_Specimen_Collected, Duration_Results_Pending
FROM (
	

		(SELECT DISTINCT patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, 'Received' AS 'VL_Results_Status', sort_order, Date_Specimen_Collected, Duration_Results_Pending
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
                                               o.value_datetime AS Date_Specimen_Collected,
											   "N/A" AS Duration_Results_Pending,
											   observed_age_group.sort_order AS sort_order

						from obs o

						      
                                 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 4267 AND datediff(cast(o.value_datetime as date), DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))) between 0 and 90
                                 AND patient.voided = 0 AND o.voided = 0

								--  CLients with with viral load results
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4268 AND datediff(cast(os.value_datetime as date), DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))) between 0 and 90
									AND patient.voided = 0 AND os.voided = 0
								 )
								 
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  	 WHERE observed_age_group.report_group_name = 'Modified_Ages'
								) AS viral_loadClients_status
		ORDER BY viral_loadClients_status.Age)

		

             UNION

    (SELECT DISTINCT patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, 'Pending' AS 'VL_Results_Status', sort_order, Date_Specimen_Collected, Duration_Results_Pending
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
                                               o.value_datetime AS Date_Specimen_Collected,
											   concat(datediff(CAST('#endDate#' AS DATE), o.value_datetime), ' ', 'days') AS Duration_Results_Pending,
											   observed_age_group.sort_order AS sort_order

						from obs o
								
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 4267 AND datediff(cast(o.value_datetime as date), DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))) between 0 and 90
                                 AND patient.voided = 0 AND o.voided = 0
                                            
                        AND o.person_id not in (
                                            select distinct os.person_id 
                                            from obs os
                                            where os.concept_id = 4268 AND datediff(cast(os.value_datetime as date), DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))) between 0 and 90
                                            AND patient.voided = 0 AND os.voided = 0
                                            )
								 
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  	 WHERE observed_age_group.report_group_name = 'Modified_Ages'
						   ) AS viral_loadClients_status
		ORDER BY viral_loadClients_status.Age)

) AS viral_load_status

ORDER BY   viral_load_status.Duration_Results_Pending,
                        viral_load_status.sort_order