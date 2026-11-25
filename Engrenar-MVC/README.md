# Engrenar — manutenção industrial

Protótipo com dois modos no menu inicial. O modo de demonstração usa o navegador. “Entrar com MySQL” abre o painel conectado às tabelas do banco existente.

## Abrir no Windows

1. Extraia toda a pasta Engrenar-MVC. Use Java 17 ou superior e PHP 8.1+ com mbstring e openssl (incluídos na instalação XAMPP usada para o teste).
2. Inicie o MySQL no painel do XAMPP, caso ainda esteja parado.
3. Dê dois cliques em Engrenar.jar. Se o Windows perguntar qual aplicativo usar, escolha Java. O iniciador procura C:\xampp\php\php.exe e, se necessário, abre um seletor para localizar php.exe. Mantenha a janela do Engrenar aberta. O próprio iniciador serve o site em uma porta local disponível.
4. No navegador, abra **Configuração do banco**. Os padrões são servidor 127.0.0.1, porta 3306, banco engrenar e usuário root. Informe a senha real da conta MySQL e clique em **Testar e usar conexão**. Uma conta local sem senha pode deixar o campo vazio.
5. Clique em **Entrar no painel MySQL** e use a conta do painel. A credencial MySQL serve para conectar o sistema. Se a tabela usuario estiver vazia, a configuração oferece o cadastro do primeiro administrador. Em uma instalação vazia, essa ação também cria a indústria e sua primeira linha. Se a indústria já existe, os cadastros e as linhas disponíveis são os do seu banco.
6. Para voltar à configuração a partir do painel, use **Sair** e **Configuração** na página de entrada. Fechar a janela do iniciador encerra o serviço. Ao reabrir, confirme novamente a conexão.

O teste de conexão consulta o esquema e não executa scripts. O arquivo script/engrenar.sql documenta a estrutura do ZIP original e serve para instalações novas. Não é necessário importá-lo para utilizar um banco já configurado com esse esquema.

## Demonstração do CRUD

Entre no painel MySQL com um perfil de gestão. Em **Ativos e saúde**, cadastre uma máquina com TAG e linha. Em **Ordens de serviço**, abra uma OS para essa máquina. Consulte e edite os dois registros. Para demonstrar a exclusão, exclua primeiro a OS e depois a máquina. Uma máquina com OS vinculada permanece protegida.

## Organização

- src/Model — entidades e validações do domínio.
- src/DAO — consultas JDBC e persistência de máquinas, ordens e registros relacionados.
- src/Controller — operações de negócio e entrada JSON do backend.
- src/Util — conexão ao MySQL.
- src/View e src/Principal.java — janela de abertura e inicialização local.
- app e views — controladores da interface web, sessão e telas PHP.
- site — menu inicial, configuração e arquivos públicos do protótipo.
- lib — driver MySQL Connector/J e Gson, com licenças.

O Java gera as operações SQL através dos DAOs. A camada PHP chama o backend passando JSON pela entrada padrão. A aplicação guarda a configuração cifrada na sessão usando uma chave temporária do iniciador. Os dados de demonstração do navegador e os registros MySQL têm armazenamento independente.

## Transparência de IA

A adaptação do protótipo, a configuração da conexão pelo menu, o iniciador Java e a validação do CRUD receberam auxílio do Codex. A organização do código segue o modelo MVC/DAO do projeto de referência.
