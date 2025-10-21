curl --location 'https://platform.kore.ai/api/public/bot/st-948507fe-03c3-5afe-b3ca-3886049737bb/getSessions?containmentType=selfService' \
--header "auth: $kore_jwt_token" \
--header 'Content-Type: application/json' \
--data '{
"skip" : 0,
"limit" : 100,
"dateFrom" : "2025-08-27",
"dateTo" : "2025-08-28"
}'

curl --location --request POST 'https://platform.kore.ai/api/public/stream/st-948507fe-03c3-5afe-b3ca-3886049737bb/conversation/testsuite/import' \
--header "auth: $kore_jwt_token" \
--header 'bot-language: en' \
--header 'Content-Type: application/json' \
--data-raw '{
          "fileName": "6721ff68208caa4dffe35be4",
          "name": "platinum",
          "tags" : [],
          "description" : "NewTesteCase",
           "userEmailId" : "botowner@domain.com"
}'