# Introducción al desarrollo sobre BFA
## _Desde 0 a deployear un contrato_

## Índice
1. Intro a BFA. 
    1. Características de la BFA
    2. Repositorios importantes
    3. Tipos de Nodos
    4. Montar un nodo para desarrollo con docker
    5. Herramientas útiles y como utilizarlas dentro del docker
    6. Proceso previo
2. Workflow de trabajo
    1. Truffle suite
    2. Deployear a la red de prueba
    3. Interactuar con un contrato desde JS

## 1. Intro a BFA

### 1.1. Características de la BFA
- Basada en Ethereum
    - Sin valor monetario de criptomoneda
    - El eth se utiliza únicamente para realizar transacciones/deployear smart contracts
    - 2 Redes
        - Main
        - Test
    - Open Source
    - Ofrecen algunos contratos generales ya deployeados
        -  Sello de tiempo
        -  Sello de tiempo 2.0
    -  El ETH para interactuar es gratuito, 
        - En la red de prueba: se consigue solicitando en el grupo de telegram (https://t.me/bfatec)
        - En la red main, se recarga automáticamente mediante una destilería

### 1.2 Repositorios importantes

- Nucleo: Contiene todo lo necesario para montar un nodo from scratch
    - https://gitlab.bfa.ar/blockchain/nucleo
- Bfar/nodo: Automatiza el alta de un nodo utilizando docker para no tener que hacer todo from scratch. Ideal para desarrollo
    - https://gitlab.bfa.ar/docker/bfanodo
	    
### 1.3 Tipos de nodos
- Nodo sellador: Requiere acuerdo conel team de bfa, no es nceesario para desarrolla o para utilizar la bfa puede ser algo deseable para la organización, para contribuir con bfa. Estos nodos se asignan en partes iguales a organismos publicos y privados.
- Nodo transaccional: Es una gateway hacia la BFA, permite crear cuentas, deployear contractos, interactuar con contratos etc. 

### 1.4 Montar un nodo para desarrollo con docker
 -  Instalar docker en la maquina donde se va a desarrollar
 -  Clonar el repositorio [bfaar/nodo](https://gitlab.bfa.ar/docker/bfanodo)
 -  Iniciar el nodo en la red de test utilizando el script `start.sh`
   `bash start.sh test`      
 
### 1.5. Herramientas útiles y como utilizarlas dentro del docker

El nucleo tiene una gran cantidad de herramientas útiles para interactuar con la BFA que son automáticamente provistas dentro de la instancia de docker. Para esto podemos ingresar a la misma utilizando:

 ` docker exec -it bfanodotest /bin/bash `

Esto nos permitirá entrar en la terminal de la instancia de docker y acceder a cualquiera de las herramientas listadas en el repositorio del [nucleo](https://gitlab.bfa.ar/blockchain/nucleo). Dentro de estas herramientas pre-instaladas hay algunas que son de interés:

### localstate.pl
Muestra varias detalles del entorno local, con esta herramienta podemos saber el estado de sincronización del nodo.

### attach.sh
Te conecta a la línea de comandos (CLI) del geth que está corriendo en tu máquina local. Lo utilizaremos para gestionar cuentas en la red de test.

### unlock.js
Debloquea las cuentas del sistema (vease tambien monitor.js). Si una cuenta tiene clave, se puede poner la clave con este script. Se necesita desbloquear la cuenta para poder realizar transaccioones.

### walker.pl
Muestra una línea por bloque que se va sellando en la red, luego espera hasta el siguiente bloque.

### sendether.sh
Script para mandar Ether a de una cuenta a otra.

Existen otras herramientas documentadas en el repositorio del nucleo pero no son de interés para este tutorial.

### 1.6. Proceso previo

1. Montar el nodo sobre la red de test utilizando docker
2. Ingresar al bash del container
3. Esperar a que termine la sincronización mirando el progreso con `localstate.pl`
4. Crear una cuenta nueva

Para esto utailizaremos 
```
geth account new
```

Se nos solicitará un password para encriptar la private key generada, este parametro puede ser vacío.
La salida de este comando tendrá una forma similar a la siguiente:
```
bash-5.0$ geth account new 
...
Your new account is locked with a password. Please give a password. Do not forget this password.
...
Your new key was generated

Public address of the key:   0x0A9479f28842D1C86721F1fc89270E14B4855323
Path of the secret key file: /home/bfa/.ethereum/keystore/UTC--2021-09-03T14-22-50.529046500Z--0a9479f28842d1c86721f1fc89270e14b4855323
```

Nos interesa particularmente anotar la dirección pública:
`Public address of the key:   0x0A9479f28842D1C86721F1fc89270E14B4855323`

Y nos interesa guardar el archivo de clave privada creado en la dirección:
`/home/bfa/.ethereum/keystore/UTC--2021-09-03T14-22-50.529046500Z--0a9479f28842d1c86721`

El script que inicializa el docker crea un volumen que vincula esta carpeta con la carpeta `./keystores` por lo que no es necesario utilizar `docker cp` para sacarla del container.

5. Podemos verificar la creación de la cuenta attacheandose a la consola de geth utilizando `attach.sh` 
 ```
 Welcome to the Geth JavaScript console!

instance: Geth/v1.9.22-stable-c71a7e26/linux-amd64/go1.15.2
coinbase: 0x83e362503e1c13dfcd0b1a64307f0fc5d8e6c598
at block: 12760141 (Fri Sep 03 2021 14:17:00 GMT+0000 (UTC))
 datadir: /home/bfa/bfa/test2network/node
 modules: admin:1.0 clique:1.0 debug:1.0 eth:1.0 miner:1.0 net:1.0 personal:1.0 rpc:1.0 txpool:1.0 web3:1.0

> 
```
Nos encontraremos con una consola como la que se muestra anteriormente, aquí podemos ejecutar cualquier [comando de geth](https://geth.ethereum.org/docs/interface/command-line-options). En este caso utilizaremos:
`web3.eth.accounts`

Esto nos mostrará las cuentas creadas localmente, en base a lo que se encuentre en el directorio de keystores.

6. Solicitar ether en el grupo de telegram 
7. Una vez que recibamos ether, podemos verificar el estado y balance de la cuenta usando el comando `localstate.pl`

```
Our latest block number is 12760417. It's timestamp says 2021-09-03T14:40:00Z (04s old).
We have all the blocks and are not syncing.
We do not seal.
Locally available accounts:
Account 1: 0x83e362503e1c13dfcd0b1a64307f0fc5d8e6c598          0 transactions, 100000000000000000 wei.
```
 Podemos ver que la cuenta tiene `100000000000000000 wei` es decir, 1 ETH (Wei es la unidad en al que se subdivide el ETH).
 
 > **Nota Importante**: Para poder interactuar con la blockchain utilizando esa cuenta creada es necesario desbloquearla, para esto se debe usar el comando `unlock.js` pero este comando fallará debido a que no se está conectando al nodo de  manera segura (https) sino que se está realizando mediante http. Para poder sortear esta dificultad (únicamente en  desarrollo) es necesario modificar el script de arranque del nodo `singleStart.sh` en la carpeta bin. Para esto modificamos la funcion startGeth(), agregando `--allow-insecure-unlock`, como se muestra a continuación:
 
 ### singleStart.sh
 ```
 //... 
 function startgeth()
{
    echo "***" Starting geth $*
    # "NoPruning=true" means "--gcmode archive"
        geth --config ${BFATOML} --allow-insecure-unlock $* &
    gethpid=$!
    PIDIDX[${gethpid}]="geth"
}
//...
 ```

 > Reiniciamos el container y ya podremos utilizar `unlock.js`. También pueden encontrar el archivo ya modificado en este repo, en la carpeta bfa-nodo. Solo deberían renombrar a singleStart.sh y reemplazar
 
 
 ## 2. Workflow de trabajo en desarrollo
 
### 2.1 Truffle suite

Si bien podemos desarrollar utilizando la red de prueba de la BFA,  durante el proceso de desarrollo es mejor utilizar herramientas más rápidas que nos permitan iterar continuamente para poder detectar errores antes de hacer un deploy. 

Para eso existe [truffle suite](https://www.trufflesuite.com/), que esta compuesto de 3 programas diferentes 
- **Truffle**: Un ambiente de de desarrollo y testing 
- **Ganache**: Una blockchain personal que se levanta en localhost  utilizada para hacer pruebas rapidas
- **Drizzle**: Una colección de librerías de frontend (No nos interesa por el momento)

### Truffle 
Par esto utilizaremos [nodejs](https://nodejs.org/es/), particularmente su manager de paquetes npm. Para instalar truffle de manera global utilizaremos

``` npm i -g truffle ```

Una vez instalado ya podremos utilizar todos los comandos del cli de truffle.  Para crear un proyecto nuevo podemos utilizar ``truffle init``. Esto nos creará el scaffolding de un proyecto de truffle, que cuenta con 3 carpetas principales:

- **Contracts**: Almacenará todos los contratos de solidity que formen parte de nuestro proyecto
- **Migrations**: Utilizado para migrar y deployear los contratos a la red
- **Test**: Almacena los tests escritos en `js` o en `sol`. Truffle soporta ambos lenguajes

Además encontraremos un archivo impoortante `truffle-config.js`, este archivo nos permitirá definir las redes con las que vamos a interactuar, especificando los datos del `RPC` que permite interactuar con la red de destino. En el caso de BFA, utilizaremos el nodo que creamos anteriormente, para hacer pruebas rápidas utilizaremos ganache.

El archivo `truffle-config.js` tiene la siguiente forma:

### truffle-config.js
```
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8877,
      network_id: "123456" // Network ID de ganache
    },
    bfaDev: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "55555000000" // Network ID BFA test
    }
  },
  compilers: {
    solc: {
      version: "^0.7.0"
    }
  }
};
```

En este archivo se pueden declarar múltiples redes, donde se establecen los datos del  RPC para poder acceder a la  red junto con el network_id de la misma. En el caso de bfa, se debe utilizar el id `55555000000`. Para ganache, podemos configurar el id que deseamos y escuchar en el puerto que deseamos.

### Ganache

Ganache nos permite montar una blockchain personal descartable de manera local para interactuar con ella y poder hacer todo tipo de pruebas, evaluando los resultados rapidamente.  Existen dos formas de instalar y ejecutar ganache

- **CLI**: Ideal para trabajo en instancias remotas o para armar pipelines de CI/CD. Para instalar el CLI utilizamos `npm i -g ganache-cli`
- **UI**: Para trabajo en una computadora personal, tiene algunas herramientas útiles que el CLI no tiene, pero no es obligatorio instalarlo. Para instalaro simplemente descargamos la versión correspondiente a nuestro S.O desde la [web de gancahe](https://www.trufflesuite.com/ganache)

#### Configurando ganche en su versión de escritorio

Lo primero que debemos hacer al ingresar a ganache es crear un workspace darle un nombre y configurar los datos del server. En la pestaña `Server` podemos configurar todos los datos de `network_id` ,`port`, `direccion` etc. Una vez ejecutado ganache ya tendremos una blockchain de eth con la cual podemos interactuar mediante `RPC`.


### Combinando Ganache y Truffle

Como se mostró anteriormente, truffle puede ser configurado para apuntar a la instancia de ganache que acabamos de crear. 
Una vez congfigurada la red en el archivo `truffle-config.js` que se creó al ejecutar `truffle init` podemos ir a nuestra carpepta de contratos `Contracts` y empezar a desarrollar los contratos en Solidity. Para este ejemplo utilizaremos un contrato `HelloWorld.sol` que permite almacenar un valor en string y  luego leerlo. Pueden encontrar todo el codigo de este proyecto en la carpeta truffle de este repo.

Una vez dentro del proyecto, nos interesan dos comandos de truffle `truffle compile` y `truffle migrate` , estos nos permitiran generar los abi y binarios de nuestros contratos y luego migrarlos y deployearlos a la blockchain que hayamos configurado. Es necesario tener una cuenta desbloqueada y con fondos para poder hacer esto. Si estamos en el contexto de ganache, no vamos a tener este problema.

# Testing de los contratos

Truffle permite generar tests  en lenguaje `JS` utilizando sintaxis mocha con `assert` o bin utilizando solidty. En este repo van a encontrar los ejemplos de tests escritos en JS. Para ejecutarlos haremos `truffle test`. Esto ejecutará todos los tests que encuentre dentro de la carpeta de tests, en la red "development" por defecto. Podemos cambiar esto por configuracion. 
