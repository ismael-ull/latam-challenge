# LATAM Airlines DevSecOps Challenge
### _Ismael Ull_
A continuación se detallan los diferentes componentes de la soculión imlpementada. Cabe destacar que algunas conifiguraciones pueden ser mejoradas pero, por cuestiones de tiempo, se ha optado por realizarlas de manera genérica teniendo en cuenta que es una demo. en cada caso habrá un apartado denominado **TO-DO** el cual indicará las recomendaciones para seguir las buenas prácticas y pensar en un ambiente productivo real.

## Parte 1: Infraestructura

El sistema cuenta de dos microservicios los cuales son para ingesta y consulta de datos independientemente. Ambos utilizan una base de datos Mysql de CloudSQL para grabar y consultar los datos debido al balance entre calidad y precio del mismo buscando un servicio gestionado que permita escalabilidad.

![Infra](assets/infra.jpg)

### IaC

Se utiliza Terraform para gestionar la infraestructura para facilitar el versionado y trabajo colaborativo del equipo de ingenieros **Cloud** y **DevOps**. Los archivos declarativos se almacenan junto al código de la aplicación en **GitHub** y los estados (inicialmente de Desarrollo y Produccion) se almacenan en un bucket especìfico para tal fin y con la seguridad adecuada.

**TO-DO:**
- Utilizar **Terragrunt** para unificar la configuración de los ambientes sin perder la personalización de variables.
- Dar un nivel más de segregación de los estados de Terraform. Actualmente solo se separan PROD y DEV, pero se recomienda ahondar un nivel mas logrando separar los servicios para optimizar los tiempos de despliegue y minimizar la complejidad, por ejemplo teniendo diferentes state files para Cómputo (los servicios de CloudRun), base de datos (CloudSQL y BigQuery), seguridad (cuentas de servicio y bindings de roles) y PubSub.

### Base de datos
El motor elegido para la base de datos principal del sistema es CloudSQL
- En lo posible se crean Service Accounts específicas para cada servicio con los permisos necesarios (siguiendo el principio del menor privilegio)
- Se sepran los endpoints en dos servicios distintos. Si bien para el tamaño del challenge no es necesario, a fines de dar mayor envergadura al proyecto se lo piensa como si hubiera dos equipos de desarrollo separados (uno por cada servicio) y se busca independizar el código y los subsiguientes releases.
- El motor de base de datos elegido es CloudSQL debido a que se busca un balance entre escalabilidad 
