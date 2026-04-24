WITH curl_args AS (
	SELECT printf('getOfficesScs "%s" "%s" -o response-form-offices_%s_%s.json', form_name, form_key, form_name, form_key) AS args FROM form_types
)

SELECT args FROM curl_args;
