SELECT i.individual_id,
       iis.value              AS sex,
       iv.variant_id,
       z.zygosity,
       vi.variant_inheritance AS inheritance,
       v.hgvs_string,
       itp.publication_id,
       p.title,
       p.first_author,
       p.pmid,
       p.reference,
       p.doi,
       p.year,
       i.extra_information
FROM individual i
         LEFT JOIN individual_sex iis
                   ON i.individual_sex_id = iis.individual_sex_id
         LEFT JOIN individual_variant iv
                   ON i.individual_id = iv.individual_id
         LEFT JOIN zygosity z
                   ON iv.zygosity_id = z.zygosity_id
         LEFT JOIN variant_inheritance vi
                   ON iv.variant_inheritance_id = vi.variant_inheritance_id
         LEFT JOIN variant v
                   ON iv.variant_id = v.variant_id
         LEFT JOIN individual_to_publication itp
                   ON i.individual_id = itp.individual_id
         LEFT JOIN publication p
                   ON itp.publication_id = p.publication_id
ORDER BY i.individual_id;


SELECT i.individual_id,
       c.condition,
       ic.age_of_onset,
       ic.description,
       ic.onset_symptoms
FROM individual i
         LEFT JOIN individual_condition ic
                   ON i.individual_id = ic.individual_id
         LEFT JOIN condition c
                   ON ic.condition_id = c.condition_id
WHERE ic.description IS NOT NULL;


SELECT i.individual_id,
       c.condition,
       num_family_members
FROM individual i
         LEFT JOIN family_history_record fhr
                   ON i.individual_id = fhr.individual_id
         LEFT JOIN condition c
                   ON fhr.condition_id = c.condition_id
ORDER BY num_family_members;


SELECT i.individual_id,
       c.condition,
       fmh.*,
       kn.name AS relationship
FROM individual i
         LEFT JOIN family_history_record fhr
                   ON i.individual_id = fhr.individual_id
         LEFT JOIN condition c
                   ON fhr.condition_id = c.condition_id
         LEFT JOIN family_member_history fmh
                   ON fhr.family_history_record_id =
                      fmh.family_history_record_id
         LEFT JOIN kinship_name kn
                   ON fmh.kinship_name_id = kn.kinship_name_id
WHERE i.individual_id < 10
ORDER BY i.individual_id;


SELECT i.individual_id,
       tr.treatment_taken,
       tr.effective,
       t.treatment_name
FROM individual i
         LEFT JOIN treatment_record tr
                   ON i.individual_id = tr.patient_id
         LEFT JOIN treatment t
                   ON tr.treatment_id = t.treatment_id
WHERE i.individual_id < 10