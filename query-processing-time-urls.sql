WITH curl_args AS (
	SELECT printf('"https://egov.uscis.gov/processing-times/api/processingtime/%s/%s" -o response-processing-time_%s_%s.json', name, json_each.value, name, json_each.value) AS args FROM forms, json_each(offices)
)

SELECT printf('curl -H "Referer: https://egov.uscis.gov/processing-times/" %s', group_concat(args,' ')) FROM curl_args;