-- new/relapse
(select id,patientName,patientIdentifier,'New and relapse' as 'Outcome'
from 
(
	select obs.person_id as id,patient_identifier.identifier AS patientIdentifier,concat(person_name.given_name, ' ', person_name.family_name) AS patientName,"New_Relapse"
	from obs 
	INNER JOIN patient_identifier ON patient_identifier.patient_id = obs.person_id AND patient_identifier.identifier_type = 3
	INNER JOIN person_name ON obs.person_id = person_name.person_id
where concept_id in (1034,1084)
AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
	)as a
)

UNION
-- retreatment
(select id,patientName,patientIdentifier,'retreatment' as 'Outcome'
from 
(
	select obs.person_id as id,patient_identifier.identifier AS patientIdentifier,concat(person_name.given_name, ' ', person_name.family_name) AS patientName,"retreatment"
	from obs 
	INNER JOIN patient_identifier ON patient_identifier.patient_id = obs.person_id AND patient_identifier.identifier_type = 3
	INNER JOIN person_name ON obs.person_id = person_name.person_id
where concept_id in (1037)
AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
) as b)

UNION
-- all HIV pos
(select id,patientName,patientIdentifier,'HIV_Positive' as 'Outcome'
from 
(
	select obs.person_id as id,patient_identifier.identifier AS patientIdentifier,concat(person_name.given_name, ' ', person_name.family_name) AS patientName,"HIV_Positive"
	from obs 
	INNER JOIN patient_identifier ON patient_identifier.patient_id = obs.person_id AND patient_identifier.identifier_type = 3
	INNER JOIN person_name ON obs.person_id = person_name.person_id
where concept_id in (4153,1158)
and obs.person_id in (select person_id from obs where concept_id = 2249)
AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
) as c)

-- children
(select id,patientName,patientIdentifier,'Child' as 'Outcome'
FROM
         (       (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('2019-01-31' AS DATE), person.birthdate)/365) AS Age,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('2019-01-31' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'HIV_ages') AS Newly_Initiated_ART_Clients
					WHERE age <= 14
				   
ORDER BY Newly_Initiated_ART_Clients.Age) as children)


-- Adolescent
(select id,patientName,patientIdentifier,'Adolescent' as 'Outcome'
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('2019-01-31' AS DATE), person.birthdate)/365) AS Age,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('2019-01-31' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'HIV_ages') AS Newly_Initiated_ART_Clients
					WHERE age >= 10 AND age <= 19
				   
)

UNION
-- Female
(select id,patientName,patientIdentifier,'Female' as 'Outcome'
from 
(
	select obs.person_id as id,patient_identifier.identifier AS patientIdentifier,concat(person_name.given_name, ' ', person_name.family_name) AS patientName,"Female"
	from obs 
	INNER JOIN patient_identifier ON patient_identifier.patient_id = obs.person_id AND patient_identifier.identifier_type = 3
	INNER JOIN person_name ON obs.person_id = person_name.person_id
	INNER JOIN person p ON obs.person_id = p.person_id 
where gender = "F"
) as c)

UNION
-- miners
(select id,patientName,patientIdentifier,'miners' as 'Outcome'
from 
(
	select obs.person_id as id,patient_identifier.identifier AS patientIdentifier,concat(person_name.given_name, ' ', person_name.family_name) AS patientName,"miners"
	from obs 
	INNER JOIN patient_identifier ON patient_identifier.patient_id = obs.person_id AND patient_identifier.identifier_type = 3
	INNER JOIN person_name ON obs.person_id = person_name.person_id
where concept_id in (3667)
AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
) as d)

UNION
-- ex miner
(select id,patientName,patientIdentifier,'ex_miner' as 'Outcome'
from 
(
	select obs.person_id as id,patient_identifier.identifier AS patientIdentifier,concat(person_name.given_name, ' ', person_name.family_name) AS patientName,"New_Relapse"
	from obs 
	INNER JOIN patient_identifier ON patient_identifier.patient_id = obs.person_id AND patient_identifier.identifier_type = 3
	INNER JOIN person_name ON obs.person_id = person_name.person_id
where concept_id in (3778)
AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
) as e)

UNION
-- factory
(select id,patientName,patientIdentifier,'factory' as 'Outcome'
from 
(
	select obs.person_id as id,patient_identifier.identifier AS patientIdentifier,concat(person_name.given_name, ' ', person_name.family_name) AS patientName,"New_Relapse"
	from obs 
	INNER JOIN patient_identifier ON patient_identifier.patient_id = obs.person_id AND patient_identifier.identifier_type = 3
	INNER JOIN person_name ON obs.person_id = person_name.person_id
where concept_id in (3669)
AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
) as f)

UNION
-- prison
(select id,patientName,patientIdentifier,'prison' as 'Outcome'
from 
(
	select obs.person_id as id,patient_identifier.identifier AS patientIdentifier,concat(person_name.given_name, ' ', person_name.family_name) AS patientName,"New_Relapse"
	from obs 
	INNER JOIN patient_identifier ON patient_identifier.patient_id = obs.person_id AND patient_identifier.identifier_type = 3
	INNER JOIN person_name ON obs.person_id = person_name.person_id
where concept_id in (3779,3671)
AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
) as g)