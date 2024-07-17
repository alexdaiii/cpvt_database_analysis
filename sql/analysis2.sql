SELECT sv.p_posedit_str,
       treatment_name,
       effective,
       COUNT(tr.patient_id)
           AS
           num_patients
FROM treatment_record tr
         JOIN treatment t
              ON tr.treatment_id = t.treatment_id
         JOIN individual_variant iv
              ON tr.patient_id = iv.individual_id
         JOIN variant v
              ON iv.variant_id = v.variant_id
         JOIN sequence_variant sv
              ON sv.sequence_variant_id = v.sequence_variant_id
WHERE 1 = 1
  AND tr.patient_id
    IN (
          -- ONLY CPVT1 patients
          SELECT individual_id
          FROM cpvt_patients_v)
  AND tr.patient_id
    IN (
          -- ONLY PATIENTS WHO ARE TAKING BETA BLOCKERS
          SELECT tr.patient_id
          FROM treatment_record tr
                   JOIN
               treatment t
               ON
                   tr.treatment_id = t.treatment_id
          WHERE t.treatment_name = 'Beta blocker'
            AND tr.treatment_taken = TRUE)
  AND tr.treatment_taken = TRUE
  AND t.treatment_name = :treatment_name
  AND tr.effective IS NOT NULL
  AND sv.p_posedit_str IS NOT NULL
GROUP BY sv.p_posedit_str, treatment_name, effective
ORDER BY num_patients
        DESC;


SELECT sv.p_posedit_str, v.hgvs_string, v.variant_id, vmv.num_individuals
FROM variant_num_individuals_v vmv
         JOIN variant v
              ON vmv.variant_id = v.variant_id
         JOIN sequence_variant sv
              ON v.sequence_variant_id = sv.sequence_variant_id
ORDER BY vmv.num_individuals
        DESC
LIMIT 5;

SELECT individual_id,
       bool_or(has_family_history)
           AS
           has_family_history
FROM (SELECT fhr.individual_id,
             CASE
                 WHEN
                     num_family_members >= 1
                     THEN
                     TRUE
                 WHEN
                     has_condition = TRUE
                     THEN
                     TRUE
                 WHEN
                     has_condition = FALSE
                     THEN
                     FALSE
                 WHEN
                     num_family_members = 0
                     THEN
                     FALSE
                 ELSE
                     NULL
                 END
                 AS
                 has_family_history
      FROM family_history_record fhr
               JOIN
           condition c
           ON
               fhr.condition_id = c.condition_id
               LEFT JOIN
           family_member_history fmh
           ON
               fhr.family_history_record_id = fmh.family_history_record_id
      WHERE c.condition = 'Sudden cardiac death'
        AND fhr.individual_id
          IN (SELECT individual_id
              FROM individual_condition ic
                       JOIN
                   condition c2
                   ON
                       ic.condition_id = c2.condition_id
              WHERE c2.condition =
                    'Catecholaminergic polymorphic ventricular tachycardia 1'
                AND ic.has_condition = true)) AS subquery
WHERE has_family_history IS NOT NULL
GROUP BY individual_id;

SELECT t.treatment_name,
       COUNT(tr.patient_id)
           AS
           num_patients
FROM treatment_record tr
         JOIN
     treatment t
     ON
         tr.treatment_id = t.treatment_id
WHERE tr.patient_id
    IN (SELECT individual_id
        FROM cpvt_patients_v)
  AND tr.treatment_taken = TRUE
  AND tr.patient_id
    IN (SELECT tr.patient_id
        FROM treatment_record tr
                 JOIN
             treatment t
             ON
                 tr.treatment_id = t.treatment_id
        WHERE t.treatment_name = 'Beta blocker'
          AND tr.treatment_taken = TRUE)
GROUP BY t.treatment_name
ORDER BY num_patients
        DESC;


SELECT t.treatment_name,
       tr.effective,
       COUNT(tr.patient_id)
           AS
           num_patients
FROM treatment_record tr
         JOIN
     treatment t
     ON
         tr.treatment_id = t.treatment_id
WHERE tr.patient_id
    IN (SELECT individual_id
        FROM cpvt_patients_v)
  AND tr.treatment_taken = TRUE
  AND tr.effective IS NOT NULL
GROUP BY t.treatment_name, tr.effective
ORDER BY t.treatment_name, tr.effective;

SELECT sv.p_posedit_str,
       treatment_name,
       COUNT(tr.patient_id)
           AS
           num_patients
FROM treatment_record tr
         JOIN
     treatment t
     ON
         tr.treatment_id = t.treatment_id
         JOIN
     individual_variant iv
     ON
         tr.patient_id = iv.individual_id
         JOIN
     variant v
     ON
         iv.variant_id = v.variant_id
         JOIN
     sequence_variant sv
     ON
         sv.sequence_variant_id = v.sequence_variant_id
WHERE 1 = 1
  AND tr.patient_id
    IN (
          -- ONLY CPVT1 patients
          SELECT individual_id
          FROM cpvt_patients_v)
  AND tr.patient_id
    IN (
          -- ONLY PATIENTS WITHTOP 5 VARIANTS BY NUMBER OF INDIVIDUALS
          SELECT iv.individual_id
          FROM individual_variant iv
                   JOIN
               variant v
               ON
                   iv.variant_id = v.variant_id
          WHERE v.variant_id
                    IN (SELECT v2.variant_id
                        FROM variant_num_individuals_v v2
                        ORDER BY v2.num_individuals
                                DESC
                        LIMIT 5))
  AND tr.patient_id
    IN (
          -- ONLY PATIENTS WHO ARE TAKING BETA BLOCKERS
          SELECT tr.patient_id
          FROM treatment_record tr
                   JOIN
               treatment t
               ON
                   tr.treatment_id = t.treatment_id
          WHERE t.treatment_name = 'Beta blocker'
            AND tr.treatment_taken = TRUE)
  AND tr.treatment_taken = TRUE
GROUP BY sv.p_posedit_str, treatment_name
ORDER BY sv.p_posedit_str, treatment_name;

-- FOR FISHER TEST
SELECT sv.p_posedit_str,
       treatment_name,
       COUNT(tr.patient_id)
           AS
           num_patients
FROM treatment_record tr
         JOIN
     treatment t
     ON
         tr.treatment_id = t.treatment_id
         JOIN
     individual_variant iv
     ON
         tr.patient_id = iv.individual_id
         JOIN
     variant v
     ON
         iv.variant_id = v.variant_id
         JOIN
     sequence_variant sv
     ON
         sv.sequence_variant_id = v.sequence_variant_id
WHERE 1 = 1
  AND tr.patient_id
    IN (SELECT individual_id
        FROM cpvt_patients_v)
  AND tr.patient_id
    IN (SELECT tr.patient_id
        FROM treatment_record tr
                 JOIN
             treatment t
             ON
                 tr.treatment_id = t.treatment_id
        WHERE t.treatment_name = 'Beta blocker'
          AND tr.treatment_taken = TRUE)
--   AND tr.patient_id
--     IN (SELECT iv.individual_id
--         FROM individual_variant iv
--         WHERE v.variant_id IN (SELECT v2.variant_id
--                                FROM variant_num_individuals_v v2
--                                ORDER BY v2.num_individuals DESC
--                                LIMIT:num_top_variants))
  AND p_hgvs_string IN (SELECT p_hgvs_string
                        FROM protein_variant_num_cpvt_patients_v
                        ORDER BY num_patients DESC
                        LIMIT 5)
  AND tr.treatment_taken = TRUE

  AND t.treatment_name
    IN (: treatment_name, 'Beta blocker')
GROUP BY sv.p_posedit_str, treatment_name
ORDER BY sv.p_posedit_str, treatment_name;

-- Just beta blockers
SELECT sv.p_posedit_str,
       tr.effective
           AS
           Beta_Blocker_Effective,
       COUNT(tr.patient_id)
           AS
           num_patients
FROM treatment_record tr
         JOIN
     treatment t
     ON
         tr.treatment_id = t.treatment_id
         JOIN
     individual_variant iv
     ON
         tr.patient_id = iv.individual_id
         JOIN
     variant v
     ON
         iv.variant_id = v.variant_id
         JOIN
     sequence_variant sv
     ON
         sv.sequence_variant_id = v.sequence_variant_id
WHERE tr.patient_id
    IN (SELECT individual_id
        FROM cpvt_patients_v)
  AND sv.p_posedit_str
    IN (SELECT sv2.p_posedit_str
        FROM treatment_record tr2
                 JOIN
             treatment t2
             ON
                 tr2.treatment_id = t2.treatment_id
                 JOIN
             individual_variant iv2
             ON
                 tr2.patient_id = iv2.individual_id
                 JOIN
             variant v2
             ON
                 iv2.variant_id = v2.variant_id
                 JOIN
             sequence_variant sv2
             ON
                 sv2.sequence_variant_id = v2.sequence_variant_id
        WHERE tr2.patient_id
            IN (SELECT individual_id
                FROM cpvt_patients_v)
          AND tr2.treatment_taken = TRUE
          AND t2.treatment_name = 'Beta blocker'
          AND tr2.effective IS NOT NULL
        GROUP BY sv2.p_posedit_str
        HAVING COUNT(tr2.patient_id) >= 5)
  AND tr.treatment_taken = TRUE
  AND t.treatment_name = 'Beta blocker'
  AND tr.effective IS NOT NULL
GROUP BY sv.p_posedit_str, tr.effective
ORDER BY sv.p_posedit_str, tr.effective;
