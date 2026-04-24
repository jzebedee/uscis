WITH curl_args AS (
	SELECT printf('getProcessingTime "%s" "%s" "%s" -o response-processing-time_%s_%s_%s.json', form_name, form_key, json_each.value, form_name, json_each.value, form_key) AS args FROM form_types, json_each(offices)
)

SELECT args FROM curl_args;
