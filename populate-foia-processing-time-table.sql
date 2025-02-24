INSERT INTO foia_processing_time(id, metricTimestamp, metricName, metricValue, trackId, officeId, officeCode)
SELECT
 (metric ->> '$.id') AS id,
 (metric ->> '$.metricTimestamp') AS metricTimestamp,
 (metric ->> '$.metricName') AS metricName,
 (metric ->> '$.metricValue') AS metricValue,
 (metric ->> '$.trackId') AS trackId,
 (metric ->> '$.officeId') AS officeId,
 (metric ->> '$.officeCode') AS officeCode
FROM (SELECT json_each.value AS metric FROM (SELECT json(CAST(readfile('foia-metrics.json') AS TEXT)) as all_metrics), json_each(all_metrics));