# Projeto Linux

## Criando a VPC

## Criando a EC2

## User Data - Inicializando

```bash
#!/bin/bash

# Instalando dependências
apt update -y
apt install nginx -y
apt install unzip -y
apt install jq -y

# Baixando arquivos de html, css e script
cd /home/ubuntu
wget https://github.com/vitorialeda/compass-projeto-linux/archive/refs/heads/main.zip
unzip main.zip

# Movendo os arquivos html e css para a pasta do NGINX
cd compass-projeto-linux-main/
mv html/* /var/www/html/
systemctl reload nginx

```
- É preciso digitar ```#!/bin/bash``` para indicar qual interpretador de comandos será usado para executar o script.

- O user data roda no root. Dessa forma, não é necessário incluir o sudo nos comandos.

- Outro ponto importante é que não é permitido interação com o usuário durante a execução do script. Por isso adiciono "-y" para responder "sim" caso seja necessário.

- Utilizando o ```wget``` consigo baixar os arquivos, como html, css e scripts que irei precisar pelo link do github. O ```unzip``` serve para descompactar esses arquivos.

- Vou até a diretório onde estão os arquivos que acabei de baixar (usando ```cd```) e movo o conteudo da pasta "html" para o diretório onde ficam armazenados os sites disponiveis a serem servidos no NGINX (usando ```mv```).

- Reinicio o NGINX para que as configurações sejam atualizadas. (```systemctl reload nginx```)


---


## NGINX - Servidor
#### Verificando se o NGINX rodando:
![Verificando serviço NGINX](https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/1%20-%20verificando%20se%20o%20nginx%20instalou.png)

#### Testando a página no NGINX:
![Testando a página no NGINX](https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/2%20-%20testando%20se%20a%20pagina%20funcionou.png)
- Para isso basta colar o IP público da EC2 no navegador

## WebHook - Integração

1. No canto superior esquerdo, ao lado do nome do servidor existe um ícone de seta para baixo que ao ser clicada exibe diversas configurações. Para criarmos o webhook devemos ir em "Config. do servidor":

    ![config do servidor discord](https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/WebHook%20-%20Discord/Captura%20de%20tela%202025-07-01%20094520.png)

3. Navegamos até a seção "APPS" e depois até "Integração":
   
    ![Onde localizar a integração](https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/WebHook%20-%20Discord/Captura%20de%20tela%202025-06-29%20152043.png)
   =============================
    ![Localizar weebhook](https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/WebHook%20-%20Discord/Captura%20de%20tela%202025-06-29%20152055.png)

5. Em seguida basta clicar em Webhooks, escolher um nome, uma imagem e copiar o link por onde será feita a integração e pronto! :D
   
    ![Config Weebhook](https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/WebHook%20-%20Discord/Captura%20de%20tela%202025-06-29%20152224.png)


---


## Script - Verificação

```bash
#!/bin/bash

get_response(){
        URL="IP_SERVIDOR";
        time_stamp=$(date +"%Y-%m-%d %H:%M");
        res=$(curl -sS -I $URL 2>&1 | head -n 1);

        if [[ ! $res =~ HTTP ]]; then
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
```

#### **- Função *get_response***
- Guardo a URL em uma variável para facilitar a leitura, da mesma forma guardo o horário em que o script foi executado;
- A variável ```res``` guarda o retorno do comando ```curl```
    - ```-sS``` a flag -s desabilita o medidor de progresso mas a -S permite que ainda mostre a mesagem de erro;
    - ```I``` Indica que o comando curl só trará o cabeçalho da requisição;
    - ```2>&1``` "2" representa "stderr" ou "standard error" e o "1" representa "stdout" ou "standard output", o ">" serve para indicar que o a mensagem de erro será redirecionada para a saída padrão do comando.  assim consigo armazenar, caso exista, na variável;
    - ```head -n 1``` Restringe a saída do curl à primeira linha.
- ```if [[ ! $res =~ HTTP ]]; then ``` Se a resposta do curl não contiver "HTTP", isso indica que a requisição falhou, pois não foi retornada uma resposta HTTP válida. Nesse caso, uma notificação é enviada para o Discord por meio da funcao *notificacao* passando como parametro a mensagem contendo o time_stamp, uma breve descrição e o erro;
- ``` echo -e "---\n[$time_stamp]:\n$res" >> /var/log/monitoramento.log``` A resposta é entao acrescentada ao arquivo de log.



#### **- Função *notificacao***
- Guardo a url do webhook na variável;
- Guardo em ```mensagem``` o resultado do comando ```echo -e``` que garante a leitura de caracteres especiais como o \ (usaremos \n para quebra de linha) e ```jq -Rs .``` que será responsável por formatar corretamente o json passado para o webhook do Discord. 
    - ```-Rs .``` permite que a resposta seja passada como uma unica string longa.

- Um bloco de texto formatado é atribuído à variável ```conteudo```;
    - ```cat << EOF ... EOF ``` é uma técnica chamada heredoc que permite passar multiplas linhas a uma variável. O conteúdo guardará o json necessário para o envio da mensagem.

- ``` curl --json "$conteudo" $WEBHOOK_URL``` faz uma requisição do tipo POST ao webhook, enviando como conteúdo a mensagem passada.
    - ```--json``` é uma forma curta de enviar dados formatados em JSON para servidores HTTP usando o método POST sem a necessidade das flags --header, --request POST e --data.


Por fim, a função *get_response* é executada.


---


## Testando o Script
#### # Rodando o Script:
![Rodando o Script](https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/3%20-%20rodando%20o%20script.png)
1. Script com o NGINX rodando;
2. Desligando o NGINX para simular a queda do servidor;
3. Script com NGINX desligado.



#### # Resposta Bot:
![Resposta bot](https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/4%20-%20resposta_bot.png)



#### # Cat no arquivo de log:
![cat arquivo log](https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/5%20-%20cat_arquivo_log.png)



---



## Cron - Automatização
#### # Comando cron

![Crontab](https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/6%20-%20crontab.png)

- Acessamos a tabela pelo comando ```sudo crontab -e```;
    - O ```sudo``` é necessário para obter permissão de escrita no diretório /var/log;
    - A opção 2 serve para editar o aquivo utilizando o vim.


#### # Arquivo crontab
![Arquivo crontab](https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/7%20-%20arquivo%20crontab.png)
- ``` */1 * * * * /home/ubuntu/projeto_linux/monitoramento.sh ``` agenda para cada minuto a execução do script encontrado no caminho ```/home/ubuntu/projeto_linux/monitoramento.sh```


---


#### # Testando o crontab
![testando o crontab](https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/8%20-%20crontab%20funcionando.png)
