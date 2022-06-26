WITH curl_args AS (
	SELECT printf('"https://egov.uscis.gov/processing-times/api/formtypes/%s" -o response-form-types_%s.json', name, name) AS args FROM forms
)

SELECT group_concat(args,' ') FROM curl_args;