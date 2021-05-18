SELECT Total_Aggregated_TxCurr.Sex
		, Total_Aggregated_TxCurr.MMDlt3mnts_Under15 AS '<3 months, Under15yrs'
		, Total_Aggregated_TxCurr.MMDlt3mnts_15andMore AS '<3 months, 15+yrs'
		, Total_Aggregated_TxCurr.MMD3to5mnts_Under15 AS '3-5 months, Under15yrs'
		, Total_Aggregated_TxCurr.MMD3to5mnts_15andMore AS '3-5 months, 15+yrs'
		, Total_Aggregated_TxCurr.MMDgte6mnts_Under15 AS '6+ months, Under15yrs'
		, Total_Aggregated_TxCurr.MMDgte6mnts_15andMore AS '6+ months, 15+yrs'
		, Total_Aggregated_TxCurr.Total

FROM (
	(SELECT IF(TXCURR_DETAILS.Gender = 'F', 'Female', 'Male') AS 'Sex'
		, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(IF(TXCURR_DETAILS.MMD_Status = 'MMD_lt_3months' AND TXCURR_DETAILS.age_group = '<15', 1, 0))) AS MMDlt3mnts_Under15
		, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(IF(TXCURR_DETAILS.MMD_Status = 'MMD_lt_3months' AND TXCURR_DETAILS.age_group = '15+', 1, 0))) AS MMDlt3mnts_15andMore
		, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(IF(TXCURR_DETAILS.MMD_Status = 'MMD_3to5months' AND TXCURR_DETAILS.age_group = '<15', 1, 0))) AS MMD3to5mnts_Under15
		, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(IF(TXCURR_DETAILS.MMD_Status = 'MMD_3to5months' AND TXCURR_DETAILS.age_group = '15+', 1, 0))) AS MMD3to5mnts_15andMore
		, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(IF(TXCURR_DETAILS.MMD_Status = 'MMD_gte_6months' AND TXCURR_DETAILS.age_group = '<15', 1, 0))) AS MMDgte6mnts_Under15
		, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(IF(TXCURR_DETAILS.MMD_Status = 'MMD_gte_6months' AND TXCURR_DETAILS.age_group = '15+', 1, 0))) AS MMDgte6mnts_15andMore
		, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(1)) as 'Total'
		, TXCURR_DETAILS.sort_order
		
FROM (
		SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, MMD_Status AS 'MMD_Status', sort_order
		FROM (
				   
		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
										   person.gender AS Gender,
										   observed_age_group.name AS age_group,
										   observed_age_group.sort_order AS sort_order,
										   'MMD_lt_3months' AS 'MMD_Status'

				from obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) and YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) AND patient.voided = 0 AND o.voided = 0 
						  AND (o.concept_id = 4174 and (o.value_coded = 4176))
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
				   WHERE observed_age_group.report_group_name = 'Coarse_Ages')

		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
										   person.gender AS Gender,
										   observed_age_group.name AS age_group,
										   observed_age_group.sort_order AS sort_order,
										   'MMD_3to5months' AS 'MMD_Status'

				from obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (3, 4, 5 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) and YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) AND patient.voided = 0 AND o.voided = 0 
						  AND (o.concept_id = 4174 and (o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246))
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
				   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
				   
		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
										   person.gender AS Gender,
										   observed_age_group.name AS age_group,
										   observed_age_group.sort_order AS sort_order,
										   'MMD_gte_6months' AS 'MMD_Status'

				from obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) and YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) AND patient.voided = 0 AND o.voided = 0 
						  AND (o.concept_id = 4174 and (o.value_coded = 4247))
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
				   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
				   
		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender,
										   observed_age_group.name AS age_group,
										   observed_age_group.sort_order AS sort_order,
										   'MMD_3to5months' AS 'MMD_Status'

						from obs o
						-- CAME IN PREVIOUS 2 MONTHS AND WAS GIVEN (3, 4, 5 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient ON o.person_id = patient.patient_id 
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and (o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246)
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
							 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
				   WHERE observed_age_group.report_group_name = 'Coarse_Ages')

		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender,
										   observed_age_group.name AS age_group,
										   observed_age_group.sort_order AS sort_order,
										   'MMD_gte_6months' AS 'MMD_Status'

						from obs o
						-- CAME IN PREVIOUS 2 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient ON o.person_id = patient.patient_id 
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and (o.value_coded = 4247)
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
							 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
				   WHERE observed_age_group.report_group_name = 'Coarse_Ages')

		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender,
										   observed_age_group.name AS age_group,
										   observed_age_group.sort_order AS sort_order,
										   'MMD_3to5months' AS 'MMD_Status'
						from obs o
						-- CAME IN PREVIOUS 3 MONTHS AND WAS GIVEN (4, 5 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient ON o.person_id = patient.patient_id 
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and (o.value_coded = 4245 or o.value_coded = 4246)
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0			 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
							 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
				   WHERE observed_age_group.report_group_name = 'Coarse_Ages')

		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender,
										   observed_age_group.name AS age_group,
										   observed_age_group.sort_order AS sort_order,
										   'MMD_gte_6months' AS 'MMD_Status'
						from obs o
						-- CAME IN PREVIOUS 3 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient ON o.person_id = patient.patient_id 
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and (o.value_coded = 4247)
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0			 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
							 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
				   WHERE observed_age_group.report_group_name = 'Coarse_Ages')

		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender,
										   observed_age_group.name AS age_group,
										   observed_age_group.sort_order AS sort_order,
										   'MMD_3to5months' AS 'MMD_Status'

						from obs o
						-- CAME IN PREVIOUS 4 MONTHS AND WAS GIVEN (5 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient ON o.person_id = patient.patient_id 
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and (o.value_coded = 4246)
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
							 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
				   WHERE observed_age_group.report_group_name = 'Coarse_Ages')

		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender,
										   observed_age_group.name AS age_group,
										   observed_age_group.sort_order AS sort_order,
										   'MMD_gte_6months' AS 'MMD_Status'

						from obs o
						-- CAME IN PREVIOUS 4 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient ON o.person_id = patient.patient_id 
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and (o.value_coded = 4246)
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
							 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
				   WHERE observed_age_group.report_group_name = 'Coarse_Ages')

		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender,
										   observed_age_group.name AS age_group,
										   observed_age_group.sort_order AS sort_order,
										   'MMD_gte_6months' AS 'MMD_Status'

						from obs o
						-- CAME IN PREVIOUS 5 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient ON o.person_id = patient.patient_id 
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and o.value_coded = 4247
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
							 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
				   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
				   
		UNION


		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender,
										   observed_age_group.name AS age_group,
										   observed_age_group.sort_order AS sort_order,
										   'MMD_lt_3months' AS 'MMD_Status'

						from obs o
						 INNER JOIN patient ON o.person_id = patient.patient_id
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and o.value_coded = 4175
							 AND o.person_id in (
								select distinct os.person_id from obs os
								where 
									MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
									AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
									AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
							 )
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
							 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
				   WHERE observed_age_group.report_group_name = 'Coarse_Ages')


		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender,
										   observed_age_group.name AS age_group,
										   observed_age_group.sort_order AS sort_order,
										   'MMD_lt_3months' AS 'MMD_Status'

						from obs o
						 INNER JOIN patient ON o.person_id = patient.patient_id
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and o.value_coded = 4176
							 AND o.person_id in (
								select distinct os.person_id from obs os
								where 
									MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
									AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
									AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
										
							 )
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
							 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
				   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
				   
		UNION


		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender,
										   observed_age_group.name AS age_group,
										   observed_age_group.sort_order AS sort_order,
										   'MMD_3to5months' AS 'MMD_Status'

						from obs o
						 INNER JOIN patient ON o.person_id = patient.patient_id
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and o.value_coded = 4177
							 AND o.person_id in (
								select distinct os.person_id from obs os
								where 
									MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
									AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
									AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
										
							 )
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
							 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
				   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
				   
		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender,
										   observed_age_group.name AS age_group,
										   observed_age_group.sort_order AS sort_order,
										   'MMD_3to5months' AS 'MMD_Status'

						from obs o
						 INNER JOIN patient ON o.person_id = patient.patient_id
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and o.value_coded = 4245
							 AND o.person_id in (
								select distinct os.person_id from obs os
								where 
									MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
									AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
									AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
										
							 )
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
							 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
				   WHERE observed_age_group.report_group_name = 'Coarse_Ages')



		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender,
										   observed_age_group.name AS age_group,
										   observed_age_group.sort_order AS sort_order,
										   'MMD_3to5months' AS 'MMD_Status'

						from obs o
						 INNER JOIN patient ON o.person_id = patient.patient_id
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and o.value_coded = 4246
							 AND o.person_id in (
								select distinct os.person_id from obs os
								where 
									MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
									AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
									AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
							 )
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
							 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
				   WHERE observed_age_group.report_group_name = 'Coarse_Ages')



		UNION

		(select distinct patient.patient_id AS Id,
										   patient_identifier.identifier AS patientIdentifier,
										   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
										   person.gender AS Gender,
										   observed_age_group.name AS age_group,
										   observed_age_group.sort_order AS sort_order,
										   'MMD_gte_6months' AS 'MMD_Status'

						from obs o
						 INNER JOIN patient ON o.person_id = patient.patient_id
							 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
							 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
							 AND patient.voided = 0 AND o.voided = 0 
							 AND o.concept_id = 4174 and o.value_coded = 4247
							 AND o.person_id in (
								select distinct os.person_id from obs os
								where 
									MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
									AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
									AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
							 )
							 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
							 INNER JOIN person_name ON person.person_id = person_name.person_id
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
							 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
				   WHERE observed_age_group.report_group_name = 'Coarse_Ages')	   
				   
		) AS ARTCurrent_PrevMonths
		 
		WHERE ARTCurrent_PrevMonths.Id not in (
						SELECT os.person_id 
						FROM obs os
						WHERE (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
						AND (DATE(os.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
												)
		and ARTCurrent_PrevMonths.Id not in (
					   select distinct patient.patient_id AS Id
					   from obs o
								   -- CLIENTS NEWLY INITIATED ON ART
						INNER JOIN patient ON o.person_id = patient.patient_id													
						AND (o.concept_id = 2249 
						AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0)
		AND ARTCurrent_PrevMonths.Id not in (
						select distinct os.person_id 
						from obs os
						where os.concept_id = 4155 and os.value_coded = 2146
				)
		AND ARTCurrent_PrevMonths.Id not in (
					select person_id 
					from person 
					where death_date < CAST('#endDate#' AS DATE)
					and dead = 1
					)
		ORDER BY ARTCurrent_PrevMonths.Age

) AS TXCURR_DETAILS

GROUP BY TXCURR_DETAILS.Gender
ORDER BY TXCURR_DETAILS.sort_order)


UNION ALL


(SELECT 'Total' AS Sex
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.MMD_Status = 'MMD_lt_3months' AND Totals.Age < 15, 1, 0))) AS MMDlt3mnts_Under15
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.MMD_Status = 'MMD_lt_3months' AND Totals.Age >= 15, 1, 0))) AS MMDlt3mnts_15andMore
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.MMD_Status = 'MMD_3to5months' AND Totals.Age < 15, 1, 0))) AS MMD3to5mnts_Under15
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.MMD_Status = 'MMD_3to5months' AND Totals.Age >= 15, 1, 0))) AS MMD3to5mnts_15andMore
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.MMD_Status = 'MMD_gte_6months' AND Totals.Age < 15 , 1, 0))) AS MMDgte6mnts_Under15
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.MMD_Status = 'MMD_gte_6months' AND Totals.Age >= 15 , 1, 0))) AS MMDgte6mnts_15andMore
		, IF(Totals.Id IS NULL, 0, SUM(1)) as 'Total'
		, 99 AS 'sort_order'
		
FROM

		(SELECT  Total_TxCurr.Id
					, Total_TxCurr.patientIdentifier AS "Patient Identifier"
					, Total_TxCurr.patientName AS "Patient Name"
					, Total_TxCurr.Age
					, Total_TxCurr.Gender
					, Total_TxCurr.MMD_Status		
		FROM (		
				SELECT Id, patientIdentifier, patientName, Age, Gender, MMD_Status AS 'MMD_Status'
				FROM (
						   
				(select distinct patient.patient_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   'MMD_lt_3months' AS 'MMD_Status'

						from obs o
								-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2 MONHTS SUPPLY OF DRUGS)
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) and YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) AND patient.voided = 0 AND o.voided = 0 
								  AND (o.concept_id = 4174 and (o.value_coded = 4176))
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1)

				UNION

				(select distinct patient.patient_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   'MMD_3to5months' AS 'MMD_Status'

						from obs o
								-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (3, 4, 5 MONHTS SUPPLY OF DRUGS)
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) and YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) AND patient.voided = 0 AND o.voided = 0 
								  AND (o.concept_id = 4174 and (o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246))
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1)
						   
				UNION

				(select distinct patient.patient_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   'MMD_gte_6months' AS 'MMD_Status'

						from obs o
								-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) and YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) AND patient.voided = 0 AND o.voided = 0 
								  AND (o.concept_id = 4174 and (o.value_coded = 4247))
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1)
						   
				UNION

				(select distinct patient.patient_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   'MMD_3to5months' AS 'MMD_Status'

								from obs o
								-- CAME IN PREVIOUS 2 MONTHS AND WAS GIVEN (3, 4, 5 MONHTS SUPPLY OF DRUGS)
								 INNER JOIN patient ON o.person_id = patient.patient_id 
									 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
									 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
									 AND patient.voided = 0 AND o.voided = 0 
									 AND o.concept_id = 4174 and (o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246)
									 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
									 INNER JOIN person_name ON person.person_id = person_name.person_id
									 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1)

				UNION

				(select distinct patient.patient_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   'MMD_gte_6months' AS 'MMD_Status'

								from obs o
								-- CAME IN PREVIOUS 2 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
								 INNER JOIN patient ON o.person_id = patient.patient_id 
									 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
									 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
									 AND patient.voided = 0 AND o.voided = 0 
									 AND o.concept_id = 4174 and (o.value_coded = 4247)
									 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
									 INNER JOIN person_name ON person.person_id = person_name.person_id
									 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1)

				UNION

				(select distinct patient.patient_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   'MMD_3to5months' AS 'MMD_Status'
								from obs o
								-- CAME IN PREVIOUS 3 MONTHS AND WAS GIVEN (4, 5 MONHTS SUPPLY OF DRUGS)
								 INNER JOIN patient ON o.person_id = patient.patient_id 
									 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
									 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
									 AND patient.voided = 0 AND o.voided = 0 
									 AND o.concept_id = 4174 and (o.value_coded = 4245 or o.value_coded = 4246)
									 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0			 
									 INNER JOIN person_name ON person.person_id = person_name.person_id
									 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1)

				UNION

				(select distinct patient.patient_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   'MMD_gte_6months' AS 'MMD_Status'
								from obs o
								-- CAME IN PREVIOUS 3 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
								 INNER JOIN patient ON o.person_id = patient.patient_id 
									 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
									 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
									 AND patient.voided = 0 AND o.voided = 0 
									 AND o.concept_id = 4174 and (o.value_coded = 4247)
									 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0			 
									 INNER JOIN person_name ON person.person_id = person_name.person_id
									 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1)

				UNION

				(select distinct patient.patient_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   'MMD_3to5months' AS 'MMD_Status'

								from obs o
								-- CAME IN PREVIOUS 4 MONTHS AND WAS GIVEN (5 MONHTS SUPPLY OF DRUGS)
								 INNER JOIN patient ON o.person_id = patient.patient_id 
									 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
									 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
									 AND patient.voided = 0 AND o.voided = 0 
									 AND o.concept_id = 4174 and (o.value_coded = 4246)
									 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
									 INNER JOIN person_name ON person.person_id = person_name.person_id
									 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1)

				UNION

				(select distinct patient.patient_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   'MMD_gte_6months' AS 'MMD_Status'

								from obs o
								-- CAME IN PREVIOUS 4 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
								 INNER JOIN patient ON o.person_id = patient.patient_id 
									 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
									 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
									 AND patient.voided = 0 AND o.voided = 0 
									 AND o.concept_id = 4174 and (o.value_coded = 4246)
									 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
									 INNER JOIN person_name ON person.person_id = person_name.person_id
									 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1)

				UNION

				(select distinct patient.patient_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   'MMD_gte_6months' AS 'MMD_Status'

								from obs o
								-- CAME IN PREVIOUS 5 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
								 INNER JOIN patient ON o.person_id = patient.patient_id 
									 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
									 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
									 AND patient.voided = 0 AND o.voided = 0 
									 AND o.concept_id = 4174 and o.value_coded = 4247
									 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
									 INNER JOIN person_name ON person.person_id = person_name.person_id
									 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1)
						   
				UNION


				(select distinct patient.patient_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   'MMD_lt_3months' AS 'MMD_Status'

								from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id
									 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
									 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
									 AND patient.voided = 0 AND o.voided = 0 
									 AND o.concept_id = 4174 and o.value_coded = 4175
									 AND o.person_id in (
										select distinct os.person_id from obs os
										where 
											MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
											AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
											AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
									 )
									 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
									 INNER JOIN person_name ON person.person_id = person_name.person_id
									 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1)


				UNION

				(select distinct patient.patient_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   'MMD_lt_3months' AS 'MMD_Status'

								from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id
									 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
									 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
									 AND patient.voided = 0 AND o.voided = 0 
									 AND o.concept_id = 4174 and o.value_coded = 4176
									 AND o.person_id in (
										select distinct os.person_id from obs os
										where 
											MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
											AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
											AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
												
									 )
									 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
									 INNER JOIN person_name ON person.person_id = person_name.person_id
									 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1)
						   
				UNION


				(select distinct patient.patient_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   'MMD_3to5months' AS 'MMD_Status'

								from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id
									 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
									 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
									 AND patient.voided = 0 AND o.voided = 0 
									 AND o.concept_id = 4174 and o.value_coded = 4177
									 AND o.person_id in (
										select distinct os.person_id from obs os
										where 
											MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
											AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
											AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
												
									 )
									 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
									 INNER JOIN person_name ON person.person_id = person_name.person_id
									 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1)
						   
				UNION

				(select distinct patient.patient_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   'MMD_3to5months' AS 'MMD_Status'

								from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id
									 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
									 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
									 AND patient.voided = 0 AND o.voided = 0 
									 AND o.concept_id = 4174 and o.value_coded = 4245
									 AND o.person_id in (
										select distinct os.person_id from obs os
										where 
											MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
											AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
											AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
												
									 )
									 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
									 INNER JOIN person_name ON person.person_id = person_name.person_id
									 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1)



				UNION

				(select distinct patient.patient_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   'MMD_3to5months' AS 'MMD_Status'

								from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id
									 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
									 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
									 AND patient.voided = 0 AND o.voided = 0 
									 AND o.concept_id = 4174 and o.value_coded = 4246
									 AND o.person_id in (
										select distinct os.person_id from obs os
										where 
											MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
											AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
											AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
									 )
									 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
									 INNER JOIN person_name ON person.person_id = person_name.person_id
									 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1)



				UNION

				(select distinct patient.patient_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   'MMD_gte_6months' AS 'MMD_Status'

								from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id
									 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
									 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
									 AND patient.voided = 0 AND o.voided = 0 
									 AND o.concept_id = 4174 and o.value_coded = 4247
									 AND o.person_id in (
										select distinct os.person_id from obs os
										where 
											MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
											AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
											AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
									 )
									 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
									 INNER JOIN person_name ON person.person_id = person_name.person_id
									 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1)	   
						   
				) AS ARTCurrent_PrevMonths
				 
				WHERE ARTCurrent_PrevMonths.Id not in (
								SELECT os.person_id 
								FROM obs os
								WHERE (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
								AND (DATE(os.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
														)
				and ARTCurrent_PrevMonths.Id not in (
							   select distinct patient.patient_id AS Id
							   from obs o
										   -- CLIENTS NEWLY INITIATED ON ART
								INNER JOIN patient ON o.person_id = patient.patient_id													
								AND (o.concept_id = 2249 
								AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
								AND patient.voided = 0 AND o.voided = 0)
				AND ARTCurrent_PrevMonths.Id not in (
								select distinct os.person_id 
								from obs os
								where os.concept_id = 4155 and os.value_coded = 2146
						)
				AND ARTCurrent_PrevMonths.Id not in (
							select person_id 
							from person 
							where death_date < CAST('#endDate#' AS DATE)
							and dead = 1
							)
				ORDER BY ARTCurrent_PrevMonths.Age		

		) AS Total_TxCurr
  ) AS Totals
 )
) AS Total_Aggregated_TxCurr
ORDER BY Total_Aggregated_TxCurr.sort_order