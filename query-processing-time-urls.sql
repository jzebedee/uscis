WITH curl_args AS (
	SELECT printf('"https://egov.uscis.gov/processing-times/api/processingtime/%s/%s/%s" -o response-processing-time_%s_%s_%s.json', form_name, json_each.value, form_key, form_name, json_each.value, form_key) AS args FROM form_types, json_each(offices)
)

SELECT group_concat(args,' ') FROM curl_args;