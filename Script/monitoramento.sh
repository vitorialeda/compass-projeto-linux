#!/bin/bash

get_response(){
        URL="IP_SERVIDOR";
        time_stamp=$(date +"%Y-%m-%d %H:%M");
        res=$(curl -sS -I $URL 2>&1 | head -n 1);

        if [[ $res =~ ^(curl: \([0-9]+\)|HTTP/[0-9.]+ [45][0-9]{2}) ]]; then
                notificacao "[$time_stamp] Erro ao tentar acessar o servidor: \n$res"
        fi

        echo -e "---\n[$time_stamp]:\n$res" >> /var/log/monitoramento.log
}


notificacao(){
        WEBHOOK_URL="URL"
        mensagem=$(echo -e $1 | jq -Rs .)
        conteudo=$(cat << EOF
{
        "content": $mensagem
}
EOF
)
        curl --json "$conteudo" $WEBHOOK_URL
}

get_response