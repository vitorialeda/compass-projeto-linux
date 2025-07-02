# Projeto Linux
Esse repositório detalha a criação e configuração de uma VPC (Virtual Private Cloud) e uma instância EC2 (Elastic Compute Cloud) na AWS. Além disso, mostra como:
- Implatar um servidor web NGINX;
- Automatizar sua inicialização usando User Data;
- Acesssar a instância via SSH;
- Implementar um sistema de monitoramento com Webhooks do Discord e agendamento de tarefas via Cron.

## Criando a VPC

#### Navegando na AWS
   <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/VPC_EC2/1_Criar_VPC.png" alt="Opção para criar VPC"/>
   </p>
   
> Na AWS vou até "Painel da VPC", em seguida clico no botão "Criar VPC"

#### Criando e configurando a VPC
   <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/VPC_EC2/2_Configs_VPC.png" alt="Criando a VPC"/>
   </p>
   
> Nas configurações da VPC seleciono "VPC e muito mais" e mantenho as configurações para criar tambem as subredes, tabela de roteamento e gateway e concluo a configuração clicando em "criar VPC".

## Criando a EC2
Na página de EC2 clico em "Executar instância" para criar uma nova EC2.

#### Imagem da EC2
   <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/VPC_EC2/3_Imagem_EC2.png" alt="Escolhendo a imagem da EC2"/>
   </p>
   
> Escolhendo a imagem da EC2

#### Tipo da instância e Par de Chaves
   <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/VPC_EC2/4_Tipo_de_instancia_e_par_de_chaves.png" alt="Tipo de Instancia e Par de Chaves"/>
   </p>
   
> Escolher o par de chaves (será necessário para conexão ssh por exemplo)

#### Configuração de rede e grupo de segurança
   <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/VPC_EC2/5_config_rede.png" alt="Configuração de rede e Grupo de segurança"/>
   </p>
   
> Configuração de entrada:
>   - SSH: Acesso apenas pelo meu IP
>   - HTTP: Qualquer ip (apenas para fins de estudo)

#### User data
   <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/VPC_EC2/6_dados_do_usu%C3%A1rio.png" alt="User data"/>
   </p>
   
> Configurações que rodarão durante a inicialização da EC2


<hr/>


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

# Movendo o script
cp /home/ubuntu/compass-projeto-linux-main/Script/monitoramento.sh /home/ubuntu
cd
chmod 700 monitoramento.sh
```
- É preciso digitar ```#!/bin/bash``` para indicar qual interpretador de comandos será usado para executar o script;

- O user data roda no root. Dessa forma, não é necessário incluir o sudo nos comandos;

- Outro ponto importante é que não é permitido interação com o usuário durante a execução do script. Por isso adiciono "-y" para responder "sim" caso seja necessário;

- Utilizando o ```wget``` consigo baixar os arquivos, como html, css e scripts que irei precisar pelo link do github. O ```unzip``` serve para descompactar esses arquivos;

- Vou até a diretório onde estão os arquivos que acabei de baixar (usando ```cd```) e movo o conteudo da pasta "html" para o diretório onde ficam armazenados os sites disponiveis a serem servidos no NGINX (usando ```mv```);

- Reinicio o NGINX para que as configurações sejam atualizadas. (```systemctl reload nginx```);

- Copio e mudo o script de monitoramento de lugar para conseguir configurar permissões;

- Espero a máquina terminar de rodar o script. Quando a verificação de status (coluna no painel de instâncias) estiver verde é sinal de que está tudo ok.


<hr/>


## SSH - Acesso remoto

- Para acessar remotamente é necessário ter um cliente ssh instalado na máquina .
- ```bash
    sudo apt update
    sudo apt install openssh-client
    ```
Depois basta digitar o comando:
- ```bash
    ssh -i [senha.pem] [usuário_remoto]@[ip]
    ```
> "Senha é o par de chaves selecionado durante a criação da EC2"

   <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/acesso%20ssh.png" alt="Acesso via terminal"/>
   </p>
   
> *Ip utilizado para fins de exemplo*


<hr/>


## NGINX - Servidor

#### Verificando se o NGINX rodando:
   <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/1%20-%20verificando%20se%20o%20nginx%20instalou.png" alt="Verificando serviço NGINX"/>
   </p>
   
> service --status-all para listar todos os serviços.

#### Testando a página no NGINX:
   <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/2%20-%20testando%20se%20a%20pagina%20funcionou.png" alt="Testando a página no NGINX"/>
   </p>
   
> Para isso basta colar o IP público da EC2 no navegador


<hr/>


## WebHook - Integração

1. No canto superior esquerdo, ao lado do nome do servidor existe um ícone de seta para baixo que ao ser clicada exibe diversas configurações. Para criarmos o webhook devemos ir em "Config. do servidor":
    <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/WebHook%20-%20Discord/Captura%20de%20tela%202025-07-01%20094520.png" alt="config do servidor discord"/>
    </p>

4. Navegamos até a seção "APPS" e depois até "Integração":
   <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/WebHook%20-%20Discord/Captura%20de%20tela%202025-06-29%20152043.png" alt="Onde localizar a integração"/>
   </p>

6. Em seguida basta clicar em Webhooks, escolher um nome, uma imagem e copiar o link por onde será feita a integração e pronto! :D
   <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/WebHook%20-%20Discord/Captura%20de%20tela%202025-06-29%20152055.png" alt="Onde localizar webhook"/>
   </p>
   
   <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/WebHook%20-%20Discord/Captura%20de%20tela%202025-06-29%20152224.png" alt="Config Webhook"/>
   </p>


<hr/>


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

#### **Função *get_response()***
> - Guardo a URL em uma variável para facilitar a leitura, da mesma forma guardo o horário em que o script foi executado;
> - ```res``` guarda o retorno do comando ```curl```
>    - ```-sS``` a flag -s desabilita o medidor de progresso mas a -S permite que ainda mostre a mesagem de erro;
>    - ```I``` Indica que o comando curl só trará o cabeçalho da requisição;
>    - ```2>&1``` "2" representa "standard error" e o "1" representa "standard output", o ">" serve para indicar que o a mensagem de erro será redirecionada para a saída padrão do comando. Assim consigo armazenar o erro caso exista um;
>    - ```head -n 1``` Restringe a saída do curl à primeira linha.
> 
> - ```if [[ ! $res =~ HTTP ]]; then ``` Se a resposta do curl não contiver "HTTP", indica que a requisição falhou, pois não foi retornada uma resposta HTTP válida. Nesse caso, uma notificação é enviada para o Discord por meio da funcao *notificacao* passando como parametro a mensagem contendo o time_stamp, uma breve descrição e o erro;
>   
> - ``` echo -e "---\n[$time_stamp]:\n$res" >> /var/log/monitoramento.log``` A resposta é acrescentada ao arquivo de log.


#### **Função *notificacao()***
> - Guardo em ```mensagem``` o resultado do comando ```echo -e``` que garante a leitura de caracteres especiais como o \ (usaremos \n para quebra de linha) e ```jq -Rs .``` que será responsável por formatar corretamente o json passado para o webhook. 
>    - ```-Rs .``` permite que a resposta seja passada como uma única string longa.
>
> - Um bloco de texto formatado é atribuído à variável ```conteudo```;
>    - ```cat << EOF ... EOF ``` é uma técnica chamada *heredoc* que permite passar múltiplas linhas a uma variável. O conteúdo guardará o json necessário para o envio da mensagem.
>
> - ``` curl --json "$conteudo" $WEBHOOK_URL``` faz uma requisição do tipo POST ao webhook, enviando como conteúdo a mensagem passada.
>    - ```--json``` é uma forma curta de enviar dados formatados em JSON para servidores HTTP usando o método POST sem a necessidade das flags --header, --request POST e --data.

Por fim, a função *get_response* é executada.


<hr/>


## Testando o Script

#### Rodando o Script:
   <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/3-rodando_script.png" alt="Rodando o Script"/>
   </p>
   
> 1. Script com o NGINX rodando;
> 2. Desligando o NGINX para simular a queda do servidor;
> 3. Script com NGINX desligado.

#### Resposta Bot:
   <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/4%20-%20respostabot.png" alt="Resposta bot"/>
   </p>
   
> Resposta caso não seja possível acessar o servidor.

#### Cat no arquivo de log:
   <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/5%20-%20cat_log.png" alt="Cat arquivo log"/>
   </p>
   
> Respostas referentes aos comandos acima.


<hr/>


## Cron - Automatização

#### Comando cron
   <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/6%20-%20crontab.png" alt="Crontab"/>
   </p>
   
> Acessamos a tabela pelo comando ```sudo crontab -e```;
>    - O ```sudo``` é necessário para obter permissão de escrita no diretório /var/log;
>    - A opção 2 serve para editar o aquivo utilizando o vim.

#### Arquivo crontab
   <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/7%20-%20arquivo%20crontab.png" alt="Arquivo crontab"/>
   </p>
   
> Agenda para cada minuto a execução do script encontrado no caminho.


#### Testando o crontab
   <p align="center">
        <img src="https://github.com/vitorialeda/compass-projeto-linux/blob/main/prints/8%20-%20crontab_funcionando.png" alt="Testando o crontab"/>
   </p>
   
> Intervalo de um minuto entre as mensagens.
