nohup ./PandoraNext &
function update_license {
    curl -fLO https://dash.pandoranext.com/data/$(cat /etc/secrets/LICENSE_URL)/license.jwt
    curl -H "Authorization: Bearer $(cat /etc/secrets/SETUP_PASSWORD)" -X POST "http://localhost:8080/setup/reload"
}
# 无限循环
while true
do
    sleep 600       # 暂停600秒（10分钟）
    update_license   # 调用函数
done 