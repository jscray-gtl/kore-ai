curl --location 'https://platform.kore.ai/api/public/bot/st-948507fe-03c3-5afe-b3ca-3886049737bb/getSessions?containmentType=selfService' \
--header "auth: $kore_jwt_token" \
--header 'Content-Type: application/json' \
--data '{
"skip" : 0,
"limit" : 100,
"dateFrom" : "2025-08-27",
"dateTo" : "2025-08-28"
}'