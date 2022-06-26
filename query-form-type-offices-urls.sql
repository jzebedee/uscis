WITH curl_args AS (
	SELECT printf('"https://egov.uscis.gov/processing-times/api/formoffices/%s/%s" -o response-form-offices_%s_%s.json', form_name, form_key, form_name, form_key) AS args FROM form_types
)

SELECT group_concat(args,' ') FROM curl_args;