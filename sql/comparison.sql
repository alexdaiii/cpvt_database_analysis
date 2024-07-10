WITH only_top_variant_patients AS (SELECT iv.individual_id
                                   FROM individual_variant iv
                                   WHERE iv.variant_id IN (SELECT v2.variant_id
                                                           FROM variant_num_individuals_v v2
                                                           ORDER BY v2.num_individuals DESC
                                                           LIMIT 5)),
     patients_with_other_treatments AS (
         -- Exclude patients taking any other treatment than the one specified + beta blockers
         SELECT tr.patient_id
         FROM treatment_record tr
                  JOIN treatment t
                       ON tr.treatment_id = t.treatment_id
         WHERE t.treatment_name NOT IN
               ('Flecainide', 'Beta blocker')
           AND tr.treatment_taken = TRUE),
     treatment_with_protein AS (SELECT sv.p_posedit_str,
                                       t.treatment_name,
                                       tr.patient_id,
                                       tr.treatment_taken
                                FROM treatment_record tr
                                         JOIN treatment t
                                              ON tr.treatment_id = t.treatment_id
                                         JOIN individual_variant iv
                                              ON tr.patient_id = iv.individual_id
                                         JOIN variant v
                                              ON iv.variant_id = v.variant_id
                                         JOIN sequence_variant sv
                                              ON sv.sequence_variant_id = v.sequence_variant_id),
     beta_blocker_patients AS (SELECT tr.patient_id
                               FROM treatment_record tr
                                        JOIN treatment t
                                             ON tr.treatment_id = t.treatment_id
                               WHERE t.treatment_name = 'Beta blocker'
                                 AND tr.treatment_taken = TRUE),
     only_treatment AS (SELECT p_posedit_str,
                               treatment_name,
                               COUNT(tr.patient_id) AS num_patients
                        FROM treatment_with_protein tr
                        WHERE 1 = 1
                          AND tr.patient_id IN (
                            -- ONLY CPVT1 patients
                            SELECT individual_id
                            FROM cpvt_patients_v)
                          AND tr.patient_id IN (
                            -- ONLY PATIENTS WHO ARE TAKING BETA BLOCKERS
                            SELECT patient_id
                            FROM beta_blocker_patients)
                          AND tr.patient_id NOT IN (
                            -- Exclude patients taking any other treatment than the one specified + beta blockers
                            SELECT patient_id
                            FROM patients_with_other_treatments)
                          AND tr.patient_id IN (
                            -- ONLY take patients with the top 5 variants by number of individuals
                            SELECT individual_id FROM only_top_variant_patients)
                          AND tr.treatment_taken = TRUE
                          AND tr.treatment_name = 'Flecainide'
                        GROUP BY tr.p_posedit_str, treatment_name
                        ORDER BY tr.p_posedit_str, treatment_name)
SELECT *
FROM only_treatment;



SELECT sv.p_posedit_str, COUNT(tr.patient_id) AS num_patients
FROM treatment_record tr
         JOIN treatment t
              ON tr.treatment_id = t.treatment_id
         JOIN individual_variant iv
              ON tr.patient_id = iv.individual_id
         JOIN variant v
              ON iv.variant_id = v.variant_id
         JOIN sequence_variant sv
              ON sv.sequence_variant_id = v.sequence_variant_id
WHERE tr.patient_id IN (SELECT individual_id
                        FROM cpvt_patients_v)
  AND tr.treatment_taken = TRUE
  AND t.treatment_name = 'Beta blocker'
  AND tr.effective IS NOT NULL
GROUP BY sv.p_posedit_str
HAVING COUNT(tr.patient_id) >= 5
