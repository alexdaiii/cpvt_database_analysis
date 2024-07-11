SELECT sv.p_posedit_str,
       treatment_name,
       effective,
       COUNT(tr.patient_id) AS num_patients
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
  AND tr.patient_id IN (
-- ONLY CPVT1 patients
    SELECT individual_id
    FROM cpvt_patients_v)
  AND tr.patient_id IN (
-- ONLY PATIENTS WHO ARE TAKING BETA BLOCKERS
    SELECT tr.patient_id
    FROM treatment_record tr
             JOIN treatment t
                  ON tr.treatment_id = t.treatment_id
    WHERE t.treatment_name = 'Beta blocker'
      AND tr.treatment_taken = TRUE)
  AND tr.treatment_taken = TRUE
  AND tr.effective IS NOT NULL
  AND t.treatment_name = 'Flecainide'
  AND sv.p_posedit_str IS NOT NULL
GROUP BY sv.p_posedit_str, treatment_name, effective
ORDER BY num_patients DESC
