## infra-automationAccount-aclStorage
- esse processo foi criado para facilitar o processo de permissionamento via ACL. Todas variaveis são obrigatórias.
- A variavel SUBSCRIPTIONID foi guardada dentro de uma secret variável no Automation account, por conta disso existe o get-automationvariable. No caso de não utilizar, basta mudar a variavel para ir direto para o set-azcontext.

- O script é usado tanto para adicionar quanto para remover, basta especificar no processo de execução.

- Poderá ser colocar ou permissão de leitura ou permissão de escrita no path especificado.

é possível adaptar para Azure devops, incluindo apenas um Yaml de validação e execução do script.
