WITH curl_args AS (
	SELECT printf('getFormCategories "%s" -o response-form-types_%s.json', name, name) AS args FROM forms
)

SELECT args FROM curl_args;
