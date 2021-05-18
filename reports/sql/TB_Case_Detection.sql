SELECT grping,
IF(Id IS NULL, 0, SUM(IF(outcome = 'total_screened', 1, 0))) AS total_screened,
IF(Id IS NULL, 0, SUM(IF(outcome = 'with_signs', 1, 0))) AS with_signs,
IF(Id IS NULL, 0, SUM(IF(outcome = 'signs_bacteriology', 1, 0))) AS signs_bacteriology
FROM 
(
SELECT Id, outcome,grping
FROM
(	-- CASE DETECTION FROM ALL SCREENED
                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'CHW' as grping
                                        from obs o

                                                INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
												AND o.person_Id in (select person_id 
													from obs
													where (concept_id = 3780 and value_coded = 3784)
													AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
													AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE)))
												
												
                                                INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                                                WHERE concept_id in (3710) -- TB,ART
                                                        AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                                                        AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
							UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'CBO' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3780 and value_coded = 3637)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3710) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )	
							
							UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'children' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select id
													FROM
													( 
													select distinct o.person_id AS Id,
													floor(datediff(CAST('2019-01-31' AS DATE), person.birthdate)/365) AS Age								   
													from obs o
													INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
													INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
													) as a
												WHERE age <= 14
												)
												
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3710) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'miners' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (
												select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3667)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3710) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'ex_miners' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3778)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
												
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3710) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'HHCM' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3777)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3710) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'HHXM' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3778)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3710) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'factory workers' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3669)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3710) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'staff or inmates' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded in (3779,3671))
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3710) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'Health Workers' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3670)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3710) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'Public Transport Operators' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3780 and value_coded = 3637)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3710) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'Total' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
												
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3710) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )

UNION			-- CASE DETECTION ON THOSE WITH TB SIGNS
                (select distinct o.person_id AS Id,'with_signs' as outcome,'CHW' as grping

                                        from obs o
												-- query for community health worker
                                                INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
												AND o.person_Id in (select person_id 
													from obs
													where (concept_id = 3780 and value_coded = 3784)
													AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
													AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE)))
													
													
													-- combine with query for TB clients with signs
                                                INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                                                AND o.person_id in (
                                                        select person_id
                                                        from obs
                                                        where concept_id = 3711 or (concept_id = 3710 and value_coded = 1876) -- TB,ART
                                                        AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                                                        AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))              )

                                )
								UNION
								  (select distinct o.person_id AS Id,'with_signs' as outcome,'CBO' as grping

                                        from obs o
													-- query for community health worker
                                                INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
												AND o.person_Id in (select person_id 
													from obs
													where (concept_id = 3780 and value_coded = 3637)
													AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
													AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE)))
													
													-- combine with query for TB clients with signs
													
                                                INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                                                AND o.person_id in (
                                                        select person_id
                                                        from obs
                                                        where concept_id = 3711 or (concept_id = 3710 and value_coded = 1876) -- TB,ART
                                                        AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                                                        AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))              )

                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'with_signs' as outcome, 'children' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select id
													FROM
													( 
													select distinct o.person_id AS Id,
													floor(datediff(CAST('2019-01-31' AS DATE), person.birthdate)/365) AS Age								   
													from obs o
													INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
													INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
													) as a
												WHERE age <= 14
												) 
												
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            where concept_id = 3711 or (concept_id = 3710 and value_coded = 1876) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'with_signs' as outcome, 'miners' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (
												select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3667)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            where concept_id = 3711 or (concept_id = 3710 and value_coded = 1876) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'with_signs' as outcome, 'ex_miners' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3778)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
												
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            where concept_id = 3711 or (concept_id = 3710 and value_coded = 1876) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'with_signs' as outcome, 'HHCM' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3777)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            where concept_id = 3711 or (concept_id = 3710 and value_coded = 1876) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'with_signs' as outcome, 'HHXM' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3778)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            where concept_id = 3711 or (concept_id = 3710 and value_coded = 1876) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'with_signs' as outcome, 'factory workers' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3669)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            where concept_id = 3711 or (concept_id = 3710 and value_coded = 1876) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'with_signs' as outcome, 'staff or inmates' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded in (3779,3671))
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            where concept_id = 3711 or (concept_id = 3710 and value_coded = 1876) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'with_signs' as outcome, 'Health Workers' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3670)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            where concept_id = 3711 or (concept_id = 3710 and value_coded = 1876) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'with_signs' as outcome, 'Public Transport Operators' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3780 and value_coded = 3637)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            where concept_id = 3711 or (concept_id = 3710 and value_coded = 1876) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'with_signs' as outcome, 'Total' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
												
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            where concept_id = 3711 or (concept_id = 3710 and value_coded = 1876) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )

								UNION
					-- CASE DETECTION ON THOSE BACTERIOLOGICALLY TESTED
					(select distinct o.person_id AS Id,'signs_bacteriology'as outcome,'CHW' as grping
					from obs o
						
						INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
						AND o.person_Id in (select person_id 
													from obs
													where (concept_id = 3780 and value_coded = 3784)
													AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
													AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
													
											)
						INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
						AND o.person_id in (
							select person_id 
							from obs
							where concept_id in (3814,3815)
							AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
							)	
							
					)

					UNION
					(select distinct o.person_id AS Id,'signs_bacteriology'as outcome,'CBO' as grping
					from obs o
						
						INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
						AND o.person_Id in (select person_id 
													from obs
													where (concept_id = 3780 and value_coded = 3637)
													AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
													AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
													
											)
						INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
						AND o.person_id in (
							select person_id 
							from obs
							where concept_id in (3814,3815)
							AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
							AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
							)	
							
					) 
					UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'children' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select id
													FROM
													( 
													select distinct o.person_id AS Id,
													floor(datediff(CAST('2019-01-31' AS DATE), person.birthdate)/365) AS Age								   
													from obs o
													INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
													INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
													) as a
												WHERE age <= 14
												) 
												
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3814,3815)
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'miners' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (
												select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3667)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3814,3815)
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'ex_miners' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3778)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
												
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3814,3815)
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'HHCM' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3777)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3814,3815)
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'HHXM' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3778)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3710) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'factory workers' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3669)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3814,3815)
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                            )
								UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'staff or inmates' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded in (3779,3671))
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3814,3815)
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                                )
								UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'Health Workers' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3776 and value_coded = 3670)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3814,3815)
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                            )
								UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'Public Transport Operators' as grping
                             from obs o

                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							 AND o.person_Id in (select person_id 
												from obs
												where (concept_id = 3780 and value_coded = 3637)
												AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
												AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
												)
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3710) -- TB,ART
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                            )
								UNION
								
			                (select distinct o.person_id AS Id , 'total_screened' as outcome, 'Total' as grping
                             from obs o
                             INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0												
							INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
                            WHERE concept_id in (3814,3815)
                            AND MONTH(obs_datetime) = MONTH(CAST('2019-01-31' AS DATE))
                            AND YEAR(obs_datetime) =  YEAR(CAST('2019-01-31' AS DATE))
                            )							
) as B

) AS BB
group by grping



